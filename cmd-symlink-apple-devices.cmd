@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

:: --- Check if running as administrator ---
openfiles >nul 2>&1
if %errorlevel% NEQ 0 (
    echo.
    echo This script must be run as Administrator.
    echo Right-click the script and choose "Run as administrator".
    pause
    exit /b
)

:: --- Load the config.ini ---
set "configFile=config.ini"
if not exist "%configFile%" (
    echo Config file 'config.ini' not found.
    pause
    exit /b
)

:: --- Read NewBackupPath from config.ini ---
for /f "usebackq tokens=1,* delims==" %%A in ("%configFile%") do (
    if /i "%%A"=="NewBackupPath" (
        set "NEWBACKUPDIR=%%B"
    )
)

:: --- Validate NewBackupPath is set ---
if "%NEWBACKUPDIR%"=="" (
    echo Error: NewBackupPath is not defined in config.ini
    pause
    exit /b
)

:: --- Paths setup ---
set "OLD_BACKUP=%USERPROFILE%\Apple\MobileSync\Backup"

echo Old Backup folder: "%OLD_BACKUP%"
echo New Backup folder: "%NEWBACKUPDIR%"
echo.

:: --- Check if the new backup path exists ---
if not exist "%NEWBACKUPDIR%" (
    echo Error: The target backup directory "%NEWBACKUPDIR%" does not exist.
    pause
    exit /b
)

:: --- Check if OLD_BACKUP exists and is not empty ---
set "NEED_DELETE=0"

if exist "%OLD_BACKUP%" (
    dir /a "%OLD_BACKUP%" | findstr /r /c:"[0-9][0-9]* File(s)" >nul
    if %errorlevel%==0 (
        set "NEED_DELETE=1"
    )
)

:: --- Ask confirmation only if needed ---
if "%NEED_DELETE%"=="1" (
    echo Warning: Old Backup folder exists and is NOT empty.
    set /p CONFIRM=Delete old Backup folder and create symbolic link? (Y/N): 
    if /I not "%CONFIRM%"=="Y" (
        echo Operation cancelled.
        pause
        exit /b
    )

    echo Deleting old Backup folder...
    rmdir /S /Q "%OLD_BACKUP%"
) else (
    if exist "%OLD_BACKUP%" (
        echo Old Backup folder is empty. Removing it silently...
        rmdir /S /Q "%OLD_BACKUP%"
    )
)

:: --- Create symbolic link ---
echo Creating symbolic link...
mklink /J "%OLD_BACKUP%" "%NEWBACKUPDIR%"

if %errorlevel% EQU 0 (
    echo.
    echo Symbolic link created successfully!
) else (
    echo.
    echo Error creating symbolic link.
)

pause
