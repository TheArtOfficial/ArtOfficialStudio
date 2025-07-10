# Build script to create a self-contained ComfyUI installer executable
param(
    [string]$OutputName = "ComfyUI_Installer.exe",
    [switch]$IncludeWorkflows = $true
)

Write-Host "Building ComfyUI Installer Executable..." -ForegroundColor Cyan

# Check if PS2EXE is installed
if (-not (Get-Module -ListAvailable -Name PS2EXE)) {
    Write-Host "Installing PS2EXE module..." -ForegroundColor Yellow
    Install-Module -Name PS2EXE -Force -Scope CurrentUser
}

# Create temporary directory for packaging
$tempDir = Join-Path $env:TEMP "ComfyUI_Installer_Build"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -Path $tempDir -ItemType Directory | Out-Null

# Copy the main installer script
Copy-Item "windows_installer.ps1" (Join-Path $tempDir "installer.ps1")

# Copy workflows if requested and they exist
if ($IncludeWorkflows -and (Test-Path "workflows")) {
    Write-Host "Including workflows in executable..." -ForegroundColor Green
    Copy-Item "workflows" (Join-Path $tempDir "workflows") -Recurse
}

# Create a launcher script that extracts workflows and runs installer
$launcherScript = @"
# ComfyUI Installer Launcher
# This script extracts embedded workflows and runs the installer

param(
    [Parameter(Mandatory=$false)]
    [string]$InstallPath = "C:\ComfyUI",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipCustomNodes,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipStart
)

# Get the directory where this executable is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Extract embedded workflows if they exist
$workflowsDir = Join-Path $scriptDir "workflows"
if (Test-Path $workflowsDir) {
    Write-Host "Found embedded workflows, extracting..." -ForegroundColor Green
    # Workflows are already extracted by the executable
} else {
    Write-Host "No embedded workflows found." -ForegroundColor Yellow
}

# Run the installer with extracted workflows
$installerScript = Join-Path $scriptDir "installer.ps1"
if (Test-Path $installerScript) {
    & $installerScript -InstallPath $InstallPath -SkipCustomNodes:$SkipCustomNodes -SkipStart:$SkipStart
} else {
    Write-Host "Installer script not found!" -ForegroundColor Red
    exit 1
}
"@

Set-Content (Join-Path $tempDir "launcher.ps1") $launcherScript

# Build the executable
Write-Host "Building executable: $OutputName" -ForegroundColor Cyan

$ps2exeArgs = @(
    "-inputFile", (Join-Path $tempDir "launcher.ps1"),
    "-outputFile", $OutputName,
    "-noConsole",
    "-noVisualStyles",
    "-noError",
    "-requireAdmin",
    "-title", "ComfyUI Installer",
    "-version", "1.0.0.0",
    "-company", "Your Company Name",
    "-product", "ComfyUI Installer",
    "-description", "ComfyUI Installation Package"
)

# Add embedded files
if ($IncludeWorkflows -and (Test-Path "workflows")) {
    $ps2exeArgs += "-embeddedFiles"
    $ps2exeArgs += (Join-Path $tempDir "workflows")
    $ps2exeArgs += (Join-Path $tempDir "installer.ps1")
}

Invoke-ps2exe @ps2exeArgs

# Clean up
Remove-Item $tempDir -Recurse -Force

Write-Host "Executable created successfully: $OutputName" -ForegroundColor Green
Write-Host "File size: $((Get-Item $OutputName).Length / 1MB) MB" -ForegroundColor Cyan 