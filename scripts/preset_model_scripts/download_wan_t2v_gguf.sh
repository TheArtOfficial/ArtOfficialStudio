#!/bin/bash
# Model: Wan2.1 T2V 14B GGUF
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/city96/Wan2.1-T2V-14B-gguf

echo "Downloading files from HuggingFace repository city96/Wan2.1-T2V-14B-gguf..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download wan2.1-t2v-14b-Q3_K_M.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "wan2.1-t2v-14b-Q3_K_M.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/city96/Wan2.1-T2V-14B-gguf/resolve/main/wan2.1-t2v-14b-Q3_K_M.gguf"

# Download wan2.1-t2v-14b-Q4_K_M.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "wan2.1-t2v-14b-Q4_K_M.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/city96/Wan2.1-T2V-14B-gguf/resolve/main/wan2.1-t2v-14b-Q4_K_M.gguf"

# Download wan2.1-t2v-14b-Q5_K_M.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "wan2.1-t2v-14b-Q5_K_M.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/city96/Wan2.1-T2V-14B-gguf/resolve/main/wan2.1-t2v-14b-Q5_K_M.gguf"

    # Download wan2.1-t2v-14b-Q4_0.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "wan2.1-t2v-14b-Q4_0.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/city96/Wan2.1-T2V-14B-gguf/resolve/main/wan2.1-t2v-14b-Q4_0.gguf"

# Download wan2.1-t2v-14b-Q5_0.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "wan2.1-t2v-14b-Q5_0.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/city96/Wan2.1-T2V-14B-gguf/resolve/main/wan2.1-t2v-14b-Q5_0.gguf"

# Download wan2.1-t2v-14b-Q8_0.gguf
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/unet" \
    -o "wan2.1-t2v-14b-Q8_0.gguf" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/city96/Wan2.1-T2V-14B-gguf/resolve/main/wan2.1-t2v-14b-Q8_0.gguf"


echo "All downloads completed!"