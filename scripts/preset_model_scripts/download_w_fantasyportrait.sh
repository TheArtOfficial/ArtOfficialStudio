#!/bin/bash
# Model: FantasyPortrait
# Requires-HF-Token: false
# Model-URL: https://fantasy-amap.github.io/fantasy-portrait/

echo "Downloading files from HuggingFace repository Kijai/WanVideo_comfy..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download Wan2_1-Wan-I2V-MAGREF-14B_fp8_e4m3fn.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "Wan2_1-Wan-I2V-MAGREF-14B_fp8_e4m3fn.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1-Wan-I2V-MAGREF-14B_fp8_e4m3fn.safetensors"

    # Download split_files/diffusion_models/wan2.1_i2v_720p_14B_bf16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "wan2.1_i2v_720p_14B_fp16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_fp16.safetensors"

# Download Wan2_1_VAE_fp32.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "Wan2_1_VAE_fp32.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_fp32.safetensors"

    # Download split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "native_umt5_xxl_fp8_e4m3fn_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "Wan2_1_FantasyPortrait_fp16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/FantasyPortrait/Wan2_1_FantasyPortrait_fp16.safetensors"

    # Download WanVideo_2_1_Multitalk_14B_fp8_e4m3fn.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "WanVideo_2_1_Multitalk_14B_fp8_e4m3fn.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/WanVideo_2_1_Multitalk_14B_fp8_e4m3fn.safetensors"

aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "umt5-xxl-enc-bf16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/umt5-xxl-enc-bf16.safetensors"

# Download split_files/clip_vision/clip_vision_h.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/clip_vision" \
    -o "native_clip_vision_h.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"


echo "All downloads completed!"