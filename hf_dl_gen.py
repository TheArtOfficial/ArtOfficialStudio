#!/usr/bin/env python3
"""
HuggingFace Download Script Generator

This script generates a shell script that downloads files from a Hugging Face repository
using aria2c. It can recursively search for files and supports file pattern matching.

Usage:
    python3 hf_download_generator.py --repo username/repo_name [--files "*.safetensors" "text_encoder/*"] [--output output.sh] [--precision fp16 fp32]

Requirements:
    pip install huggingface_hub
"""

import argparse
import os
import fnmatch
from pathlib import Path
from typing import List, Optional
import sys

try:
    from huggingface_hub import HfApi, list_repo_files, hf_hub_url
except ImportError:
    print("Error: Required package 'huggingface_hub' not found.")
    print("Please install it using: pip install huggingface_hub")
    sys.exit(1)


def get_repository_files(repo_id: str) -> List[str]:
    """
    Get all files from a HuggingFace repository.
    
    Args:
        repo_id: The repository ID (e.g., 'username/repo_name')
        
    Returns:
        List of file paths
    """
    try:
        api = HfApi()
        files = list_repo_files(repo_id)
        return files
    except Exception as e:
        print(f"Error fetching files from repository {repo_id}: {e}")
        sys.exit(1)


def filter_files(files: List[str], patterns: Optional[List[str]] = None, precisions: Optional[List[str]] = None) -> List[str]:
    """
    Filter files based on patterns and precision.
    
    Args:
        files: List of file paths
        patterns: List of glob patterns to match
        precisions: Filter by precision types (fp8, bf16, fp16, fp32, etc.)
        
    Returns:
        Filtered list of file paths
    """
    # Apply pattern filtering first
    filtered_by_pattern = files
    if patterns:
        filtered_by_pattern = []
        for file_path in files:
            for pattern in patterns:
                if fnmatch.fnmatch(file_path, pattern):
                    filtered_by_pattern.append(file_path)
                    break
    
    # If no precision filter is specified, return all pattern-filtered files
    if not precisions:
        return filtered_by_pattern
    
    # Apply precision filter
    filtered_by_precision = []
    
    # Common precision markers - Used to identify files without precision markers
    precision_markers = ['fp8', 'fp16', 'fp32', 'bf16']
    
    for file_path in filtered_by_pattern:
        file_path_lower = file_path.lower()
        
        # Check if file has no precision marker (always include these)
        has_any_precision = any(marker in file_path_lower for marker in precision_markers)
        
        if not has_any_precision:
            # This file has no precision marker, so always include it
            filtered_by_precision.append(file_path)
            continue
            
        # Check for requested precision markers
        for precision in precisions:
            # Skip 'none' as it's handled above
            if precision.lower() == 'none':
                continue
                
            if precision.lower() in file_path_lower:
                filtered_by_precision.append(file_path)
                break
    
    return filtered_by_precision


def generate_download_script(repo_id: str, files: List[str], output_path: str, model_name: Optional[str] = None):
    """
    Generate a shell script to download the files.
    
    Args:
        repo_id: The repository ID
        files: List of file paths
        output_path: Path to save the shell script
        model_name: Optional custom model name
    """
    display_name = model_name if model_name else f"{repo_id}"
    
    script_lines = [
        "#!/bin/bash",
        f"# Model: {display_name}",
        "",
        f"echo \"Downloading files from HuggingFace repository {repo_id}...\"",
        "",
        "# Create output directory if it doesn't exist",
        "mkdir -p \"/workspace/ComfyUI/models\"",
        ""
    ]
    
    # Add download commands
    for file_path in files:
        # Extract just the filename without directories
        filename = os.path.basename(file_path)
        
        # Generate the download URL using huggingface_hub
        download_url = hf_hub_url(repo_id=repo_id, filename=file_path, repo_type="model")
        
        script_lines.append(f"# Download {file_path}")
        script_lines.append(f"aria2c -x 16 -s 16 -d \"/workspace/ComfyUI/models\" \\\n"
                           f"    -o \"{filename}\" --auto-file-renaming=false --conditional-get=true \\\n"
                           f"    \"{download_url}\"")
        script_lines.append("")
    
    script_lines.append("echo \"All downloads completed!\"")
    
    # Write the script to file
    with open(output_path, "w") as f:
        f.write("\n".join(script_lines))
    
    # Make the script executable
    os.chmod(output_path, 0o755)
    print(f"Download script created at {output_path}")
    print(f"Total files to download: {len(files)}")


def main():
    parser = argparse.ArgumentParser(description="Generate a download script for HuggingFace repositories")
    parser.add_argument("--repo", required=True, help="HuggingFace repository ID (e.g., 'username/repo_name')")
    parser.add_argument("--files", nargs="+", help="Optional list of files or patterns to download (e.g., '*.safetensors' 'configs/*')")
    parser.add_argument("--output", default=None, help="Output script path")
    parser.add_argument("--model-name", default=None, help="Optional custom model name for the script header")
    parser.add_argument("--precision", nargs="+", choices=["fp8", "fp16", "fp32", "bf16"], 
                       help="Filter files by precision type(s). Multiple values can be specified (e.g., '--precision fp16 fp32'). Files without precision markers are always included. If not specified, all files are downloaded.")
    parser.add_argument("--folder", default=None, help="Optional folder to download files to")
    args = parser.parse_args()
    
    repo_id = args.repo
    file_patterns = args.files
    model_name = args.model_name
    precisions = args.precision
    
    folder = "scripts/preset_model_scripts"
    if args.folder:
        folder = args.folder
        
    # Determine output filename
    if args.output:
        output_path = args.output
    else:
        # Replace '/' with '_' to get 'user_repo' format
        repo_formatted = repo_id.replace('/', '_')
        output_path = f"{folder}/download_{repo_formatted}.sh"
        if precisions:
            precision_suffix = '_'.join(precisions)
            output_path = f"{folder}/download_{repo_formatted}_{precision_suffix}.sh"
    
    try:
        print(f"Fetching files from repository {repo_id}...")
        all_files = get_repository_files(repo_id)
        print(f"Found {len(all_files)} files in repository.")
        
        filtered_files = filter_files(all_files, file_patterns, precisions)
        
        if file_patterns:
            pattern_msg = f", patterns: {', '.join(file_patterns)}"
        else:
            pattern_msg = ""
            
        if precisions:
            precision_msg = f", precisions: [none, {', '.join(precisions)}]"
        else:
            precision_msg = ", downloading all files (no precision filter)"
            
        print(f"Filtered to {len(filtered_files)} files based on{pattern_msg}{precision_msg}")
        
        if not filtered_files:
            print("No files matched the provided filters.")
            return
        
        generate_download_script(repo_id, filtered_files, output_path, model_name)
        
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main() 