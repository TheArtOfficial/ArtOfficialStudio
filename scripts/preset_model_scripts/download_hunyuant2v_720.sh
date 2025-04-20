#!/bin/bash
# Model: HunyuanVideo T2V 720

echo "Downloading Wan2.1 T2V model and related files..."

// ... rest of the existing code ...
echo "Downloading HunyuanVideo model files..."

# Download CLIP vision model
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/clip_vision \
    -o llava_llama3_vision.safetensors \
    https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/clip_vision/llava_llama3_vision.safetensors

# Download diffusion models
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models \
    -o hunyuan_video_t2v_720p_bf16.safetensors \
    https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/diffusion_models/hunyuan_video_t2v_720p_bf16.safetensors

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