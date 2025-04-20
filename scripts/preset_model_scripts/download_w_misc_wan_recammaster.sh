#!/bin/bash
# Model: ReCamMaster Wan2.1

echo "Downloading VACE, Skyreels, and Recam models..."

# Download Recam model
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models \
    -o Wan2_1_kwai_recammaster_1_3B_step20000_bf16.safetensors \
    https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_kwai_recammaster_1_3B_step20000_bf16.safetensors 