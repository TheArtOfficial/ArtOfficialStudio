#!/bin/bash
# Model: Easy Animate 5.1 12B

echo "Downloading files from HuggingFace repository alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers..."

# Create output directory if it doesn't exist
mkdir -p "/workspace/ComfyUI/models"

# Download .gitattributes
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o ".gitattributes" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/.gitattributes"

# Download README.md
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "README.md" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/README.md"

# Download README_en.md
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "README_en.md" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/README_en.md"

# Download model_index.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "model_index.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/model_index.json"

# Download scheduler/scheduler_config.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "scheduler_config.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/scheduler/scheduler_config.json"

# Download text_encoder/chat_template.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "chat_template.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/chat_template.json"

# Download text_encoder/config.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "config.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/config.json"

# Download text_encoder/generation_config.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "generation_config.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/generation_config.json"

# Download text_encoder/merges.txt
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "merges.txt" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/merges.txt"

# Download text_encoder/model-00001-of-00005.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "model-00001-of-00005.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/model-00001-of-00005.safetensors"

# Download text_encoder/model-00002-of-00005.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "model-00002-of-00005.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/model-00002-of-00005.safetensors"

# Download text_encoder/model-00003-of-00005.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "model-00003-of-00005.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/model-00003-of-00005.safetensors"

# Download text_encoder/model-00004-of-00005.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "model-00004-of-00005.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/model-00004-of-00005.safetensors"

# Download text_encoder/model-00005-of-00005.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "model-00005-of-00005.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/model-00005-of-00005.safetensors"

# Download text_encoder/model.safetensors.index.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "model.safetensors.index.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/model.safetensors.index.json"

# Download text_encoder/preprocessor_config.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "preprocessor_config.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/preprocessor_config.json"

# Download text_encoder/tokenizer.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "tokenizer.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/tokenizer.json"

# Download text_encoder/tokenizer_config.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "tokenizer_config.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/tokenizer_config.json"

# Download text_encoder/vocab.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "vocab.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/text_encoder/vocab.json"

# Download tokenizer/chat_template.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "chat_template.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/tokenizer/chat_template.json"

# Download tokenizer/merges.txt
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "merges.txt" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/tokenizer/merges.txt"

# Download tokenizer/preprocessor_config.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "preprocessor_config.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/tokenizer/preprocessor_config.json"

# Download tokenizer/tokenizer.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "tokenizer.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/tokenizer/tokenizer.json"

# Download tokenizer/tokenizer_config.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "tokenizer_config.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/tokenizer/tokenizer_config.json"

# Download tokenizer/vocab.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "vocab.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/tokenizer/vocab.json"

# Download transformer/config.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "config.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/transformer/config.json"

# Download transformer/diffusion_pytorch_model.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "diffusion_pytorch_model.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/transformer/diffusion_pytorch_model.safetensors"

# Download vae/config.json
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "config.json" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/vae/config.json"

# Download vae/diffusion_pytorch_model.safetensors
aria2c -x 16 -s 16 -d "/workspace/ComfyUI/models/EasyAnimate" \
    -o "diffusion_pytorch_model.safetensors" --auto-file-renaming=false --conditional-get=true --allow-overwrite=true \
    "https://huggingface.co/alibaba-pai/EasyAnimateV5.1-12b-zh-Control-diffusers/resolve/main/vae/diffusion_pytorch_model.safetensors"

echo "All downloads completed!"