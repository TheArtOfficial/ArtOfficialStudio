docker build -f Dockerfile -t ghcr.io/theartofficial/artofficialstudio:latest .
docker push ghcr.io/theartofficial/artofficialstudio:latest

docker build -f DockerfileCu126 -t ghcr.io/theartofficial/artofficialstudio:Cu126latest .
docker push ghcr.io/theartofficial/artofficialstudio:Cu126latest

