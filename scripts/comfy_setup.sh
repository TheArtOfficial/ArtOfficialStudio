# Set up ComfyUI
echo "Setting up ComfyUI..."
cd /workspace
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
git fetch origin
git reset --hard origin/master
python3.12 -m venv comfyui_venv
./comfyui_venv/bin/python -m pip install --upgrade pip -qq
echo "Installing ComfyUI requirements, this may take up to 5mins..."
CUDA_VERSION=$(nvidia-smi | grep -oP "CUDA Version: \K[0-9]+\.[0-9]+")
echo "CUDA Version: $CUDA_VERSION"
# Set appropriate PyTorch index URL
if [[ "$CUDA_VERSION" == "12.8" ]]; then
    TORCH_INDEX_URL="https://download.pytorch.org/whl/nightly/cu128"
else
    TORCH_INDEX_URL="https://download.pytorch.org/whl/nightly/cu126"
fi
./comfyui_venv/bin/pip install --pre torch torchvision torchaudio --index-url $TORCH_INDEX_URL -qq
sed -i '/^torch$/d' requirements.txt
sed -i '/^torchvision$/d' requirements.txt
sed -i '/^torchaudio$/d' requirements.txt
./comfyui_venv/bin/pip install -r requirements.txt -qq 
./comfyui_venv/bin/pip install triton

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
# rm -rf /workspace/workflows

# Install ComfyUI nodes
echo "Installing ComfyUI custom nodes..."
cd /workspace/ComfyUI/custom_nodes

# ComfyUI Manager
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ComfyUI-Manager
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# KJNodes
git clone https://github.com/kijai/ComfyUI-KJNodes.git
cd ComfyUI-KJNodes
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# Crystools
git clone https://github.com/crystian/ComfyUI-Crystools.git
cd ComfyUI-Crystools
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# VideoHelperSuite
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
cd ComfyUI-VideoHelperSuite
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# Segment Anything 2
git clone https://github.com/kijai/ComfyUI-Segment-Anything-2.git
cd ComfyUI-Segment-Anything-2
git fetch origin
git reset --hard origin/main
cd ..

# Florence2
git clone https://github.com/kijai/ComfyUI-Florence2.git
cd ComfyUI-Florence2
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# WanVideoWrapper
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
cd ComfyUI-WanVideoWrapper
git fetch origin
git reset --hard origin/main
git switch -c dev --track origin/dev
git pull
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# HunyuanVideoWrapper
git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper.git
cd ComfyUI-HunyuanVideoWrapper
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# Easy-Use Nodes
git clone https://github.com/yolain/ComfyUI-Easy-Use.git
cd ComfyUI-Easy-Use
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# Impact Pack
git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
cd ComfyUI-Impact-Pack
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# LatentSync Wrapper
git clone https://github.com/ShmuelRonen/ComfyUI-LatentSyncWrapper.git
cd ComfyUI-LatentSyncWrapper
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# FramePackI2V
git clone https://github.com/kijai/ComfyUI-FramePackWrapper.git
cd ComfyUI-FramePackWrapper
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# ComfyUI Essentials
git clone https://github.com/cubiq/ComfyUI_essentials.git
cd ComfyUI_essentials
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git
cd comfyui_controlnet_aux
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

git clone https://github.com/chflame163/ComfyUI_LayerStyle.git
cd ComfyUI_LayerStyle
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale --recursive
cd ComfyUI_UltimateSDUpscale
git fetch origin
git reset --hard origin/main
cd ..

git clone https://github.com/rgthree/rgthree-comfy.git
cd rgthree-comfy
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

git clone https://github.com/welltop-cn/ComfyUI-TeaCache.git
cd ComfyUI-TeaCache
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git
cd ComfyUI_Comfyroll_CustomNodes
git fetch origin
git reset --hard origin/main
cd ..

git clone https://github.com/ZHO-ZHO-ZHO/ComfyUI-BRIA_AI-RMBG.git
cd ComfyUI-BRIA_AI-RMBG
git fetch origin
git reset --hard origin/main
cd ..

git clone https://github.com/SozeInc/ComfyUI_Soze.git
cd ComfyUI_Soze
git fetch origin
git reset --hard origin/main   
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

git clone https://github.com/city96/ComfyUI-GGUF.git
cd ComfyUI-GGUF
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

git clone https://github.com/logtd/ComfyUI-HunyuanLoom.git
cd ComfyUI-HunyuanLoom
git fetch origin
git reset --hard origin/main
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt
cd ..

# Fix onnxruntime for ComfyUI
echo "Fixing onnxruntime & Installing SageAttention for ComfyUI..."
cd /workspace/ComfyUI
./comfyui_venv/bin/pip uninstall -y onnxruntime
./comfyui_venv/bin/pip install onnxruntime-gpu=="1.19" sageattention

# Start ComfyUI
cd /workspace/ComfyUI && ./comfyui_venv/bin/python main.py --listen --port 8188 --preview-method auto > comfy.log 2>&1 &