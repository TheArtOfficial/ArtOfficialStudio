from flask import Flask, render_template, request, jsonify
import os
import subprocess
import threading

app = Flask(__name__)

# Store the download status
download_status = {
    "status": "idle",
    "message": ""
}

def run_download_script(api_key):
    global download_status
    try:
        download_status["status"] = "downloading"
        download_status["message"] = "Starting download..."
        
        # Run the download script
        process = subprocess.Popen(
            ["/workspace/flux_model_downloader/download_models.sh", api_key],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        # Stream the output
        for line in process.stdout:
            download_status["message"] = line.strip()
        
        process.wait()
        
        if process.returncode == 0:
            download_status["status"] = "completed"
            download_status["message"] = "Download completed successfully!"
        else:
            download_status["status"] = "error"
            download_status["message"] = "Error during download. Please check the logs."
            
    except Exception as e:
        download_status["status"] = "error"
        download_status["message"] = f"Error: {str(e)}"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/download', methods=['POST'])
def download():
    api_key = request.form.get('api_key')
    if not api_key:
        return jsonify({"error": "API key is required"}), 400
    
    # Start download in background
    thread = threading.Thread(target=run_download_script, args=(api_key,))
    thread.daemon = True
    thread.start()
    
    return jsonify({"message": "Download started"})

@app.route('/status')
def status():
    return jsonify(download_status)

if __name__ == '__main__':
    port = int(os.environ.get('FLUX_DOWN_PORT', 5000))
    app.run(host='0.0.0.0', port=port) 