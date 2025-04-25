import unittest
import os
import tempfile
from pathlib import Path
from unittest.mock import patch, MagicMock
import sys

# Add the parent directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from hf_dl_gen import get_repository_files, filter_files, generate_download_script

class TestHuggingFaceDownloadGenerator(unittest.TestCase):
    def setUp(self):
        self.test_repo = "test_user/test_repo"
        self.temp_dir = tempfile.mkdtemp()
        self.test_files = [
            "model.safetensors",
            "config.json",
            "text_encoder/model.safetensors",
            "vae/diffusion_pytorch_model.safetensors"
        ]

    @patch('hf_dl_gen.HfApi')
    @patch('hf_dl_gen.list_repo_files')
    def test_get_repository_files(self, mock_list_repo_files, mock_hf_api):
        # Setup mock
        mock_list_repo_files.return_value = self.test_files
        
        # Test
        result = get_repository_files(self.test_repo)
        
        # Assertions
        self.assertEqual(result, self.test_files)
        mock_list_repo_files.assert_called_once_with(self.test_repo)

    def test_filter_files_no_patterns(self):
        # Test filtering without patterns
        result = filter_files(self.test_files)
        self.assertEqual(result, self.test_files)

    def test_filter_files_with_patterns(self):
        # Test filtering with patterns
        patterns = ["*.safetensors"]
        result = filter_files(self.test_files, patterns)
        expected = ["model.safetensors", "text_encoder/model.safetensors"]
        self.assertEqual(result, expected)

    def test_filter_files_with_precision(self):
        # Test filtering with precision
        files = [
            "model_fp16.safetensors",
            "model_fp32.safetensors",
            "config.json"
        ]
        precisions = ["fp16"]
        result = filter_files(files, precisions=precisions)
        expected = ["model_fp16.safetensors", "config.json"]
        self.assertEqual(result, expected)

    def test_generate_download_script(self):
        # Test script generation
        output_path = os.path.join(self.temp_dir, "test_script.sh")
        generate_download_script(self.test_repo, self.test_files, output_path)
        
        # Verify script was created
        self.assertTrue(os.path.exists(output_path))
        
        # Verify script content
        with open(output_path, 'r') as f:
            content = f.read()
            self.assertIn("#!/bin/bash", content)
            self.assertIn(self.test_repo, content)
            for file in self.test_files:
                self.assertIn(file, content)

    def tearDown(self):
        # Cleanup
        if os.path.exists(self.temp_dir):
            for root, dirs, files in os.walk(self.temp_dir, topdown=False):
                for name in files:
                    os.remove(os.path.join(root, name))
                for name in dirs:
                    os.rmdir(os.path.join(root, name))
            os.rmdir(self.temp_dir)

if __name__ == '__main__':
    unittest.main() 