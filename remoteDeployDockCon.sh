docker run -it --gpus all \
--rm \
--network host \
-p 80:80 \
-v /home/art-official/vol1:/workspace \
ghcr.io/theartofficial/artofficialstudio:latest