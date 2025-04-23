#!/bin/bash
# Tool: Diffusion Pipe
# Description: Training tool for Wan, Hidream, Hunyuan, and LTX Loras

# Set up diffusion-pipe-ui
echo "Setting up diffusion-pipe-ui..."
cd /workspace
git clone --recurse-submodules https://github.com/tdrussell/diffusion-pipe.git
cd diffusion-pipe
mv /gradio_interface.py /workspace/diffusion-pipe/gradio_interface.py
python3.12 -m venv diffpipe_venv
./diffpipe_venv/bin/pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128
./diffpipe_venv/bin/pip install packaging wheel setuptools
sed -i '/^torch$/d' requirements.txt
sed -i '/^torchaudio$/d' requirements.txt
sed -i '/^torchvision$/d' requirements.txt
wget -c https://huggingface.co/TheArtOfficialTrainer/cu128Torch128whls/resolve/main/flash_attn-2.7.4.post1-cp312-cp312-linux_x86_64.whl
./diffpipe_venv/bin/pip install flash_attn-2.7.4.post1-cp312-cp312-linux_x86_64.whl
./diffpipe_venv/bin/pip install -r requirements.txt
./diffpipe_venv/bin/pip install gradio
# Start Diffusion Pipe UI
echo "Starting Diffusion Pipe UI..."
cd /workspace/diffusion-pipe && ./diffpipe_venv/bin/python gradio_interface.py