#!/bin/bash
# Model: Phantom 14B GGUF
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/QuantStack/Phantom_Wan_14B-GGUF

echo "Downloading files from HuggingFace repository QuantStack/Phantom_Wan_14B-GGUF..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models/unet"

# Download Phantom_Wan_14B-Q3_K_M.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "Phantom_Wan_14B-Q3_K_M.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/QuantStack/Phantom_Wan_14B-GGUF/resolve/main/Phantom_Wan_14B-Q3_K_M.gguf"

# Download Phantom_Wan_14B-Q4_K_M.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "Phantom_Wan_14B-Q4_K_M.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/QuantStack/Phantom_Wan_14B-GGUF/resolve/main/Phantom_Wan_14B-Q4_K_M.gguf"

# Download Phantom_Wan_14B-Q5_K_M.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "Phantom_Wan_14B-Q5_K_M.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/QuantStack/Phantom_Wan_14B-GGUF/resolve/main/Phantom_Wan_14B-Q5_K_M.gguf"

# Download Phantom_Wan_14B-Q4_0.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "Phantom_Wan_14B-Q4_0.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/QuantStack/Phantom_Wan_14B-GGUF/resolve/main/Phantom_Wan_14B-Q4_0.gguf"

# Download Phantom_Wan_14B-Q5_0.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "Phantom_Wan_14B-Q5_0.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/QuantStack/Phantom_Wan_14B-GGUF/resolve/main/Phantom_Wan_14B-Q5_0.gguf"

# Download Phantom_Wan_14B-Q8_0.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "Phantom_Wan_14B-Q8_0.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/QuantStack/Phantom_Wan_14B-GGUF/resolve/main/Phantom_Wan_14B-Q8_0.gguf"

echo "All downloads completed!"