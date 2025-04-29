
# ##################################################################################################################################################################
# ## CONTROLNETS ##
# ##################################################################################################################################################################

# aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11e_sd15_ip2p_fp16.safetensors -d models/controlnet/ -o control_v11e_sd15_ip2p_fp16.sft
# aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11e_sd15_shuffle_fp16.safetensors -d models/controlnet -o control_v11e_sd15_shuffle_fp16.safetensors
aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_canny_fp16.safetensors -d models/controlnet -o control_v11p_sd15_canny_fp16.safetensors
aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11f1p_sd15_depth_fp16.safetensors -d models/controlnet -o control_v11f1p_sd15_depth_fp16.safetensors
aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_inpaint_fp16.safetensors -d models/controlnet -o control_v11p_sd15_inpaint_fp16.safetensors
aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_lineart_fp16.safetensors -d models/controlnet -o control_v11p_sd15_lineart_fp16.safetensors
# aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_mlsd_fp16.safetensors -d models/controlnet -o control_v11p_sd15_mlsd_fp16.safetensors
# aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_normalbae_fp16.safetensors -d models/controlnet -o control_v11p_sd15_normalbae_fp16.safetensors
aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_openpose_fp16.safetensors -d models/controlnet -o control_v11p_sd15_openpose_fp16.safetensors
# aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_scribble_fp16.safetensors -d models/controlnet -o control_v11p_sd15_scribble_fp16.safetensors
# aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_seg_fp16.safetensors -d models/controlnet -o control_v11p_sd15_seg_fp16.safetensors
# aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_softedge_fp16.safetensors -d models/controlnet -o control_v11p_sd15_softedge_fp16.safetensors
# aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15s2_lineart_anime_fp16.safetensors -d models/controlnet -o control_v11p_sd15s2_lineart_anime_fp16.safetensors
aria2c -c -x 16 -s 16 https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11u_sd15_tile_fp16.safetensors -d models/controlnet -o control_v11u_sd15_tile_fp16.safetensors

ControlNet SDXL
aria2c -c -x 16 -s 16 https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_full -d models/controlnet -o diffusers_xl_canny_full.safetensors
aria2c -c -x 16 -s 16 https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/t2i-adapter_diffusers_xl_depth_midas.safetensors -d models/controlnet -o t2i-adapter_diffusers_xl_depth_midas.safetensors
aria2c -c -x 16 -s 16 https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/sai_xl_depth_256lora.safetensors -d models/controlnet -o sai_xl_depth_256lora.safetensors
aria2c -c -x 16 -s 16 https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_depth_small.safetensors -d models/controlnet -o diffusers_xl_depth_small.safetensors
aria2c -c -x 16 -s 16 https://huggingface.co/TencentARC/t2i-adapter-dpenpose-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors -d models/controlnet -o t2i_openpose_sdxl.safetensors
aria2c -c -x 16 -s 16 https://huggingface.co/xinsir/controlnet-tile-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors -d models/controlnet -o tile_sdxl.safetensors

# aria2c -c -x 16 -s 16 https://huggingface.co/stabilityai/control-lora/resolve/main/control-LoRAs-rank256/control-lora-canny-rank256.safetensors -d models/controlnet -o
# aria2c -c -x 16 -s 16 https://huggingface.co/stabilityai/control-lora/resolve/main/control-LoRAs-rank256/control-lora-depth-rank256.safetensors -d models/controlnet -o
# aria2c -c -x 16 -s 16 https://huggingface.co/stabilityai/control-lora/resolve/main/control-LoRAs-rank256/control-lora-recolor-rank256.safetensors -d models/controlnet -o
# aria2c -c -x 16 -s 16 https://huggingface.co/stabilityai/control-lora/resolve/main/control-LoRAs-rank256/control-lora-sketch-rank256.safetensors -d models/controlnet -o


# Flux Controlnet

aria2c -c -x 16 -s 16 https://huggingface.co/Shakker-Labs/FLUX.1-dev-ControlNet-Union-Pro-2.0/resolve/main/diffusion_pytorch_model.safetensors -d models/controlnet -o flux_union_pro_2.0.safetensors