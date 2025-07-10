cd "$(pwd)"
bash copy_wf_to_dock.sh
docker rm -f $(docker ps -aq)bas