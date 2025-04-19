from flask import Flask, render_template, request, jsonify
import os
import subprocess
import glob
import requests
from flask_wtf import FlaskForm
from wtforms import SelectField, StringField, SubmitField
from wtforms.validators import DataRequired, URL

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-here'  # Change this in production

class LoraTrainingForm(FlaskForm):
    tool = SelectField('Select Training Tool', choices=[
        ('flux_gym', 'Flux Gym (for Flux Loras)'),
        ('diffusion_pipe', 'Diffusion Pipe (for Wan, Hidream, Hunyuan, and LTX Loras)')
    ])
    submit = SubmitField('Install')

class HuggingFaceForm(FlaskForm):
    model_url = StringField('HuggingFace Model URL', validators=[DataRequired(), URL()])
    submit = SubmitField('Download')

@app.route('/')
def index():
    # Get available download scripts
    download_scripts = glob.glob('/scripts/download_*.sh')
    script_names = [os.path.basename(script).replace('download_', '').replace('.sh', '') for script in download_scripts]
    
    return render_template('index.html', 
                         lora_form=LoraTrainingForm(),
                         hf_form=HuggingFaceForm(),
                         download_scripts=script_names)

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
        # Extract model ID from URL
        model_id = model_url.split('/')[-1]
        # Use huggingface_hub to download
        subprocess.run(['python3', '-m', 'pip', 'install', 'huggingface_hub'])
        subprocess.run(['python3', '-c', f'from huggingface_hub import snapshot_download; snapshot_download(repo_id="{model_id}")'])
        return jsonify({'status': 'success', 'message': f'Downloaded {model_id}'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=1000) 