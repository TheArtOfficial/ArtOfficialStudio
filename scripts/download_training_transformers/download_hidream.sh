# CONFIG:
# {
#   "model_type": "hidream",
#   "diffusers_path": "/workspace/training_models/HiDream-ai/HiDream-I1-Full",
#   "llama3_path": "/workspace/training_models/meta-llama/Meta-Llama-3.1-8B-Instruct",
#   "llama3_4bit": true,
#   "dtype": "bfloat16",
#   "transformer_dtype": "float8",
#   "max_llama3_sequence_length": 128,
#   "requires_hf_token": true
# }

mkdir -p /workspace/training_models

/hfd.sh HiDream-ai/HiDream-I1-Full -d /workspace/training_models
/hfd.sh meta-llama/Meta-Llama-3.1-8B-Instruct -d /workspace/training_models --hf_token "$HUGGINGFACE_TOKEN"