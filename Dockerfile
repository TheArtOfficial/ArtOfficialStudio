FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV FLUXGYM_PORT=7860
ENV COMFYUI_PORT=8188

RUN apt update && apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.12 \
    python3-pip \
    python3.12-venv \
    git \
    aria2 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Create and set up FluxGym virtual environment
RUN python3.12 -m venv /workspace/fluxgym_venv && \
    git clone https://github.com/cocktailpeanut/fluxgym.git && \
    cd fluxgym && \
    /workspace/fluxgym_venv/bin/pip install -r requirements.txt

# Create and set up ComfyUI virtual environment
RUN python3.12 -m venv /workspace/comfyui_venv && \
    git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd ComfyUI && \
    /workspace/comfyui_venv/bin/pip install -r requirements.txt

# Download models
RUN mkdir -p /workspace/ComfyUI/models/diffusion_models && \
    mkdir -p /workspace/ComfyUI/models/vae && \
    mkdir -p /workspace/ComfyUI/models/controlnet && \
    mkdir -p /workspace/ComfyUI/models/loras && \
    mkdir -p /workspace/ComfyUI/models/clip_vision && \
    mkdir -p /workspace/ComfyUI/models/text_encoders

# Download SDXL base model
RUN aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/checkpoints -o sd_xl_base_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors

# Download Wan2.1 I2V model and related files
RUN aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models -o wan2_1_i2v.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_480p_14B_fp16.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/clip_vision -o clip_vision_h.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/loras -o 360_lora.safetensors https://huggingface.co/Remade-AI/Rotate/resolve/main/rotate_20_epochs.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/text_encoders -o umt5_xxl_fp16.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors

# Create startup script
RUN echo '#!/bin/bash\n\
cd /workspace/fluxgym && /workspace/fluxgym_venv/bin/python app.py --port $FLUXGYM_PORT &\n\
cd /workspace/ComfyUI && /workspace/comfyui_venv/bin/python main.py --port $COMFYUI_PORT\n\
' > /workspace/start.sh && \
    chmod +x /workspace/start.sh

# Expose ports
EXPOSE $FLUXGYM_PORT $COMFYUI_PORT

# Set the entrypoint
ENTRYPOINT ["/workspace/start.sh"] 