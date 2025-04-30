#!/bin/bash
# Model:  WanFun Camera Control v1.1 1.3B

echo "Downloading files from HuggingFace repository alibaba-pai/Wan2.1-Fun-V1.1-1.3B-Control-Camera..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download diffusion_pytorch_model.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "wan2.1-fun-v11-13b-control-camera.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/Wan2.1-Fun-V1.1-1.3B-Control-Camera/resolve/main/diffusion_pytorch_model.safetensors"

# Download split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "native_umt5_xxl_fp8_e4m3fn_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

# Download Wan2_1_VAE_fp32.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "Wan2_1_VAE_fp32.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_fp32.safetensors"

# Download open-clip-xlm-roberta-large-vit-huge-14_visual_fp32.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "open-clip-xlm-roberta-large-vit-huge-14_visual_fp32.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/open-clip-xlm-roberta-large-vit-huge-14_visual_fp32.safetensors"


echo "All downloads completed!"