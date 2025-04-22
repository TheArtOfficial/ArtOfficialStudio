# CONFIG:
# {
#   "model_type": "hunyuan-video",
#   "transformer_path": "/workspace/training_models/tencent/HunyuanVideo",
#   "vae_path": "/workspace/training_models/hunyuan_video_comfyui/hunyuan_video_vae_bf16.safetensors",
#   "llm_path": "/workspace/training_models/hunyuan_video_comfyui/llava-llama-3-8b-text-encoder-tokenizer",
#   "clip_path": "/workspace/training_models/hunyuan_video_comfyui/clip-vit-large-patch14",
#   "dtype": "bfloat16",
#   "transformer_dtype": "float8",
#   "timestep_sample_method": "logit_normal"
# }

mkdir -p /workspace/training_models

/hfd.sh tencent/HunyuanVideo -d /workspace/training_models