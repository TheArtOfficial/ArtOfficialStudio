# ComfyUI Windows Installer

This PowerShell script provides a clean, automated installation of ComfyUI on Windows systems.

## Prerequisites

Before running the installer, ensure you have:

1. **Python 3.10+** installed and added to your PATH
2. **Git** installed and added to your PATH
3. **NVIDIA GPU** (optional, but recommended for optimal performance)
4. **Windows PowerShell** (run as Administrator if needed)

## Usage

### Basic Installation
```powershell
.\windows_installer.ps1
```
This will install ComfyUI to `C:\ComfyUI` with all default settings.

### Custom Installation Path
```powershell
.\windows_installer.ps1 -InstallPath "D:\MyComfyUI"
```

### With Local Workflows
The script automatically copies workflows from the local `workflows/` folder if it exists in the same directory as the installer.

### Skip Custom Nodes Installation
```powershell
.\windows_installer.ps1 -SkipCustomNodes
```

### Install Only (Don't Start ComfyUI)
```powershell
.\windows_installer.ps1 -SkipStart
```

### Combined Options
```powershell
.\windows_installer.ps1 -InstallPath "D:\ComfyUI" -SkipStart
```

## Parameters

- `-InstallPath`: Custom installation directory (default: `C:\ComfyUI`)
- `-SkipCustomNodes`: Skip installation of custom nodes (faster installation)
- `-SkipStart`: Don't automatically start ComfyUI after installation

## What the Script Does

1. **Checks Prerequisites**: Verifies Python and Git are installed
2. **Creates Installation Directory**: Sets up the specified installation path
3. **Clones ComfyUI**: Downloads the latest ComfyUI repository
4. **Sets Up Virtual Environment**: Creates and activates a Python virtual environment
5. **Detects CUDA**: Automatically detects your CUDA version for optimal PyTorch installation
6. **Installs Dependencies**: Installs PyTorch and ComfyUI requirements
7. **Creates Model Directories**: Sets up standard ComfyUI directory structure
8. **Copies Workflows**: Automatically copies workflows from local `workflows/` folder if available
9. **Installs Custom Nodes**: Installs popular ComfyUI custom nodes (unless skipped)
10. **Configures Settings**: Sets up ComfyUI-Manager with auto-preview
11. **Creates Startup Scripts**: Generates convenient startup scripts
12. **Starts ComfyUI**: Launches ComfyUI (unless skipped)

## Custom Nodes Included

The script installs these popular custom nodes:
- ComfyUI-Manager
- KJNodes
- Crystools
- VideoHelperSuite
- Segment Anything 2
- Florence2
- WanVideoWrapper
- HunyuanVideoWrapper
- Easy-Use Nodes
- Impact Pack
- LatentSync Wrapper
- FramePack Wrapper
- ComfyUI Essentials
- ControlNet Aux
- Layer Style
- Ultimate SD Upscale
- RGThree Comfy
- Tea Cache
- Comfyroll Custom Nodes
- BRIA AI RMBG
- GGUF
- Hunyuan Loom
- Efficiency Nodes
- AnimateDiff Evolved
- RES4LYF
- LTX Video
- Audio Separation Nodes

## After Installation

Once installation is complete, you can start ComfyUI using:

1. **Double-click**: `start_comfyui.bat`
2. **PowerShell**: `.\start_comfyui.ps1`
3. **Manual**: Navigate to the installation directory and run the Python command

ComfyUI will be available at: **http://localhost:8188**

## Troubleshooting

### Common Issues

1. **"Python is not recognized"**
   - Install Python and ensure it's added to your PATH
   - Restart PowerShell after installing Python

2. **"Git is not recognized"**
   - Install Git and ensure it's added to your PATH
   - Restart PowerShell after installing Git

3. **Permission Denied**
   - Run PowerShell as Administrator
   - Check Windows Defender/Firewall settings

4. **CUDA Detection Issues**
   - The script will use CUDA 12.8 as fallback
   - Install NVIDIA drivers if you have an NVIDIA GPU

5. **Installation Fails**
   - Check your internet connection
   - Ensure you have sufficient disk space
   - Try running with `-SkipCustomNodes` for faster installation

### Logs

The script provides colored output to help identify issues:
- **Green**: Success messages
- **Yellow**: Warnings
- **Red**: Errors
- **Cyan**: Information

## Uninstalling

To uninstall ComfyUI, simply delete the installation directory:
```powershell
Remove-Item "C:\ComfyUI" -Recurse -Force
```

## Support

If you encounter issues:
1. Check the prerequisites
2. Review the troubleshooting section
3. Check the colored output for specific error messages
4. Ensure you have sufficient disk space and internet connectivity 