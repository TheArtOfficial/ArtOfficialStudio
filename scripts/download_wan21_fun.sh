#!/bin/bash

echo "Downloading Wan2.1 Fun models..."

# Download 1.3B Control model
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models \
    -o wan2_1_fun_1_3b_control.safetensors \
    https://huggingface.co/alibaba-pai/Wan2.1-Fun-1.3B-Control/resolve/main/diffusion_pytorch_model.safetensors

# Download 14B Control model
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models \
    -o wan2_1_fun_14b_control.safetensors \
    https://huggingface.co/alibaba-pai/Wan2.1-Fun-14B-Control/resolve/main/diffusion_pytorch_model.safetensors 