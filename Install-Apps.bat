@echo off
setlocal EnableExtensions
title Software Deployment - Winget Automated Installer

:: ============================================================================
:: Winget Automated Application Installer
::
:: Installs 7-Zip, Adobe Reader 64-bit, Audacity, FFmpeg, LAME, VLC,
:: Paint.NET, Google Chrome, and Mozilla Firefox via winget.
::
:: Usage:   Install-Apps.bat [/silent]
::    /silent    no prompts, pauses or colors (for deployment tools)
::
:: Look: district navy (#063d71) and yellow (#fdd757) using 24-bit ANSI colors
:: (Windows 10/11).
::
:: Exit codes:
::    0 success        1 not admin        2 cancelled by user
::    10 winget missing / corrupted       13 one or more app installs failed
:: ============================================================================

set "ORG=WEST ISLIP UFSD"
set "LOGDIR=%ProgramData%\AppDeploy"
set "LOG=%LOGDIR%\deploy.log"
set "SILENT=0"
set "FAILCOUNT=0"
set "SUCCESSCOUNT=0"
set "EXITCODE=0"

:parse
if "%~1"=="" goto :parsed
if /i "%~1"=="/silent" set "SILENT=1"
shift
goto :parse
:parsed

if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1

:: 0. Administrator check
fltmc >nul 2>&1
if errorlevel 1 (
    echo [ERROR] This script must be run as Administrator!
    echo Right-click Install-Apps.bat and choose "Run as administrator".
    set "EXITCODE=1"
    goto :end
)

:: 0b. Color setup (skipped when /silent)
set "ESC="
if "%SILENT%"=="0" for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "C_BG="
set "C_FG="
set "C_WHT="
set "C_OK="
set "C_ERR="
set "C_BAR="
set "C_EBAR="
set "C_RST="
if defined ESC set "C_BG=%ESC%[48;2;6;61;113m"
if defined ESC set "C_FG=%ESC%[38;2;253;215;87m"
if defined ESC set "C_WHT=%ESC%[38;2;255;255;255m"
if defined ESC set "C_OK=%ESC%[38;2;144;238;144m"
if defined ESC set "C_ERR=%ESC%[38;2;255;130;130m"
if defined ESC set "C_BAR=%ESC%[48;2;253;215;87m%ESC%[38;2;6;61;113m"
if defined ESC set "C_EBAR=%ESC%[48;2;255;130;130m%ESC%[38;2;6;61;113m"
if defined ESC set "C_RST=%C_BG%%C_WHT%"

:: Paint the whole window navy, then draw the banner
echo.%C_BG%%C_WHT%
cls
call :bar " "
call :bar "  %ORG%  -  NETWORK AND SYSTEMS"
call :bar "  WINGET AUTOMATED APP INSTALLER"
call :bar " "
call :log "===== App deployment started on %COMPUTERNAME% =====" q

:: 1. PRE-INSTALLATION CHECKS
call :step "STEP 1 OF 3  -  PRE-INSTALLATION CHECKS"
where winget >nul 2>&1
if errorlevel 1 (
    call :log "[ERROR] Winget utility was not found on this system."
    call :log "[!] Ensure Windows Package Manager is installed and updated."
    set "EXITCODE=10"
    goto :end
)
call :log "[+] Winget Package Manager detected."

if "%SILENT%"=="1" goto :run_installs
echo.
echo The script is about to install the following applications via winget:
echo.
echo   %C_FG%1.%C_WHT% 7-Zip (7zip.7zip)
echo   %C_FG%2.%C_WHT% Adobe Acrobat Reader 64-bit (Adobe.Acrobat.Reader.64-bit)
echo   %C_FG%3.%C_WHT% Audacity (Audacity.Audacity)
echo   %C_FG%4.%C_WHT% FFmpeg (Gyan.FFmpeg)
echo   %C_FG%5.%C_WHT% LAME MP3 Encoder (LAME.LAME)
echo   %C_FG%6.%C_WHT% VLC Media Player (VideoLAN.VLC)
echo   %C_FG%7.%C_WHT% Paint.NET (dotPDN.PaintDotNet)
echo   %C_FG%8.%C_WHT% Google Chrome (Google.Chrome)
echo   %C_FG%9.%C_WHT% Mozilla Firefox (Mozilla.Firefox)
echo.
call :confirm "Is this PC connected to the Internet and ready to install these apps?"
if errorlevel 1 (
    call :log "[CANCELLED] Installation aborted by user. No changes were made."
    set "EXITCODE=2"
    goto :end
)

:: 2. RUN WINGET INSTALLATIONS
:run_installs
call :step "STEP 2 OF 3  -  INSTALLING APPLICATIONS"

call :install_app "7-Zip" "7zip.7zip"
call :install_app "Adobe Acrobat Reader 64-bit" "Adobe.Acrobat.Reader.64-bit"
call :install_app "Audacity" "Audacity.Audacity"
call :install_app "FFmpeg" "Gyan.FFmpeg"
call :install_app "LAME MP3 Encoder" "LAME.LAME"
call :install_app "VLC Media Player" "VideoLAN.VLC"
call :install_app "Paint.NET" "dotPDN.PaintDotNet"
call :install_app "Google Chrome" "Google.Chrome"
call :install_app "Mozilla Firefox" "Mozilla.Firefox"

:: 3. SUMMARY & VERIFICATION
call :step "STEP 3 OF 3  -  DEPLOYMENT SUMMARY"
call :log "[+] Successful installs: %SUCCESSCOUNT% / 9"
if not "%FAILCOUNT%"=="0" (
    call :log "[ERROR] Failed installs: %FAILCOUNT% / 9"
    set "EXITCODE=13"
    goto :end
)

call :log "[+] SUCCESS: All applications deployed successfully." q
echo.
call :bar " "
call :bar "  DEPLOYMENT COMPLETE"
call :bar "  All requested applications have been installed."
call :bar " "
set "EXITCODE=0"

:end
call :log "Exit code %EXITCODE%" q
if "%EXITCODE%"=="0" goto :pausing
if "%EXITCODE%"=="2" goto :pausing
echo.
call :barerr " "
call :barerr "  DEPLOYMENT FAILED  -  EXIT CODE %EXITCODE%"
call :barerr "  Log: %LOG%"
call :barerr " "
:pausing
if "%SILENT%"=="0" pause
:: Hand the window back in its normal colors
if defined ESC echo.%ESC%[0m
if defined ESC cls
exit /b %EXITCODE%

:: ============================================================================
:: SUBROUTINES
:: ============================================================================

:: install_app "Display Name" "Winget.ID"
:install_app
call :log "[*] Installing %~1 (%~2)..."
winget install -e --id "%~2" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity >>"%LOG%" 2>&1
if errorlevel 1 (
    call :log "[ERROR] Failed to install %~1 (%~2). See %LOG% for details."
    set /a FAILCOUNT+=1
) else (
    call :log "[+] %~1 installed successfully."
    set /a SUCCESSCOUNT+=1
)
exit /b 0

:: log "message" [q]   - colors by prefix, writes to the log; q = log file only
:log
set "MSG=%~1"
set "CLR=%C_WHT%"
if "%MSG:~0,3%"=="[+]" set "CLR=%C_OK%"
if "%MSG:~0,3%"=="[*]" set "CLR=%C_FG%"
if "%MSG:~0,3%"=="[!]" set "CLR=%C_FG%"
if "%MSG:~0,7%"=="[ERROR]" set "CLR=%C_ERR%"
if "%MSG:~0,11%"=="[CANCELLED]" set "CLR=%C_FG%"
if /i not "%~2"=="q" echo %CLR%%MSG%%C_RST%
>>"%LOG%" 2>nul echo [%date% %time%] %MSG%
exit /b 0

:: bar "text"     - full-width yellow bar, navy text
:bar
set "BL=%~1                                                                                "
echo %C_BAR%%BL:~0,76%%C_RST%
exit /b 0

:: barerr "text"  - full-width coral bar for failures
:barerr
set "BL=%~1                                                                                "
echo %C_EBAR%%BL:~0,76%%C_RST%
exit /b 0

:: step "title"   - yellow section heading with a rule underneath
:step
echo.
echo %C_FG%%~1%C_RST%
echo %C_FG%----------------------------------------------------------------------------%C_RST%
exit /b 0

:confirm
set "ANS="
set /p "ANS=%C_FG%%~1 (Y/N): %C_WHT%"
if /i "%ANS%"=="Y" exit /b 0
exit /b 1