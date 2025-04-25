docker run -it --gpus all \
--network host \
-p 5000:5000 \
-p 6000:6000 \
-p 7000:7000 \
-p 6006:6006 \
-p 8188:8188 \
-p 8888:8888 \
-v /home/art-official/vol1:/workspace \
ghcr.io/theartofficial/artofficialstudio:latest