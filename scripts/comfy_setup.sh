# Set up ComfyUI
echo "Setting up ComfyUI..."
cd /workspace
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
git fetch origin
git reset --hard origin/master
python3.12 -m venv comfyui_venv
source comfyui_venv/bin/activate
python /scripts/modifier_scripts/frontend_fix.py '' ''/workspace/ComfyUI
python -m pip install --upgrade pip -qq
echo "Installing ComfyUI requirements, this may take up to 5mins..."
CUDA_VERSION=$(nvcc --version | grep -oP "release \K[0-9]+\.[0-9]+")
echo "CUDA Version: $CUDA_VERSION"
# Set appropriate PyTorch index URL
if [[ "$CUDA_VERSION" == "12.8" ]]; then
    TORCH_INDEX_URL="https://download.pytorch.org/whl/cu128"
elif [[ "$CUDA_VERSION" == "12.6" ]]; then
    TORCH_INDEX_URL="https://download.pytorch.org/whl/cu126"
elif [[ "$CUDA_VERSION" == "12.5" ]]; then
    TORCH_INDEX_URL="https://download.pytorch.org/whl/cu125"
elif [[ "$CUDA_VERSION" == "12.4" ]]; then
    TORCH_INDEX_URL="https://download.pytorch.org/whl/cu124"
else
    TORCH_INDEX_URL="https://download.pytorch.org/whl/cu128"
fi
/workspace/ComfyUI/comfyui_venv/bin/pip install torch torchvision torchaudio --index-url $TORCH_INDEX_URL
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt --extra-index-url $TORCH_INDEX_URL
/workspace/ComfyUI/comfyui_venv/bin/pip install comfyui_frontend_package --upgrade
/workspace/ComfyUI/comfyui_venv/bin/pip install comfyui_workflow_templates --upgrade
/workspace/ComfyUI/comfyui_venv/bin/pip install comfyui_embedded_docs --upgrade
# Create model directories
echo "Creating model directories..."
mkdir -p models/diffusion_models
mkdir -p models/checkpoints
mkdir -p models/vae
mkdir -p models/controlnet
mkdir -p models/loras
mkdir -p models/clip_vision
mkdir -p models/text_encoders

# Set up directory structure
echo "Setting up directory structure..."
mkdir -p /workspace/ComfyUI/user/default/workflows
cp -r /workflows/* /workspace/ComfyUI/user/default/workflows
chmod -R 777 /workspace/ComfyUI/user/default/workflows
# rm -rf /workspace/workflows
mkdir -p /workspace/ComfyUI/models/checkpoints

# Install ComfyUI nodes
echo "Installing ComfyUI custom nodes..."
cd /workspace/ComfyUI/custom_nodes

# ComfyUI Manager
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ComfyUI-Manager
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

# KJNodes
git clone https://github.com/kijai/ComfyUI-KJNodes.git
cd ComfyUI-KJNodes
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

# Crystools
git clone https://github.com/crystian/ComfyUI-Crystools.git
cd ComfyUI-Crystools
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

# VideoHelperSuite
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
cd ComfyUI-VideoHelperSuite
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes
/workspace/ComfyUI/comfyui_venv/bin/python /scripts/modifier_scripts/ensure_previews.py /workspace/ComfyUI/user/default/comfy.settings.json

# Segment Anything 2
git clone https://github.com/kijai/ComfyUI-Segment-Anything-2.git
cd ComfyUI-Segment-Anything-2
git fetch origin
git reset --hard origin/main
cd /workspace/ComfyUI/custom_nodes

# Florence2
git clone https://github.com/kijai/ComfyUI-Florence2.git
cd ComfyUI-Florence2
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

# WanVideoWrapper
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
cd ComfyUI-WanVideoWrapper
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

# HunyuanVideoWrapper
git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper.git
cd ComfyUI-HunyuanVideoWrapper
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

# Easy-Use Nodes
git clone https://github.com/yolain/ComfyUI-Easy-Use.git
cd ComfyUI-Easy-Use
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

# Impact Pack
git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
cd ComfyUI-Impact-Pack
git fetch origin
git reset --hard origin/Main
cd /workspace/ComfyUI/custom_nodes

# LatentSync Wrapper
git clone https://github.com/ShmuelRonen/ComfyUI-LatentSyncWrapper.git
cd ComfyUI-LatentSyncWrapper
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
/workspace/ComfyUI/comfyui_venv/bin/pip install insightface
cd /workspace/ComfyUI/custom_nodes

# FramePackI2V
git clone https://github.com/kijai/ComfyUI-FramePackWrapper.git
cd ComfyUI-FramePackWrapper
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

# ComfyUI Essentials
git clone https://github.com/cubiq/ComfyUI_essentials.git
cd ComfyUI_essentials
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git
cd comfyui_controlnet_aux
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/chflame163/ComfyUI_LayerStyle.git
cd ComfyUI_LayerStyle
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale --recursive
cd ComfyUI_UltimateSDUpscale
git fetch origin
git reset --hard origin/main
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/rgthree/rgthree-comfy.git
cd rgthree-comfy
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/welltop-cn/ComfyUI-TeaCache.git
cd ComfyUI-TeaCache
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git
cd ComfyUI_Comfyroll_CustomNodes
git fetch origin
git reset --hard origin/main
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/ZHO-ZHO-ZHO/ComfyUI-BRIA_AI-RMBG.git
cd ComfyUI-BRIA_AI-RMBG
git fetch origin
git reset --hard origin/main
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/city96/ComfyUI-GGUF.git
cd ComfyUI-GGUF
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/logtd/ComfyUI-HunyuanLoom.git
cd ComfyUI-HunyuanLoom
git fetch origin
git reset --hard origin/main
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/jags111/efficiency-nodes-comfyui.git
cd efficiency-nodes-comfyui
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git
cd ComfyUI-AnimateDiff-Evolved
git fetch origin
git reset --hard origin/main
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/ClownsharkBatwing/RES4LYF.git
cd RES4LYF
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/Lightricks/ComfyUI-LTXVideo.git
cd ComfyUI-LTXVideo
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/christian-byrne/audio-separation-nodes-comfyui.git
cd audio-separation-nodes-comfyui
git fetch origin
git reset --hard origin/master
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler.git
cd ComfyUI-SeedVR2_VideoUpscaler
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
cd ComfyUI-Custom-Scripts
git fetch origin
git reset --hard origin/main
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/AIWarper/ComfyUI-NormalCrafterWrapper.git
cd ComfyUI-NormalCrafterWrapper
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/akatz-ai/ComfyUI-DepthCrafter-Nodes.git
cd ComfyUI-DepthCrafter-Nodes
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/kijai/ComfyUI-Hunyuan3DWrapper.git
cd ComfyUI-Hunyuan3DWrapper
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
source /workspace/ComfyUI/comfyui_venv/bin/activate
cd ./hy3dgen/texgen/custom_rasterizer
/workspace/ComfyUI/comfyui_venv/bin/python setup.py install
cd ..
cd ./differentiable_renderer
/workspace/ComfyUI/comfyui_venv/bin/python setup.py build_ext --inplace
deactivate
cd /workspace/ComfyUI/custom_nodes

# Fix onnxruntime for ComfyUI
echo "Fixing onnxruntime & Installing SageAttention for ComfyUI..."
cd /workspace/ComfyUI
/workspace/ComfyUI/comfyui_venv/bin/python -m pip uninstall -y onnxruntime-gpu
/workspace/ComfyUI/comfyui_venv/bin/python -m pip install onnxruntime-gpu hf_transfer
VENV_PYTHON="/workspace/ComfyUI/comfyui_venv/bin/python"
PIP_OUTPUT=$("$VENV_PYTHON" -m pip list)
python -m pip install sageattention
# Update ComfyUI-Manager config to use auto preview method
sed -i 's/preview_method = none/preview_method = auto/' /workspace/ComfyUI/user/default/ComfyUI-Manager/config.ini

# Start ComfyUI
cd /workspace/ComfyUI && ./comfyui_venv/bin/python main.py --listen --port 8188 > comfy.log 2>&1 &
