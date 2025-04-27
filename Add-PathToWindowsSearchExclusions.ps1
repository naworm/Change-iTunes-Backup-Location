function Add-PathToWindowsSearchExclusions {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        $searchManager = New-Object -ComObject "Microsoft.Windows.Search.Configuration.SearchManager"
        $indexingPolicy = $searchManager.UserPolicy

        # Normalize paths to lower case for comparison
        $currentExclusions = @($indexingPolicy.ExcludedPaths) | ForEach-Object { $_.ToLowerInvariant().TrimEnd('\') }
        $normalizedPath = $Path.ToLowerInvariant().TrimEnd('\')

        if ($currentExclusions -contains $normalizedPath) {
            Write-Host "Already excluded (safe check passed): $Path" -ForegroundColor Yellow
        }
        else {
            $indexingPolicy.AddExcludedPath($Path)
            Write-Host "Added to Windows Search exclusions: $Path" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Warning "Could not modify Windows Search exclusions. Ensure you are running as Administrator. Error: $_"
    }
}

# $pathsToExclude = @(
#     "C:\Users\Naworz\Apple\MobileSync\Backup",
#     "D:\Backups\iPhone Backups"
# )

# foreach ($path in $pathsToExclude) {
#     Add-PathToWindowsSearchExclusions -Path $path
# }
