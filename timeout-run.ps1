param(
    [Parameter(Position = 0, Mandatory = $true)]
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
    # Not in a managed terminal, just run the command normally
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
Write-Host "[timeout-run] Running with timeout $TimeoutSeconds seconds: $Command" -ForegroundColor Cyan

# Start the process
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = "powershell.exe"
$startInfo.Arguments = "-NoProfile -Command $Command"
$startInfo.RedirectStandardOutput = $false
$startInfo.RedirectStandardError = $false
$startInfo.UseShellExecute = $true
$process = [System.Diagnostics.Process]::Start($startInfo)

$completed = $process.WaitForExit($TimeoutSeconds * 1000)
if (-not $completed) {
    Write-Host "\nERROR: Command timed out after $TimeoutSeconds seconds: $Command" -ForegroundColor Red
    $process.Kill()
    exit 124
}
exit $process.ExitCode 