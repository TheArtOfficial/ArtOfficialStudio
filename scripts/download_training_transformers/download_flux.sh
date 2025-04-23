# CONFIG:
# {
#   "model_type": "flux",
#   "model_name": "FLUX.1-dev",
#   "diffusers_path": "/workspace/training_models/FLUX.1-dev",
#   "dtype": "bfloat16",
#   "transformer_dtype": "float8",
#   "flux_shift": true,
#   "requires_hf_token": true
# }

mkdir -p /workspace/training_models

cd /workspace/training_models

bash /hfd.sh black-forest-labs/FLUX.1-dev --hf_token "$HUGGINGFACE_TOKEN"