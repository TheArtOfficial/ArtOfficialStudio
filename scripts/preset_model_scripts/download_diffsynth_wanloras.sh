#!/bin/bash
# Model: Evados DiffSynth Reward LoRAs
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/Evados/DiffSynth-Studio-Lora-Wan2.1-ComfyUI

echo "Downloading files from HuggingFace repository Evados/DiffSynth-Studio-Lora-Wan2.1-ComfyUI..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download ComfyUI_Wan2.1-Fun-1.3B-InP-HPS2.1_lora_new.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Evados_Wan2.1-Fun-1.3B-InP-HPS2.1_lora_new.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Evados/DiffSynth-Studio-Lora-Wan2.1-ComfyUI/resolve/main/ComfyUI_Wan2.1-Fun-1.3B-InP-HPS2.1_lora_new.safetensors"

# Download ComfyUI_Wan2.1-Fun-1.3B-InP-MPS_lora_new.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Evados_Wan2.1-Fun-1.3B-InP-MPS_lora_new.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Evados/DiffSynth-Studio-Lora-Wan2.1-ComfyUI/resolve/main/ComfyUI_Wan2.1-Fun-1.3B-InP-MPS_lora_new.safetensors"

echo "All downloads completed!"