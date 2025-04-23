# CONFIG:
# {
#   "model_type": "wan",
#   "model_name": "Wan2.1-T2V-1.3B",
#   "checkpoint_path": "/workspace/training_models/Wan2.1-T2V-1.3B",
#   "dtype": "bfloat16",
#   "transformer_dtype": "float8",
#   "timestep_sample_method": "logit_normal"
# }

mkdir -p /workspace/training_models

cd /workspace/training_models

bash /hfd.sh Wan-AI/Wan2.1-T2V-1.3B
