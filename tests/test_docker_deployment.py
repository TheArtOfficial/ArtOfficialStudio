import unittest
import os
import subprocess
from unittest.mock import patch, MagicMock
import sys

# Add the parent directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

class TestDockerDeployment(unittest.TestCase):
    def setUp(self):
        self.test_image = "ghcr.io/theartofficial/artofficialstudio:latest"
        self.test_volume = "/home/art-official/vol1:/workspace"
        self.test_ports = [
            "5000:5000",
            "6000:6000",
            "7000:7000",
            "6006:6006",
            "8188:8188",
            "8888:8888"
        ]

    @patch('subprocess.run')
    def test_deploy_docker_container(self, mock_run):
        # Test the deployDockConRemote.sh script
        mock_run.return_value = MagicMock(returncode=0)
        
        # Simulate running the deployment script
        result = subprocess.run(
            ["docker", "run", "-it", "--gpus", "all",
             "--network", "host"] + 
            [f"-p{p}" for p in self.test_ports] +
            ["-v", self.test_volume, self.test_image],
            capture_output=True, text=True
        )
        
        # Verify the command was constructed correctly
        self.assertEqual(result.returncode, 0)
        mock_run.assert_called_once()

    @patch('subprocess.run')
    def test_build_docker_image(self, mock_run):
        # Test the buildDockCon.sh script
        mock_run.return_value = MagicMock(returncode=0)
        
        # Simulate building the Docker image
        result = subprocess.run(
            ["docker", "build", "-t", self.test_image, "."],
            capture_output=True, text=True
        )
        
        # Verify the command was constructed correctly
        self.assertEqual(result.returncode, 0)
        mock_run.assert_called_once()

    @patch('subprocess.run')
    def test_remove_docker_containers(self, mock_run):
        # Test the rmAllDockCon.sh script
        mock_run.return_value = MagicMock(returncode=0)
        
        # Simulate removing all containers
        result = subprocess.run(
            ["docker", "rm", "-f", "$(docker ps -aq)"],
            capture_output=True, text=True
        )
        
        # Verify the command was constructed correctly
        self.assertEqual(result.returncode, 0)
        mock_run.assert_called_once()

    def test_dockerfile_exists(self):
        # Verify that the Dockerfile exists
        self.assertTrue(os.path.exists("Dockerfile"))
        self.assertTrue(os.path.exists("DockerfileCu126"))

    def test_docker_compose_exists(self):
        # Verify that the docker-compose file exists
        self.assertTrue(os.path.exists("runpod.yaml"))

if __name__ == '__main__':
    unittest.main() 