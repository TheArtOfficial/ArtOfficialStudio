#!/bin/bash

echo "Starting post-installation setup..."

# Create workspace directory if it doesn't exist
cd /workspace

# Set up ComfyUI
echo "Setting up ComfyUI..."
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
python3.12 -m venv comfyui_venv
./comfyui_venv/bin/python -m pip install --upgrade pip
./comfyui_venv/bin/pip install -r requirements.txt -q 

# Create model directories
echo "Creating model directories..."
mkdir -p models/diffusion_models
mkdir -p models/checkpoints
mkdir -p models/vae
mkdir -p models/controlnet
mkdir -p models/loras
mkdir -p models/clip_vision
mkdir -p models/text_encoders

# Set up directory structure
echo "Setting up directory structure..."
rm -rf /workspace/ComfyUI/user/default/workflows
mkdir -p /workspace/ComfyUI/user/default/workflows
mv /workspace/workflows/* /workspace/ComfyUI/user/default/workflows

# Install ComfyUI nodes
echo "Installing ComfyUI custom nodes..."
cd /workspace/ComfyUI/custom_nodes

# ComfyUI Manager
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ComfyUI-Manager
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -q
cd ..

# KJNodes
git clone https://github.com/kijai/ComfyUI-KJNodes.git
cd ComfyUI-KJNodes
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -q
cd ..

# Crystools
git clone https://github.com/crystian/ComfyUI-Crystools.git
cd ComfyUI-Crystools
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -q
cd ..

# VideoHelperSuite
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
cd ComfyUI-VideoHelperSuite
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -q
cd ..

# Segment Anything 2
git clone https://github.com/kijai/ComfyUI-Segment-Anything-2.git

# Florence2
git clone https://github.com/kijai/ComfyUI-Florence2.git
cd ComfyUI-Florence2
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -q
cd ..

# WanVideoWrapper
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
cd ComfyUI-WanVideoWrapper
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -q
cd ..

# HunyuanVideoWrapper
git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper.git
cd ComfyUI-HunyuanVideoWrapper
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -q
cd ..

# Easy-Use Nodes
git clone https://github.com/yolain/ComfyUI-Easy-Use.git
cd ComfyUI-Easy-Use
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -q
cd ..

# Impact Pack
git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
cd ComfyUI-Impact-Pack
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -q
cd ..

# LatentSync Wrapper
git clone https://github.com/ShmuelRonen/ComfyUI-LatentSyncWrapper.git
cd ComfyUI-LatentSyncWrapper
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -q
cd ..

# Fix onnxruntime for ComfyUI
cd /workspace/ComfyUI
./comfyui_venv/bin/pip uninstall -y onnxruntime
./comfyui_venv/bin/pip install onnxruntime-gpu=="1.19" sageattention -q

# Start ComfyUI
cd /workspace/ComfyUI && ./comfyui_venv/bin/python main.py --listen --port 8188 > comfy.log 2>&1 &

# Set up model downloaders
echo "Setting up model downloaders..."
cd /workspace/flux_model_downloader
python3.12 -m venv flask_venv
./flask_venv/bin/pip install flask gunicorn gevent -q
# Start Flux Model Downloader
cd /workspace/flux_model_downloader && ./flask_venv/bin/python app.py --port 5000 &

cd /workspace
mkdir -p civitai_model_downloader/templates
cd civitai_model_downloader
python3.12 -m venv civitai_venv
./civitai_venv/bin/pip install flask gunicorn gevent -q
# Start CivitAI Model Downloader
cd /workspace/civitai_model_downloader && ./civitai_venv/bin/python app.py --port 5001 &

# Set up FluxGym
echo "Setting up FluxGym..."
cd /workspace
git clone https://github.com/cocktailpeanut/fluxgym.git
cd fluxgym
python3.12 -m venv fluxgym_venv
./fluxgym_venv/bin/python -m pip install --upgrade pip
./fluxgym_venv/bin/pip install -r requirements.txt -q
./fluxgym_venv/bin/pip install library
# Start FluxGym
echo "Starting FluxGym..."
cd /workspace/fluxgym && ./fluxgym_venv/bin/python app.py --port 7000 &

# Set up diffusion-pipe-ui
echo "Setting up diffusion-pipe-ui..."
cd /workspace
git clone https://github.com/alisson-anjos/diffusion-pipe-ui.git
cd diffusion-pipe-ui
python3.12 -m venv diffusion_venv
./diffusion_venv/bin/pip install packaging wheel setuptools
./diffusion_venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
./diffusion_venv/bin/pip install --no-build-isolation flash-attn==2.7.4.post1
./diffusion_venv/bin/pip install -r requirements.txt -q
# Start Diffusion Pipe UI
echo "Starting Diffusion Pipe UI..."
cd /workspace/diffusion-pipe-ui && ./diffusion_venv/bin/python gradio_interface.py &

echo "Post-installation setup complete!"

# Run model download scripts
echo "Starting model downloads..."
/workspace/scripts/download_sdxl.sh 
/workspace/scripts/download_wan21.sh
/workspace/scripts/download_wan21_fun.sh
/workspace/scripts/download_wrapper_models.sh
/workspace/scripts/download_hunyuan.sh

sleep infinity