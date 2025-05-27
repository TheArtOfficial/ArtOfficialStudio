#!/bin/bash
# Model: Hunyuan Custom
# Requires-HF-Token: false
# Model-URL: https://hunyuancustom.github.io/

echo "Downloading files from HuggingFace repository Kijai/HunyuanVideo_comfy..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download hunyuan_video_custom_720p_bf16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "hunyuan_video_custom_720p_bf16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_custom_720p_bf16.safetensors"

# Download hunyuan_video_custom_720p_fp8_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "hunyuan_video_custom_720p_fp8_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_custom_720p_fp8_scaled.safetensors"

# Download CLIP vision model
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/clip_vision \
    -o llava_llama3_vision.safetensors --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/clip_vision/llava_llama3_vision.safetensors

# Download text encoders
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/text_encoders \
    -o llava_llama3_fp8_scaled.safetensors --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/llava_llama3_fp8_scaled.safetensors

aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/text_encoders \
    -o clip_l.safetensors --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/clip_l.safetensors 

# Download hunyuan_video_vae_fp32.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "hunyuan_video_vae_fp32.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_vae_fp32.safetensors"


echo "All downloads completed!"