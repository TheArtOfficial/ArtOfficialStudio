# CONFIG:
# {
#   "model_type": "ltx-video",
#   "model_name": "LTX-Video",
#   "diffusers_path": "/workspace/training_models/LTX-Video",
#   "dtype": "bfloat16",
#   "timestep_sample_method": "logit_normal"
# }

mkdir -p /workspace/training_models

cd /workspace/training_models

bash /hfd.sh "Lightricks/LTX-Video"