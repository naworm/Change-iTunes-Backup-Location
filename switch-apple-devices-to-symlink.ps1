# --- Ensure the script is running as Administrator ---
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
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

# --- Check if old backup folder exists and if it's empty ---
$NeedDelete = $false

If (Test-Path $OldBackupPath) {
    $content = Get-ChildItem $OldBackupPath -Force -ErrorAction SilentlyContinue
    If ($content) {
        $NeedDelete = $true
    }
}

# --- If needed, ask for confirmation ---
If ($NeedDelete) {
    $confirmation = Read-Host "Old Backup folder is NOT empty. Delete and create symlink? (Y/N)"
    If ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
        Write-Host "Operation cancelled."
        Pause
        Exit
    }

    Write-Host "Deleting old Backup folder..."
    Remove-Item $OldBackupPath -Recurse -Force
}
ElseIf (Test-Path $OldBackupPath) {
    Write-Host "Old Backup folder is empty. Removing silently..."
    Remove-Item $OldBackupPath -Recurse -Force
}

# --- Ask user confirmation ---
Write-Host ""
$createLink = Read-Host "Do you want to create the symbolic link now? (This helps avoid useless indexing) (Y/N)"

if ($createLink -ne 'Y' -and $createLink -ne 'y') {
    Write-Host "Operation cancelled."
    Pause
    exit
}

# --- Create symbolic link ---
Write-Host "Creating symbolic link..."
try {
    New-Item -ItemType Junction -Path $OldBackupPath -Target $NewBackupPath -ErrorAction Stop | Out-Null
    Write-Host "`nSymbolic link created successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Failed to create symbolic link. $_"
    Pause
    exit
}

# --- Now that the path exists, add exclusions ---
Write-Host "`nAdding Windows Search exclusions..."
. .\Add-SearchExclusion.ps1
Add-PathToWindowsSearchExclusions -Path $OldBackupPath
Add-PathToWindowsSearchExclusions -Path $NewBackupPath

Write-Host "`nAll operations completed successfully!" -ForegroundColor Cyan

Pause
