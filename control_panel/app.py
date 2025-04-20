#!/usr/bin/env python3
"""
RunPod Control Panel

A web-based control panel for managing model downloads and tools for RunPod instances.
Supports Flux, CivitAI, and direct script-based model downloads.
"""

import os
import re
import glob
import subprocess
import threading
import json
from pathlib import Path

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

# Process tracking
flux_current_process = None
civitai_current_process = None
model_current_process = None

# -------------------------------------------------------------------------
# Helper Functions
# -------------------------------------------------------------------------

def ensure_directories_exist():
    """
    Ensure all required directories for model downloads exist.
    Creates directories if they don't exist.
    """
    os.system('mkdir -p "/workspace/ComfyUI/models/diffusion_models" "/workspace/ComfyUI/models/vae" "workspace/ComfyUI/models/text_encoders"')

def get_flux_script_path():
    """Get the path to the Flux download script."""
    return SCRIPTS_PATH / "download_flux_models.sh"

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

def run_flux_download(token):
    global flux_download_status, flux_current_process
    try:
        flux_download_status["status"] = "downloading"
        flux_download_status["message"] = "Starting download..."
        flux_download_status["progress"] = 0
        
        print(f"DEBUG: Starting Flux download with token: {token[:4]}...")
        
        # Run the download script with unbuffered output
        script_path = get_flux_script_path()
        command = f"stdbuf -oL {script_path} {token}"
        
        flux_current_process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            shell=True,
            bufsize=1,
            cwd=str(BASE_PATH),
            env=dict(os.environ, PYTHONUNBUFFERED="1")
        )
        
        print(f"DEBUG: Started Flux download with PID: {flux_current_process.pid}")
        
        # Read output line by line
        for line in iter(flux_current_process.stdout.readline, ''):
            if not line.strip():
                continue
                
            print(f"DEBUG: Flux output: {line.strip()}")
            
            # Try to parse download progress
            downloaded, total, percent, speed, eta = parse_aria2c_output(line.strip())
            if downloaded and total and percent is not None:
                flux_download_status.update({
                    "downloaded": downloaded,
                    "total": total,
                    "progress": percent,
                    "speed": speed + "/s",
                    "eta": eta
                })
                
                # Update message based on content
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
                flux_download_status["message"] = line.strip()
        
        # Wait for process to complete
        return_code = flux_current_process.wait()
        print(f"DEBUG: Flux download completed with return code: {return_code}")
        
        if return_code == 0:
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
        print(f"DEBUG: Error in run_flux_download: {e}")
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


def run_aria2c_command(cmd, status_dict, filename, display_name, file_index=None, total_files=None):
    """
    Run an aria2c command and process its output.
    
    Args:
        cmd: The aria2c command to run
        status_dict: The status dictionary to update
        filename: The name of the file being downloaded
        display_name: The display name of the model
        file_index: The index of the current file (optional)
        total_files: The total number of files to download (optional)
    
    Returns:
        int: The return code of the aria2c process
    """
    global model_current_process
    
    print(f"DEBUG: Starting aria2c command for {filename}")
    
    # Update status message
    if file_index is not None and total_files is not None:
        status_dict["message"] = f"Downloading {filename} for {display_name}... ({file_index}/{total_files})"
    else:
        status_dict["message"] = f"Downloading {filename}..."
    
    try:
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
            env=dict(os.environ, PYTHONUNBUFFERED="1")  # Add unbuffered env var
        )
        print(f"DEBUG: Process started with PID: {model_current_process.pid}")
        
        # Alternative approach - read line by line instead of char by char
        for line in iter(model_current_process.stdout.readline, ''):
            print(f"DEBUG: Got line: {line.strip()}")
            if line.strip():
                process_aria2c_line(line.strip(), status_dict, filename, display_name, file_index, total_files)
        
        # Wait for process to complete
        return_code = model_current_process.wait()
        print(f"DEBUG: Process completed with return code {return_code}")
        return return_code
        
    except Exception as e:
        print(f"DEBUG: Error in run_aria2c_command: {e}")
        if model_current_process:
            try:
                model_current_process.kill()
            except:
                pass
        raise


def run_model_download(script_path, script_name, display_name):
    """
    Run a model download script, tracking progress and updating status.
    
    Args:
        script_path: Path to the download script
        script_name: Name of the script (used for status tracking)
        display_name: Human-readable name of the model
    """
    global model_download_status, model_current_process
    
    print(f"DEBUG: Starting download for {display_name} using {script_path}")
    
    try:
        # Initialize download status
        update_download_status(
            model_download_status,
            status="downloading",
            message=f"Starting download for {display_name}...",
            progress=0,
            script_name=script_name,
            display_name=display_name
        )
        
        # Ensure directories exist
        ensure_directories_exist()
        
        # Extract aria2c commands from the script
        commands = extract_aria2c_commands(script_path)
        
        # Handle case when no aria2c commands are found
        if not commands:
            print(f"DEBUG: No aria2c commands found, falling back to direct script execution")
            # Fall back to running the script directly
            return run_script_fallback(script_path, display_name)
                
        # Process each aria2c command individually for better progress tracking
        total_commands = len(commands)
        print(f"DEBUG: Processing {total_commands} commands")
        
        for i, cmd in enumerate(commands):
            # Get current file index and extract filename
            file_index = i + 1
            filename = extract_filename_from_command(cmd) or f"file {file_index} of {total_commands}"
            print(f"DEBUG: Processing command {file_index}/{total_commands} for file: {filename}")
            
            # Run the command and process its output
            try:
                returncode = run_aria2c_command(
                    cmd, 
                    model_download_status, 
                    filename, 
                    display_name, 
                    file_index, 
                    total_commands
                )
                print(f"DEBUG: Command completed with return code: {returncode}")
            except Exception as e:
                print(f"DEBUG: Exception in run_aria2c_command: {e}")
                raise
            
            # Check if the command succeeded
            if returncode != 0:
                print(f"DEBUG: Command failed with code {returncode}")
                update_download_status(
                    model_download_status,
                    status="error",
                    message=f"Error downloading {filename} for {display_name}.",
                    progress=(i * 100) // total_commands
                )
                return
            
            # Update overall progress based on completed commands
            update_download_status(
                model_download_status,
                progress=((i + 1) * 100) // total_commands
            )
        
        # All commands completed successfully
        print("DEBUG: All commands completed successfully")
        update_download_status(
            model_download_status,
            status="completed",
            message=f"All downloads completed successfully for {display_name}!",
            progress=100
        )
    
    except Exception as e:
        print(f"DEBUG: Error in run_model_download: {e}")
        update_download_status(
            model_download_status,
            status="error",
            message=f"Error: {str(e)}"
        )
    finally:
        print("DEBUG: Finished run_model_download")
        model_current_process = None


def run_script_fallback(script_path, display_name):
    """
    Fallback method to run a script directly when no aria2c commands are found.
    
    Args:
        script_path: Path to the script to run
        display_name: Human-readable name of the model
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
            env=dict(os.environ, PYTHONUNBUFFERED="1")
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

class LoraTrainingForm(FlaskForm):
    tool = SelectField('Select Training Tool', choices=[
        ('flux_gym', 'Flux Gym (for Flux Loras)'),
        ('diffusion_pipe', 'Diffusion Pipe (for Wan, Hidream, Hunyuan, and LTX Loras)')
    ])
    submit = SubmitField('Install')

class HuggingFaceForm(FlaskForm):
    model_url = StringField('HuggingFace Model URL', validators=[DataRequired(), URL()])
    token = StringField('HuggingFace API Token (optional)')
    download_path = StringField('Download Path (optional)')
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
    download_scripts = glob.glob('/scripts/preset_model_scripts/download_*.sh')
    #download_scripts = glob.glob('/scripts/preset_model_scripts/download_*.sh')
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
    
    # Try different possible paths for the script
    possible_paths = [
        f'/scripts/preset_model_scripts/download_{script_name}.sh',  # Original path
        f'/scripts/download_{script_name}.sh'                        # Alternative path
    ]
    #possible_paths = [
    #    f'/scripts/preset_model_scripts/download_{script_name}.sh',  # Original path
    #    f'/scripts/download_{script_name}.sh'                        # Alternative path
    #]
    
    script_path = None
    for path in possible_paths:
        if os.path.exists(path):
            script_path = path
            break
    
    if not script_path:
        return jsonify({'status': 'error', 'message': f'Script not found for {script_name}'}), 404
    
    # Get display name
    display_name = parse_script_header(script_path)
    
    # Reset download status
    model_download_status.update({
        "status": "idle",
        "message": "Initializing download...",
        "script_name": script_name,
        "display_name": display_name
    })
    
    # Start download in a background thread
    thread = threading.Thread(target=run_model_download, args=(script_path, script_name, display_name))
    thread.daemon = True
    thread.start()
    
    return jsonify({'status': 'success', 'message': f'Started downloading {display_name}'})

@app.route('/download_huggingface', methods=['POST'])
def download_huggingface():
    model_url = request.form.get('model_url')
    token = request.form.get('token')
    download_path = request.form.get('download_path')
    
    try:
        model_id = model_url.split('/')[-1]
        subprocess.run(['python3', '-m', 'pip', 'install', 'huggingface_hub'])
        
        # Create Python command with appropriate parameters
        cmd_parts = [
            'from huggingface_hub import snapshot_download;',
            f'snapshot_download(repo_id="{model_id}"'
        ]
        
        # Add token if provided
        if token:
            cmd_parts.append(f', token="{token}"')
        
        # Add local_dir parameter if download_path is provided
        if download_path and download_path.strip():
            cmd_parts.append(f', local_dir="{download_path.strip()}"')
            output_msg = f'Downloaded {model_id} to {download_path.strip()}'
        else:
            output_msg = f'Downloaded {model_id} to default location'
        
        # Close the function call
        cmd_parts.append(')')
        
        # Join the parts to create the final command
        python_cmd = ' '.join(cmd_parts)
        
        print(f"DEBUG: Running command: {python_cmd}")
        subprocess.run(['python3', '-c', python_cmd])
        return jsonify({'status': 'success', 'message': output_msg})
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

@app.route('/stop_model_download', methods=['POST'])
def stop_model_download():
    global model_current_process
    if model_current_process:
        try:
            model_current_process.terminate()
            model_current_process.wait(timeout=5)
        except:
            model_current_process.kill()
        finally:
            model_current_process = None
            model_download_status.update({
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

@app.route('/model_status')
def model_status():
    """
    Return the current status of model downloads.
    This endpoint is polled by the frontend to update progress.
    """
    # Add some minimal logging
    print(f"STATUS UPDATE: {model_download_status.get('status')}, Progress: {model_download_status.get('progress')}%, Message: {model_download_status.get('message')}")
    return jsonify(model_download_status)

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