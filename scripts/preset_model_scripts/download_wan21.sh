#!/bin/bash
# Model: Wan 2.1 I2V Models

echo "Downloading Wan2.1 I2V model and related files..."

# Download main model files
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models \
    -o wan2_1_i2v.safetensors \
    https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_480p_14B_fp16.safetensors

aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models \
    -o Wan2_1_I2V_14B_720P_fp8_e4m3fn.safetensors \
    https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_fp16.safetensors

# Download CLIP vision model
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/clip_vision \
    -o clip_vision_h.safetensors \
    https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors

# Download 360 LoRA
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/loras \
    -o 360_lora.safetensors \
    https://huggingface.co/Remade-AI/Rotate/resolve/main/rotate_20_epochs.safetensors

# Download text encoder
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/text_encoders \
    -o umt5_xxl_fp16.safetensors \
    https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors 

# Download Wan2.1 VAE
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/vae \
    -o wan_2.1_vae_native.safetensors \
    https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors?download=true