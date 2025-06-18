#!/bin/bash
# Model: FusionX LoRAs
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX

echo "Downloading files from HuggingFace repository vrgamedevgirl84/Wan14BT2VFusioniX..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download FusionX_LoRa/Phantom_Wan_14B_FusionX_LoRA.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Phantom_Wan_14B_FusionX_LoRA.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX/resolve/main/FusionX_LoRa/Phantom_Wan_14B_FusionX_LoRA.safetensors"

# Download FusionX_LoRa/Wan2.1_I2V_14B_FusionX_LoRA.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Wan2.1_I2V_14B_FusionX_LoRA.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX/resolve/main/FusionX_LoRa/Wan2.1_I2V_14B_FusionX_LoRA.safetensors"

# Download FusionX_LoRa/Wan2.1_T2V_14B_FusionX_LoRA.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/loras" \
    -o "Wan2.1_T2V_14B_FusionX_LoRA.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX/resolve/main/FusionX_LoRa/Wan2.1_T2V_14B_FusionX_LoRA.safetensors"

echo "All downloads completed!"