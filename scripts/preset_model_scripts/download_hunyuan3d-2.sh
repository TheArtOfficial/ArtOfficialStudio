#!/bin/bash
# Model: Hunyuan3D-2
# Requires-HF-Token: false
# Model-URL: https://github.com/Tencent-Hunyuan/Hunyuan3D-2

echo "Downloading files from HuggingFace repository Kijai/Hunyuan3D-2_safetensors..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download hunyuan3d-dit-v2-0-fp16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "hunyuan3d-dit-v2-0-fp16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/Hunyuan3D-2_safetensors/resolve/main/hunyuan3d-dit-v2-0-fp16.safetensors"

echo "All downloads completed!"