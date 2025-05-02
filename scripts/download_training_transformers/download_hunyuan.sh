# CONFIG:
# {
#   "model_type": "hunyuan-video",
#   "model_name": "HunyuanVideo",
#   "ckpt_path": "/workspace/training_models/HunyuanVideo",
#   "llm_path": "/workspace/training_models/llava-llama-3-8b-text-encoder-tokenizer",
#   "clip_path": "/workspace/training_models/clip-vit-large-patch14",
#   "dtype": "bfloat16",
#   "transformer_dtype": "float8",
#   "timestep_sample_method": "logit_normal"
# }

mkdir -p /workspace/training_models

cd /workspace/training_models

bash /hfd.sh tencent/HunyuanVideo

bash /hfd.sh Kijai/llava-llama-3-8b-text-encoder-tokenizer

bash /hfd.sh openai/clip-vit-large-patch14

# The following paths will be included in the configuration above:
#   "vae_path": "/workspace/training_models/hunyuan_video_comfyui/hunyuan_video_vae_bf16.safetensors",
#   "llm_path": "/workspace/training_models/llava-llama-3-8b-text-encoder-tokenizer",
#   "clip_path": "/workspace/training_models/clip-vit-large-patch14",