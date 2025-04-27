if not exist "%APPDATA%\Apple Computer\MobileSync\" mkdir "%APPDATA%\Apple Computer\MobileSync\"
if exist "%APPDATA%\Apple Computer\MobileSync\Backup" rmdir /s /q "%APPDATA%\Apple Computer\MobileSync\Backup"
mklink /J "%APPDATA%\Apple Computer\MobileSync\Backup" "E:\Backups\iPhone Backups"