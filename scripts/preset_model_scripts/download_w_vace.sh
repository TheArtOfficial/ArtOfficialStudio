#!/bin/bash
# Model: VACE

echo "Downloading VACE, Skyreels, and Recam models..."

# Download VACE model
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models \
    -o Wan2_1_VACE_1_3B_preview_bf16.safetensors \
    https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VACE_1_3B_preview_bf16.safetensors

    