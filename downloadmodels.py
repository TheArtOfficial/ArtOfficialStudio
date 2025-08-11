from huggingface_hub import snapshot_download
import shutil
import os

# Your target folder
target_folder = "Wan-AI_Wan2.1-VACE-1.3B"

# Download into HF cache (filtered)
snapshot_dir = snapshot_download(
    repo_id="Wan-AI/Wan2.1-VACE-1.3B"  # Add patterns you need
)

# Create target folder if it doesn't exist
os.makedirs(target_folder, exist_ok=True)

# Copy files into your target folder
for file_name in os.listdir(snapshot_dir):
    source_path = os.path.join(snapshot_dir, file_name)
    if os.path.isfile(source_path):
        shutil.copy(source_path, os.path.join(target_folder, file_name))