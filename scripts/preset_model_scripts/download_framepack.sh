#!/bin/bash
# Model: FramepackI2V

echo "Downloading files from HuggingFace repository Kijai/HunyuanVideo_comfy..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download FramePackI2V model
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "FramePackI2V_HY_bf16.safetensors" \
    "https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/FramePackI2V_HY_bf16.safetensors"

# Download CLIP vision model
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/clip_vision" \
    -o "sigclip_vision_patch14_384.safetensors" \
    "https://huggingface.co/Comfy-Org/sigclip_vision_384/resolve/main/sigclip_vision_patch14_384.safetensors"

# Download VAE
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/vae \
    -o hunyuan_video_vae_bf16.safetensors \
    https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/vae/hunyuan_video_vae_bf16.safetensors

# Download text encoders
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/text_encoders \
    -o llava_llama3_fp8_scaled.safetensors \
    https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/llava_llama3_fp8_scaled.safetensors

aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/text_encoders \
    -o clip_l.safetensors \
    https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/clip_l.safetensors 

echo "All downloads completed!"