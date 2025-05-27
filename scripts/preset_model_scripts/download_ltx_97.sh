#!/bin/bash
# Model: LTX Video 0.9.7
# Requires-HF-Token: false
# Model-URL: https://github.com/Lightricks/ComfyUI-LTXVideo

echo "Downloading files from HuggingFace repository Lightricks/LTX-Video..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download ltxv-13b-0.9.7-dev.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/checkpoints" \
    -o "ltxv-13b-0.9.7-dev.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltxv-13b-0.9.7-dev.safetensors"

# Download ltxv-13b-0.9.7-dev.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/checkpoints" \
    -o "ltxv-13b-0.9.7-dev-fp8.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltxv-13b-0.9.7-dev-fp8.safetensors"

# Download ltxv-spatial-upscaler-0.9.7.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/checkpoints" \
    -o "ltxv-spatial-upscaler-0.9.7.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltxv-spatial-upscaler-0.9.7.safetensors"

# Download ltxv-temporal-upscaler-0.9.7.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/checkpoints" \
    -o "ltxv-temporal-upscaler-0.9.7.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltxv-temporal-upscaler-0.9.7.safetensors"

# Download vae/diffusion_pytorch_model.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "ltx_vae.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Lightricks/LTX-Video/resolve/main/vae/diffusion_pytorch_model.safetensors"

# Download t5xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "t5xxl_fp8_e4m3fn_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors"

# Download t5xxl_fp16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "t5xxl_fp16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"


echo "All downloads completed!"