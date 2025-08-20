# CONFIG:
# {
#   "model_type": "wan",
#   "model_name": "Wan2.2-I2V-A14B High Noise",
#   "ckpt_path": "/workspace/training_models/Wan2.2-I2V-A14B",
#   "transformer_path": "/workspace/training_models/Wan2.2-I2V-A14B/high_noise_model",
#   "dtype": "bfloat16",
#   "transformer_dtype": "float8",
#   "timestep_sample_method": "logit_normal",
#   "min_t": 0.875,
#   "max_t": 1.0
# }

mkdir -p /workspace/training_models

cd /workspace/training_models

bash /hfd.sh Wan-AI/Wan2.2-I2V-A14B