#!/usr/bin/env python3
"""
RunPod Control Panel

A web-based control panel for managing model downloads and tools for RunPod instances.
Supports CivitAI and direct script-based model downloads.
"""

import os
import re
import glob
import subprocess
import threading
import json
from pathlib import Path
import signal
import time

from flask import Flask, render_template, request, jsonify
from flask_wtf import FlaskForm
from wtforms import SelectField, StringField, SubmitField
from wtforms.validators import DataRequired, URL
from dotenv import load_dotenv

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------

# Flag to determine if running in local development or production environment
DOCKER_DEV = os.environ.get('DOCKER_DEV', 'false').lower() == 'true'

# Directory paths - adjust based on environment
if DOCKER_DEV:
    BASE_PATH = Path("/workspace/ComfyUI/models")
    SCRIPTS_PATH = Path("/scripts")
else:
    BASE_PATH = Path("workspace/ComfyUI/models")
    SCRIPTS_PATH = Path("scripts")

PRESET_SCRIPTS_PATH = SCRIPTS_PATH / "preset_model_scripts"

# Default directories that should exist for models
MODEL_DIRS = {
    'lora': BASE_PATH / 'loras',
    'checkpoint': BASE_PATH / 'checkpoints',
    'diffusion_models': BASE_PATH / 'diffusion_models',
    'vae': BASE_PATH / 'vae',
    'text_encoders': BASE_PATH / 'text_encoders'
}

# -------------------------------------------------------------------------
# Flask Application Setup
# -------------------------------------------------------------------------

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-here'  # Change this in production

# Load environment variables
load_dotenv()

# -------------------------------------------------------------------------
# Download Status Tracking
# -------------------------------------------------------------------------

# Download status objects for different downloaders
civitai_download_status = {
    "status": "idle",
    "message": "",
    "progress": 0,
    "downloaded": "0B",
    "total": "0B",
    "speed": "0B/s",
    "eta": "Unknown"
}

model_download_status = {
    "status": "idle",
    "message": "",
    "progress": 0,
    "downloaded": "0B",
    "total": "0B",
    "speed": "0B/s",
    "eta": "Unknown",
    "current_model": "",
    "total_models": 0,
    "completed_models": 0,
    "script_name": "",
    "display_name": "",
    "existing_files_count": 0
}

huggingface_download_status = {
    "status": "idle",
    "message": "",
    "progress": 0,
    "downloaded": "0B",
    "total": "0B",
    "speed": "0B/s",
    "eta": "Unknown",
    "model_id": "",
    "url": "",
    "download_path": ""
}

# Process tracking
civitai_current_process = None
model_current_process = None
huggingface_current_process = None

model_download_thread = None

# Add this near the other status dictionaries
training_tool_output = {
    "status": "idle",
    "message": "",
    "output": []
}

# Add this near the top of the file with other global variables
training_tool_process = None
training_tool_thread = None

# Add this near the other status dictionaries
service_restart_status = {
    "status": "idle",
    "message": "",
    "service": "",
    "port": 0,
    "pid": None,
    "script": "",
    "output": []
}

# Add this with other process tracking variables
service_restart_thread = None
service_restart_process = None

# -------------------------------------------------------------------------
# Helper Functions
# -------------------------------------------------------------------------

def ensure_directories_exist():
    """
    Ensure all required directories for model downloads exist.
    Creates directories if they don't exist.
    """
    os.system('mkdir -p "/workspace/ComfyUI/models/diffusion_models" "/workspace/ComfyUI/models/vae" "workspace/ComfyUI/models/text_encoders"')

def parse_aria2c_output(line):
    """
    Parse aria2c output to extract download progress information.
    
    Args:
        line: A line of text from aria2c output
        
    Returns:
        tuple: (downloaded, total, percent, speed, eta) or (None, None, None, None, None) if parsing fails
    """
    # Pattern to match aria2c output like: [#bc945d 16GiB/31GiB(52%) CN:16 DL:80MiB ETA:3m12s]
    pattern = r'\[#[0-9a-fA-F]+\s+([\d.]+(?:[KMG]i?B)?)/(?:([\d.]+)(?:[KMG]i?B)?)\((\d+(?:\.\d+)?)%\)(?:.*?CN:\d+\s+DL:([\d.]+(?:[KMG]i?B)?)?(?:.*?ETA:(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?)?)?'
    
    match = re.search(pattern, line)
    if not match:
        return None, None, None, None, None
        
    # Extract information from regex match
    downloaded = match.group(1)
    total = match.group(2)
    percent = int(float(match.group(3)))  # Handle potential decimal percentages
    speed = match.group(4) if match.group(4) else "0B"
    
    # Construct ETA string from components
    eta_parts = []
    if match.group(5): eta_parts.append(f"{match.group(5)}h")
    if match.group(6): eta_parts.append(f"{match.group(6)}m")
    if match.group(7): eta_parts.append(f"{match.group(7)}s")
    
    eta = "".join(eta_parts) if eta_parts else "Unknown"
    
    return downloaded, total, percent, speed, eta

def run_civitai_download(url, model_type, filename, token):
    global civitai_download_status, civitai_current_process
    try:
        civitai_download_status["status"] = "downloading"
        civitai_download_status["message"] = "Starting download..."
        civitai_download_status["progress"] = 0
        
        print(f"DEBUG: Starting CivitAI download: {url}")
        
        download_dir = MODEL_DIRS[model_type]
        url_extension = os.path.splitext(url.split('?')[0])[1]
        
        if not os.path.splitext(filename)[1] and url_extension:
            filename = f"{filename}{url_extension}"
        
        download_url = f"{url}?token={token}" if token else url
        print(f"DEBUG: Download filename: {filename}, directory: {download_dir}")
        
        # Use stdbuf to disable output buffering
        command = f"stdbuf -oL aria2c -x 16 -s 16 -d {download_dir} -o {filename} {download_url}"
        
        civitai_current_process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            shell=True, 
            bufsize=1,
            env=dict(os.environ, PYTHONUNBUFFERED="1")
        )
        
        print(f"DEBUG: Started CivitAI download with PID: {civitai_current_process.pid}")
        
        # Read output line by line
        for line in iter(civitai_current_process.stdout.readline, ''):
            if not line.strip():
                continue
                
            print(f"DEBUG: CivitAI output: {line.strip()}")
            downloaded, total, percent, speed, eta = parse_aria2c_output(line.strip())
            
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
                    civitai_download_status["message"] = f"Downloading {filename}... {percent}%"
            else:
                civitai_download_status["message"] = line.strip()
        
        # Wait for process to complete
        return_code = civitai_current_process.wait()
        print(f"DEBUG: CivitAI download completed with return code: {return_code}")
        
        if return_code == 0:
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
        print(f"DEBUG: Error in run_civitai_download: {e}")
        civitai_download_status.update({
            "status": "error",
            "message": f"Error: {str(e)}"
        })
    finally:
        civitai_current_process = None

def extract_aria2c_commands(script_paths):
    """
    Extract aria2c commands from multiple download scripts.
    
    Args:
        script_paths: List of paths to the download scripts
        
    Returns:
        list: List of extracted aria2c commands
    """
    print(f"DEBUG: Extracting commands from {len(script_paths)} scripts")
    commands = []
    
    try:
        for script_path in script_paths:
            with open(script_path, 'r') as f:
                current_command = None
                
                for line in f:
                    line = line.strip()
                    
                    # Skip empty lines and comments
                    if not line or line.startswith('#'):
                        continue
                        
                    # Check if line starts with aria2c
                    if line.startswith('aria2c'):
                        if current_command:
                            current_command = current_command.replace('\\', '')
                            current_command = current_command.replace('  ', ' ')
                            commands.append(current_command)
                        current_command = line
                    # Handle command continuation
                    elif current_command and line.endswith('\\'):
                        add_line = line[:-1]
                        current_command += ' ' + add_line
                    elif current_command and not line.startswith('echo'):
                        current_command += ' ' + line
                        
                # Add the last command if exists and it's an aria2c command
                if current_command and current_command.startswith('aria2c'):
                    current_command = current_command.replace('\\', '')
                    current_command = current_command.replace('  ', ' ')
                    commands.append(current_command)
                    
        print(f"DEBUG: Found {len(commands)} total aria2c commands")
    except Exception as e:
        print(f"DEBUG: Error extracting aria2c commands: {e}")
        
    return commands

def extract_filename_from_command(cmd):
    """
    Extract the output filename from an aria2c command.
    
    Args:
        cmd: The aria2c command string
        
    Returns:
        str: The extracted filename, or None if not found
    """
    if not isinstance(cmd, str):
        return None
        
    # First try to find the output path using -o or --out
    output_match = re.search(r'(?:--out=|\s-o\s+)["\']([^"\']+)["\']', cmd)
    if output_match:
        return output_match.group(1)
    
    # If no output path found, try to extract from the URL
    url_match = re.search(r'https?://[^\s"\']+', cmd)
    if url_match:
        url = url_match.group(0)
        # Extract filename from URL
        filename = url.split('/')[-1]
        # Remove any query parameters
        filename = filename.split('?')[0]
        return filename
    
    return None

def update_download_status(status_dict, **kwargs):
    """
    Update a download status dictionary with new values.
    
    Args:
        status_dict: The status dictionary to update
        **kwargs: Key-value pairs to update in the dictionary
    """
    status_dict.update(kwargs)

def run_huggingface_download(url, token=None, download_path=None):
    global huggingface_download_status, huggingface_current_process
    
    try:
        # Reset download status
        update_download_status(
            huggingface_download_status,
            status="downloading",
            message="Starting download...",
            progress=0,
            downloaded="0B",
            total="0B",
            speed="0B/s",
            eta="Unknown",
            url=url,  # Store the URL in the status
            download_path=download_path  # Store the download path in the status
        )

        # Create download directory if specified
        if download_path:
            os.makedirs(download_path, exist_ok=True)
            target_dir = download_path
        else:
            target_dir = "/workspace/ComfyUI/models"
            os.makedirs(target_dir, exist_ok=True)

        # Add token to URL if provided
        if token:
            url = f"{url}?token={token}"

        # Get filename from URL
        filename = os.path.basename(url.split('?')[0])
        target_path = os.path.join(target_dir, filename)

        # Use aria2c with progress tracking
        cmd = f"stdbuf -oL aria2c -x 16 -s 16 -d '{target_dir}' -o '{filename}' '{url}'"
        
        # Start process in its own process group
        huggingface_current_process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            shell=True,
            bufsize=1,
            env=dict(os.environ, PYTHONUNBUFFERED="1"),
            preexec_fn=os.setsid  # Create new process group
        )

        # Process aria2c output
        for line in iter(huggingface_current_process.stdout.readline, ''):
            if not line.strip():
                continue

            # Try to parse download progress
            downloaded, total, percent, speed, eta = parse_aria2c_output(line.strip())
            if downloaded and total and percent is not None:
                update_download_status(
                    huggingface_download_status,
                    downloaded=downloaded,
                    total=total,
                    progress=percent,
                    speed=speed + "/s",
                    eta=eta,
                    message=f"Downloading {filename}... {percent}%"
                )
            else:
                huggingface_download_status["message"] = line.strip()

        # Wait for process to complete
        return_code = huggingface_current_process.wait()
        
        if return_code == 0:
            update_download_status(
                huggingface_download_status,
                status="completed",
                message=f"Successfully downloaded to {target_path}",
                progress=100
            )
            return True
        else:
            stderr_output = huggingface_current_process.stderr.read()
            update_download_status(
                huggingface_download_status,
                status="error",
                message=f"Download failed: {stderr_output}",
                progress=0
            )
            return False

    except Exception as e:
        update_download_status(
            huggingface_download_status,
            status="error",
            message=f"Error: {str(e)}",
            progress=0
        )
        return False
    finally:
        huggingface_current_process = None

def parse_script_header(script_path):
    """Parse the header comment from a script to get the model name."""
    print(f"DEBUG: Parsing script header for {script_path}")
    try:
        with open(script_path, 'r') as f:
            content = f.readlines()
            
        # Get a clean filename as fallback
        fallback_name = os.path.basename(script_path)\
            .replace('download_', '')\
            .replace('.sh', '')\
            .replace('_', ' ')\
            .title()
            
        # Look for Model/Description/Token/URL markers
        name = None
        description = ''
        requires_token = False
        model_url = None
        
        for line in content:
            line = line.strip()
            if line.startswith('# Model:'):
                name = line.replace('# Model:', '').strip()
            elif line.startswith('# Description:'):
                description = line.replace('# Description:', '').strip()
            elif line.startswith('# Requires-HF-Token:'):
                requires_token = line.replace('# Requires-HF-Token:', '').strip().lower() == 'true'
            elif line.startswith('# Model-URL:'):
                model_url = line.replace('# Model-URL:', '').strip()
                
        # If no name found in header, use fallback
        if not name:
            name = fallback_name
            
        print(f"DEBUG: Parsed name: {name}, description: {description}, requires token: {requires_token}, url: {model_url}")
        return {
            'name': name,
            'description': description,
            'requires_token': requires_token,
            'model_url': model_url
        }
            
    except Exception as e:
        print(f"DEBUG: Error parsing script header: {e}")
        fallback_name = os.path.basename(script_path)\
            .replace('download_', '')\
            .replace('.sh', '')\
            .replace('_', ' ')\
            .title()
        return {
            'name': fallback_name,
            'description': '',
            'requires_token': False,
            'model_url': None
        }

def parse_training_tool_script(script_path):
    """Parse a training tool script to get its info."""
    script_name = os.path.basename(script_path).replace('_setup.sh', '')
    info = parse_script_header(script_path)
    
    # For training tools, we still look for Tool: marker
    try:
        with open(script_path, 'r') as f:
            content = f.readlines()
            
        for line in content:
            line = line.strip()
            if line.startswith('# Tool:'):
                info['name'] = line.replace('# Tool:', '').strip()
            elif line.startswith('# Description:'):
                info['description'] = line.replace('# Description:', '').strip()
    except Exception as e:
        print(f"DEBUG: Error parsing training tool script: {e}")
    
    return {
        'id': script_name,
        'name': info['name'],
        'description': info['description']
    }

class LoraTrainingForm(FlaskForm):
    tool = SelectField('Select Training Tool', choices=[])
    submit = SubmitField('Install')

class HuggingFaceForm(FlaskForm):
    model_url = StringField('HuggingFace Model URL', validators=[DataRequired(), URL()])
    token = StringField('HuggingFace API Token (optional)')
    download_path = StringField('Download Path (optional)')
    submit = SubmitField('Download')

@app.route('/')
def index():
    # Get available download scripts
    download_scripts = []
    for script in glob.glob(f'{SCRIPTS_PATH}/preset_model_scripts/download_*.sh'):
        script_name = os.path.basename(script).replace('download_', '').replace('.sh', '')
        model_info = parse_script_header(script)
        download_scripts.append({
            'id': script_name,
            'name': model_info['name'],
            'description': model_info.get('description', ''),
            'requires_token': model_info.get('requires_token', False),
            'model_url': model_info.get('model_url', '')
        })
    
    # Sort scripts alphabetically by name
    download_scripts.sort(key=lambda x: x['name'].lower())
    
    # Get available training tools
    training_tools = []
    training_scripts = glob.glob(f'{SCRIPTS_PATH}/training_tool_scripts/*setup.sh')
    print(f"DEBUG: Found training scripts: {training_scripts}")
    for script in training_scripts:
        tool_info = parse_training_tool_script(script)
        print(f"DEBUG: Parsed tool info: {tool_info}")
        training_tools.append(tool_info)
    
    # Sort training tools alphabetically by name
    training_tools.sort(key=lambda x: x['name'].lower())
    print(f"DEBUG: Final training tools list: {training_tools}")
    
    # Create form with dynamic choices
    lora_form = LoraTrainingForm()
    lora_form.tool.choices = [(tool['id'], f"{tool['name']} - {tool['description']}") for tool in training_tools]
    print(f"DEBUG: Form choices: {lora_form.tool.choices}")
    
    return render_template('index.html', 
                         lora_form=lora_form,
                         hf_form=HuggingFaceForm(),
                         download_scripts=download_scripts)

def run_training_tool_installation(script_path, tool):
    global training_tool_process, training_tool_output
    
    try:
        print(f"DEBUG: Running script: {script_path}")
        # Run the script and capture output
        process = subprocess.Popen(
            [script_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            bufsize=1,
            universal_newlines=True
        )
        training_tool_process = process
        
        # Set a timeout for reading output
        timeout = 30  # seconds
        last_output_time = time.time()
        
        # Read output line by line
        while True:
            # Check if process has finished
            if process.poll() is not None:
                break
                
            # Check if we've been waiting too long for output
            current_time = time.time()
            if current_time - last_output_time > timeout:
                # Process is still running but no output for a while
                training_tool_output["output"].append(f"[{time.strftime('%H:%M:%S')}] Waiting for process to continue...")
                last_output_time = current_time
                continue
                
            # Try to read a line with a short timeout
            try:
                line = process.stdout.readline()
                if line:
                    try:
                        decoded_line = line.strip()
                        training_tool_output["output"].append(decoded_line)
                        print(f"DEBUG: Output line: {decoded_line}")
                        last_output_time = time.time()
                        
                        # Check for Gradio server startup message
                        if "Running on local URL" in decoded_line or "Running on public URL" in decoded_line:
                            training_tool_output.update({
                                "status": "completed",
                                "message": f"{tool} installed and server started successfully"
                            })
                            return
                    except Exception as e:
                        print(f"Warning: Error processing line: {e}")
                        training_tool_output["output"].append("[Error processing output line]")
            except Exception as e:
                print(f"Warning: Error reading output: {e}")
                continue
        
        # Process has finished
        if process.returncode == 0:
            training_tool_output.update({
                "status": "completed",
                "message": f"{tool} installed successfully"
            })
        else:
            error_msg = f"Installation failed with return code {process.returncode}"
            print(f"DEBUG: {error_msg}")
            training_tool_output.update({
                "status": "error",
                "message": error_msg
            })
            
    except Exception as e:
        error_msg = str(e)
        print(f"DEBUG: Exception in run_training_tool_installation: {error_msg}")
        training_tool_output.update({
            "status": "error",
            "message": error_msg
        })
    finally:
        training_tool_process = None

@app.route('/install_training_tool', methods=['POST'])
def install_training_tool():
    global training_tool_thread
    
    tool = request.form.get('tool')
    try:
        # Construct and verify the script path
        script_path = str(SCRIPTS_PATH / f"training_tool_scripts/{tool}_setup.sh")
        print(f"DEBUG: Looking for script at: {script_path}")
        print(f"DEBUG: SCRIPTS_PATH: {SCRIPTS_PATH}")
        print(f"DEBUG: Tool name: {tool}")
        
        # Check if the scripts directory exists
        if not os.path.exists(SCRIPTS_PATH):
            error_msg = f"Scripts directory not found at {SCRIPTS_PATH}"
            print(f"ERROR: {error_msg}")
            return jsonify({'status': 'error', 'message': error_msg}), 404
            
        # Check if the training_tool_scripts directory exists
        training_scripts_dir = SCRIPTS_PATH / "training_tool_scripts"
        if not os.path.exists(training_scripts_dir):
            error_msg = f"Training tools directory not found at {training_scripts_dir}"
            print(f"ERROR: {error_msg}")
            return jsonify({'status': 'error', 'message': error_msg}), 404
            
        # Check if the script exists
        if not os.path.exists(script_path):
            error_msg = f"Setup script not found for {tool} at {script_path}"
            print(f"ERROR: {error_msg}")
            # List available scripts for debugging
            available_scripts = [f for f in os.listdir(training_scripts_dir) if f.endswith('_setup.sh')]
            print(f"DEBUG: Available scripts: {available_scripts}")
            return jsonify({'status': 'error', 'message': error_msg}), 404
        
        # Reset status
        training_tool_output.update({
            "status": "installing",
            "message": f"Installing {tool}...",
            "output": []
        })
        
        # Start installation in a separate thread
        training_tool_thread = threading.Thread(
            target=run_training_tool_installation,
            args=(script_path, tool)
        )
        training_tool_thread.daemon = True
        training_tool_thread.start()
        
        # Return immediately with a success message
        return jsonify({
            'status': 'started',
            'message': f'Started installing {tool}. Please check the status for updates.'
        })
            
    except Exception as e:
        error_msg = str(e)
        print(f"DEBUG: Exception in install_training_tool: {error_msg}")
        training_tool_output.update({
            "status": "error",
            "message": error_msg
        })
        return jsonify({'status': 'error', 'message': error_msg}), 500

@app.route('/training_tool_status')
def training_tool_status():
    return jsonify(training_tool_output)

@app.route('/download_huggingface', methods=['POST'])
def download_huggingface():
    model_url = request.form.get('model_url')
    token = request.form.get('token')
    download_path = request.form.get('download_path')
    
    if not model_url:
        return jsonify({'status': 'error', 'message': 'Model URL is required'}), 400
        
    # Start download in a background thread
    thread = threading.Thread(
        target=run_huggingface_download,
        args=(model_url, token, download_path)
    )
    thread.daemon = True
    thread.start()
    
    return jsonify({
        "status": "started",
        "message": f"Started downloading from {model_url}"
    })

@app.route('/download_civitai', methods=['POST'])
def download_civitai():
    url = request.form.get('url')
    model_type = request.form.get('model_type')
    filename = request.form.get('filename')
    token = request.form.get('token')
    
    if not url or not model_type or not filename:
        return jsonify({"error": "URL, model type, and filename are required"}), 400
    
    if model_type not in MODEL_DIRS:
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

@app.route('/civitai_status')
def civitai_status():
    return jsonify(civitai_download_status)

@app.route('/huggingface_status')
def huggingface_status():
    """
    Return the current status of HuggingFace downloads.
    This endpoint is polled by the frontend to update progress.
    """
    print(f"HF STATUS UPDATE: {huggingface_download_status.get('status')}, Progress: {huggingface_download_status.get('progress')}%, Message: {huggingface_download_status.get('message')}")
    return jsonify(huggingface_download_status)

@app.route('/stop_huggingface', methods=['POST'])
def stop_huggingface_download():
    global huggingface_current_process
    if huggingface_current_process:
        try:
            # Get the process group ID (pgid) of the aria2c process
            pgid = os.getpgid(huggingface_current_process.pid)
            
            # Kill the entire process group
            os.killpg(pgid, signal.SIGTERM)
            time.sleep(1)
            # Delete the partial download file
            try:
                # Get URL from the stored status
                model_url = huggingface_download_status.get('url', '')
                if model_url:
                    # Extract filename from URL (remove any query parameters)
                    filename = os.path.basename(model_url.split('?')[0])
                    if filename:
                        # Check both possible locations
                        possible_paths = []
                        # Add custom download path if specified
                        download_path = huggingface_download_status.get('download_path')
                        if download_path:
                            possible_paths.extend([
                                os.path.join(download_path, filename),
                                os.path.join(download_path, filename + ".aria2"),  # aria2 control file
                            ])
                        
                        for path in possible_paths:
                            if os.path.exists(path):
                                os.remove(path)
                                print(f"Deleted partial download file: {path}")
            except Exception as e:
                print(f"Error deleting partial download file: {e}")
                
        except ProcessLookupError:
            # Process already terminated
            pass
        except Exception as e:
            print(f"Error stopping download: {e}")
        finally:
            huggingface_current_process = None
            update_download_status(
                huggingface_download_status,
                status="stopped",
                message="Download stopped by user",
                progress=0
            )
    return jsonify({"status": "stopped"})

@app.route('/health')
def health_check():
    """
    Simple health check endpoint.
    """
    return jsonify({"status": "ok", "message": "Server is running"})

def run_model_download(script_path, script_name, display_name, token=None):
    """
    Run a model download script and track its progress.
    
    Args:
        script_path: Path to the download script
        script_name: Name of the script
        display_name: Display name of the model
        token: Optional HuggingFace token
    """
    global model_download_status, model_current_process
    
    try:
        print(f"DEBUG: Starting download for {display_name} from {script_path}")
        
        # Extract aria2c commands from the script
        commands = extract_aria2c_commands(script_path)
        
        if not commands:
            print(f"DEBUG: No aria2c commands found in {script_path}")
            return False
            
        print(f"DEBUG: Found {len(commands)} commands to execute")
            
        # Run each command sequentially
        for i, cmd in enumerate(commands):
            if model_download_status.get('status') == 'stopped':
                print("DEBUG: Download stopped by user")
                return False
                
            # Update status for current file
            model_download_status.update({
                "current_model": f"{display_name} ({i+1}/{len(commands)})",
                "message": f"Downloading {display_name} ({i+1}/{len(commands)})..."
            })
            
            # Add token to URL if needed
            if token:
                # Find the URL in the command, handling both quoted and unquoted URLs
                url_match = re.search(r'["\']?https?://[^\s"\']+(?=["\']|$)', cmd)
                if url_match:
                    url = url_match.group(0)
                    # Remove any leading quotes from the URL
                    # url = url.lstrip('"\'')
                    # Add Authorization header with Bearer token
                    cmd = cmd.replace(url_match.group(0), f'--header="Authorization: Bearer {token}" {url}')
            
            print(f"DEBUG: Executing command: {cmd}")
            
            # Run aria2c with unbuffered output
            cmd = f"stdbuf -oL {cmd}"
            model_current_process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                shell=True,
                bufsize=1,
                env=dict(os.environ, PYTHONUNBUFFERED="1"),
                preexec_fn=os.setsid
            )
            
            print(f"DEBUG: Started process with PID: {model_current_process.pid}")
            
            # Process output
            while True:
                output = model_current_process.stdout.readline()
                if output == '' and model_current_process.poll() is not None:
                    break
                if output:
                    line = output.strip()
                    print(f"DEBUG: aria2c output: {line}")
                    
                    # Skip status legend messages
                    if line.startswith('Status Legend:'):
                        continue
                    
                    # If all files already exist, we'll see a pattern of completed messages without downloads
                    if line.endswith("file already exists."):
                        # We'll let our Completed download message handle the status updates
                        print(f"DEBUG: File already exists detected: {line}")
                        
                    # Check for aria2c file already exists message - expanded patterns to catch all variations
                    if ("file already exists" in line or 
                        "download completed" in line or 
                        "already downloaded" in line or
                        "already exists" in line or
                        "resume download not supported" in line):
                        print(f"DEBUG: Detected file already exists: {line}")
                        
                        # If we've detected all files already exist
                        total_commands = len(commands)
                        existing_files_count = model_download_status.get("existing_files_count", 0) + 1
                        model_download_status["existing_files_count"] = existing_files_count
                        
                        # If all files exist, update the message
                        if existing_files_count == total_commands:
                            model_download_status.update({
                                "status": "completed",
                                "message": "All files already exist. No download required.",
                                "progress": 100,
                                "downloaded": "0B",
                                "total": "0B",
                                "speed": "0B/s",
                                "eta": "N/A"
                            })
                        
                        # File already exists will be followed by a "Completed download" message from our script
                        # No need to update status here
                        continue
                    
                    downloaded, total, percent, speed, eta = parse_aria2c_output(line)
                    if downloaded and total and percent is not None:
                        model_download_status.update({
                            "downloaded": downloaded,
                            "total": total,
                            "progress": percent,
                            "speed": speed + "/s",
                            "eta": eta,
                            "message": f"Downloading {display_name} ({i+1}/{len(commands)})... {percent}%"
                        })
            
            # Check for errors
            stderr_output = model_current_process.stderr.read()
            if stderr_output:
                print(f"DEBUG: aria2c stderr: {stderr_output}")
            
            # Wait for process to complete
            return_code = model_current_process.wait()
            print(f"DEBUG: Process completed with return code: {return_code}")
            
            if return_code != 0:
                model_download_status.update({
                    "status": "error",
                    "message": f"Error downloading {display_name} ({i+1}/{len(commands)}). Return code: {return_code}"
                })
                return False
                
            # Update status for successful completion of this file
            model_download_status.update({
                "progress": 100,
                "message": f"Completed {display_name} ({i+1}/{len(commands)})"
            })
            
            # If this was the last command, mark the overall download as complete
            if i == len(commands) - 1:
                model_download_status.update({
                    "status": "completed",
                    "message": f"Successfully downloaded {display_name}",
                    "progress": 100
                })
                
        return True
        
    except Exception as e:
        print(f"DEBUG: Error in run_model_download: {str(e)}")
        model_download_status.update({
            "status": "error",
            "message": f"Error: {str(e)}"
        })
        return False
    finally:
        model_current_process = None

def run_model_downloads(model_infos, token=None):
    global model_download_status, model_download_thread, model_current_process
    
    try:
        # Reset status counters
        model_download_status["existing_files_count"] = 0
        
        # Check if we should stop before starting
        if model_download_status.get('status') == 'stopped':
            return
            
        # Extract all aria2c commands from all scripts
        script_paths = [info[0] for info in model_infos]
        commands = extract_aria2c_commands(script_paths)
        
        if not commands:
            model_download_status.update({
                "status": "completed",
                "message": "All files already downloaded. No download required.",
                "progress": 100,
                "downloaded": "0B",
                "total": "0B",
                "speed": "0B/s",
                "eta": "N/A"
            })
            return
            
        # Initialize status
        model_download_status.update({
            "status": "downloading",
            "message": "Starting downloads...",
            "progress": 0,
            "downloaded": "0B",
            "total": "0B",
            "speed": "0B/s",
            "eta": "Unknown",
            "current_model": "",
            "total_models": len(commands),
            "completed_models": 0,
            "current_file": 1
        })
        
        # Add token to URLs if needed
        if token:
            for i, cmd in enumerate(commands):
                url_match = re.search(r'["\']?https?://[^\s"\']+(?=["\']|$)', cmd)
                if url_match:
                    url = url_match.group(0)
                    commands[i] = cmd.replace(url_match.group(0), f'--header="Authorization: Bearer {token}" {url}')
        
        # Check if force flag is needed for aria2c
        need_force_download = False
        for cmd in commands:
            # Check if any command is missing the -c or --continue flag
            if all(flag not in cmd for flag in [' -c ', ' -c=', ' --continue ', ' --continue=']):
                need_force_download = True
                break
        
        # Create a temporary script with all commands
        temp_script = "/tmp/batch_download.sh"
        with open(temp_script, 'w') as f:
            f.write("#!/bin/bash\n")
            f.write("set -e\n")  # Exit on error
            
            # Track overall progress
            f.write("total_files=" + str(len(commands)) + "\n")
            f.write("current_file=1\n")
            
            # Run each command sequentially (without the & at the end)
            for i, cmd in enumerate(commands):
                # Add force flag if needed to re-download existing files
                if need_force_download and '--allow-overwrite=true' not in cmd:
                    cmd = cmd.replace('aria2c', 'aria2c --allow-overwrite=true')
                
                # Add progress message before each download
                f.write(f'echo "Starting download {i+1}/{len(commands)}..."\n')
                f.write(f"{cmd}\n")  # Run command without & to make it sequential
                
                # After each command completes, increment the counter
                f.write('current_file=$((current_file + 1))\n')
                f.write('echo "Completed download $((current_file - 1))/$total_files"\n')
            
        os.chmod(temp_script, 0o755)
        
        # Run all commands in a single subprocess with its own process group
        cmd = f"stdbuf -oL {temp_script}"
        model_current_process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            shell=True,
            bufsize=1,
            env=dict(os.environ, PYTHONUNBUFFERED="1"),
            preexec_fn=os.setsid  # Create new process group
        )
        
        # Process output
        while True:
            # Check if we should stop
            if model_download_status.get('status') == 'stopped':
                try:
                    # Get the process group ID and kill it
                    pgid = os.getpgid(model_current_process.pid)
                    os.killpg(pgid, signal.SIGTERM)
                    time.sleep(1)
                except:
                    pass
                finally:
                    model_current_process = None
                    # Clean up the temporary script
                    try:
                        os.remove(temp_script)
                    except:
                        pass
                    return
                    
            output = model_current_process.stdout.readline()
            if output == '' and model_current_process.poll() is not None:
                break
            if output:
                line = output.strip()
                print(f"DEBUG: aria2c output: {line}")
                
                # Check for our custom progress messages
                if line.startswith("Starting download "):
                    parts = line.split("download ")[1].split("/")
                    current_file = int(parts[0])
                    total_files = int(parts[1].strip("..."))
                    
                    model_download_status.update({
                        "current_file": current_file,
                        "message": f"Starting download {current_file}/{total_files}..."
                    })
                    continue
                
                if line.startswith("Completed download "):
                    parts = line.split("download ")[1].split("/")
                    completed = int(parts[0])
                    total = int(parts[1])
                    
                    # Update completed count and calculate progress percentage
                    model_download_status["completed_models"] = completed
                    percent = int(100 * completed / total)
                    
                    model_download_status.update({
                        "progress": percent,
                        "message": f"Completed download {completed}/{total}"
                    })
                    
                    # If all downloads complete, mark as finished
                    if completed == total:
                        # If all files exist, update with appropriate message
                        if model_download_status.get("existing_files_count", 0) == total:
                            model_download_status.update({
                                "status": "completed",
                                "message": "All files already exist. No download required.",
                                "progress": 100,
                                "downloaded": "0B",
                                "total": "0B",
                                "speed": "0B/s",
                                "eta": "N/A"
                            })
                        else:
                            model_download_status.update({
                                "status": "completed",
                                "message": "All downloads completed successfully!",
                                "progress": 100
                            })
                    continue
                
                # Skip status legend messages
                if line.startswith('Status Legend:'):
                    continue
                
                # If all files already exist, we'll see a pattern of completed messages without downloads
                if line.endswith("file already exists."):
                    # Count this as an existing file
                    existing_files_count = model_download_status.get("existing_files_count", 0) + 1
                    model_download_status["existing_files_count"] = existing_files_count
                    print(f"DEBUG: File already exists detected: {line}, count: {existing_files_count}/{len(commands)}")
                    continue
                
                # Check for aria2c file already exists message - expanded patterns to catch all variations
                if ("file already exists" in line or 
                    "download completed" in line or 
                    "already downloaded" in line or
                    "already exists" in line or
                    "resume download not supported" in line):
                    print(f"DEBUG: Detected file already exists: {line}")
                    
                    # Count as an existing file
                    existing_files_count = model_download_status.get("existing_files_count", 0) + 1
                    model_download_status["existing_files_count"] = existing_files_count
                    print(f"DEBUG: File already exists count: {existing_files_count}/{len(commands)}")
                    
                    # File already exists will be followed by a "Completed download" message from our script
                    # No need to update status here
                    continue
                
                downloaded, total, percent, speed, eta = parse_aria2c_output(line)
                if downloaded and total and percent is not None:
                    # Only update current_file when a new download starts (percent = 0)
                    if percent == 0 and model_download_status["current_file"] < len(commands):
                        model_download_status["current_file"] = model_download_status["completed_models"] + 1
                    
                    model_download_status.update({
                        "downloaded": downloaded,
                        "total": total,
                        "progress": percent,
                        "speed": speed + "/s",
                        "eta": eta,
                        "message": f"Downloading file {model_download_status['current_file']}/{len(commands)}... {percent}%"
                    })
                elif line == '(OK):download completed.':
                    # Handle the final completion message
                    if model_download_status["completed_models"] == len(commands):
                        model_download_status.update({
                            "status": "completed",
                            "message": "All downloads completed successfully!",
                            "progress": 100
                        })
                
        # Check for errors
        stderr_output = model_current_process.stderr.read()
        if stderr_output:
            print(f"DEBUG: aria2c stderr: {stderr_output}")
        
        # Wait for process to complete
        return_code = model_current_process.wait()
        print(f"DEBUG: Process completed with return code: {return_code}")
        
        if return_code != 0:
            model_download_status.update({
                "status": "error",
                "message": f"Error during download. Return code: {return_code}"
            })
        else:
            # Ensure status is set to completed if all downloads finished successfully
            if model_download_status.get('progress') == 100:
                model_download_status.update({
                    "status": "completed",
                    "message": "All downloads completed successfully!",
                    "progress": 100
                })
            
        # Clean up temporary script
        try:
            os.remove(temp_script)
        except:
            pass
            
    except Exception as e:
        print(f"Error in run_model_downloads: {e}")
        model_download_status.update({
            "status": "error",
            "message": f"Error: {str(e)}"
        })
    finally:
        model_download_thread = None
        # Only set process to None after status is updated
        if model_download_status.get('status') in ['completed', 'error']:
            model_current_process = None

@app.route('/run_download_script', methods=['POST'])
def run_download_script():
    script_names = json.loads(request.form.get('script_names', '[]'))
    token = request.form.get('token')
    
    if not script_names:
        return jsonify({'status': 'error', 'message': 'No models selected'}), 400
    
    # Get script info for all selected models
    model_infos = []
    for script_name in script_names:
        download_script = f'{SCRIPTS_PATH}/preset_model_scripts/download_{script_name}.sh'
        
        if not os.path.exists(download_script):
            return jsonify({'status': 'error', 'message': f'Script not found for {script_name}'}), 404
        
        model_info = parse_script_header(download_script)
        model_infos.append((download_script, script_name, model_info))
    
    # Check if any selected model requires a token but none is provided
    requires_token = any(info[2].get('requires_token', False) for info in model_infos)
    if requires_token and not token:
        return jsonify({
            'status': 'error',
            'message': 'HuggingFace token is required for one or more selected models'
        }), 400
    
    # Start downloads in a background thread
    global model_download_thread
    model_download_thread = threading.Thread(
        target=run_model_downloads,
        args=(model_infos, token)
    )
    model_download_thread.daemon = True
    model_download_thread.start()
    
    return jsonify({
        'status': 'success',
        'message': f'Started downloading {len(script_names)} models'
    })

@app.route('/stop_model_download', methods=['POST'])
def stop_model_download():
    global model_current_process, model_download_status, model_download_thread
    
    # Store the process in a local variable to avoid race conditions
    current_process = model_current_process
    
    try:
        # Update status first to signal the download thread to stop
        model_download_status.update({
            "status": "stopped",
            "message": "Stopping download...",
            "progress": 0,
            "downloaded": "0B",
            "total": "0B",
            "speed": "0B/s",
            "eta": "Unknown"
        })
        
        # If we have a process, try to kill it
        if current_process:
            try:
                # Get the process group ID and kill it
                pgid = os.getpgid(current_process.pid)
                os.killpg(pgid, signal.SIGTERM)
                time.sleep(1)
            except Exception as e:
                print(f"Error killing process group: {e}")
        
        # Clean up the temporary script and any partial downloads
        try:
            if os.path.exists("/tmp/batch_download.sh"):
                os.remove("/tmp/batch_download.sh")
            # Clean up any .aria2 files
            for root, dirs, files in os.walk(BASE_PATH):
                for file in files:
                    if file.endswith('.aria2'):
                        try:
                            os.remove(os.path.join(root, file))
                        except:
                            pass
        except Exception as e:
            print(f"Error cleaning up files: {e}")
                
    except Exception as e:
        print(f"Error stopping download: {e}")
        model_download_status.update({
            "status": "error",
            "message": f"Error stopping download: {str(e)}"
        })
    finally:
        # Only set to None if it's still the same process
        if model_current_process == current_process:
            model_current_process = None
        if model_download_thread:
            model_download_thread = None
        
        # Reset the download status to idle after a short delay
        time.sleep(1)  # Give time for any cleanup to complete
        model_download_status.update({
            "status": "idle",
            "message": "",
            "progress": 0,
            "downloaded": "0B",
            "total": "0B",
            "speed": "0B/s",
            "eta": "Unknown",
            "current_model": "",
            "total_models": 0,
            "completed_models": 0,
            "current_file": 1
        })
    
    return jsonify({"status": "stopped"})

@app.route('/model_status')
def model_status():
    """
    Return the current status of model downloads.
    This endpoint is polled by the frontend to update progress.
    """
    global model_current_process, model_download_thread
    
    # If we already have a completed or error status, just return it
    if model_download_status.get('status') in ['completed', 'error', 'stopped', 'idle']:
        return jsonify(model_download_status)
    
    # If we're in downloading state but process is None, check if it completed
    if model_download_status.get('status') == 'downloading':
        if model_download_status.get('progress') == 100:
            # If progress is 100%, mark as completed regardless of process state
            model_download_status.update({
                "status": "completed",
                "message": "Download completed successfully!",
                "progress": 100
            })
        elif model_current_process is None:
            # Process is None but progress is not 100% - check if thread is still alive
            if model_download_thread and model_download_thread.is_alive():
                # Thread is still running, probably setting up a new process
                return jsonify(model_download_status)
            else:
                # Neither process nor thread is running and progress < 100%, this is an error
                model_download_status.update({
                    "status": "error",
                    "message": "Download process exited unexpectedly. Please try again.",
                    "progress": 0,
                    "downloaded": "0B",
                    "total": "0B",
                    "speed": "0B/s",
                    "eta": "Unknown"
                })
    
    return jsonify(model_download_status)

@app.route('/model_downloader')
def model_downloader():
    # Get available download scripts
    download_scripts = []
    for script in glob.glob(f'{SCRIPTS_PATH}/preset_model_scripts/download_*.sh'):
        script_name = os.path.basename(script).replace('download_', '').replace('.sh', '')
        model_info = parse_script_header(script)
        download_scripts.append({
            'id': script_name,
            'name': model_info['name'],
            'description': model_info.get('description', ''),
            'requires_token': model_info.get('requires_token', False),
            'model_url': model_info.get('model_url', '')
        })
    
    # Sort scripts alphabetically by name
    download_scripts.sort(key=lambda x: x['name'].lower())
    
    return render_template('model_downloader.html', download_scripts=download_scripts)

# -------------------------------------------------------------------------
# Service Restart Functions
# -------------------------------------------------------------------------

def find_process_by_port(port):
    """
    Find a process using a specific port.
    
    Args:
        port: The port number to check
    
    Returns:
        int: PID of the process using the port, or None if not found
    """
    try:
        # Run lsof to find process using the port
        cmd = f"lsof -i :{port} -t"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        if result.returncode == 0 and result.stdout.strip():
            # Return the first PID (there might be multiple)
            return int(result.stdout.strip().split('\n')[0])
        return None
    except Exception as e:
        print(f"Error finding process by port: {e}")
        return None

def kill_process(pid):
    """
    Kill a process by its PID.
    
    Args:
        pid: Process ID to kill
    
    Returns:
        bool: True if successful, False otherwise
    """
    try:
        # First try SIGTERM for graceful shutdown
        os.kill(pid, signal.SIGTERM)
        
        # Wait a bit to see if it terminates
        time.sleep(2)
        
        # Check if process still exists
        try:
            os.kill(pid, 0)  # Signal 0 is used to check if process exists
            # Process still exists, use SIGKILL
            os.kill(pid, signal.SIGKILL)
            time.sleep(1)
        except OSError:
            # Process has already terminated
            pass
            
        return True
    except Exception as e:
        print(f"Error killing process: {e}")
        return False

def determine_script_path(service, script_name):
    """
    Determine the path to the restart script for a service.
    
    Args:
        service: Service name (e.g., 'comfyui', 'kohya')
        script_name: Name of the script file (not used anymore, keeping for backward compatibility)
    
    Returns:
        str: Full path to the script
    """
    # Use the dedicated restart scripts from the restart_apps directory
    return str(SCRIPTS_PATH / "restart_apps" / f"restart_{service}.sh")

def run_service_restart(service, port, script_name):
    """
    Restart a service by first killing any existing process and then running the restart script.
    
    Args:
        service: Service name
        port: Port the service runs on
        script_name: Name of the restart script
    """
    global service_restart_status, service_restart_process
    
    try:
        # Update status
        service_restart_status.update({
            "status": "running",
            "message": f"Attempting to restart {service}...",
            "service": service,
            "port": port,
            "pid": None,
            "script": script_name,
            "output": []
        })
        
        # Find process by port
        pid = find_process_by_port(port)
        service_restart_status["pid"] = pid
        
        if pid:
            # Log found process
            service_restart_status["message"] = f"Found {service} process with PID {pid}, attempting to kill..."
            service_restart_status["output"].append(f"Found process on port {port} with PID {pid}")
            
            # Kill the process
            if kill_process(pid):
                service_restart_status["message"] = f"Successfully killed {service} process with PID {pid}"
                service_restart_status["output"].append(f"Successfully killed process with PID {pid}")
            else:
                service_restart_status["message"] = f"Failed to kill {service} process with PID {pid}"
                service_restart_status["output"].append(f"Failed to kill process with PID {pid}")
                service_restart_status["status"] = "error"
                return
        else:
            service_restart_status["message"] = f"No process found running on port {port}"
            service_restart_status["output"].append(f"No process found running on port {port}")
        
        # Determine script path
        script_path = determine_script_path(service, script_name)
        
        if not os.path.exists(script_path):
            service_restart_status["message"] = f"Restart script not found at {script_path}"
            service_restart_status["output"].append(f"Restart script not found at {script_path}")
            service_restart_status["status"] = "error"
            return
            
        # Run the restart script
        service_restart_status["message"] = f"Running restart script for {service}..."
        service_restart_status["output"].append(f"Running restart script: {script_path}")
        
        # Execute restart script
        cmd = f"bash {script_path}"
        service_restart_process = subprocess.Popen(
            cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            env=dict(os.environ, PYTHONUNBUFFERED="1")
        )
        
        # Create a thread to read output in real-time
        output_thread = threading.Thread(
            target=read_process_output,
            args=(service_restart_process, service)
        )
        output_thread.daemon = True
        output_thread.start()
        
        # Wait for process to complete
        return_code = service_restart_process.wait()
        
        # Give the output thread time to finish reading
        time.sleep(0.5)
        
        if return_code == 0:
            service_restart_status["message"] = f"{service} restarted successfully"
            service_restart_status["status"] = "success"
        else:
            service_restart_status["message"] = f"Error restarting {service}. Return code: {return_code}"
            service_restart_status["status"] = "error"
            
    except Exception as e:
        service_restart_status["message"] = f"Error restarting {service}: {str(e)}"
        service_restart_status["output"].append(f"Error: {str(e)}")
        service_restart_status["status"] = "error"
    finally:
        service_restart_process = None

def read_process_output(process, service):
    """
    Read output from a process and update the status.
    
    Args:
        process: The subprocess.Popen process
        service: The service name for status updates
    """
    global service_restart_status
    
    try:
        for line in iter(process.stdout.readline, ''):
            if not line.strip():
                continue
                
            # Debug print to verify we're getting output
            print(f"DEBUG - Service restart output: {line.strip()}")
                
            # Add to output list
            service_restart_status["output"].append(line.strip())
            
            # Check for completion indicators
            if "server starting" in line.lower() or "running on" in line.lower():
                service_restart_status["message"] = f"{service} restarted successfully"
                service_restart_status["status"] = "success"
    except Exception as e:
        print(f"Error reading process output: {e}")
        service_restart_status["output"].append(f"Error reading process output: {str(e)}")

@app.route('/restart_service', methods=['POST'])
def restart_service():
    """
    API endpoint to restart a service.
    """
    global service_restart_thread
    
    try:
        data = request.json
        service = data.get('service')
        port = data.get('port')
        script = data.get('script')
        
        if not service or not port:
            return jsonify({
                'status': 'error',
                'message': 'Missing required parameters: service, port'
            }), 400
            
        # Reset status
        service_restart_status.update({
            "status": "running",
            "message": f"Preparing to restart {service}...",
            "service": service,
            "port": port,
            "pid": None,
            "script": script,
            "output": []
        })
        
        # Start the restart process in a background thread
        service_restart_thread = threading.Thread(
            target=run_service_restart,
            args=(service, port, script)
        )
        service_restart_thread.daemon = True
        service_restart_thread.start()
        
        return jsonify({
            'status': 'success',
            'message': f'Restarting {service} (port {port})...'
        })
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Error: {str(e)}'
        }), 500

@app.route('/check_service_status', methods=['GET'])
def check_service_status():
    """
    API endpoint to check the status of a service restart operation.
    """
    service = request.args.get('service')
    
    if service != service_restart_status.get('service'):
        return jsonify({
            'status': 'error',
            'message': f'No restart operation in progress for {service}'
        })
        
    return jsonify({
        'status': service_restart_status.get('status'),
        'message': service_restart_status.get('message'),
        'service': service_restart_status.get('service'),
        'output': service_restart_status.get('output', [])
    })

# -------------------------------------------------------------------------
# Storage Utilities
# -------------------------------------------------------------------------

def clear_trash_directory(trash_dir: str = "/workspace/.Trash-0"):
    """
    Attempt to clear the contents of the specified trash directory.

    Tries to fix common permission issues and force delete all contents
    (including hidden files and directories).

    Returns:
        dict: { status: 'success'|'error', message: str }
    """
    try:
        # If the directory does not exist, nothing to do
        if not os.path.exists(trash_dir):
            return {
                'status': 'success',
                'message': f'Trash folder {trash_dir} not found. Nothing to clear.'
            }

        # Build a robust shell command to clear contents, including hidden files
        # 1) Relax permissions and ownership where possible
        # 2) Remove regular and hidden entries
        # 3) Fallback to find -exec rm -rf
        shell_cmd = (
            f'if [ -d "{trash_dir}" ]; then '
            f'  chmod -R u+rwX "{trash_dir}" 2>/dev/null || true; '
            f'  chown -R $(id -u):$(id -g) "{trash_dir}" 2>/dev/null || true; '
            f'  rm -rf {trash_dir}/* {trash_dir}/.[!.]* {trash_dir}/..?* 2>/dev/null || true; '
            f'  find "{trash_dir}" -mindepth 1 -exec rm -rf {{}} + 2>/dev/null || true; '
            f'fi'
        )

        result = subprocess.run(
            ["bash", "-lc", shell_cmd],
            capture_output=True,
            text=True
        )

        # Verify directory is empty
        remaining = []
        try:
            remaining = os.listdir(trash_dir)
        except Exception:
            # If we cannot list it, assume it's fine if the directory is gone
            if not os.path.exists(trash_dir):
                remaining = []

        if len(remaining) == 0:
            return {
                'status': 'success',
                'message': f'Successfully cleared contents of {trash_dir}.'
            }
        else:
            # Include some stderr to help diagnose
            stderr_tail = (result.stderr or '').strip().splitlines()[-3:]
            stderr_msg = ('\n'.join(stderr_tail)).strip()
            return {
                'status': 'error',
                'message': (
                    f'Attempted to clear {trash_dir}, but some items could not be removed.\n'
                    f'Remaining entries (first 5 shown): {remaining[:5]}\n'
                    f'Errors (if any): {stderr_msg or "None"}'
                )
            }
    except Exception as e:
        return {
            'status': 'error',
            'message': f'Error clearing trash: {str(e)}'
        }


@app.route('/clear_trash', methods=['POST'])
def clear_trash():
    """API endpoint to clear /workspace/.Trash-0 contents."""
    result = clear_trash_directory("/workspace/.Trash-0")
    http_status = 200 if result.get('status') == 'success' else 500
    return jsonify(result), http_status

if __name__ == '__main__':
    # Validate configuration
    ensure_directories_exist()
    app.run(host='0.0.0.0', port=5000) 