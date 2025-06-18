#!/bin/bash
# Model: VACE 14B GGUF
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/QuantStack/Wan2.1_14B_VACE-GGUF

echo "Downloading files from HuggingFace repository QuantStack/Wan2.1_14B_VACE-GGUF..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models/unet"

# Download Wan2.1_14B_VACE-Q4_K_M.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "Wan2.1_14B_VACE-Q4_K_M.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/QuantStack/Wan2.1_14B_VACE-GGUF/resolve/main/Wan2.1_14B_VACE-Q4_K_M.gguf"

# Download Wan2.1_14B_VACE-Q5_K_M.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "Wan2.1_14B_VACE-Q5_K_M.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/QuantStack/Wan2.1_14B_VACE-GGUF/resolve/main/Wan2.1_14B_VACE-Q5_K_M.gguf"

# Download Wan2.1_14B_VACE-Q4_0.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "Wan2.1_14B_VACE-Q4_0.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/QuantStack/Wan2.1_14B_VACE-GGUF/resolve/main/Wan2.1_14B_VACE-Q4_0.gguf"

# Download Wan2.1_14B_VACE-Q5_0.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "Wan2.1_14B_VACE-Q5_0.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/QuantStack/Wan2.1_14B_VACE-GGUF/resolve/main/Wan2.1_14B_VACE-Q5_0.gguf"

# Download Wan2.1_14B_VACE-Q8_0.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "Wan2.1_14B_VACE-Q8_0.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/QuantStack/Wan2.1_14B_VACE-GGUF/resolve/main/Wan2.1_14B_VACE-Q8_0.gguf"


echo "All downloads completed!"