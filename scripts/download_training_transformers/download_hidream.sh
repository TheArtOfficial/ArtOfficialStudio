# CONFIG:
# {
#   "model_type": "hidream",
#   "model_name": "HiDream-I1-Full",
#   "diffusers_path": "/workspace/training_models/HiDream-I1-Full",
#   "llama3_path": "/workspace/training_models/Meta-Llama-3.1-8B-Instruct",
#   "llama3_4bit": true,
#   "dtype": "bfloat16",
#   "transformer_dtype": "float8",
#   "max_llama3_sequence_length": 128,
#   "requires_hf_token": true
# }

mkdir -p /workspace/training_models

cd /workspace/training_models

bash /hfd.sh HiDream-ai/HiDream-I1-Full
bash /hfd.sh meta-llama/Meta-Llama-3.1-8B-Instruct --hf_username "$HF_USERNAME" --hf_token "$HUGGINGFACE_TOKEN"