# CONFIG:
# {
#   "model_type": "wan",
#   "model_name": "Wan2.1-I2V",
#   "checkpoint_path": "/workspace/training_models/WWan2.1-T2V-I2V-14B",
#   "dtype": "bfloat16",
#   "transformer_dtype": "float8",
#   "timestep_sample_method": "logit_normal"
# }

mkdir -p /workspace/training_models

cd /workspace/training_models

bash /hfd.sh Wan-AI/Wan2.1-T2V-I2V-14B