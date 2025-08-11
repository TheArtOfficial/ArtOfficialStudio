#!/bin/bash
# Model: Wan2.2-Fun Control A14B
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/alibaba-pai/Wan2.2-Fun-A14B-Control

echo "Downloading files from HuggingFace repository alibaba-pai/Wan2.1-Fun-V1.1-14B-Control..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download high_noise_model/diffusion_pytorch_model.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "high_wan2.2_fun_a14b_control.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/Wan2.2-Fun-A14B-Control/resolve/main/high_noise_model/diffusion_pytorch_model.safetensors"

# Download low_noise_model/diffusion_pytorch_model.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "low_wan2.2_fun_a14b_control.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/Wan2.2-Fun-A14B-Control/resolve/main/low_noise_model/diffusion_pytorch_model.safetensors"

# Download split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "native_umt5_xxl_fp8_e4m3fn_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

# Download split_files/vae/wan_2.1_vae.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "native_wan_2.1_vae.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

