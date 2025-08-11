#!/bin/bash
# Model: Lightx2v Loras
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/lightx2v

echo "Downloading files from HuggingFace repository Kijai/WanVideo_comfy..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank128_bf16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "lightx2v_I2V_14B_480p_cfg_step_distill_rank128_bf16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank128_bf16.safetensors"

# Download Wan22-Lightning/Wan2.2-Lightning_T2V-A14B-4steps-lora_HIGH_fp16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Wan2.2-Lightning_T2V-A14B-4steps-lora_HIGH_fp16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan22-Lightning/Wan2.2-Lightning_T2V-A14B-4steps-lora_HIGH_fp16.safetensors"

# Download Wan22-Lightning/Wan2.2-Lightning_T2V-A14B-4steps-lora_LOW_fp16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Wan2.2-Lightning_T2V-A14B-4steps-lora_LOW_fp16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan22-Lightning/Wan2.2-Lightning_T2V-A14B-4steps-lora_LOW_fp16.safetensors"

    # Download Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "lightx2v_T2V_14B_cfg_step_distill_v2_lora_rank128_bf16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_T2V_14B_cfg_step_distill_v2_lora_rank128_bf16.safetensors"


echo "All downloads completed!"