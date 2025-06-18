#!/bin/bash

docker run -it --gpus all --shm-size=32g \
--rm \
-p 80:80 \
-v /home/art-official/vol1:/workspace \
ghcr.io/theartofficial/artofficialstudio:latest