from flask import Flask, render_template, request, jsonify
import os
import subprocess
import threading
import re
import signal
from pathlib import Path

app = Flask(__name__)

# Configuration
class Config:
    # Default paths for local development
    DEFAULT_SCRIPT_PATH = Path(__file__).parent / "download_models.sh"
    DEFAULT_MODELS_PATH = Path(__file__).parent / "models"
    
    # Get paths from environment variables or use defaults
    SCRIPT_PATH = Path(os.environ.get('FLUX_SCRIPT_PATH', DEFAULT_SCRIPT_PATH))
    MODELS_PATH = Path(os.environ.get('FLUX_MODELS_PATH', DEFAULT_MODELS_PATH))
    PORT = int(os.environ.get('FLUX_DOWN_PORT', 5000))
    
    # Ensure paths exist
    @classmethod
    def validate_paths(cls):
        if not cls.SCRIPT_PATH.exists():
            raise FileNotFoundError(f"Download script not found at {cls.SCRIPT_PATH}")
        if not cls.MODELS_PATH.exists():
            cls.MODELS_PATH.mkdir(parents=True, exist_ok=True)

# Store the download status and process
download_status = {
    "status": "idle",
    "message": "",
    "progress": 0,
    "downloaded": "0B",
    "total": "0B",
    "speed": "0B/s",
    "eta": "Unknown"
}
current_process = None

def parse_aria2c_output(line):
    # More flexible pattern to match various aria2c output formats
    # Examples:
    # [#6c169a 1.0GiB/23GiB(4%) CN:1 DL:1.7MiB ETA:3h42m58s]
    # [#6c169a 1.0GiB/23GiB(4%) CN:1 DL:1.2MiB ETA:5h1m9s]
    # [#9d7870 196MiB/23GiB(0%) CN:1 DL:29MiB ETA:13m44s]
    pattern = r'\[#[0-9a-fA-F]+\s+([\d.]+[KMG]iB)/([\d.]+[KMG]iB)\((\d+)%\)(?:\s+CN:\d+\s+DL:([\d.]+[KMG]iB)(?:\s+ETA:(\d+h)?(\d+m)?(\d+s)?)?)?'
    match = re.search(pattern, line)
    if match:
        downloaded = match.group(1)
        total = match.group(2)
        percent = int(match.group(3))
        speed = match.group(4) if match.group(4) else "0B"
        
        # Construct ETA from optional components
        eta = ""
        if match.group(5):  # hours
            eta += match.group(5)
        if match.group(6):  # minutes
            eta += match.group(6)
        if match.group(7):  # seconds
            eta += match.group(7)
        eta = eta if eta else "Unknown"
        
        return downloaded, total, percent, speed, eta
    return None, None, None, None, None

def run_download_script(token):
    global download_status, current_process
    try:
        download_status["status"] = "downloading"
        download_status["message"] = "Starting download..."
        download_status["progress"] = 0
        download_status["downloaded"] = "0B"
        download_status["total"] = "0B"
        download_status["speed"] = "0B/s"
        download_status["eta"] = "Unknown"
        
        # Run the download script
        current_process = subprocess.Popen(
            [str(Config.SCRIPT_PATH), token],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            cwd=str(Config.MODELS_PATH),
            bufsize=1  # Line buffered
        )
        
        # Read output line by line
        while True:
            output = current_process.stdout.readline()
            if output == '' and current_process.poll() is not None:
                break
            if output:
                line = output.strip()
                downloaded, total, percent, speed, eta = parse_aria2c_output(line)
                if downloaded and total and percent is not None:
                    # Update progress information
                    download_status["downloaded"] = downloaded
                    download_status["total"] = total
                    download_status["progress"] = percent
                    download_status["speed"] = speed + "/s"
                    download_status["eta"] = eta
                    
                    # Update message based on progress
                    if percent == 100:
                        if "flux1-dev" in line:
                            download_status["message"] = "Download Complete!"
                        elif "flux11-fill-dev" in line:
                            download_status["message"] = "Download Complete!"
                        elif "VAE" in line:
                            download_status["message"] = "Download Complete!"
                    else:
                        if "flux1-dev" in line:
                            download_status["message"] = "Downloading flux1-dev..."
                        elif "flux11-fill-dev" in line:
                            download_status["message"] = "Downloading flux11-fill-dev..."
                        elif "VAE" in line:
                            download_status["message"] = "Downloading VAE..."
                else:
                    # If we don't have progress info, still update the message
                    download_status["message"] = line
        
        # Check the return code
        if current_process.returncode == 0:
            download_status["status"] = "completed"
            download_status["message"] = "All downloads completed successfully!"
            download_status["progress"] = 100
        else:
            download_status["status"] = "error"
            download_status["message"] = "Error during download. Please check the logs."
            
    except Exception as e:
        download_status["status"] = "error"
        download_status["message"] = f"Error: {str(e)}"
    finally:
        current_process = None

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/download', methods=['POST'])
def download():
    token = request.form.get('token')
    if not token:
        return jsonify({"error": "Hugging Face token is required"}), 400
    
    # Reset download status
    download_status["status"] = "idle"
    download_status["message"] = "Initializing download..."
    
    # Start download in background
    thread = threading.Thread(target=run_download_script, args=(token,))
    thread.daemon = True
    thread.start()
    
    # Return success response
    return jsonify({"status": "started"})

@app.route('/stop', methods=['POST'])
def stop_download():
    global current_process
    if current_process:
        try:
            # Send SIGTERM to the process
            current_process.terminate()
            # Wait for the process to terminate
            current_process.wait(timeout=5)
        except:
            # If process doesn't terminate, force kill it
            current_process.kill()
        finally:
            current_process = None
            download_status["status"] = "stopped"
            download_status["message"] = "Download stopped by user"
    
    return jsonify({"status": "stopped"})

@app.route('/status')
def status():
    return jsonify(download_status)

if __name__ == '__main__':
    # Validate configuration
    Config.validate_paths()
    
    # Start the application
    app.run(host='0.0.0.0', port=Config.PORT) 