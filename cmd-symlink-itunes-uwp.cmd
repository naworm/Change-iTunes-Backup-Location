set bkp_old_base_path = "%HOMEPATH%\Apple"
set bkp_old_short_path = "%bkp_old_base_path%\MobileSync"
set bkp_old_path = "%bkp_old_short_path%\Backup"

set bkp_new_path = "E:\Backups\iPhone Backups"

if not exist "%bkp_old_base_path%" mkdir "%bkp_old_base_path%"
if not exist "%bkp_old_short_path%" mkdir "%bkp_old_short_path%"
if exist "%bkp_old_path%" rmdir /s /q "%bkp_old_path%"
mklink /J "%bkp_old_path%" "%bkp_new_path%"

PAUSE