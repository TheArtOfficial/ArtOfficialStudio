#!/bin/bash
# Model: CausVid Loras (Wan also required)
# Requires-HF-Token: false
# Model-URL: https://causvid.github.io/

echo "Downloading files from HuggingFace repository Kijai/WanVideo_comfy..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download Wan21_CausVid_14B_T2V_lora_rank32.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Wan21_CausVid_14B_T2V_lora_rank32.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_CausVid_14B_T2V_lora_rank32.safetensors"

# Download Wan21_CausVid_bidirect2_T2V_1_3B_lora_rank32.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Wan21_CausVid_bidirect2_T2V_1_3B_lora_rank32.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_CausVid_bidirect2_T2V_1_3B_lora_rank32.safetensors"

# Download Wan2_1-T2V-14B_CausVid_fp8_e4m3fn.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "Wan2_1-T2V-14B_CausVid_fp8_e4m3fn.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1-T2V-14B_CausVid_fp8_e4m3fn.safetensors"

echo "All downloads completed!"