# Requires -Modules Pester

Describe 'Timeout-Run' {
    $timeoutScript = Join-Path $PSScriptRoot '..' 'timeout-run.ps1'
    $isWindows = $env:OS -eq 'Windows_NT'

    Context 'Happy path: command completes before timeout' {
        It 'should output text and exit 0' {
            $proc = Start-Process powershell.exe -ArgumentList "-NoProfile", "-File", $timeoutScript, "3", "cmd", "/c", "echo happy-path" -NoNewWindow -PassThru -Wait -RedirectStandardOutput output.txt
            $result = Get-Content output.txt -Raw
            $result | Should -Match 'happy-path'
            Remove-Item output.txt -Force
        }
    }

    Context 'Sad path: command exceeds timeout' {
        It 'should time out and exit 124' {
            $proc = Start-Process powershell.exe -ArgumentList "-NoProfile", "-File", $timeoutScript, "1", "timeout", "/t", "5", "/nobreak" -NoNewWindow -PassThru -Wait
            $proc.ExitCode | Should -Be 124
        }
    }

    Context 'Quoted command' {
        It 'should handle quoted echo command' {
            $proc = Start-Process powershell.exe -ArgumentList "-NoProfile", "-File", $timeoutScript, "2", "cmd", "/c", "echo quoted test" -NoNewWindow -PassThru -Wait -RedirectStandardOutput output.txt
            $result = Get-Content output.txt -Raw
            $result | Should -Match 'quoted test'
            Remove-Item output.txt -Force
        }
    }

    Context 'cmd /c command' {
        It 'should handle cmd /c echo' {
            $proc = Start-Process powershell.exe -ArgumentList "-NoProfile", "-File", $timeoutScript, "2", "cmd", "/c", "echo from-cmd" -NoNewWindow -PassThru -Wait -RedirectStandardOutput output.txt
            $result = Get-Content output.txt -Raw
            $result | Should -Match 'from-cmd'
            Remove-Item output.txt -Force
        }
    }

    Context 'Complex PowerShell command' {
        It 'should handle script block and pipeline' {
            $proc = Start-Process powershell.exe -ArgumentList "-NoProfile", "-File", $timeoutScript, "3", "powershell", "-NoProfile", "-Command", "1..3 | ForEach-Object { $_ * 2 } | Out-String" -NoNewWindow -PassThru -Wait -RedirectStandardOutput output.txt
            $result = Get-Content output.txt -Raw
            $result | Should -Match '2'
            $result | Should -Match '4'
            $result | Should -Match '6'
            Remove-Item output.txt -Force
        }
    }

    Context 'No side effects' {
        $testFile = Join-Path $env:TEMP "timeout-run-testfile.txt"
        AfterEach { if (Test-Path $testFile) { Remove-Item $testFile -Force } }
        It 'should not leave files behind' {
            $proc = Start-Process powershell.exe -ArgumentList "-NoProfile", "-File", $timeoutScript, "2", "cmd", "/c", "echo test > $testFile" -NoNewWindow -PassThru -Wait
            Test-Path $testFile | Should -Be $true
            Remove-Item $testFile -Force
            Start-Sleep -Milliseconds 500
            Test-Path $testFile | Should -Be $false
        }
    }
} 