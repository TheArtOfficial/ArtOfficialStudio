# CONFIG:
# {
#   "model_type": "flux",
#   "diffusers_path": "/workspace/training_models/black-forest-labs/FLUX.1-dev",
#   "dtype": "bfloat16",
#   "transformer_dtype": "float8",
#   "flux_shift": true,
#   "requires_hf_token": true
# }

mkdir -p /workspace/training_models

bash /hfd.sh black-forest-labs/FLUX.1-dev -d /workspace/training_models --hf_token "$HUGGINGFACE_TOKEN"