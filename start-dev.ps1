# Quick start script after restarting terminal

Write-Host "Loading Visual Studio environment..." -ForegroundColor Yellow

# Find and load VS environment
$vcvars = Get-ChildItem "$env:ProgramFiles\Microsoft Visual Studio\2022" -Recurse -Filter "vcvars64.bat" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($vcvars) {
    Write-Host "Found: $($vcvars.FullName)" -ForegroundColor Green
    
    # Load environment
    & cmd /c "`"$($vcvars.FullName)`" && set" | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            Set-Item -Path "env:$($matches[1])" -Value $matches[2]
        }
    }
    
    Write-Host "Starting build..." -ForegroundColor Green
    cd D:\pomodoroapp
    $env:Path = "$env:USERPROFILE\.cargo\bin;" + $env:Path
    npm run tauri:dev
} else {
    Write-Host "Visual Studio not found. Trying without VS environment..." -ForegroundColor Yellow
    cd D:\pomodoroapp
    $env:Path = "$env:USERPROFILE\.cargo\bin;" + $env:Path
    npm run tauri:dev
}



