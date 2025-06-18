#!/bin/bash
# Model: Chroma
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/lodestones/Chroma

echo "Downloading files from HuggingFace repository lodestones/Chroma..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download chroma-unlocked-v35-detail-calibrated.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "chroma-unlocked-v35-detail-calibrated.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/lodestones/Chroma/resolve/main/chroma-unlocked-v35-detail-calibrated.safetensors"

# Download chroma-unlocked-v35.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "chroma-unlocked-v35.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/lodestones/Chroma/resolve/main/chroma-unlocked-v35.safetensors"

# Download t5xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "t5xxl_fp8_e4m3fn_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors"

# Download t5xxl_fp16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "t5xxl_fp16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"

# Download ae.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "chroma_vae.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/lodestones/Chroma/resolve/main/ae.safetensors"


echo "All downloads completed!"