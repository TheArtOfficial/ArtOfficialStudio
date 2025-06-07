#!/bin/bash
# Model: Wan Reward LoRAs
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/alibaba-pai/Wan2.1-Fun-Reward-LoRAs

echo "Downloading files from HuggingFace repository alibaba-pai/Wan2.1-Fun-Reward-LoRAs..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download Wan2.1-Fun-1.3B-InP-HPS2.1.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Wan2.1-Fun-1.3B-InP-HPS2.1.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/Wan2.1-Fun-Reward-LoRAs/resolve/main/Wan2.1-Fun-1.3B-InP-HPS2.1.safetensors"

# Download Wan2.1-Fun-1.3B-InP-MPS.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Wan2.1-Fun-1.3B-InP-MPS.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/Wan2.1-Fun-Reward-LoRAs/resolve/main/Wan2.1-Fun-1.3B-InP-MPS.safetensors"

# Download Wan2.1-Fun-14B-InP-HPS2.1.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Wan2.1-Fun-14B-InP-HPS2.1.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/Wan2.1-Fun-Reward-LoRAs/resolve/main/Wan2.1-Fun-14B-InP-HPS2.1.safetensors"

# Download Wan2.1-Fun-14B-InP-MPS.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Wan2.1-Fun-14B-InP-MPS.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/Wan2.1-Fun-Reward-LoRAs/resolve/main/Wan2.1-Fun-14B-InP-MPS.safetensors"

echo "All downloads completed!"