#!/bin/bash
# Model: Wan2.2 S2V 14B
# Requires-HF-Token: false
# Model-URL: https://huggingface.co/Wan-AI/Wan2.2-S2V-14B

echo "Downloading files from HuggingFace repository Comfy-Org/Wan_2.2_ComfyUI_repackaged..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download split_files/diffusion_models/wan2.1_i2v_720p_14B_bf16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/diffusion_models" \
    -o "wan2.2_s2v_14B_bf16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_s2v_14B_bf16.safetensors"

# Download split_files/audio_encoders/wav2vec2_large_english_fp16.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/audio_encoders" \
    -o "wav2vec2_large_english_fp16.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/audio_encoders/wav2vec2_large_english_fp16.safetensors"

# Download split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/text_encoders" \
    -o "native_umt5_xxl_fp8_e4m3fn_scaled.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"


# Download split_files/vae/wan_2.1_vae.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/vae" \
    -o "native_wan_2.1_vae.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

echo "All downloads completed!"