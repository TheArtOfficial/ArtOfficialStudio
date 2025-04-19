#!/bin/bash
# Model: VACE, Skyreels, and Recam Models (Also download Wan2.1 if you want to use them)

echo "Downloading VACE, Skyreels, and Recam models..."

# Download VACE model
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models \
    -o Wan2_1_VACE_1_3B_preview_bf16.safetensors \
    https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VACE_1_3B_preview_bf16.safetensors

# Download Skyreels model
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models \
    -o Wan2_1_SkyreelsA2_fp8_e4m3fn.safetensors \
    https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_SkyreelsA2_fp8_e4m3fn.safetensors

# Download Recam model
aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models \
    -o Wan2_1_kwai_recammaster_1_3B_step20000_bf16.safetensors \
    https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_kwai_recammaster_1_3B_step20000_bf16.safetensors 