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
LOCAL_DEV = os.environ.get('LOCAL_DEV', 'false').lower() == 'true'

# Directory paths - adjust based on environment
if LOCAL_DEV:
    BASE_PATH = Path("/workspace/ComfyUI/models")
    SCRIPTS_PATH = Path("/scripts")
else:
    BASE_PATH = Path("/workspace/ComfyUI/models")
    SCRIPTS_PATH = Path("/scripts")

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
            for line in f:
                line = line.strip()
                
                # Skip if not an aria2c command
                if not line.startswith('aria2c'):
                    continue
                    
                # Extract the command (may span multiple lines)
                cmd = line
                if line.endswith('\\'):
                    cmd = line[:-1]  # Remove trailing backslash
                    
                    # Read continuation lines
                    for cont_line in f:
                        cont_line = cont_line.strip()
                        if cont_line.endswith('\\'):
                            cmd += ' ' + cont_line[:-1]
                        else:
                            cmd += ' ' + cont_line
                            break
                            
                commands.append(cmd)
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
    # Check if the command is not a string
    if not isinstance(cmd, str):
        return None
        
    # Look for -o or --out parameters
    output_match = re.search(r'(?:--out=|\s-o\s+)["\'](.*?)["\']', cmd)
    if output_match:
        return output_match.group(1)
    
    # Try to extract filename from the URL in the command
    url_match = re.search(r'https?://[^\s"\']+', cmd)
    if not url_match:
        return None
    
    url = url_match.group(0)
    filename_match = re.search(r'/([^/]+)$', url)
    if filename_match:
        return filename_match.group(1)
    
    # Extract based on directory and output pattern
    filename_start = cmd.find('"/workspace/ComfyUI/models/')
    if filename_start == -1:
        return None
    
    filename_end = cmd.find('"', filename_start + 1)
    if filename_end == -1:
        return None
    
    return cmd[filename_start:filename_end]

def update_download_status(status_dict, **kwargs):
    """
    Update a download status dictionary with new values.
    
    Args:
        status_dict: The status dictionary to update
        **kwargs: Key-value pairs to update in the dictionary
    """
    status_dict.update(kwargs)


def process_aria2c_line(line, status_dict, filename, display_name, file_index=None, total_files=None):
    """
    Process a line of aria2c output and update the status dictionary.
    
    Args:
        line: The line of aria2c output to process
        status_dict: The status dictionary to update
        filename: The name of the file being downloaded
        display_name: The display name of the model
        file_index: The index of the current file (optional)
        total_files: The total number of files to download (optional)
    
    Returns:
        bool: True if the line contained download progress information, False otherwise
    """
    if not line:
        return False
        
    # Try to parse download progress information
    downloaded, total, percent, speed, eta = parse_aria2c_output(line)
    if downloaded and total and percent is not None:
        # Format the message based on whether we're tracking multiple files
        if file_index is not None and total_files is not None:
            message = f"Downloading {filename} for {display_name}... {percent}% ({file_index}/{total_files})"
        else:
            message = f"Downloading {filename}... {percent}%"
        
        # Update the status dictionary
        update_download_status(
            status_dict,
            downloaded=downloaded,
            total=total,
            progress=percent,
            speed=speed + "/s",
            eta=eta,
            message=message
        )
        return True
    
    # Handle other aria2c output that looks like status information
    if '[' in line and ']' in line:
        if file_index is not None and total_files is not None:
            message = f"{line} ({file_index}/{total_files})"
        else:
            message = line
        status_dict["message"] = message
        return True
        
    # Handle any other non-empty output
    if line.strip():
        if file_index is not None and total_files is not None:
            message = f"{line} ({file_index}/{total_files})"
        else:
            message = line
        status_dict["message"] = message
        return True
        
    return False


def run_aria2c_command(cmd, status_dict, filename, display_name, file_index=None, total_files=None, token=None):
    """Run an aria2c command and process its output."""
    global model_current_process
    
    print(f"DEBUG: Starting aria2c command for {filename}")
    
    # Update status message and ensure status is set to downloading
    status_dict["status"] = "downloading"  # Ensure status is set to downloading
    
    if file_index is not None and total_files is not None:
        status_dict["message"] = f"Downloading {filename} for {display_name}... ({file_index}/{total_files})"
    else:
        status_dict["message"] = f"Downloading {filename}..."
    
    try:
        # If token is provided, add the authorization header to aria2c
        if token:
            # Add --header option before the URL in the command
            cmd = cmd.replace('"https://', '--header="Authorization: Bearer ' + token + '" "https://')
        
        # Start the aria2c process - modify the command to include unbuffered output
        modified_cmd = f"stdbuf -oL {cmd}"  # Use stdbuf to disable output buffering
        print(f"DEBUG: Running command with unbuffered output: {modified_cmd[:80]}...")
        
        model_current_process = subprocess.Popen(
            modified_cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            shell=True,
            bufsize=1,  # Line buffered
            env=dict(os.environ, PYTHONUNBUFFERED="1"),  # Add unbuffered env var
            preexec_fn=os.setsid  # Create new process group
        )
        print(f"DEBUG: Process started with PID: {model_current_process.pid}")
        
        # Read output line by line
        for line in iter(model_current_process.stdout.readline, ''):
            print(f"DEBUG: Got line: {line.strip()}")
            if line.strip():
                process_aria2c_line(line.strip(), status_dict, filename, display_name, file_index, total_files)
        
        # Check if stderr has output (for debugging)
        stderr_output = model_current_process.stderr.read()
        if stderr_output:
            print(f"DEBUG: STDERR from aria2c: {stderr_output}")
        
        # Wait for process to complete
        return_code = model_current_process.wait()
        print(f"DEBUG: Process completed with return code {return_code}")
        return return_code
        
    except Exception as e:
        print(f"DEBUG: Error in run_aria2c_command: {e}")
        if model_current_process:
            try:
                pgid = os.getpgid(model_current_process.pid)
                os.killpg(pgid, signal.SIGTERM)
            except Exception as kill_ex:
                print(f"DEBUG: Error killing process: {kill_ex}")
        raise


def run_model_download(script_path, script_name, display_name, token=None):
    """
    Run a model download script, tracking progress and updating status.
    Uses the HuggingFace download method sequentially for each model.
    """
    global model_download_status, model_current_process
    
    try:
        # Initialize download status
        model_download_status.update({
            "status": "downloading",
            "message": f"Starting download for {display_name}...",
            "progress": 0,
            "downloaded": "0B",
            "total": "0B",
            "speed": "0B/s",
            "eta": "Unknown",
            "script_name": script_name,
            "display_name": display_name
        })
        
        # Ensure directories exist
        ensure_directories_exist()
        
        # Extract aria2c commands from the script
        commands = extract_aria2c_commands(script_path)
        if not commands:
            print(f"DEBUG: No aria2c commands found, falling back to direct script execution")
            env = os.environ.copy()
            if token:
                env['HF_TOKEN'] = token
            return run_script_fallback(script_path, display_name, env)
        
        # Run each command sequentially
        for i, cmd in enumerate(commands):
            if model_download_status.get('status') == 'stopped':
                return
                
            # Extract URL from the command
            url_match = re.search(r'https?://[^\s"\']+', cmd)
            if not url_match:
                print(f"DEBUG: No URL found in command: {cmd}")
                continue
                
            url = url_match.group(0)
            
            # Extract download path from the command
            path_match = re.search(r'-d\s+["\']([^"\']+)["\']', cmd)
            download_path = path_match.group(1) if path_match else None
            
            # Update status for current file
            model_download_status.update({
                "message": f"Downloading file {i+1}/{len(commands)} for {display_name}..."
            })
            
            # Run the download using the HuggingFace method
            success = run_huggingface_download(url, token, download_path)
            
            if not success:
                model_download_status.update({
                    "status": "error",
                    "message": f"Error downloading file {i+1}/{len(commands)} for {display_name}"
                })
                return
        
        # All files downloaded successfully
        model_download_status.update({
            "status": "completed",
            "message": f"Download completed successfully for {display_name}!",
            "progress": 100
        })
        
    except Exception as e:
        print(f"Error in run_model_download: {e}")
        model_download_status.update({
            "status": "error",
            "message": f"Error: {str(e)}"
        })
    finally:
        model_current_process = None


def run_script_fallback(script_path, display_name, env):
    """
    Fallback method to run a script directly when no aria2c commands are found.
    
    Args:
        script_path: Path to the script to run
        display_name: Human-readable name of the model
        env: Environment variables for the script
    """
    global model_download_status, model_current_process
    
    print(f"DEBUG: Running fallback script for {display_name}: {script_path}")
    
    try:
        # Add stdbuf to disable output buffering
        command = f"stdbuf -oL bash {script_path}"
        
        model_current_process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            shell=True,
            bufsize=1,
            env=env
        )
        
        print(f"DEBUG: Started fallback script with PID: {model_current_process.pid}")
        
        # Read output line by line
        for line in iter(model_current_process.stdout.readline, ''):
            if line.strip():
                print(f"DEBUG: Script output: {line.strip()}")
                model_download_status["message"] = line.strip()
        
        # Wait for process to complete
        return_code = model_current_process.wait()
        print(f"DEBUG: Script completed with return code: {return_code}")
        
        if return_code == 0:
            update_download_status(
                model_download_status,
                status="completed",
                message=f"Download completed successfully for {display_name}!",
                progress=100
            )
        else:
            update_download_status(
                model_download_status,
                status="error",
                message=f"Error during download of {display_name}. Please check the logs.",
                progress=0
            )
            
        return return_code
        
    except Exception as e:
        print(f"DEBUG: Error in run_script_fallback: {e}")
        update_download_status(
            model_download_status,
            status="error",
            message=f"Error: {str(e)}",
            progress=0
        )
        if model_current_process:
            try:
                model_current_process.kill()
            except:
                pass
        return 1

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
    download_scripts = glob.glob('scripts/preset_model_scripts/download_*.sh')
    script_info = []
    for script in download_scripts:
        script_name = os.path.basename(script).replace('download_', '').replace('.sh', '')
        model_info = parse_script_header(script)
        script_info.append({
            'id': script_name,  # Used for the download endpoint
            'name': model_info['name'],  # The display name from the header
            'description': model_info.get('description', ''),  # Optional description
            'requires_token': model_info.get('requires_token', False)  # Whether it needs a HF token
        })
    
    # Sort script_info alphabetically by name
    script_info.sort(key=lambda x: x['name'].lower())
    
    # Get available training tools
    training_tools = []
    training_scripts = glob.glob('/scripts/training_tool_scripts/*setup.sh')
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
                         download_scripts=script_info)

@app.route('/install_training_tool', methods=['POST'])
def install_training_tool():
    tool = request.form.get('tool')
    try:
        script_path = f'/scripts/training_tool_scripts/{tool}setup.sh'  # Updated to match actual filename pattern
        if not os.path.exists(script_path):
            return jsonify({'status': 'error', 'message': f'Setup script not found for {tool}'}), 404
            
        subprocess.run([script_path], check=True)
        return jsonify({'status': 'success', 'message': f'{tool} installed successfully'})
    except subprocess.CalledProcessError as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/run_download_script', methods=['POST'])
def run_download_script():
    script_names = json.loads(request.form.get('script_names', '[]'))
    token = request.form.get('token')
    
    if not script_names:
        return jsonify({'status': 'error', 'message': 'No models selected'}), 400
    
    # Get script info for all selected models
    model_infos = []
    for script_name in script_names:
        download_script = f'scripts/preset_model_scripts/download_{script_name}.sh'
        
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
    
    # Reset download status
    model_download_status.update({
        "status": "downloading",
        "message": "Initializing downloads...",
        "progress": 0,
        "downloaded": "0B",
        "total": "0B",
        "speed": "0B/s",
        "eta": "Unknown",
        "script_name": ", ".join(script_names),
        "display_name": ", ".join(info[2]['name'] for info in model_infos)
    })
    
    # Start downloads in a background thread
    thread = threading.Thread(
        target=run_model_downloads,
        args=(model_infos, token)
    )
    thread.daemon = True
    thread.start()
    
    return jsonify({
        'status': 'success',
        'message': f'Started downloading {len(script_names)} models'
    })

def run_model_downloads(model_infos, token=None):
    """
    Run multiple model downloads sequentially.
    
    Args:
        model_infos: List of tuples (script_path, script_name, model_info)
        token: Optional HuggingFace token
    """
    global model_download_status, model_current_process
    
    try:
        # Ensure directories exist
        ensure_directories_exist()
        
        for i, (script_path, script_name, model_info) in enumerate(model_infos):
            if model_download_status.get('status') == 'stopped':
                return
                
            # Update status for current model
            model_download_status.update({
                "status": "downloading",
                "message": f"Downloading {model_info['name']} ({i+1}/{len(model_infos)})...",
                "progress": 0,
                "downloaded": "0B",
                "total": "0B",
                "speed": "0B/s",
                "eta": "Unknown"
            })
            
            try:
                # Run the download
                success = run_model_download(script_path, script_name, model_info['name'], token)
                
                if not success:
                    model_download_status.update({
                        "status": "error",
                        "message": f"Error downloading {model_info['name']}"
                    })
                    return
            except Exception as e:
                print(f"Error downloading {model_info['name']}: {e}")
                model_download_status.update({
                    "status": "error",
                    "message": f"Error downloading {model_info['name']}: {str(e)}"
                })
                return
        
        # All models downloaded successfully
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
        model_current_process = None

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

if __name__ == '__main__':
    # Validate configuration
    ensure_directories_exist()
    app.run(host='0.0.0.0', port=5000) 