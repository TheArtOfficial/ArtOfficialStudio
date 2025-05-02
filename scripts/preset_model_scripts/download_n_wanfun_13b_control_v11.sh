#!/bin/bash
# Model: WanFun Control v1.1 1.3B
# Requires-HF-Token: false
# Model-URL: https://github.com/aigc-apps/VideoX-Fun

echo "Downloading files from HuggingFace repository alibaba-pai/Wan2.1-Fun-V1.1-1.3B-Control..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download split_files/clip_vision/clip_vision_h.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/clip_vision" \
    -o "native_clip_vision_h.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"

# Download diffusion_pytorch_model.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "wan2.1_fun_control_v11_1.3B.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/Wan2.1-Fun-V1.1-1.3B-Control/resolve/main/diffusion_pytorch_model.safetensors"

# Download split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "native_umt5_xxl_fp8_e4m3fn_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

# Download split_files/vae/wan_2.1_vae.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "native_wan_2.1_vae.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"


echo "All downloads completed!"