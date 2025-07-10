@echo off
echo Creating ComfyUI Self-Extracting Installer...

REM Check if WinRAR is installed
where rar >nul 2>&1
if %errorlevel% neq 0 (
    echo WinRAR is not installed or not in PATH
    echo Please install WinRAR and try again
    pause
    exit /b 1
)

REM Create temporary directory
set "tempDir=%TEMP%\ComfyUI_SFX_Build"
if exist "%tempDir%" rmdir /s /q "%tempDir%"
mkdir "%tempDir%"

REM Copy files to temp directory
copy "windows_installer.ps1" "%tempDir%\"
if exist "workflows" xcopy "workflows" "%tempDir%\workflows\" /e /i /y

REM Create SFX comment file
echo Setup=PowerShell.exe -ExecutionPolicy Bypass -File "windows_installer.ps1" > "%tempDir%\sfx_comment.txt"
echo TempMode >> "%tempDir%\sfx_comment.txt"
echo Silent=1 >> "%tempDir%\sfx_comment.txt"
echo Overwrite=1 >> "%tempDir%\sfx_comment.txt"
echo Title=ComfyUI Installer >> "%tempDir%\sfx_comment.txt"
echo Text=Extracting ComfyUI installer... >> "%tempDir%\sfx_comment.txt"

REM Create the SFX archive
rar a -sfx -z"%tempDir%\sfx_comment.txt" "ComfyUI_Installer.exe" "%tempDir%\*"

REM Clean up
rmdir /s /q "%tempDir%"

echo Self-extracting installer created: ComfyUI_Installer.exe
pause 