param(
    [Parameter(Mandatory=$false)]
    [string]$InstallPath = "C:\ComfyUI",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipCustomNodes,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipStart
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Function to check if directory exists and is empty
function Test-DirectoryEmpty {
    param([string]$Path)
    if (Test-Path $Path) {
        $items = Get-ChildItem $Path -Force
        return ($items.Count -eq 0)
    }
    return $true
}

# Check prerequisites
Write-ColorOutput "Checking prerequisites..." "Cyan"

if (-not (Test-Command "python")) {
    Write-ColorOutput "ERROR: Python is not installed or not in PATH" "Red"
    Write-ColorOutput "Please install Python 3.10+ and ensure it's in your PATH" "Yellow"
    exit 1
}

if (-not (Test-Command "git")) {
    Write-ColorOutput "ERROR: Git is not installed or not in PATH" "Red"
    Write-ColorOutput "Please install Git and ensure it's in your PATH" "Yellow"
    exit 1
}

# Get Python version
$pythonVersion = python --version 2>&1
Write-ColorOutput "Found: $pythonVersion" "Green"

# Create installation directory
Write-ColorOutput "Setting up installation directory: $InstallPath" "Cyan"

if (Test-Path $InstallPath) {
    if (-not (Test-DirectoryEmpty $InstallPath)) {
        Write-ColorOutput "WARNING: Installation directory is not empty!" "Yellow"
        $response = Read-Host "Do you want to continue? (y/N)"
        if ($response -ne "y" -and $response -ne "Y") {
            Write-ColorOutput "Installation cancelled." "Red"
            exit 1
        }
    }
} else {
    New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
}

# Set working directory
Set-Location $InstallPath

# Clone ComfyUI
Write-ColorOutput "Cloning ComfyUI repository..." "Cyan"
if (Test-Path "ComfyUI") {
    Write-ColorOutput "ComfyUI directory already exists, updating..." "Yellow"
    Set-Location "ComfyUI"
    git fetch origin
    git reset --hard origin/master
} else {
    git clone https://github.com/comfyanonymous/ComfyUI.git
    Set-Location "ComfyUI"
}

# Create and activate virtual environment
if (Test-Path "comfyui_venv") {
    Write-ColorOutput "Virtual environment already exists, using existing..." "Green"
} else {
    Write-ColorOutput "Creating virtual environment..." "Cyan"
    python -m venv comfyui_venv
}

# Activate virtual environment
Write-ColorOutput "Activating virtual environment..." "Cyan"
$venvScripts = Join-Path $PWD "comfyui_venv\Scripts"
$env:PATH = "$venvScripts;$env:PATH"

# Upgrade pip
Write-ColorOutput "Upgrading pip..." "Cyan"
& "$venvScripts\python.exe" -m pip install --upgrade pip -qq

# Detect CUDA version using PyTorch after installation
Write-ColorOutput "Installing PyTorch first to detect CUDA version..." "Cyan"
$cudaVersion = "12.8"  # Default fallback

# Install PyTorch CPU first to get torch module
& "$venvScripts\python.exe" -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Now detect CUDA version using PyTorch
Write-ColorOutput "Detecting CUDA version using PyTorch..." "Cyan"
try {
    $cudaDetectionScript = @"
import torch
if torch.cuda.is_available():
    cuda_version = torch.version.cuda
    print(f"CUDA_VERSION:{cuda_version}")
else:
    print("CUDA_VERSION:CPU_ONLY")
"@
    
    $cudaOutput = & "$venvScripts\python.exe" -c $cudaDetectionScript 2>&1
    if ($cudaOutput -match "CUDA_VERSION:(\d+\.\d+)") {
        $cudaVersion = $matches[1]
        Write-ColorOutput "PyTorch detected CUDA Version: $cudaVersion" "Green"
    } elseif ($cudaOutput -match "CUDA_VERSION:CPU_ONLY") {
        Write-ColorOutput "No CUDA detected, will use CPU-only PyTorch" "Yellow"
        $cudaVersion = "CPU"
    } else {
        Write-ColorOutput "Could not detect CUDA version, using default: $cudaVersion" "Yellow"
    }
} catch {
    Write-ColorOutput "CUDA detection failed, using default CUDA version: $cudaVersion" "Yellow"
}

# Map CUDA version to PyTorch index and reinstall if needed
if ($cudaVersion -eq "CPU") {
    Write-ColorOutput "Using CPU-only PyTorch (already installed)" "Green"
    $TORCH_INDEX_URL = "https://download.pytorch.org/whl/cpu"
} else {
    switch ($cudaVersion) {
        "12.8" { $TORCH_INDEX_URL = "https://download.pytorch.org/whl/cu128" }
        "12.6" { $TORCH_INDEX_URL = "https://download.pytorch.org/whl/cu126" }
        "12.5" { $TORCH_INDEX_URL = "https://download.pytorch.org/whl/cu125" }
        "12.4" { $TORCH_INDEX_URL = "https://download.pytorch.org/whl/cu124" }
        default { 
            Write-ColorOutput "Unknown CUDA version '$cudaVersion', using cu128 as fallback" "Yellow"
            $TORCH_INDEX_URL = "https://download.pytorch.org/whl/cu128"
        }
    }
    
    # Reinstall PyTorch with correct CUDA version
    Write-ColorOutput "Reinstalling PyTorch with CUDA support from: $TORCH_INDEX_URL" "Cyan"
    & "$venvScripts\python.exe" -m pip uninstall torch torchvision torchaudio -y
    & "$venvScripts\python.exe" -m pip install torch torchvision torchaudio --index-url $TORCH_INDEX_URL
}

# Install main requirements
Write-ColorOutput "Installing ComfyUI requirements..." "Cyan"
& "$venvScripts\python.exe" -m pip install -r requirements.txt --extra-index-url $TORCH_INDEX_URL

# Create model directories
Write-ColorOutput "Creating model directories..." "Cyan"
$dirs = @(
    "models\diffusion_models", "models\checkpoints", "models\vae",
    "models\controlnet", "models\loras", "models\clip_vision",
    "models\text_encoders", "user\default\workflows"
)
foreach ($dir in $dirs) {
    $fullPath = Join-Path $PWD $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
    }
}

# Copy workflows from local workflows folder
$localWorkflowsPath = Join-Path $PSScriptRoot "workflows"
if (Test-Path $localWorkflowsPath) {
    Write-ColorOutput "Copying workflows from local workflows folder..." "Cyan"
    $workflowsDest = Join-Path $PWD "user\default\workflows"
    Copy-Item -Path "$localWorkflowsPath\*" -Destination $workflowsDest -Recurse -Force
    Write-ColorOutput "Workflows copied successfully!" "Green"
} else {
    Write-ColorOutput "No local workflows folder found, skipping workflow copy" "Yellow"
}

# Install custom nodes
if (-not $SkipCustomNodes) {
    Write-ColorOutput "Installing ComfyUI custom nodes..." "Cyan"
    Set-Location "custom_nodes"

    $repos = @(
        @{repo="ltdrdata/ComfyUI-Manager"; branch="main"},
        @{repo="kijai/ComfyUI-KJNodes"; branch="main"},
        @{repo="crystian/ComfyUI-Crystools"; branch="main"},
        @{repo="Kosinkadink/ComfyUI-VideoHelperSuite"; branch="main"},
        @{repo="kijai/ComfyUI-Segment-Anything-2"; branch="main"},
        @{repo="kijai/ComfyUI-Florence2"; branch="main"},
        @{repo="kijai/ComfyUI-WanVideoWrapper"; branch="multitalk"},
        @{repo="kijai/ComfyUI-HunyuanVideoWrapper"; branch="main"},
        @{repo="yolain/ComfyUI-Easy-Use"; branch="main"},
        @{repo="ltdrdata/ComfyUI-Impact-Pack"; branch="main"},
        @{repo="ShmuelRonen/ComfyUI-LatentSyncWrapper"; branch="main"},
        @{repo="kijai/ComfyUI-FramePackWrapper"; branch="main"},
        @{repo="cubiq/ComfyUI_essentials"; branch="main"},
        @{repo="Fannovel16/comfyui_controlnet_aux"; branch="main"},
        @{repo="chflame163/ComfyUI_LayerStyle"; branch="main"},
        @{repo="ssitu/ComfyUI_UltimateSDUpscale"; branch="main"},
        @{repo="rgthree/rgthree-comfy"; branch="main"},
        @{repo="welltop-cn/ComfyUI-TeaCache"; branch="main"},
        @{repo="Suzie1/ComfyUI_Comfyroll_CustomNodes"; branch="main"},
        @{repo="ZHO-ZHO-ZHO/ComfyUI-BRIA_AI-RMBG"; branch="main"},
        @{repo="city96/ComfyUI-GGUF"; branch="main"},
        @{repo="logtd/ComfyUI-HunyuanLoom"; branch="main"},
        @{repo="jags111/efficiency-nodes-comfyui"; branch="main"},
        @{repo="Kosinkadink/ComfyUI-AnimateDiff-Evolved"; branch="main"},
        @{repo="ClownsharkBatwing/RES4LYF"; branch="main"},
        @{repo="Lightricks/ComfyUI-LTXVideo"; branch="main"},
        @{repo="christian-byrne/audio-separation-nodes-comfyui"; branch="master"}
    )

    foreach ($repoInfo in $repos) {
        $repo = $repoInfo.repo
        $branch = $repoInfo.branch
        $repoName = ($repo -split "/")[1]
        
        Write-ColorOutput "Installing $repoName..." "Cyan"
        
        try {
            if (Test-Path $repoName) {
                Write-ColorOutput "  Updating existing $repoName..." "Yellow"
                Set-Location $repoName
                git fetch origin
                git reset --hard "origin/$branch"
            } else {
                Write-ColorOutput "  Cloning $repoName..." "Yellow"
                git clone "https://github.com/$repo.git"
                Set-Location $repoName
                git checkout $branch
            }
            
            # Install requirements if they exist
            if (Test-Path "requirements.txt") {
                Write-ColorOutput "  Installing requirements for $repoName..." "Yellow"
                & "$venvScripts\..\..\comfyui_venv\Scripts\python.exe" -m pip install -r requirements.txt
            }
            
            Set-Location ".."
        } catch {
            Write-ColorOutput "  Failed to install $repoName`: $($_.Exception.Message)" "Red"
            Set-Location ".."
        }
    }

    # Return to ComfyUI root
    Set-Location ".."
}

# Run preview fix script if available
$previewScript = Join-Path $PWD "scripts\modifier_scripts\ensure_previews.py"
if (Test-Path $previewScript) {
    Write-ColorOutput "Running preview fix script..." "Cyan"
    $settingsPath = Join-Path $PWD "user\default\comfy.settings.json"
    & "$venvScripts\python.exe" $previewScript $settingsPath
}

# Patch onnxruntime and install additional packages
Write-ColorOutput "Installing additional packages..." "Cyan"
& "$venvScripts\python.exe" -m pip uninstall -y onnxruntime-gpu
& "$venvScripts\python.exe" -m pip install onnxruntime-gpu hf_transfer sageattention

# Enable auto-preview in ComfyUI-Manager
$configPath = Join-Path $PWD "user\default\ComfyUI-Manager\config.ini"
if (Test-Path $configPath) {
    Write-ColorOutput "Configuring ComfyUI-Manager..." "Cyan"
    $content = Get-Content $configPath -Raw
    $content = $content -replace "preview_method = none", "preview_method = auto"
    Set-Content $configPath $content -NoNewline
}

# Create startup script
$startupScript = Join-Path $PWD "start_comfyui.bat"
$startupContent = @"
@echo off
cd /d "$InstallPath\ComfyUI"
call comfyui_venv\Scripts\activate.bat
python main.py --listen --port 8188
pause
"@
Set-Content $startupScript $startupContent

# Create PowerShell startup script
$startupPSScript = Join-Path $PWD "start_comfyui.ps1"
$startupPSContent = @"
Set-Location "$InstallPath\ComfyUI"
& ".\comfyui_venv\Scripts\python.exe" main.py --listen --port 8188
"@
Set-Content $startupPSScript $startupPSContent

Write-ColorOutput "`nInstallation completed successfully!" "Green"
Write-ColorOutput "ComfyUI has been installed to: $InstallPath\ComfyUI" "Green"
Write-ColorOutput "`nTo start ComfyUI:" "Yellow"
Write-ColorOutput "  - Double-click: start_comfyui.bat" "White"
Write-ColorOutput "  - Or run: .\start_comfyui.ps1" "White"
Write-ColorOutput "  - Or manually: cd $InstallPath\ComfyUI && .\comfyui_venv\Scripts\python.exe main.py --listen --port 8188" "White"
Write-ColorOutput "`nComfyUI will be available at: http://localhost:8188" "Cyan"

# Start ComfyUI if not skipped
if (-not $SkipStart) {
    Write-ColorOutput "`nStarting ComfyUI..." "Cyan"
    Start-Process "$venvScripts\python.exe" -ArgumentList "main.py", "--listen", "--port", "8188" -WorkingDirectory $PWD -NoNewWindow
    Write-ColorOutput "ComfyUI is starting up..." "Green"
    Write-ColorOutput "You can access it at: http://localhost:8188" "Cyan"
}
