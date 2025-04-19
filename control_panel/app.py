from flask import Flask, render_template, request, jsonify
import os
import subprocess
import threading
import re
import signal
from pathlib import Path
from flask_wtf import FlaskForm
from wtforms import SelectField, StringField, SubmitField
from wtforms.validators import DataRequired, URL
import json
from dotenv import load_dotenv
import glob

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-here'  # Change this in production

# Load environment variables
load_dotenv()

# Configuration for different downloaders
class Config:
    # Default paths
    DEFAULT_MODELS_PATH = Path("/workspace/models")
    FLUX_SCRIPT_PATH = Path("/scripts/download_models.sh")
    
    # Model type paths for CivitAI
    MODEL_PATHS = {
        'lora': DEFAULT_MODELS_PATH / 'loras',
        'checkpoint': DEFAULT_MODELS_PATH / 'checkpoints'
    }
    
    @classmethod
    def validate_paths(cls):
        # Ensure all paths exist
        cls.DEFAULT_MODELS_PATH.mkdir(parents=True, exist_ok=True)
        for path in cls.MODEL_PATHS.values():
            path.mkdir(parents=True, exist_ok=True)

# Download status trackers
flux_download_status = {
    "status": "idle",
    "message": "",
    "progress": 0,
    "downloaded": "0B",
    "total": "0B",
    "speed": "0B/s",
    "eta": "Unknown"
}

civitai_download_status = {
    "status": "idle",
    "message": "",
    "progress": 0,
    "downloaded": "0B",
    "total": "0B",
    "speed": "0B/s",
    "eta": "Unknown"
}

flux_current_process = None
civitai_current_process = None

def parse_aria2c_output(line):
    pattern = r'\[#[0-9a-fA-F]+\s+([\d.]+[KMG]iB)/([\d.]+[KMG]iB)\((\d+)%\)(?:\s+CN:\d+\s+DL:([\d.]+[KMG]iB)(?:\s+ETA:(\d+h)?(\d+m)?(\d+s)?)?)?'
    match = re.search(pattern, line)
    if match:
        downloaded = match.group(1)
        total = match.group(2)
        percent = int(match.group(3))
        speed = match.group(4) if match.group(4) else "0B"
        
        eta = ""
        if match.group(5): eta += match.group(5)
        if match.group(6): eta += match.group(6)
        if match.group(7): eta += match.group(7)
        eta = eta if eta else "Unknown"
        
        return downloaded, total, percent, speed, eta
    return None, None, None, None, None

def run_flux_download(token):
    global flux_download_status, flux_current_process
    try:
        flux_download_status["status"] = "downloading"
        flux_download_status["message"] = "Starting download..."
        flux_download_status["progress"] = 0
        
        # Run the download script
        flux_current_process = subprocess.Popen(
            [str(Config.FLUX_SCRIPT_PATH), token],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            cwd=str(Config.DEFAULT_MODELS_PATH),
            bufsize=1
        )
        
        while True:
            output = flux_current_process.stdout.readline()
            if output == '' and flux_current_process.poll() is not None:
                break
            if output:
                line = output.strip()
                downloaded, total, percent, speed, eta = parse_aria2c_output(line)
                if downloaded and total and percent is not None:
                    flux_download_status.update({
                        "downloaded": downloaded,
                        "total": total,
                        "progress": percent,
                        "speed": speed + "/s",
                        "eta": eta
                    })
                    
                    if percent == 100:
                        if "flux1-dev" in line:
                            flux_download_status["message"] = "Flux1-dev download complete!"
                        elif "flux11-fill-dev" in line:
                            flux_download_status["message"] = "Flux11-fill-dev download complete!"
                        elif "VAE" in line:
                            flux_download_status["message"] = "VAE download complete!"
                    else:
                        if "flux1-dev" in line:
                            flux_download_status["message"] = "Downloading flux1-dev..."
                        elif "flux11-fill-dev" in line:
                            flux_download_status["message"] = "Downloading flux11-fill-dev..."
                        elif "VAE" in line:
                            flux_download_status["message"] = "Downloading VAE..."
                else:
                    flux_download_status["message"] = line
        
        if flux_current_process.returncode == 0:
            flux_download_status.update({
                "status": "completed",
                "message": "All downloads completed successfully!",
                "progress": 100
            })
        else:
            flux_download_status.update({
                "status": "error",
                "message": "Error during download. Please check the logs."
            })
            
    except Exception as e:
        flux_download_status.update({
            "status": "error",
            "message": f"Error: {str(e)}"
        })
    finally:
        flux_current_process = None

def run_civitai_download(url, model_type, filename, token):
    global civitai_download_status, civitai_current_process
    try:
        civitai_download_status["status"] = "downloading"
        civitai_download_status["message"] = "Starting download..."
        civitai_download_status["progress"] = 0
        
        download_dir = Config.MODEL_PATHS[model_type]
        url_extension = os.path.splitext(url.split('?')[0])[1]
        
        if not os.path.splitext(filename)[1] and url_extension:
            filename = f"{filename}{url_extension}"
        
        download_url = f"{url}?token={token}" if token else url
        
        civitai_current_process = subprocess.Popen(
            ['aria2c', '-x', '16', '-s', '16', '-d', str(download_dir), '-o', filename, download_url],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )
        
        while True:
            output = civitai_current_process.stdout.readline()
            if output == '' and civitai_current_process.poll() is not None:
                break
            if output:
                line = output.strip()
                downloaded, total, percent, speed, eta = parse_aria2c_output(line)
                if downloaded and total and percent is not None:
                    civitai_download_status.update({
                        "downloaded": downloaded,
                        "total": total,
                        "progress": percent,
                        "speed": speed + "/s",
                        "eta": eta
                    })
                    
                    if percent == 100:
                        civitai_download_status.update({
                            "status": "completed",
                            "message": "Download Complete!"
                        })
                    else:
                        civitai_download_status["message"] = f"Downloading {filename}..."
                else:
                    civitai_download_status["message"] = line
        
        if civitai_current_process.returncode == 0:
            civitai_download_status.update({
                "status": "completed",
                "message": "Download Complete!",
                "progress": 100
            })
        else:
            civitai_download_status.update({
                "status": "error",
                "message": "Error during download. Please check the logs."
            })
            
    except Exception as e:
        civitai_download_status.update({
            "status": "error",
            "message": f"Error: {str(e)}"
        })
    finally:
        civitai_current_process = None

class LoraTrainingForm(FlaskForm):
    tool = SelectField('Select Training Tool', choices=[
        ('flux_gym', 'Flux Gym (for Flux Loras)'),
        ('diffusion_pipe', 'Diffusion Pipe (for Wan, Hidream, Hunyuan, and LTX Loras)')
    ])
    submit = SubmitField('Install')

class HuggingFaceForm(FlaskForm):
    model_url = StringField('HuggingFace Model URL', validators=[DataRequired(), URL()])
    submit = SubmitField('Download')

def parse_script_header(script_path):
    """Parse the header comment from a script to get the model name."""
    try:
        with open(script_path, 'r') as f:
            first_line = f.readline().strip()
            if first_line.startswith('#!/'):
                second_line = f.readline().strip()
                if second_line.startswith('# Model:'):
                    return second_line.replace('# Model:', '').strip()
            return os.path.basename(script_path).replace('download_', '').replace('.sh', '').replace('_', ' ').title()
    except Exception:
        return os.path.basename(script_path).replace('download_', '').replace('.sh', '').replace('_', ' ').title()

@app.route('/')
def index():
    # Get available download scripts
    download_scripts = glob.glob('/scripts/download_*.sh')
    script_info = []
    for script in download_scripts:
        script_name = os.path.basename(script).replace('download_', '').replace('.sh', '')
        model_name = parse_script_header(script)
        script_info.append({
            'name': script_name,
            'display_name': model_name
        })
    
    return render_template('index.html', 
                         lora_form=LoraTrainingForm(),
                         hf_form=HuggingFaceForm(),
                         download_scripts=script_info)

@app.route('/install_training_tool', methods=['POST'])
def install_training_tool():
    tool = request.form.get('tool')
    try:
        if tool == 'flux_gym':
            subprocess.run(['/scripts/setup_fluxgym.sh'], check=True)
        elif tool == 'diffusion_pipe':
            subprocess.run(['/scripts/setup_diffusion_pipe.sh'], check=True)
        return jsonify({'status': 'success', 'message': f'{tool} installed successfully'})
    except subprocess.CalledProcessError as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/run_download_script', methods=['POST'])
def run_download_script():
    script_name = request.form.get('script_name')
    script_path = f'/scripts/download_{script_name}.sh'
    
    if not os.path.exists(script_path):
        return jsonify({'status': 'error', 'message': 'Script not found'}), 404
    
    try:
        subprocess.Popen(['bash', script_path])
        return jsonify({'status': 'success', 'message': f'Started downloading {script_name}'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/download_huggingface', methods=['POST'])
def download_huggingface():
    model_url = request.form.get('model_url')
    try:
        model_id = model_url.split('/')[-1]
        subprocess.run(['python3', '-m', 'pip', 'install', 'huggingface_hub'])
        subprocess.run(['python3', '-c', f'from huggingface_hub import snapshot_download; snapshot_download(repo_id="{model_id}")'])
        return jsonify({'status': 'success', 'message': f'Downloaded {model_id}'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/download_flux', methods=['POST'])
def download_flux():
    token = request.form.get('token')
    if not token:
        return jsonify({"error": "Hugging Face token is required"}), 400
    
    # Reset download status
    flux_download_status.update({
        "status": "idle",
        "message": "Initializing download..."
    })
    
    thread = threading.Thread(target=run_flux_download, args=(token,))
    thread.daemon = True
    thread.start()
    
    return jsonify({"status": "started"})

@app.route('/download_civitai', methods=['POST'])
def download_civitai():
    url = request.form.get('url')
    model_type = request.form.get('model_type')
    filename = request.form.get('filename')
    token = request.form.get('token')
    
    if not url or not model_type or not filename:
        return jsonify({"error": "URL, model type, and filename are required"}), 400
    
    if model_type not in Config.MODEL_PATHS:
        return jsonify({"error": "Invalid model type"}), 400
    
    # Reset download status
    civitai_download_status.update({
        "status": "idle",
        "message": "Initializing download..."
    })
    
    thread = threading.Thread(target=run_civitai_download, args=(url, model_type, filename, token))
    thread.daemon = True
    thread.start()
    
    return jsonify({"status": "started"})

@app.route('/stop_flux', methods=['POST'])
def stop_flux_download():
    global flux_current_process
    if flux_current_process:
        try:
            flux_current_process.terminate()
            flux_current_process.wait(timeout=5)
        except:
            flux_current_process.kill()
        finally:
            flux_current_process = None
            flux_download_status.update({
                "status": "stopped",
                "message": "Download stopped by user"
            })
    return jsonify({"status": "stopped"})

@app.route('/stop_civitai', methods=['POST'])
def stop_civitai_download():
    global civitai_current_process
    if civitai_current_process:
        try:
            civitai_current_process.terminate()
            civitai_current_process.wait(timeout=5)
        except:
            civitai_current_process.kill()
        finally:
            civitai_current_process = None
            civitai_download_status.update({
                "status": "stopped",
                "message": "Download stopped by user"
            })
    return jsonify({"status": "stopped"})

@app.route('/flux_status')
def flux_status():
    return jsonify(flux_download_status)

@app.route('/civitai_status')
def civitai_status():
    return jsonify(civitai_download_status)

if __name__ == '__main__':
    # Validate configuration
    Config.validate_paths()
    app.run(host='0.0.0.0', port=1000) 