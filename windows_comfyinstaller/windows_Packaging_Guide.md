# ComfyUI Installer Packaging Guide

This guide explains how to package your ComfyUI installer with workflows into a distributable executable for commercial distribution.

## Method 1: PS2EXE (Recommended - Easiest)

### Prerequisites
- PowerShell 5.1 or later
- Internet connection (for first run to install PS2EXE module)

### Steps

1. **Run the build script:**
   ```powershell
   .\build_installer.ps1
   ```

2. **Customize the output:**
   ```powershell
   .\build_installer.ps1 -OutputName "MyComfyUI_Installer.exe" -IncludeWorkflows
   ```

### Features
- ✅ Single executable file
- ✅ Embedded workflows
- ✅ No external dependencies
- ✅ Professional metadata
- ✅ Admin privileges request
- ✅ Silent extraction

### File Size
- Without workflows: ~2-5 MB
- With workflows: Depends on workflow size

---

## Method 2: WinRAR Self-Extracting Archive

### Prerequisites
- WinRAR installed and in PATH
- Windows batch scripting

### Steps

1. **Run the batch script:**
   ```cmd
   create_sfx_installer.bat
   ```

2. **Or manually create SFX:**
   ```cmd
   rar a -sfx -zsfx_comment.txt ComfyUI_Installer.exe windows_installer.ps1 workflows\
   ```

### Features
- ✅ Self-extracting archive
- ✅ Professional extraction dialog
- ✅ Temporary extraction
- ✅ Automatic cleanup

### File Size
- Similar to PS2EXE method
- Good compression

---

## Method 3: Inno Setup (Professional)

### Prerequisites
- Inno Setup Compiler (free)
- Additional files: LICENSE.txt, icon.ico

### Steps

1. **Install Inno Setup:**
   Download from: https://jrsoftware.org/isdl.php

2. **Create required files:**
   - `LICENSE.txt` - Your license agreement
   - `icon.ico` - Installer icon (optional)

3. **Compile the installer:**
   ```cmd
   iscc ComfyUI_Setup.iss
   ```

### Features
- ✅ Professional Windows installer
- ✅ License agreement
- ✅ Start menu shortcuts
- ✅ Desktop shortcuts
- ✅ Uninstaller
- ✅ Prerequisites checking
- ✅ Modern wizard interface

### File Size
- Larger than other methods
- Most professional appearance

---

## Commercial Distribution Considerations

### 1. Licensing
- Ensure you have rights to distribute ComfyUI
- Include appropriate license files
- Consider your own license terms

### 2. Branding
- Customize company name in scripts
- Add your logo/icon
- Include your contact information

### 3. Support
- Provide installation instructions
- Include troubleshooting guide
- Offer customer support

### 4. Updates
- Version your installers
- Provide update mechanisms
- Consider auto-update functionality

### 5. Anti-Virus Considerations
- Sign your executables (recommended)
- Submit to anti-virus vendors
- Use trusted packaging tools

---

## Customization Options

### Modify Company Information
Edit these files to customize branding:

**build_installer.ps1:**
```powershell
"-company", "Your Company Name",
"-product", "ComfyUI Installer",
"-description", "ComfyUI Installation Package"
```

**ComfyUI_Setup.iss:**
```ini
AppPublisher=Your Company Name
AppPublisherURL=https://yourwebsite.com
```

### Add Custom Files
You can include additional files in your package:

**PS2EXE method:**
```powershell
$ps2exeArgs += "-embeddedFiles"
$ps2exeArgs += "additional_file.txt"
```

**Inno Setup method:**
```ini
[Files]
Source: "additional_file.txt"; DestDir: "{app}"; Flags: ignoreversion
```

### Custom Installation Path
Modify the default installation path in your scripts:

```powershell
[string]$InstallPath = "C:\YourCompany\ComfyUI"
```

---

## Testing Your Package

### Before Distribution
1. **Test on clean Windows VM**
2. **Test with different Python versions**
3. **Test with/without NVIDIA GPU**
4. **Test on different Windows versions**
5. **Test with antivirus software**

### Common Issues
- **PowerShell execution policy**
- **Missing prerequisites**
- **Antivirus false positives**
- **Permission issues**

---

## Distribution Channels

### 1. Direct Download
- Your website
- File hosting services
- Cloud storage links

### 2. Software Distribution Platforms
- GitHub Releases
- SourceForge
- Softpedia
- MajorGeeks

### 3. Package Managers
- Chocolatey
- Scoop
- Winget

---

## Pricing Strategy

### Factors to Consider
- **Development time**
- **Support costs**
- **Market competition**
- **Value provided**
- **Target audience**

### Pricing Models
- **One-time purchase**
- **Subscription**
- **Freemium**
- **Pay-what-you-want**

### Recommended Pricing
- **Basic package**: $19-49
- **Premium package**: $49-99
- **Enterprise**: $199+

---

## Legal Considerations

### Required Disclaimers
- "ComfyUI is open source software"
- "This installer is provided as-is"
- "No warranty provided"

### License Compliance
- Respect ComfyUI's license
- Include original license files
- Don't claim ownership of ComfyUI

### Terms of Service
- Installation requirements
- Support limitations
- Refund policy
- Usage restrictions

---

## Support and Documentation

### Create Documentation
- Installation guide
- Troubleshooting FAQ
- Video tutorials
- User manual

### Support Channels
- Email support
- Discord server
- GitHub issues
- Knowledge base

### Update Strategy
- Regular updates
- Security patches
- New workflow additions
- Bug fixes

---

## Recommended Workflow

1. **Choose packaging method** (PS2EXE recommended)
2. **Customize branding and metadata**
3. **Test thoroughly on multiple systems**
4. **Create documentation and support materials**
5. **Set up distribution channels**
6. **Launch with support system ready**
7. **Monitor feedback and iterate**

This approach ensures you have a professional, reliable installer that provides value to your customers while protecting your business interests. 