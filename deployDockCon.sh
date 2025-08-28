cd "$(pwd)"
bash copy_wf_to_dock.sh
docker stop aostudio
docker rm aostudio
docker run -it --name aostudio --gpus all --shm-size=32g --rm -p 8080:80 -v /home/theartofficial/comfyvol:/workspace theartofficial/artofficialstudio:latest