FROM nvidia/cuda:12.6.0-cudnn-devel-ubuntu22.04

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

# Add GitHub token build argument
ARG GITHUB_TOKEN
ENV GITHUB_TOKEN=$GITHUB_TOKEN

# Install system dependencies
RUN apt update && apt install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    git \
    aria2 \
    curl \
    build-essential \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Install JupyterLab and extensions
RUN python3.12 -m ensurepip --upgrade && \
    python3.12 -m pip install jupyterlab ipywidgets jupyter-archive jupyter_contrib_nbextensions nodejs

# Create workspace directory and clone repository
WORKDIR /workspace
RUN git clone https://${GITHUB_TOKEN}@github.com/TheArtOfficial/runpod.git . && \
    chmod +x /workspace/scripts/start.sh

# Expose ports
EXPOSE $FLUXGYM_PORT $COMFYUI_PORT $FLUX_DOWN_PORT $CIVITAI_DOWN_PORT $DIFFUSION_PIPE_UI_PORT $TENSORBOARD_PORT $JUPYTER_PORT

# Set the entrypoint
ENTRYPOINT ["/workspace/scripts/start.sh"] 