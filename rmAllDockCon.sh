cd "$(pwd)"
bash copy_wf_to_dock.sh
docker stop aostudio
docker rm aostudio