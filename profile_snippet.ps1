# terminal_control PowerShell profile snippet
# Build path: $PSScriptRoot\terminal_control_profile.ps1
# Build time: 2025-06-30
# To disable: comment out or remove the sourcing line in your $PROFILE
# To uninstall: delete this file and remove the sourcing line from $PROFILE

# PowerShell profile snippet for LLM terminal timeout enforcement
# Detect LLM/IDE terminals (Cursor, VSCode, Windsurf) by env or process tree
function Test-IsLLMTerminal {
    $current = Get-Process -Id $PID
    $llmParents = @('Code', 'Cursor', 'windsurf', 'Windsurf', 'vscode', 'VSCode')
    while ($current) {
        if ($llmParents -contains $current.ProcessName) {
            return $true
        }
        try {
            $current = Get-Process -Id $current.Parent.Id
        }
        catch {
            break
        }
    }
    return $false
}

$envDetected = ($env:TERM_PROGRAM -eq "vscode" -or $env:CURSOR_SESSION -or $env:WIND_SURF_SESSION)
$processDetected = Test-IsLLMTerminal

if ($envDetected -or $processDetected) {
    Write-Host "[terminal_control] LLM/IDE terminal detected (env or process tree)." -ForegroundColor Green
    Write-Host "[terminal_control] Profile loaded from: $PSCommandPath" -ForegroundColor Cyan
    Write-Host "[terminal_control] Build time: 2025-06-30" -ForegroundColor Cyan
    Write-Host "[terminal_control] To disable: comment out or remove the sourcing line in your `$PROFILE." -ForegroundColor Yellow
    Write-Host "[terminal_control] To uninstall: delete this file and remove the sourcing line from `$PROFILE." -ForegroundColor Yellow
    function __llm_enforce_timeout {
        param([string]$CommandName)
        Write-Host "\nERROR: All terminal commands must be run as: timeout-run <seconds> <your command>" -ForegroundColor Red
        Write-Host "Example: timeout-run 10 docker compose up -d" -ForegroundColor Yellow
        Write-Host "See the project README for details."
    }
    # List of common commands to intercept
    $commands = @('docker', 'curl', 'git', 'python', 'pip', 'npm', 'node', 'yarn', 'pwsh', 'powershell', 'ls', 'cat', 'cd', 'mkdir', 'rm', 'cp', 'mv', 'touch', 'echo', 'code', 'start', 'wsl', 'bash', 'sh')
    foreach ($cmd in $commands) {
        Set-Alias -Name $cmd -Value __llm_enforce_timeout -Force
    }
    function Uninstall-TerminalControl {
        $profilePath = "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
        $snippetPath = "$HOME\Documents\WindowsPowerShell\terminal_control_profile.ps1"
        (Get-Content $profilePath) | Where-Object { $_ -notmatch 'terminal_control enforcement' -and $_ -notmatch 'terminal_control_profile.ps1' } | Set-Content $profilePath
        Remove-Item $snippetPath -Force
        Write-Host "[terminal_control] Uninstalled. Please restart your terminal." -ForegroundColor Green
    }
}
else {
    Write-Host "[terminal_control] Standard terminal (no LLM/IDE parent detected)." -ForegroundColor Yellow
} 