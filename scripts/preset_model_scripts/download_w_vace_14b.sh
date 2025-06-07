#!/bin/bash
# Model: VACE 14B
# Requires-HF-Token: false
# Model-URL: https://ali-vilab.github.io/VACE-Page/

echo "Downloading VACE 14B..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

    # Download split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "native_umt5_xxl_fp8_e4m3fn_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

# Download split_files/diffusion_models/wan2.1_t2v_14B_fp16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "wan2.1_t2v_14B_fp16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_14B_fp16.safetensors"

# Download split_files/diffusion_models/wan2.1_t2v_14B_fp16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "wan2.1_t2v_14B_fp8_e4m3fn.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_14B_fp8_e4m3fn.safetensors"

# Download Wan2_1-VACE_module_14B_bf16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "Wan2_1-VACE_module_14B_bf16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1-VACE_module_14B_bf16.safetensors"

# Download Wan2_1-VACE_module_14B_fp8_e4m3fn.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "Wan2_1-VACE_module_14B_fp8_e4m3fn.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1-VACE_module_14B_fp8_e4m3fn.safetensors"

# Download Wan2_1_VAE_fp32.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "Wan2_1_VAE_fp32.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_fp32.safetensors"

# Download open-clip-xlm-roberta-large-vit-huge-14_visual_fp32.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "open-clip-xlm-roberta-large-vit-huge-14_visual_fp32.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/open-clip-xlm-roberta-large-vit-huge-14_visual_fp32.safetensors"
