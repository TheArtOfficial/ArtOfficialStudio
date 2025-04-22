#!/bin/bash
# Tool: Kohya_SS
# Description: Trianing Tool for SD15, SDXL, SD3, and Flux Loras

echo "Setting up kohya_ss..."
cd /workspace
git clone --recursive https://github.com/bmaltais/kohya_ss.git
cd kohya_ss
setup.sh
./venv/bin/pip install --force-reinstall --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128
./venv/bin/python kohya_gui.py --listen 0.0.0.0 --server_port 6000 --inbrowser --share