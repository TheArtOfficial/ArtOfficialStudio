docker run -it --gpus all \
--rm \
--network host \
-p 80:80 \
-v /comfyvol:/workspace \
ghcr.io/theartofficial/artofficialstudio:latest