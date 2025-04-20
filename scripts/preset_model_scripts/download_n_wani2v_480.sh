#!/bin/bash
# Model: Native Wan2.1 I2V 480p

echo "Downloading files from HuggingFace repository Comfy-Org/Wan_2.1_ComfyUI_repackaged..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download split_files/clip_vision/clip_vision_h.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/clip_vision" \
    -o "native_clip_vision_h.safetensors" \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"

# Download split_files/diffusion_models/wan2.1_i2v_480p_14B_fp16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "wan2.1_i2v_480p_14B_fp16.safetensors" \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_480p_14B_fp16.safetensors"

# Download split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "native_umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

# Download 360 LoRA
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/loras \
    -o 360_lora.safetensors \
    https://huggingface.co/Remade-AI/Rotate/resolve/main/rotate_20_epochs.safetensors

# Download split_files/vae/wan_2.1_vae.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "native_wan_2.1_vae.safetensors" \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

echo "All downloads completed!"