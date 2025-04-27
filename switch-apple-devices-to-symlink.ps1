# --- Ensure the script is running as Administrator --- 
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script must be run as Administrator."
    Pause
    Exit
}

# --- Load configuration ---
$configPath = ".\config.ini"
If (-not (Test-Path $configPath)) {
    Write-Error "Config file 'config.ini' not found."
    Pause
    Exit
}

# --- Parse the config.ini ---
$ini = Get-Content $configPath | Where-Object { $_ -match "=" } | ForEach-Object {
    $parts = $_ -split '=', 2
    [PSCustomObject]@{
        Key = $parts[0].Trim()
        Value = $parts[1].Trim()
    }
}

$NewBackupPath = ($ini | Where-Object { $_.Key -eq 'NewBackupPath' }).Value

If (-not $NewBackupPath) {
    Write-Error "NewBackupPath is not defined in config.ini."
    Pause
    Exit
}

# --- Define old backup path ---
$OldBackupPath = Join-Path $env:USERPROFILE "Apple\MobileSync\Backup"

Write-Host "Old Backup folder: `"$OldBackupPath`""
Write-Host "New Backup folder: `"$NewBackupPath`""
Write-Host ""

# --- Validate new backup path exists ---
If (-not (Test-Path $NewBackupPath)) {
    Write-Error "The target backup directory does not exist: $NewBackupPath"
    Pause
    Exit
}

# --- Check if old backup is a correct symlink ---
$symlinkOk = $false

if (Test-Path $OldBackupPath) {
    $attributes = Get-Item $OldBackupPath -ErrorAction SilentlyContinue

    if ($attributes.Attributes -match "ReparsePoint") {
        # It's a junction or symlink
        $linkTarget = (Get-Item $OldBackupPath -ErrorAction SilentlyContinue).Target

        if ($linkTarget -eq $NewBackupPath) {
            Write-Host "Existing symbolic link is already correct." -ForegroundColor Green
            $symlinkOk = $true
        }
        else {
            Write-Warning "Existing symbolic link points to a wrong location. It will be removed."
            Remove-Item $OldBackupPath -Force
        }
    }
    else {
        # Regular folder
        $content = Get-ChildItem $OldBackupPath -Force -ErrorAction SilentlyContinue
        if ($content) {
            $confirmation = Read-Host "Old Backup folder is NOT empty. Delete and create symlink? (Y/N)"
            if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
                Write-Host "Operation cancelled."
                Pause
                Exit
            }
        }
        Write-Host "Deleting old Backup folder..."
        Remove-Item $OldBackupPath -Recurse -Force
    }
}

# --- Create the symlink if needed ---
if (-not $symlinkOk) {
    Write-Host "Creating symbolic link..."
    try {
        New-Item -ItemType Junction -Path $OldBackupPath -Target $NewBackupPath -ErrorAction Stop | Out-Null
        Write-Host "`nSymbolic link created successfully!" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create symbolic link. $_"
        Pause
        Exit
    }
}

# --- Now that the path exists, add exclusions ---
Write-Host "`nAdding Windows Search exclusions..."
try {
    . .\Add-SearchExclusion.ps1
    Add-PathToWindowsSearchExclusions -Paths @($OldBackupPath, $NewBackupPath)
}
catch {
    Write-Warning "Automatic exclusion failed. Opening Windows Search settings manually..."
    Start-Process "rundll32.exe" "shell32.dll,Control_RunDLL srchadmin.dll"
    Write-Host "`nPlease manually add the following paths to Windows Search exclusions:" -ForegroundColor Yellow
    Write-Host "- $OldBackupPath"
    Write-Host "- $NewBackupPath"
}

Write-Host "`nAll operations completed successfully!" -ForegroundColor Cyan

Pause
