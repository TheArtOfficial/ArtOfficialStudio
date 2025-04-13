#!/bin/bash

# Check if API key is provided
if [ -z "$1" ]; then
    echo "Error: API key is required"
    exit 1
fi

API_KEY=$1

# Set up directories
FLUX_MODELS_DIR="/workspace/ComfyUI/models/diffusion_models"
mkdir -p "$FLUX_MODELS_DIR"

# Function to download a model
download_model() {
    local url=$1
    local output_file=$2
    echo "Downloading $output_file..."
    
    # Use aria2 with multiple connections and retries
    aria2c \
        --header="Authorization: Bearer $API_KEY" \
        --max-connection-per-server=16 \
        --split=16 \
        --min-split-size=1M \
        --retry-wait=5 \
        --max-tries=5 \
        --continue=true \
        --out="$output_file" \
        "$url"
    
    if [ $? -ne 0 ]; then
        echo "Error downloading $output_file"
        exit 1
    fi
    echo "Downloaded $output_file successfully"
}

# Download models
echo "Starting model downloads..."
download_model "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors" "$FLUX_MODELS_DIR/flux1-dev.safetensors"
download_model "https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev/resolve/main/flux1-fill-dev.safetensors" "$FLUX_MODELS_DIR/flux1-fill-dev.safetensors"
download_model "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors" "$FLUX_MODELS_DIR/flux_vae.safetensors"
# Add more model downloads as needed

echo "All models downloaded successfully"
exit 0 