FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV FLUXGYM_PORT=7000
ENV COMFYUI_PORT=8188
ENV FLUX_DOWN_PORT=5000
ENV CIVITAI_DOWN_PORT=5001
ENV DIFFUSION_PIPE_UI_PORT=7860
ENV TENSORBOARD_PORT=6006
ENV FLUX_SCRIPT_PATH=/workspace/flux_model_downloader/download_models.sh
ENV FLUX_MODELS_PATH=/workspace/ComfyUI/models/diffusion_models

# Add GitHub token build argument
ARG GITHUB_TOKEN
ENV GITHUB_TOKEN=$GITHUB_TOKEN

RUN apt update && apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa

# Install system dependencies
RUN apt-get install -y \
    python3.12 \
    python3.12-venv \
    git \
    aria2 \
    curl \
    build-essential \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Create and set up ComfyUI virtual environment
RUN cd /workspace && \
    git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd ComfyUI && \
    python3.12 -m venv comfyui_venv && \
    ./comfyui_venv/bin/python -m pip install --upgrade pip && \
    ./comfyui_venv/bin/pip install -r requirements.txt

# Download models
RUN mkdir -p /workspace/ComfyUI/models/diffusion_models && \
    mkdir -p /workspace/ComfyUI/models/vae && \
    mkdir -p /workspace/ComfyUI/models/controlnet && \
    mkdir -p /workspace/ComfyUI/models/loras && \
    mkdir -p /workspace/ComfyUI/models/clip_vision && \
    mkdir -p /workspace/ComfyUI/models/text_encoders

# Download SDXL base model
RUN aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/checkpoints -o sd_xl_base_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors

# Native Models
# Download Wan2.1 I2V model and related files
RUN aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models -o wan2_1_i2v.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_480p_14B_fp16.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models -o Wan2_1_I2V_14B_720P_fp8_e4m3fn.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_480p_14B_fp16.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/clip_vision -o clip_vision_h.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/loras -o 360_lora.safetensors https://huggingface.co/Remade-AI/Rotate/resolve/main/rotate_20_epochs.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/text_encoders -o umt5_xxl_fp16.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors

# Download Wan2.1 Fun models
RUN aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models -o wan2_1_fun_1_3b_control.safetensors https://huggingface.co/alibaba-pai/Wan2.1-Fun-1.3B-Control/resolve/main/diffusion_pytorch_model.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models -o wan2_1_fun_14b_control.safetensors https://huggingface.co/alibaba-pai/Wan2.1-Fun-14B-Control/resolve/main/diffusion_pytorch_model.safetensors

#Wrapper Files
# Download VACE, Skyreels, and Recam models
RUN aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models -o Wan2_1_VACE_1_3B_preview_bf16.safetensors https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VACE_1_3B_preview_bf16.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models -o Wan2_1_SkyreelsA2_fp8_e4m3fn.safetensors https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_SkyreelsA2_fp8_e4m3fn.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models -o Wan2_1_kwai_recammaster_1_3B_step20000_bf16.safetensors https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_kwai_recammaster_1_3B_step20000_bf16.safetensors

# Download HunyuanVideo model files
RUN aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/clip_vision -o llava_llama3_vision.safetensors https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/clip_vision/llava_llama3_vision.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models -o hunyuan_video_t2v_720p_bf16.safetensors https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/diffusion_models/hunyuan_video_t2v_720p_bf16.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models -o hunyuan_video_image_to_video_720p_bf16.safetensors https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/diffusion_models/hunyuan_video_image_to_video_720p_bf16.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/diffusion_models -o hunyuan_video_v2_replace_image_to_video_720p_bf16.safetensors https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/diffusion_models/hunyuan_video_v2_replace_image_to_video_720p_bf16.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/vae -o hunyuan_video_vae_bf16.safetensors https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/vae/hunyuan_video_vae_bf16.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/text_encoders -o llava_llama3_fp8_scaled.safetensors https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/llava_llama3_fp8_scaled.safetensors && \
    aria2c -x 16 -s 16 -d /workspace/ComfyUI/models/text_encoders -o clip_l.safetensors https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/clip_l.safetensors

# Install ComfyUI Manager
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

# Install KJNodes
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-KJNodes.git && \
    cd ComfyUI-KJNodes && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

# Install Crystools
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/crystian/ComfyUI-Crystools.git && \
    cd ComfyUI-Crystools && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

# Install Video Helper Suite
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    cd ComfyUI-VideoHelperSuite && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

# Install Segment Anything 2
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-Segment-Anything-2.git && \
    cd ComfyUI-Segment-Anything-2

# Install Florence2
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-Florence2.git && \
    cd ComfyUI-Florence2 && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

# Install WanVideoWrapper
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git && \
    cd ComfyUI-WanVideoWrapper && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

# Install HunyuanVideoWrapper
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper.git && \
    cd ComfyUI-HunyuanVideoWrapper && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

# Install Easy-Use Nodes
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/yolain/ComfyUI-Easy-Use.git && \
    cd ComfyUI-Easy-Use && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

# Install Impact Pack
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
    cd ComfyUI-Impact-Pack && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

# Install LatentSync Wrapper
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ShmuelRonen/ComfyUI-LatentSyncWrapper.git && \
    cd ComfyUI-LatentSyncWrapper && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

    # Clone RunPod repo and move workflows
    RUN git clone https://${GITHUB_TOKEN}@github.com/TheArtOfficial/RunPod.git && \
    rm -rf /workspace/ComfyUI/user/default/workflows && \
    mkdir -p /workspace/ComfyUI/user/default && \
    mv /workspace/RunPod/workflows/* /workspace/ComfyUI/user/default/ && \
    mkdir -p /workspace/flux_model_downloader/templates && \
    mv /workspace/RunPod/flux_model_downloader/* /workspace/flux_model_downloader/ && \
    chmod +x $FLUX_SCRIPT_PATH && \
    rm -rf /workspace/RunPod

# Set up model downloader
RUN cd /workspace/flux_model_downloader && \
    python3.12 -m venv flask_venv && \
    ./flask_venv/bin/pip install flask gunicorn gevent

# Set up CivitAI model downloader
RUN cd /workspace && \
    mkdir -p civitai_model_downloader/templates && \
    cd civitai_model_downloader && \
    python3.12 -m venv civitai_venv && \
    ./civitai_venv/bin/pip install flask gunicorn gevent

# Create and set up FluxGym virtual environment
RUN cd /workspace && \
    git clone https://github.com/cocktailpeanut/fluxgym.git && \
    cd fluxgym && \
    python3.12 -m venv fluxgym_venv && \
    ./fluxgym_venv/bin/python -m pip install --upgrade pip && \
    ./fluxgym_venv/bin/pip install -r requirements.txt

# Create and set up diffusion-pipe-ui
RUN cd /workspace && \
    git clone https://github.com/alisson-anjos/diffusion-pipe-ui.git && \
    cd diffusion-pipe-ui && \
    python3.12 -m venv diffusion_venv && \
    ./diffusion_venv/bin/python -m pip install --upgrade pip && \
    ./diffusion_venv/bin/pip install -r requirements.txt

# Create startup script
RUN echo '#!/bin/bash\n\
cd /workspace/fluxgym && ./fluxgym_venv/bin/python app.py --port $FLUXGYM_PORT &\n\
cd /workspace/ComfyUI && ./comfyui_venv/bin/python main.py --port $COMFYUI_PORT &\n\
cd /workspace/flux_model_downloader && ./flask_venv/bin/python app.py --port $FLUX_DOWN_PORT &\n\
cd /workspace/civitai_model_downloader && ./civitai_venv/bin/python app.py --port $CIVITAI_DOWN_PORT &\n\
cd /workspace/diffusion-pipe-ui && ./diffusion_venv/bin/python gradio_interface.py' > /workspace/start.sh && chmod +x /workspace/start.sh

RUN /workspace/ComfyUI/comfyui_venv/bin/pip uninstall -y onnxruntime && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install onnxruntime-gpu="1.19" sageattention

# Expose ports
EXPOSE $FLUXGYM_PORT $COMFYUI_PORT $FLUX_DOWN_PORT $CIVITAI_DOWN_PORT $DIFFUSION_PIPE_UI_PORT $TENSORBOARD_PORT

# Set the entrypoint
ENTRYPOINT ["/workspace/start.sh"] 