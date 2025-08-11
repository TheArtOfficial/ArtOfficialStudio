#!/bin/bash
# Model: Qwen-Image Distill Full
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/Qwen/Qwen-Image

echo "Downloading files from HuggingFace repository Comfy-Org/Qwen-Image_ComfyUI..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download non_official/diffusion_models/qwen_image_distill_full_bf16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "qwen_image_distill_full_bf16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/non_official/diffusion_models/qwen_image_distill_full_bf16.safetensors"

# Download non_official/diffusion_models/qwen_image_distill_full_fp8_e4m3fn.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "qwen_image_distill_full_fp8_e4m3fn.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/non_official/diffusion_models/qwen_image_distill_full_fp8_e4m3fn.safetensors"

# Download split_files/text_encoders/qwen_2.5_vl_7b.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "qwen_2.5_vl_7b.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b.safetensors"

# Download split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "qwen_2.5_vl_7b_fp8_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"

# Download split_files/vae/qwen_image_vae.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "qwen_image_vae.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors"

echo "All downloads completed!"