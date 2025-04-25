docker run -it --gpus all \
--network host \
-p 80:80 \
-v /home/art-official/vol1:/workspace \
ghcr.io/theartofficial/artofficialstudio:cu126latest