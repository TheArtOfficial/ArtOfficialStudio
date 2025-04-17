FROM nvidia/cuda:12.6.0-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV FLUXGYM_PORT=7000
ENV COMFYUI_PORT=8188
ENV FLUX_DOWN_PORT=5000
ENV CIVITAI_DOWN_PORT=5001
ENV DIFFUSION_PIPE_UI_PORT=7860
ENV TENSORBOARD_PORT=6006
ENV JUPYTER_PORT=8888
ENV FLUX_SCRIPT_PATH=/workspace/flux_model_downloader/download_models.sh
ENV FLUX_MODELS_PATH=/workspace/ComfyUI/models/diffusion_models
ENV SCRIPTS_DIR=/workspace/scripts
ENV JUPYTER_PASSWORD=""
ENV JUPYTER_TOKEN=""

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

# Create model directories
RUN mkdir -p /workspace/ComfyUI/models/diffusion_models && \
    mkdir -p /workspace/ComfyUI/models/checkpoints && \
    mkdir -p /workspace/ComfyUI/models/vae && \
    mkdir -p /workspace/ComfyUI/models/controlnet && \
    mkdir -p /workspace/ComfyUI/models/loras && \
    mkdir -p /workspace/ComfyUI/models/clip_vision && \
    mkdir -p /workspace/ComfyUI/models/text_encoders

# Clone RunPod repo and move workflows and scripts
RUN git clone https://${GITHUB_TOKEN}@github.com/TheArtOfficial/RunPod.git && \
    rm -rf /workspace/ComfyUI/user/default/workflows && \
    mkdir -p /workspace/ComfyUI/user/default && \
    mv /workspace/RunPod/workflows/* /workspace/ComfyUI/user/default/ && \
    mkdir -p /workspace/flux_model_downloader/templates && \
    mv /workspace/RunPod/flux_model_downloader/* /workspace/flux_model_downloader/ && \
    mkdir -p $SCRIPTS_DIR && \
    mv /workspace/RunPod/scripts/* $SCRIPTS_DIR/ && \
    chmod +x $SCRIPTS_DIR/*.sh && \
    chmod +x $FLUX_SCRIPT_PATH && \
    rm -rf /workspace/RunPod

# Download models using scripts
RUN $SCRIPTS_DIR/download_sdxl.sh && \
    $SCRIPTS_DIR/download_wan21.sh && \
    $SCRIPTS_DIR/download_wan21_fun.sh && \
    $SCRIPTS_DIR/download_wrapper_models.sh && \
    $SCRIPTS_DIR/download_hunyuan.sh

# Install ComfyUI nodes
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-KJNodes.git && \
    cd ComfyUI-KJNodes && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/crystian/ComfyUI-Crystools.git && \
    cd ComfyUI-Crystools && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    cd ComfyUI-VideoHelperSuite && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-Segment-Anything-2.git && \
    cd ComfyUI-Segment-Anything-2

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-Florence2.git && \
    cd ComfyUI-Florence2 && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git && \
    cd ComfyUI-WanVideoWrapper && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper.git && \
    cd ComfyUI-HunyuanVideoWrapper && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/yolain/ComfyUI-Easy-Use.git && \
    cd ComfyUI-Easy-Use && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
    cd ComfyUI-Impact-Pack && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ShmuelRonen/ComfyUI-LatentSyncWrapper.git && \
    cd ComfyUI-LatentSyncWrapper && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt

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
    ./diffusion_venv/bin/pip install packaging wheel setuptools && \
    ./diffusion_venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126 && \
    ./diffusion_venv/bin/pip install --no-build-isolation flash-attn==2.7.4.post1 && \
    ./diffusion_venv/bin/pip install -r requirements.txt

# Set up JupyterLab
RUN cd /workspace && \
    python3.12 -m venv jupyter_venv && \
    ./jupyter_venv/bin/pip install --upgrade pip && \
    ./jupyter_venv/bin/pip install jupyterlab ipywidgets ipykernel && \
    ./jupyter_venv/bin/python -m ipykernel install --user --name=python3.12 && \
    mkdir -p /root/.jupyter && \
    echo "c.ServerApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_server_config.py && \
    echo "c.ServerApp.allow_root = True" >> /root/.jupyter/jupyter_server_config.py && \
    echo "c.ServerApp.open_browser = False" >> /root/.jupyter/jupyter_server_config.py && \
    echo "c.ServerApp.port = 8888" >> /root/.jupyter/jupyter_server_config.py && \
    echo "c.ServerApp.token = ''" >> /root/.jupyter/jupyter_server_config.py && \
    echo "c.ServerApp.password = ''" >> /root/.jupyter/jupyter_server_config.py

# Create startup script
RUN echo '#!/bin/bash\n\
cd /workspace/fluxgym && ./fluxgym_venv/bin/python app.py --port $FLUXGYM_PORT &\n\
cd /workspace/ComfyUI && ./comfyui_venv/bin/python main.py --port $COMFYUI_PORT &\n\
cd /workspace/flux_model_downloader && ./flask_venv/bin/python app.py --port $FLUX_DOWN_PORT &\n\
cd /workspace/civitai_model_downloader && ./civitai_venv/bin/python app.py --port $CIVITAI_DOWN_PORT &\n\
cd /workspace/diffusion-pipe-ui && ./diffusion_venv/bin/python gradio_interface.py &\n\
cd /workspace && ./jupyter_venv/bin/jupyter lab --allow-root --ip=0.0.0.0 --port=$JUPYTER_PORT --ServerApp.token=$JUPYTER_TOKEN --ServerApp.password=$JUPYTER_PASSWORD &\n\
\n\
# Run download scripts\n\
echo "Starting model downloads..."\n\
$SCRIPTS_DIR/download_sdxl.sh\n\
$SCRIPTS_DIR/download_wan21.sh\n\
$SCRIPTS_DIR/download_wan21_fun.sh\n\
$SCRIPTS_DIR/download_wrapper_models.sh\n\
$SCRIPTS_DIR/download_hunyuan.sh\n\
\n\
# Keep container running\n\
tail -f /dev/null' > /workspace/start.sh && chmod +x /workspace/start.sh

RUN /workspace/ComfyUI/comfyui_venv/bin/pip uninstall -y onnxruntime && \
    /workspace/ComfyUI/comfyui_venv/bin/pip install onnxruntime-gpu=="1.19" sageattention

# Expose ports
EXPOSE $FLUXGYM_PORT $COMFYUI_PORT $FLUX_DOWN_PORT $CIVITAI_DOWN_PORT $DIFFUSION_PIPE_UI_PORT $TENSORBOARD_PORT $JUPYTER_PORT

# Set the entrypoint
ENTRYPOINT ["/workspace/start.sh"] 