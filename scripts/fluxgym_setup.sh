# Create workspace directory if it doesn't exist
cd /workspace

# Set up FluxGym
echo "Setting up FluxGym..."
cd /workspace
git clone https://github.com/cocktailpeanut/fluxgym.git
cd fluxgym
python3.12 -m venv fluxgym_venv
source fluxgym_venv/bin/activate
python -m pip install --upgrade pip
git clone -b sd3 https://github.com/kohya-ss/sd-scripts.git
cd sd-scripts
echo "Installing sd-scripts dependencies..."
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128 -qq
pip install -r requirements.txt
cd ..
echo "Installing FluxGym dependencies..."
sed -i '/^torch$/d' requirements.txt
sed -i '/^torchvision$/d' requirements.txt
sed -i '/^torchaudio$/d' requirements.txt
pip install -r requirements.txt -qq
pip install -U bitsandbytes
pip install --upgrade --force-reinstall triton==2.2.0 -qq
deactivate
# Start FluxGym
echo "modifying gradio port"
sed -i 's/demo\.launch(debug=True, show_error=True, allowed_paths=\[cwd\])/demo.launch(debug=True, show_error=True, allowed_paths=\[cwd\], server_port=7000, server_name="0.0.0.0")/' app.py
echo "Starting FluxGym..."
cd /workspace/fluxgym && ./fluxgym_venv/bin/python app.py &