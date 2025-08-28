#!/bin/bash
# Tool: Diffusion Pipe
# Description: Training tool for Wan, Hidream, Hunyuan, and LTX Loras

# Set up diffusion-pipe-ui
echo "Setting up diffusion-pipe-ui..."
CUDA_VERSION=$(nvcc --version | grep -oP "release \K[0-9]+\.[0-9]+")
echo "CUDA Version: $CUDA_VERSION"
cd /workspace

if [ ! -d "/workspace/diffusion-pipe" ]; then
    git clone --recurse-submodules https://github.com/tdrussell/diffusion-pipe.git
    cd diffusion-pipe
    git fetch origin
    git reset --hard origin/main
    git submodule foreach --recursive git fetch origin
    git submodule foreach --recursive git reset --hard
    mv /gradio_interface.py /workspace/diffusion-pipe/gradio_interface.py
else
    cd diffusion-pipe
fi
if [ ! -d "/workspace/diffusion-pipe/diffpipe_venv" ]; then
    python3.12 -m venv diffpipe_venv
    source diffpipe_venv/bin/activate
    # Set appropriate PyTorch index URL
    if [[ "$CUDA_VERSION" == "12.8" ]]; then
        TORCH_INDEX_URL="https://download.pytorch.org/whl/cu128"
    elif [[ "$CUDA_VERSION" == "12.6" ]]; then
        TORCH_INDEX_URL="https://download.pytorch.org/whl/cu126"
    elif [[ "$CUDA_VERSION" == "12.5" ]]; then
        TORCH_INDEX_URL="https://download.pytorch.org/whl/cu125"
    elif [[ "$CUDA_VERSION" == "12.4" ]]; then
        TORCH_INDEX_URL="https://download.pytorch.org/whl/cu124"
    else
        TORCH_INDEX_URL="https://download.pytorch.org/whl/cu128"
    fi
    ./diffpipe_venv/bin/pip install torch==2.7.1 torchvision torchaudio --index-url $TORCH_INDEX_URL
    ./diffpipe_venv/bin/pip install packaging wheel setuptools
    sed -i '/^torch$/d' requirements.txt
    sed -i '/^torchaudio$/d' requirements.txt
    sed -i '/^torchvision$/d' requirements.txt
    python -m pip install https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.3.13/flash_attn-2.8.1+cu128torch2.7-cp312-cp312-linux_x86_64.whl
    ./diffpipe_venv/bin/pip install -r requirements.txt
    ./diffpipe_venv/bin/pip install gradio toml
    deactivate
fi
# Start Diffusion Pipe UI
echo "Starting Diffusion Pipe UI..."
cd /workspace/diffusion-pipe && ./diffpipe_venv/bin/python gradio_interface.py