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
    "display_name": ""
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

def extract_aria2c_commands(script_path):
    """
    Extract aria2c commands from a download script.
    
    Args:
        script_path: Path to the script containing aria2c commands
        
    Returns:
        list: List of extracted aria2c commands
    """
    print(f"DEBUG: Extracting commands from {script_path}")
    commands = []
    
    try:
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
                elif current_command:
                    current_command += ' ' + line
                    
            # Add the last command if exists
            if current_command:
                current_command = current_command.replace('\\', '')
                current_command = current_command.replace('  ', ' ')
                commands.append(current_command)
                
        print(f"DEBUG: Found {len(commands)} aria2c commands")
    except Exception as e:
        print(f"DEBUG: Error extracting aria2c commands from {script_path}: {e}")
        
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
    """
    Download a model from a direct URL using aria2c.
    
    Args:
        url: Direct download URL
        token: HuggingFace API token (optional)
        download_path: Custom download location (optional)
    """
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
            
        # Look for Model/Description/Token markers
        name = None
        description = ''
        requires_token = False
        
        for line in content:
            line = line.strip()
            if line.startswith('# Model:'):
                name = line.replace('# Model:', '').strip()
            elif line.startswith('# Description:'):
                description = line.replace('# Description:', '').strip()
            elif line.startswith('# Requires-HF-Token:'):
                requires_token = line.replace('# Requires-HF-Token:', '').strip().lower() == 'true'
                
        # If no name found in header, use fallback
        if not name:
            name = fallback_name
            
        print(f"DEBUG: Parsed name: {name}, description: {description}, requires token: {requires_token}")
        return {
            'name': name,
            'description': description,
            'requires_token': requires_token
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
            'requires_token': False
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
            'requires_token': model_info.get('requires_token', False)
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
                # Find the URL in the command
                url_match = re.search(r'https?://[^\s"\']+', cmd)
                if url_match:
                    url = url_match.group(0)
                    # Add token to URL
                    new_url = f"{url}?token={token}"
                    # Replace the URL in the command
                    cmd = cmd.replace(url, new_url)
            
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
    """
    Run multiple model downloads sequentially.
    
    Args:
        model_infos: List of tuples (script_path, script_name, model_info)
        token: Optional HuggingFace token
    """
    global model_download_status, model_download_thread
    
    try:
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
            "total_models": len(model_infos),
            "completed_models": 0
        })
        
        # Run each model download
        for i, (script_path, script_name, model_info) in enumerate(model_infos):
            if model_download_status.get('status') == 'stopped':
                return
                
            # Update status for current model
            model_download_status.update({
                "current_model": model_info['name'],
                "message": f"Downloading {model_info['name']} ({i+1}/{len(model_infos)})..."
            })
            
            # Run the download
            success = run_model_download(script_path, script_name, model_info['name'], token)
            
            if not success:
                return
                
            # Update completed count
            model_download_status["completed_models"] += 1
            
        # All downloads completed successfully
        model_download_status.update({
            "status": "completed",
            "message": "All downloads completed successfully!",
            "progress": 100
        })
        
    except Exception as e:
        print(f"Error in run_model_downloads: {e}")
        model_download_status.update({
            "status": "error",
            "message": f"Error: {str(e)}"
        })
    finally:
        model_download_thread = None

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
    
    if model_current_process:
        try:
            # Get the process group ID and kill it
            pgid = os.getpgid(model_current_process.pid)
            os.killpg(pgid, signal.SIGTERM)
            time.sleep(1)
        except Exception as e:
            print(f"Error stopping download: {e}")
        finally:
            model_current_process = None
    
    # Update status
    model_download_status.update({
        "status": "stopped",
        "message": "Download stopped by user",
        "progress": 0,
        "downloaded": "0B",
        "total": "0B",
        "speed": "0B/s",
        "eta": "Unknown"
    })
    
    return jsonify({"status": "stopped"})

@app.route('/model_status')
def model_status():
    """
    Return the current status of model downloads.
    This endpoint is polled by the frontend to update progress.
    """
    global model_current_process
    
    # If process doesn't exist but status is still downloading, reset it
    if not model_current_process and model_download_status.get('status') == 'downloading':
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
            'requires_token': model_info.get('requires_token', False)
        })
    
    # Sort scripts alphabetically by name
    download_scripts.sort(key=lambda x: x['name'].lower())
    
    return render_template('model_downloader.html', download_scripts=download_scripts)

if __name__ == '__main__':
    # Validate configuration
    ensure_directories_exist()
    app.run(host='0.0.0.0', port=5000) 