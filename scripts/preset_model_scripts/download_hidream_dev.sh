#!/bin/bash
# Model: HiDream-I1 Dev
# Requires-HF-Token: false

echo "Downloading files from HuggingFace repository Comfy-Org/HiDream-I1_ComfyUI..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download split_files/text_encoders/clip_g_hidream.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "clip_g_hidream.safetensors" \
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/clip_g_hidream.safetensors"

# Download split_files/text_encoders/clip_l_hidream.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "clip_l_hidream.safetensors" \
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/clip_l_hidream.safetensors"

# Download split_files/vae/ae.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "ae.safetensors" \
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/vae/ae.safetensors"

    # Download split_files/text_encoders/llama_3.1_8b_instruct_fp8_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "llama_3.1_8b_instruct_fp8_scaled.safetensors" \
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/llama_3.1_8b_instruct_fp8_scaled.safetensors"

# Download split_files/text_encoders/t5xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "t5xxl_fp8_e4m3fn_scaled.safetensors" \
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/t5xxl_fp8_e4m3fn_scaled.safetensors"

# Download split_files/diffusion_models/hidream_i1_dev_bf16.safetensors
aria2c -x 16 -s 16 -d "workspace/ComfyUI/models/diffusion_models" \
    -o "hidream_i1_dev_bf16.safetensors" \
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/diffusion_models/hidream_i1_dev_bf16.safetensors"

echo "All downloads completed!"