$ErrorActionPreference = "Stop"

$repositoryPath = Split-Path -Parent $PSScriptRoot
Set-Location $repositoryPath

Write-Host "Auto-sync ativo para $repositoryPath"

$lastSnapshot = ""

while ($true) {
    $statusLines = @(git status --porcelain)
    $snapshot = $statusLines -join "`n"

    if ($snapshot -and $snapshot -ne $lastSnapshot) {
        Start-Sleep -Seconds 2

        $statusLines = @(git status --porcelain)
        $snapshot = $statusLines -join "`n"

        if ($snapshot) {
            git add --all
            git diff --cached --quiet

            if ($LASTEXITCODE -ne 0) {
                $commitMessage = "Sincronizacao automatica $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
                git commit -m $commitMessage
                git push origin main
                Write-Host "Sincronizado em $(Get-Date -Format 'HH:mm:ss')"
            }
        }

        $lastSnapshot = $snapshot
    }
    elseif (-not $snapshot) {
        $lastSnapshot = ""
    }

    Start-Sleep -Seconds 3
}