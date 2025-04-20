#!/bin/bash
# Model: Stable Diffusion 1.5 (SD1.5)

echo "Downloading files from HuggingFace repository stable-diffusion-v1-5/stable-diffusion-v1-5..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download v1-5-pruned.ckpt
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/checkpoints" \
    -o "v1-5-pruned.ckpt" \
    "https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5/resolve/main/v1-5-pruned.ckpt"
