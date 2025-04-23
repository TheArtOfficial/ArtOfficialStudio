#!/bin/bash
# Tool: Kohya_SS
# Description: SD15, SDXL, SD3, and Flux Loras (Clean Install, Untested)

echo "Setting up kohya_ss..."
cd /workspace || { echo "Failed to cd to /workspace"; exit 1; }
sudo add-apt-repository universe -y
sudo apt update
sudo apt install -y python3-tk
echo "Cloning kohya_ss repository..."
git clone --recursive https://github.com/bmaltais/kohya_ss.git || cd kohya_ss
cd kohya_ss
python3.10 -m venv venv
source venv/bin/activate

# Install packages one by one with error handling
echo "Installing PyTorch..."
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128 || { echo "Failed to install PyTorch"; exit 1; }

echo "Installing requirements..."
pip install -r requirements.txt

echo "Installing additional packages..."
pip install bitsandbytes==0.44.0
pip install tensorboard==2.15.2
pip install tensorflow==2.15.0.post1
pip install onnxruntime-gpu==1.19.2 

echo "Installing xformers..."
pip install --pre -U --no-deps xformers

echo "Updating bitsandbytes..."
pip install -U bitsandbytes

echo "Starting kohya_gui..."
python kohya_gui.py --listen 0.0.0.0 --server_port 6000 --inbrowser --share --noverify
echo "Kohya_SS setup complete."