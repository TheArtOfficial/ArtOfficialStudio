# Set up ComfyUI
echo "Setting up ComfyUI..."
cd /workspace
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
python3.12 -m venv comfyui_venv
./comfyui_venv/bin/python -m pip install --upgrade pip -qq
echo "Installing ComfyUI requirements, this may take up to 5mins..."
./comfyui_venv/bin/pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128 -qq
sed -i '/^torch$/d' requirements.txt
sed -i '/^torchvision$/d' requirements.txt
sed -i '/^torchaudio$/d' requirements.txt
./comfyui_venv/bin/pip install -r requirements.txt -qq 

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
rm -rf /workspace/ComfyUI/user/default/workflows
mkdir -p /workspace/ComfyUI/user/default/workflows
mv /workspace/workflows/* /workspace/ComfyUI/user/default/workflows
rm -rf /workspace/workflows

# Install ComfyUI nodes
echo "Installing ComfyUI custom nodes..."
cd /workspace/ComfyUI/custom_nodes

# ComfyUI Manager
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ComfyUI-Manager
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# KJNodes
git clone https://github.com/kijai/ComfyUI-KJNodes.git
cd ComfyUI-KJNodes
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# Crystools
git clone https://github.com/crystian/ComfyUI-Crystools.git
cd ComfyUI-Crystools
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# VideoHelperSuite
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
cd ComfyUI-VideoHelperSuite
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# Segment Anything 2
git clone https://github.com/kijai/ComfyUI-Segment-Anything-2.git

# Florence2
git clone https://github.com/kijai/ComfyUI-Florence2.git
cd ComfyUI-Florence2
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# WanVideoWrapper
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
cd ComfyUI-WanVideoWrapper
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# HunyuanVideoWrapper
git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper.git
cd ComfyUI-HunyuanVideoWrapper
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# Easy-Use Nodes
git clone https://github.com/yolain/ComfyUI-Easy-Use.git
cd ComfyUI-Easy-Use
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# Impact Pack
git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
cd ComfyUI-Impact-Pack
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# LatentSync Wrapper
git clone https://github.com/ShmuelRonen/ComfyUI-LatentSyncWrapper.git
cd ComfyUI-LatentSyncWrapper
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# FramePackI2V
git clone https://github.com/kijai/ComfyUI-FramePackWrapper.git
cd ComfyUI-FramePackWrapper
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# ComfyUI Essentials
git clone https://github.com/cubiq/ComfyUI_essentials.git
cd ComfyUI_essentials
/workspace/ComfyUI/comfyui_venv/bin/pip install -r requirements.txt -qq
cd ..

# Fix onnxruntime for ComfyUI
echo "Fixing onnxruntime & Installing SageAttention for ComfyUI..."
cd /workspace/ComfyUI
./comfyui_venv/bin/pip uninstall -y onnxruntime -qq
./comfyui_venv/bin/pip install onnxruntime-gpu=="1.19" -qq
./comfyui_venv/bin/pip install https://huggingface.co/TheArtOfficialTrainer/cu128Torch128whls/resolve/main/sageattention-2.1.1-cp312-cp312-linux_x86_64.whl -qq

# Start ComfyUI
cd /workspace/ComfyUI && ./comfyui_venv/bin/python main.py --listen --port 8188 --preview-method auto > comfy.log 2>&1 &