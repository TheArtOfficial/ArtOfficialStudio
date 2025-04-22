# CONFIG:
# {
#   "model_type": "ltx-video",
#   "diffusers_path": "/workspace/training_models/LTX-Video",
#   "dtype": "bfloat16",
#   "transformer_dtype": "float8",
#   "timestep_sample_method": "logit_normal"
# }

mkdir -p /workspace/training_models

/hfd.sh LTX-Video -d /workspace/training_models