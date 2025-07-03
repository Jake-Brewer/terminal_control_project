# Requires -Modules Pester

Describe 'Timeout-Run' {
    $timeoutScript = Join-Path $PSScriptRoot '..' 'timeout-run.ps1'
    $isWindows = $env:OS -eq 'Windows_NT'

    Context 'Happy path: command completes before timeout' {
        It 'should output text and exit 0' {
            $result = & powershell.exe -NoProfile -File $timeoutScript 3 echo happy-path
            $result | Should -Match 'happy-path'
        }
    }

    Context 'Sad path: command exceeds timeout' {
        It 'should time out and exit 124' {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $proc = Start-Process powershell.exe -ArgumentList "-NoProfile -File `"$timeoutScript`" 1 timeout /t 5 /nobreak" -NoNewWindow -PassThru -Wait
            $sw.Stop()
            $proc.ExitCode | Should -Be 124
            $sw.Elapsed.TotalSeconds | Should -BeLessThan 3
        }
    }

    Context 'Quoted command' {
        It 'should handle quoted echo command' {
            $result = & powershell.exe -NoProfile -File $timeoutScript 2 'echo "quoted test"'
            $result | Should -Match 'quoted test'
        }
    }

    Context 'cmd /c command' {
        It 'should handle cmd /c echo' {
            $result = & powershell.exe -NoProfile -File $timeoutScript 2 cmd /c echo from-cmd
            $result | Should -Match 'from-cmd'
        }
    }

    Context 'No side effects' {
        $testFile = Join-Path $env:TEMP "timeout-run-testfile.txt"
        AfterEach { if (Test-Path $testFile) { Remove-Item $testFile -Force } }
        It 'should not leave files behind' {
            & powershell.exe -NoProfile -File $timeoutScript 2 cmd /c "echo test > $testFile"
            Test-Path $testFile | Should -Be $true
            Remove-Item $testFile -Force
            Start-Sleep -Milliseconds 500
            Test-Path $testFile | Should -Be $false
        }
    }
} 