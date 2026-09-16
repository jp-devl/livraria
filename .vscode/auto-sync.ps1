$ErrorActionPreference = "Stop"

$repositoryPath = Split-Path -Parent $PSScriptRoot
Set-Location $repositoryPath

Write-Host "Auto-sync ativo para $repositoryPath"

$lastSnapshot = ""
$historyStart = "<!-- AUTO-SYNC-HISTORY-START -->"
$historyEnd = "<!-- AUTO-SYNC-HISTORY-END -->"

function Update-ReadmeHistory {
    param([string[]]$StatusLines)

    $readmePath = Join-Path $repositoryPath "Readme.md"
    $readmeContent = if (Test-Path $readmePath) { Get-Content $readmePath -Raw } else { "# Livraria`r`n" }
    $changedFiles = $StatusLines | ForEach-Object {
        if ($_.Length -gt 3) { $_.Substring(3).Trim() }
    } | Where-Object { $_ -and $_ -ne "Readme.md" } | Sort-Object -Unique

    $historyLines = @(
        $historyStart
        "## Histórico de alterações"
        ""
        "Última sincronização automática: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        ""
    )

    if ($changedFiles) {
        $historyLines += $changedFiles | ForEach-Object { "- " + '`' + $_ + '`' }
    }
    else {
        $historyLines += "- Nenhum arquivo adicional detectado."
    }

    $historyLines += $historyEnd
    $historyBlock = $historyLines -join "`r`n"
    $pattern = "(?s)$([regex]::Escape($historyStart)).*?$([regex]::Escape($historyEnd))"

    if ($readmeContent -match $pattern) {
        $readmeContent = [regex]::Replace($readmeContent, $pattern, $historyBlock)
    }
    else {
        $readmeContent = $readmeContent.TrimEnd() + "`r`n`r`n" + $historyBlock + "`r`n"
    }

    Set-Content -Path $readmePath -Value $readmeContent -Encoding utf8
}

while ($true) {
    $statusLines = @(git status --porcelain)
    $snapshot = $statusLines -join "`n"

    if ($snapshot -and $snapshot -ne $lastSnapshot) {
        Start-Sleep -Seconds 2

        $statusLines = @(git status --porcelain)
        $snapshot = $statusLines -join "`n"

        if ($snapshot) {
            Update-ReadmeHistory -StatusLines $statusLines
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