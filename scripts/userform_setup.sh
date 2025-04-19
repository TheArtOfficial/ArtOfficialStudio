# Set up model downloaders
echo "Setting up flux model downloaders..."
cd /flux_model_downloader
python3.12 -m venv flask_venv
./flask_venv/bin/pip install flask gunicorn gevent -qq
# Start Flux Model Downloader
cd /flux_model_downloader && ./flask_venv/bin/python app.py --port 5000 &

echo "Setting up civitai model downloaders..."
cd /
mkdir -p civitai_model_downloader/templates
cd civitai_model_downloader
python3.12 -m venv civitai_venv
./civitai_venv/bin/pip install flask gunicorn gevent -qq
# Start CivitAI Model Downloader
cd /civitai_model_downloader && ./civitai_venv/bin/python app.py --port 5001 &