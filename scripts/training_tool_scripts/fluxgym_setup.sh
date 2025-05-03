#!/bin/bash
# Tool: FluxGym
# Description: (Intall flux from Model Downloader) Training tool for Flux Loras with advanced features and optimizations

# Create workspace directory if it doesn't exist
cd /workspace

# Set up FluxGym
echo "Setting up FluxGym..."
CUDA_VERSION=$(nvcc --version | grep -oP "release \K[0-9]+\.[0-9]+")
echo "CUDA Version: $CUDA_VERSION"
cd /workspace
git clone https://github.com/cocktailpeanut/fluxgym.git
cd fluxgym
python3.12 -m venv fluxgym_venv
source fluxgym_venv/bin/activate
python -m pip install --upgrade pip
git clone -b sd3 https://github.com/kohya-ss/sd-scripts.git
cd sd-scripts
echo "Installing sd-scripts dependencies..."
# Set appropriate PyTorch index URL
if [[ "$CUDA_VERSION" == "12.8" ]]; then
    TORCH_INDEX_URL="https://download.pytorch.org/whl/cu128"
elif [[ "$CUDA_VERSION" == "12.6" ]]; then
    TORCH_INDEX_URL="https://download.pytorch.org/whl/cu126"
elif [[ "$CUDA_VERSION" == "12.4" ]]; then
    TORCH_INDEX_URL="https://download.pytorch.org/whl/cu124"
else
    TORCH_INDEX_URL="https://download.pytorch.org/whl/cu128"
fi
pip install -r requirements.txt --extra-index-url $TORCH_INDEX_URL
cd ..
echo "Installing FluxGym dependencies..."
sed -i '/^torch$/d' requirements.txt
sed -i '/^torchvision$/d' requirements.txt
sed -i '/^torchaudio$/d' requirements.txt
pip install -r requirements.txt --extra-index-url $TORCH_INDEX_URL
pip install -U bitsandbytes
pip install --upgrade --force-reinstall triton==2.2.0
deactivate
# Start FluxGym
echo "modifying gradio port"
sed -i 's/demo\.launch(debug=True, show_error=True, allowed_paths=\[cwd\])/demo.launch(debug=True, root_path="\/fluxgym", show_error=True, allowed_paths=\[cwd\], server_port=6000, server_name="0.0.0.0")/' app.py
echo "Starting FluxGym..."
cd /workspace/fluxgym && ./fluxgym_venv/bin/python app.py
echo "FluxGym setup complete."