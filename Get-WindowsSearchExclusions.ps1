function Get-WindowsSearchExclusions {
    [CmdletBinding()]
    param ()

    # Ensure running as Administrator
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "This function must be run as Administrator!"
        return
    }

    try {
        $searchManager = New-Object -ComObject "Microsoft.Windows.Search.Configuration.SearchManager"
        $indexingPolicy = $searchManager.UserPolicy

        $excludedPaths = $indexingPolicy.ExcludedPaths

        if ($excludedPaths.Count -eq 0) {
            Write-Host "No paths are currently excluded from Windows Search." -ForegroundColor Yellow
        } else {
            Write-Host "Currently excluded paths from Windows Search:" -ForegroundColor Cyan
            $excludedPaths | ForEach-Object {
                Write-Host "- $_"
            }
        }
    }
    catch {
        Write-Error "Failed to retrieve Windows Search exclusions. $_"
    }
}


Get-WindowsSearchExclusions
