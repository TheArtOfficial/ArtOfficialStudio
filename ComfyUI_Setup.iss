[Setup]
AppName=ComfyUI Installer
AppVersion=1.0
AppPublisher=Your Company Name
AppPublisherURL=https://yourwebsite.com
AppSupportURL=https://yourwebsite.com/support
AppUpdatesURL=https://yourwebsite.com/updates
DefaultDirName={autopf}\ComfyUI
DefaultGroupName=ComfyUI
AllowNoIcons=yes
LicenseFile=LICENSE.txt
OutputDir=Output
OutputBaseFilename=ComfyUI_Setup
SetupIconFile=icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
Source: "windows_installer.ps1"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "workflows\*"; DestDir: "{tmp}\workflows"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\ComfyUI"; Filename: "{app}\start_comfyui.bat"; WorkingDir: "{app}"
Name: "{group}\ComfyUI (PowerShell)"; Filename: "{app}\start_comfyui.ps1"; WorkingDir: "{app}"
Name: "{group}\{cm:UninstallProgram,ComfyUI}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\ComfyUI"; Filename: "{app}\start_comfyui.bat"; WorkingDir: "{app}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\ComfyUI"; Filename: "{app}\start_comfyui.bat"; WorkingDir: "{app}"; Tasks: quicklaunchicon

[Run]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{tmp}\windows_installer.ps1"" -InstallPath ""{app}"""; StatusMsg: "Installing ComfyUI..."; Flags: runhidden
Filename: "{app}\start_comfyui.bat"; Description: "{cm:LaunchProgram,ComfyUI}"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
  
  // Check if PowerShell is available
  if not Exec('powershell.exe', '-Command "exit"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    MsgBox('PowerShell is required but not found on this system. Please install PowerShell and try again.', mbError, MB_OK);
    Result := False;
    exit;
  end;
  
  // Check if Python is available
  if not Exec('python.exe', '--version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    if MsgBox('Python was not detected on this system. ComfyUI requires Python 3.10+. Do you want to continue anyway?', mbConfirmation, MB_YESNO) = IDNO then
    begin
      Result := False;
      exit;
    end;
  end;
  
  // Check if Git is available
  if not Exec('git.exe', '--version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    if MsgBox('Git was not detected on this system. ComfyUI requires Git. Do you want to continue anyway?', mbConfirmation, MB_YESNO) = IDNO then
    begin
      Result := False;
      exit;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Installation completed
    Log('ComfyUI installation completed successfully');
  end;
end; 