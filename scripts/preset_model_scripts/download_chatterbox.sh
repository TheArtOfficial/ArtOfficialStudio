#!/bin/bash
# Model: ChatterBox
# Requires-HF-Token: false

echo "Downloading files from HuggingFace repository ResembleAI/chatterbox..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models/chatterbox"

# Download s3gen.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/chatterbox" \
    -o "s3gen.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/ResembleAI/chatterbox/resolve/main/s3gen.safetensors"

# Download t3_cfg.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/chatterbox" \
    -o "t3_cfg.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/ResembleAI/chatterbox/resolve/main/t3_cfg.safetensors"

# Download ve.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/chatterbox" \
    -o "ve.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/ResembleAI/chatterbox/resolve/main/ve.safetensors"

echo "All downloads completed!"