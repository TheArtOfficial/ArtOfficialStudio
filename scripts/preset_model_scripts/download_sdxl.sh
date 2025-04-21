#!/bin/bash
# Model: Stable Diffusion XL (SDXL)
# Requires-HF-Token: false
echo "Downloading SDXL base model..."
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/checkpoints \
    -o sd_xl_base_1.0.safetensors \
    https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors 