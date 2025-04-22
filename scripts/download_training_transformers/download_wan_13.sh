# CONFIG:
# {
#   "model_type": "wan-1.3b",
#   "checkpoint_path": "/workspace/training_models/Wan-AI/Wan2.1-T2V-1.3B",
#   "dtype": "bfloat16",
#   "transformer_dtype": "float8",
#   "timestep_sample_method": "logit_normal"
# }

mkdir -p /workspace/training_models

/hfd.sh Wan-AI/Wan2.1-T2V-1.3B -d /workspace/training_models
