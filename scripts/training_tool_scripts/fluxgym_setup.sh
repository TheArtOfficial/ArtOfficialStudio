#!/bin/bash
# Tool: FluxGym
# Description: (Install Flux from Model Downloader) Training tool for Flux Loras with advanced features and optimizations

# Create workspace directory if it doesn't exist
cd /workspace

# Set up FluxGym
echo "Setting up FluxGym..."
CUDA_VERSION=$(nvcc --version | grep -oP "release \K[0-9]+\.[0-9]+")
echo "CUDA Version: $CUDA_VERSION"

if [  ! -d "/workspace/fluxgym" ]; then
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
    elif [[ "$CUDA_VERSION" == "12.5" ]]; then
        TORCH_INDEX_URL="https://download.pytorch.org/whl/cu125"
    elif [[ "$CUDA_VERSION" == "12.4" ]]; then
        TORCH_INDEX_URL="https://download.pytorch.org/whl/cu124"
    else
        TORCH_INDEX_URL="https://download.pytorch.org/whl/cu128"
    fi
    pip install torch torchvision torchaudio --index-url $TORCH_INDEX_URL
    pip install -r requirements.txt
    pip install accelerate
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
    echo "modifying model paths"
    sed -i 's#model_folder = "models/unet"#model_folder = "/workspace/ComfyUI/models/diffusion_models"#' app.py
    sed -i 's#models/clip/clip_l.safetensors#/workspace/ComfyUI/models/text_encoders/clip_l.safetensors#' app.py
    sed -i 's#models/clip/t5xxl_fp16.safetensors#/workspace/ComfyUI/models/text_encoders/t5xxl_fp16.safetensors#' app.py
    sed -i 's#models/vae/ae.sft#/workspace/ComfyUI/models/vae/flux_vae.safetensors#' app.py
    sed -i 's#flux1-dev.sft#flux1-dev.safetensors#' models.yaml
    sed -i 's#models/unet#/workspace/ComfyUI/models/diffusion_models#g' app.py
    sed -i 's#"models/vae"#"/workspace/ComfyUI/models/vae"#g' app.py
    sed -i 's#ae.sft#flux_vae.safetensors#g' app.py
    sed -i 's#models/clip#/workspace/ComfyUI/models/text_encoders#g' app.py

    # Modify the start_training function to use the virtual environment
    echo "Modifying start_training function to use virtual environment"
    # Create a new file with a simpler approach that doesn't rely on complex regex and escaping
cat > fix_command.py << 'EOF'
import re

with open('app.py', 'r') as file:
    lines = file.readlines()

# Check if already modified
if any("bash -c" in line for line in lines):
    print("File already modified, skipping.")
else:
    # Find the start_training function
    for i, line in enumerate(lines):
        if "def start_training(" in line:
            start_idx = i
        # Look for the command = line after finding the function
        if 'command = f"bash' in line and i > start_idx:
            # Replace with our new command that uses the virtual environment
            lines[i] = '        command = f"bash -c \'source /workspace/fluxgym/fluxgym_venv/bin/activate && bash {sh_filepath} && deactivate\'"\n'
            print(f"Modified line {i+1}")
            break

    # Write back to the file
    with open('app.py', 'w') as file:
        file.writelines(lines)
    print("Successfully modified app.py")
EOF
    python3 fix_command.py
    rm fix_command.py
fi

echo "Starting FluxGym..."
cd /workspace/fluxgym && ./fluxgym_venv/bin/python app.py
echo "FluxGym setup complete."