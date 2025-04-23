# ArtOfficial RunPod Docker Environment

This Dockerfile sets up a comprehensive development environment for AI and machine learning tasks, particularly focused on image generation and processing. The environment includes various tools and services, each running on specific ports.

## Environment Overview

This Docker image is based on `nvidia/cuda:12.8.0-cudnn-devel-ubuntu22.04` and includes a wide range of tools and libraries for AI development, image processing, and machine learning.

## Available Tools and Ports

The following services are available in the container:

- **Control Panel**: Port `5000`
- **FluxGym**: Port `6000`
- **Diffusion Pipeline UI**: Port `7000`
- **TensorBoard**: Port `6006`
- **ComfyUI**: Port `8188`
- **Jupyter**: Port `8888`

## Tool Documentation

Each tool in the environment has its own documentation and GitHub repository:

- **Diffusion Pipeline**: [GitHub Repository](https://github.com/tdrussell/diffusion-pipe)
  - A pipeline parallel training script for diffusion models
  - Supports SDXL, Flux, LTX-Video, and other models
  - Features pipeline parallelism for training large models

- **Kohya SS**: [GitHub Repository](https://github.com/bmaltais/kohya_ss)
  - A web UI for Stable Diffusion training
  - Supports LoRA, Dreambooth, and Textual Inversion training
  - Includes various training utilities and tools

- **FluxGym**: [GitHub Repository](https://github.com/cocktailpeanut/fluxgym)
  - A training environment for AI models
  - Focused on reinforcement learning and model training
  - Provides a flexible framework for AI experimentation

## Key Features

- **Python Support**: Includes Python 3.10 and 3.12 with development tools
- **CUDA Support**: NVIDIA CUDA 12.8.0 with cuDNN
- **Development Tools**:
  - Jupyter Lab
  - TensorBoard
  - ComfyUI
  - Various AI/ML tools

The image includes:
- Basic utilities (git, curl, wget, etc.)
- Build tools (gcc, make, cmake)
- Image/video processing libraries (ffmpeg, libavcodec, etc.)
- Deep learning dependencies
- File system tools (cifs-utils, nfs-common)

## Getting Started

The pre-built container is available at `ghcr.io/theartofficial/oneclickai:latest`. To run the container:

Request access to the container at https://www.patreon.com/c/theartofficialtrainer

```bash
docker run -it --gpus all \
  -p 5000:5000 \
  -p 6000:6000 \
  -p 7000:7000 \
  -p 6006:6006 \
  -p 8188:8188 \
  -p 8888:8888 \
  ghcr.io/theartofficial/oneclickai:latest
```

## Notes

- The container uses NVIDIA GPU support
- All services are accessible through their respective ports
- The environment includes various AI/ML tools and frameworks
- Jupyter Lab is available for interactive development
- TensorBoard is available for model visualization
