#!/bin/bash
# Model: Qwen Image Edit
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/Qwen/Qwen-Image-Edit

echo "Downloading files from HuggingFace repository Comfy-Org/Qwen-Image-Edit_ComfyUI..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download split_files/diffusion_models/qwen_image_edit_bf16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "qwen_image_edit_bf16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_bf16.safetensors"

# Download split_files/diffusion_models/qwen_image_edit_fp8_e4m3fn.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "qwen_image_edit_fp8_e4m3fn.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_fp8_e4m3fn.safetensors"

# Download split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "qwen_2.5_vl_7b_fp8_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"

echo "All downloads completed!"