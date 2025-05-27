#!/bin/bash
# Model: ACE Step
# Requires-HF-Token: false
# Model-URL: https://github.com/billwuhao/ComfyUI_ACE-Step

echo "Downloading files from HuggingFace repository Comfy-Org/ACE-Step_ComfyUI_repackaged..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download all_in_one/ace_step_v1_3.5b.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/checkpoints" \
    -o "ace_step_v1_3.5b.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/ACE-Step_ComfyUI_repackaged/resolve/main/all_in_one/ace_step_v1_3.5b.safetensors"

echo "All downloads completed!"