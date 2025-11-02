# Build Monitor - Check when build completes
# Run this script to monitor the build progress

function CheckBuildStatus {
    $cargo = Get-Process -Name "cargo" -ErrorAction SilentlyContinue
    $rustc = Get-Process -Name "rustc" -ErrorAction SilentlyContinue
    
    # Check if executable exists (build succeeded)
    if (Test-Path "target_build\release\cute-pomodoro-timer.exe") {
        Write-Host "`n✅✅✅ BUILD COMPLETE! ✅✅✅" -ForegroundColor Green
        $exe = Get-Item "target_build\release\cute-pomodoro-timer.exe"
        Write-Host "Executable: $($exe.FullName)" -ForegroundColor Cyan
        Write-Host "Size: $([math]::Round($exe.Length / 1MB, 2)) MB" -ForegroundColor Cyan
        Write-Host "Created: $($exe.CreationTime)" -ForegroundColor Cyan
        return $true
    }
    elseif (Test-Path "target\release\cute-pomodoro-timer.exe") {
        Write-Host "`n✅✅✅ BUILD COMPLETE! ✅✅✅" -ForegroundColor Green
        $exe = Get-Item "target\release\cute-pomodoro-timer.exe"
        Write-Host "Executable: $($exe.FullName)" -ForegroundColor Cyan
        return $true
    }
    # Check if processes are still running
    elseif ($cargo -or $rustc) {
        Write-Host "Build still running... (Processes active)" -ForegroundColor Yellow
        if (Test-Path "build.log") {
            $lastLines = Get-Content "build.log" -Tail 3
            Write-Host "Latest: $($lastLines[-1])" -ForegroundColor Gray
        }
        return $false
    }
    # Build finished but no executable (likely failed)
    else {
        Write-Host "`nBuild process finished. Checking for errors..." -ForegroundColor Yellow
        if (Test-Path "build.log") {
            $errors = Select-String -Path "build.log" -Pattern "error:" | Select-Object -Last 3
            if ($errors) {
                Write-Host "`nErrors found:" -ForegroundColor Red
                $errors | ForEach-Object { Write-Host "  $($_.Line)" -ForegroundColor Red }
            } else {
                Write-Host "No errors in log. Checking status..." -ForegroundColor Yellow
            }
        }
        return $true
    }
}

# Monitor loop
Write-Host "Monitoring build..." -ForegroundColor Cyan
$finished = $false
$checks = 0

while (!$finished -and $checks -lt 600) {  # Check for up to 10 minutes
    $finished = CheckBuildStatus
    if (!$finished) {
        Start-Sleep -Seconds 10  # Check every 10 seconds
        $checks++
    }
}

if ($checks -ge 600) {
    Write-Host "`nMonitoring timeout. Build may still be running." -ForegroundColor Yellow
    Write-Host "Check manually: Get-Process | Where-Object { `$_.ProcessName -match 'cargo|rustc' }" -ForegroundColor Gray
}



