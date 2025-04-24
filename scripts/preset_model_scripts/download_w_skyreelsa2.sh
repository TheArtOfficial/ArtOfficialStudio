#!/bin/bash
# Model: Skyreels A2 Demo
# Requires-HF-Token: false
echo "Downloading VACE, Skyreels, and Recam models..."

# Download Skyreels model
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models \
    -o Wan2_1_SkyreelsA2_fp8_e4m3fn.safetensors --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_SkyreelsA2_fp8_e4m3fn.safetensors

# Download split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "native_umt5_xxl_fp8_e4m3fn_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

# Download split_files/vae/wan_2.1_vae.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "native_wan_2.1_vae.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"