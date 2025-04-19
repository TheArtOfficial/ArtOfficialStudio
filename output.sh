#!/bin/bash
# Model: Files from HuggingFace repository Comfy-Org/HiDream-I1_ComfyUI

echo "Downloading files from HuggingFace repository Comfy-Org/HiDream-I1_ComfyUI..."

# Create output directories if they don't exist
mkdir -p "/workspace/models/split_files/diffusion_models"

# Download split_files/diffusion_models/hidream_i1_full_fp16.safetensors
aria2c -x 16 -s 16 -d "/workspace/models/split_files/diffusion_models" \
    -o "hidream_i1_full_fp16.safetensors" \
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/diffusion_models/hidream_i1_full_fp16.safetensors"

echo "All downloads completed for Files from HuggingFace repository Comfy-Org/HiDream-I1_ComfyUI!"