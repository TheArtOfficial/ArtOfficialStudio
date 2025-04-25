import unittest
import os
import sys
from unittest.mock import patch, MagicMock
import gradio as gr

# Add the parent directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from gradio_interface import create_interface

class TestGradioInterface(unittest.TestCase):
    def setUp(self):
        self.test_inputs = {
            "prompt": "A beautiful sunset over mountains",
            "negative_prompt": "blurry, low quality",
            "num_inference_steps": 20,
            "guidance_scale": 7.5,
            "seed": 42
        }

    @patch('gradio.Interface')
    def test_interface_creation(self, mock_interface):
        # Test interface creation
        interface = create_interface()
        
        # Verify interface was created
        self.assertIsNotNone(interface)
        mock_interface.assert_called_once()

    def test_input_validation(self):
        # Test input validation
        interface = create_interface()
        
        # Test valid inputs
        result = interface.process_inputs(**self.test_inputs)
        self.assertIsNotNone(result)
        
        # Test invalid inputs
        with self.assertRaises(ValueError):
            interface.process_inputs(
                prompt="",
                negative_prompt="",
                num_inference_steps=-1,
                guidance_scale=0,
                seed=-1
            )

    @patch('gradio_interface.generate_image')
    def test_image_generation(self, mock_generate):
        # Test image generation
        mock_generate.return_value = MagicMock()
        
        interface = create_interface()
        result = interface.generate(**self.test_inputs)
        
        # Verify generation was called
        mock_generate.assert_called_once()
        self.assertIsNotNone(result)

    def test_output_format(self):
        # Test output format
        interface = create_interface()
        result = interface.generate(**self.test_inputs)
        
        # Verify output format
        self.assertIsInstance(result, dict)
        self.assertIn('image', result)
        self.assertIn('metadata', result)

    def test_error_handling(self):
        # Test error handling
        interface = create_interface()
        
        # Test with invalid model path
        with self.assertRaises(FileNotFoundError):
            interface.load_model("invalid/path")
        
        # Test with invalid parameters
        with self.assertRaises(ValueError):
            interface.generate(
                prompt="test",
                negative_prompt="test",
                num_inference_steps=0,
                guidance_scale=0,
                seed=0
            )

if __name__ == '__main__':
    unittest.main() 