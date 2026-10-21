# Image_Install_apps
SImple application tool to install common use apps
===============================================================================
WEST ISLIP UFSD - NETWORK AND SYSTEMS
Winget App Suite Deployment Readme
===============================================================================

-------------------------------------------------------------------------------
1. QUICK START (6-Step Tech Process)
-------------------------------------------------------------------------------
1. Copy the entire 'AppDeploy' folder from the USB/network share to the local
   laptop (or run directly from USB).
2. Ensure the laptop is connected to an active Internet connection (Wi-Fi/Eth).
3. If Deep Freeze is installed, boot the system into THAWED mode and restart.
4. Open the 'AppDeploy' folder.
5. Right-click 'Install-Apps.bat' and select "Run as administrator".
6. Confirm the prompt (Y) to begin installation.

-------------------------------------------------------------------------------
2. WHAT THIS SCRIPT INSTALLS
-------------------------------------------------------------------------------
The script silently fetches and installs 7 standard software packages directly
from Microsoft Winget repositories:
  - 7-Zip (7zip.7zip)
  - Adobe Acrobat Reader 64-bit (Adobe.Acrobat.Reader.64-bit)
  - Audacity (Audacity.Audacity)
  - FFmpeg (Gyan.FFmpeg)
  - LAME MP3 Encoder (LAME.LAME)
  - VLC Media Player (VideoLAN.VLC)
  - Paint.NET (dotPDN.PaintDotNet)

-------------------------------------------------------------------------------
3. PREREQUISITES & ENVIRONMENT REQUIREMENTS
-------------------------------------------------------------------------------
- Windows 11 / Windows 10 with Windows Package Manager (Winget) available.
- Active Internet connectivity (Winget requires live access to Microsoft 
  and vendor repositories).
- Local Administrator privileges to execute silent software installers.
- Accept-Agreements flags are pre-embedded in the script commands to bypass 
  interactive license prompts automatically.

-------------------------------------------------------------------------------
4. SCRIPT DISPLAY & COLOR GUIDE
-------------------------------------------------------------------------------
The terminal utilizes District Navy (#063d71) and Yellow (#fdd757) styling:
  - Solid Yellow Banner : Header and completed status confirmation.
  - White Text          : General process output and step descriptions.
  - Green Text ([+])    : Successful application installation confirmation.
  - Coral Bar / Text    : Deployment failure or missing prerequisites.

-------------------------------------------------------------------------------
5. TROUBLESHOOTING & LOG FILES
-------------------------------------------------------------------------------
Log files are written locally to the machine at:
  C:\ProgramData\AppDeploy\deploy.log

Exit Codes:
  Code 0  : Deployment Complete (All 7 applications installed successfully).
  Code 1  : Failed Admin Check (Script was not run as administrator).
  Code 2  : Deployment cancelled by user at the confirmation prompt.
  Code 10 : Winget package manager missing or unreachable.
  Code 13 : One or more application downloads/installs failed.

If an installation fails (Exit Code 13), open deploy.log to view the specific
Winget error code returned by the vendor package installer.

-------------------------------------------------------------------------------
6. AUTOMATED & UNATTENDED DEPLOYMENT (/silent)
-------------------------------------------------------------------------------
To run this script via RMM, MDM, or automated deployment tools without visual
formatting, prompts, or pauses:
  
  Install-Apps.bat /silent

For support, contact Network and Systems.
