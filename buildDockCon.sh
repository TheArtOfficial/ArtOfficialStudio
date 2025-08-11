cd "$(pwd)"

dos2unix convertToUnix.sh
bash convertToUnix.sh


docker build -f Dockerfile -t theartofficial/artofficialstudio:latest .

docker build -f DockerfileCu126 -t theartofficial/artofficialstudio:cu126latest .

docker build -f DockerfileCu125 -t theartofficial/artofficialstudio:cu125latest .

docker build -f DockerfileCu124 -t theartofficial/artofficialstudio:cu124latest .

docker build -f Dockerfile -t ghcr.io/theartofficial/artofficialstudio:latest .

docker build -f DockerfileCu126 -t ghcr.io/theartofficial/artofficialstudio:cu126latest .

docker build -f DockerfileCu125 -t ghcr.io/theartofficial/artofficialstudio:cu125latest .

docker build -f DockerfileCu124 -t ghcr.io/theartofficial/artofficialstudio:cu124latest .

docker build -f Dockerfile -t ghcr.io/theartofficial/artofficialstudio:devlatest .
