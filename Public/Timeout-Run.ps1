$TimeoutRunVersion = '2025-07-02 20:59:39'
$TimeoutRunBuildTime = '2025-07-02 20:59:39'

function Timeout-Run {
    <#!
.SYNOPSIS
    Runs a command with a timeout, designed for LLM/IDE terminals (Cursor, VSCode, Windsurf).
.DESCRIPTION
    Executes a specified command with a timeout. If the command does not complete within the given time, it is terminated. Provides user-friendly output and error handling, and is compatible with both managed and unmanaged terminals.
.PARAMETER TimeoutSeconds
    The timeout in seconds for the command to run.
.PARAMETER CommandArgs
    The command and its arguments to execute (as an array of strings).
.EXAMPLE
    Timeout-Run -TimeoutSeconds 10 -CommandArgs @('docker', 'compose', 'up', '-d')
.EXAMPLE
    Timeout-Run -TimeoutSeconds 5 -CommandArgs @('curl.exe', '-s', 'http://localhost:49477/patterns/names')
.EXAMPLE
    Timeout-Run -TimeoutSeconds 30 -CommandArgs @('powershell', '-NoProfile', '-Command', '[Environment]::SetEnvironmentVariable(...)')
.NOTES
    Follows PowerShell best practices for function structure, parameter validation, and output.
#>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$TimeoutSeconds,

        [Parameter(Position = 1, Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$CommandArgs
    )

    Write-Host "[timeout-run] Version: $TimeoutRunVersion | Build: $TimeoutRunBuildTime" -ForegroundColor Green

    # Detect LLM/IDE terminals (Cursor, VSCode, Windsurf)
    $inLLMTerminal = $false
    if ($env:TERM_PROGRAM -eq "vscode" -or $env:CURSOR_SESSION -or $env:WIND_SURF_SESSION) {
        $inLLMTerminal = $true
    }
    if ($env:LLM_TIMEOUT_DISABLE) {
        $inLLMTerminal = $false
    }

    if (-not $inLLMTerminal) {
        & $CommandArgs
        exit $LASTEXITCODE
    }

    if ($TimeoutSeconds -le 0 -or !$CommandArgs) {
        Write-Host "\nERROR: You must use the following format for all terminal commands in LLM/IDE terminals (Cursor, VSCode, Windsurf):" -ForegroundColor Red
        Write-Host "\n    timeout-run <seconds> <your command>\n" -ForegroundColor Yellow
        Write-Host "Example:" -ForegroundColor Yellow
        Write-Host "    timeout-run 10 docker compose up -d" -ForegroundColor Yellow
        Write-Host "    timeout-run 5 curl.exe -s http://localhost:49477/patterns/names" -ForegroundColor Yellow
        Write-Host "\nThe first argument must be a positive integer (timeout in seconds). Everything after the first space is the command to run.\n" -ForegroundColor Yellow
        Write-Host "If you see this message, please update your LLM prompt or script to use the correct format."
        exit 2
    }

    $exe = $CommandArgs[0]
    $args = if ($CommandArgs.Length -gt 1) { $CommandArgs[1..($CommandArgs.Length - 1)] -join ' ' } else { '' }
    $startTime = Get-Date
    $timeoutTime = $startTime.AddSeconds($TimeoutSeconds)
    Write-Host "[timeout-run] Start: $startTime | Timeout: $timeoutTime" -ForegroundColor Magenta
    Write-Host "[timeout-run] Running with timeout $TimeoutSeconds seconds: $exe $args" -ForegroundColor Cyan

    # Start the process
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $exe
    $startInfo.Arguments = $args
    $startInfo.RedirectStandardOutput = $false
    $startInfo.RedirectStandardError = $false
    $startInfo.UseShellExecute = $true
    $process = $null
    try {
        $process = [System.Diagnostics.Process]::Start($startInfo)
    }
    catch {
        Write-Host "[timeout-run] ERROR: Failed to start process: $exe $args" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 127
    }

    if (-not $process) {
        Write-Host "[timeout-run] ERROR: Process object is null after start attempt." -ForegroundColor Red
        exit 127
    }

    $remaining = $TimeoutSeconds
    $interval = 1
    while (-not $process.HasExited -and $remaining -gt 0) {
        Write-Host ("`r[timeout-run] Time remaining: {0}s " -f $remaining) -NoNewline -ForegroundColor Yellow
        Start-Sleep -Seconds $interval
        $remaining -= $interval
    }
    # Clear the countdown line
    Write-Host "`r" + (' ' * 50) + "`r" -NoNewline

    if (-not $process.HasExited) {
        Write-Host "\nERROR: Command timed out after $TimeoutSeconds seconds: $exe $args" -ForegroundColor Red
        try { $process.Kill() } catch {}
        exit 124
    }
    exit $process.ExitCode
} unction Timeout-Run {
    <#!
.SYNOPSIS
    Runs a command with a timeout, designed for LLM/IDE terminals (Cursor, VSCode, Windsurf).
.DESCRIPTION
    Executes a specified command with a timeout. If the command does not complete within the given time, it is terminated. Provides user-friendly output and error handling, and is compatible with both managed and unmanaged terminals.
.PARAMETER TimeoutSeconds
    The timeout in seconds for the command to run.
.PARAMETER CommandArgs
    The command and its arguments to execute (as an array of strings).
.EXAMPLE
    Timeout-Run -TimeoutSeconds 10 -CommandArgs @('docker', 'compose', 'up', '-d')
.EXAMPLE
    Timeout-Run -TimeoutSeconds 5 -CommandArgs @('curl.exe', '-s', 'http://localhost:49477/patterns/names')
.NOTES
    Follows PowerShell best practices for function structure, parameter validation, and output.
#>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$TimeoutSeconds,

        [Parameter(Position = 1, Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$CommandArgs
    )

    # Detect LLM/IDE terminals (Cursor, VSCode, Windsurf)
    $inLLMTerminal = $false
    if ($env:TERM_PROGRAM -eq "vscode" -or $env:CURSOR_SESSION -or $env:WIND_SURF_SESSION) {
        $inLLMTerminal = $true
    }
    if ($env:LLM_TIMEOUT_DISABLE) {
        $inLLMTerminal = $false
    }

    if (-not $inLLMTerminal) {
        & $CommandArgs
        exit $LASTEXITCODE
    }

    if ($TimeoutSeconds -le 0 -or !$CommandArgs) {
        Write-Host "\nERROR: You must use the following format for all terminal commands in LLM/IDE terminals (Cursor, VSCode, Windsurf):" -ForegroundColor Red
        Write-Host "\n    timeout-run <seconds> <your command>\n" -ForegroundColor Yellow
        Write-Host "Example:" -ForegroundColor Yellow
        Write-Host "    timeout-run 10 docker compose up -d" -ForegroundColor Yellow
        Write-Host "    timeout-run 5 curl.exe -s http://localhost:49477/patterns/names" -ForegroundColor Yellow
        Write-Host "\nThe first argument must be a positive integer (timeout in seconds). Everything after the first space is the command to run.\n" -ForegroundColor Yellow
        Write-Host "If you see this message, please update your LLM prompt or script to use the correct format."
        exit 2
    }

    $Command = $CommandArgs -join " "
    $startTime = Get-Date
    $timeoutTime = $startTime.AddSeconds($TimeoutSeconds)
    Write-Host "[timeout-run] Start: $startTime | Timeout: $timeoutTime" -ForegroundColor Magenta
    Write-Host "[timeout-run] Running with timeout $TimeoutSeconds seconds: $Command" -ForegroundColor Cyan

    # Start the process
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "powershell.exe"
    $startInfo.Arguments = "-NoProfile -Command $Command"
    $startInfo.RedirectStandardOutput = $false
    $startInfo.RedirectStandardError = $false
    $startInfo.UseShellExecute = $true
    $process = [System.Diagnostics.Process]::Start($startInfo)

    $remaining = $TimeoutSeconds
    $interval = 1
    while (-not $process.HasExited -and $remaining -gt 0) {
        Write-Host ("`r[timeout-run] Time remaining: {0}s " -f $remaining) -NoNewline -ForegroundColor Yellow
        Start-Sleep -Seconds $interval
        $remaining -= $interval
    }
    # Clear the countdown line
    Write-Host "`r" + (' ' * 50) + "`r" -NoNewline

    if (-not $process.HasExited) {
        Write-Host "\nERROR: Command timed out after $TimeoutSeconds seconds: $Command" -ForegroundColor Red
        $process.Kill()
        exit 124
    }
    exit $process.ExitCode
} 
