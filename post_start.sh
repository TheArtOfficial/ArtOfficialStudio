#!/bin/bash

echo "Starting post-installation setup..."

/scripts/comfy_setup.sh

/scripts/fluxgym_setup.sh

/scripts/userform_setup.sh

/scripts/diffpipe_setup.sh

echo "Post-installation setup complete!"

# Run model download scripts
echo "Starting model downloads..."
/scripts/download_sdxl.sh 
/scripts/download_wan21.sh
/scripts/download_wan21_fun.sh
/scripts/download_wrapper_models.sh
/scripts/download_hunyuan.sh

sleep infinity