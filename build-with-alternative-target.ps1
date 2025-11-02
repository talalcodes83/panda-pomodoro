# Build script using alternative target directory to avoid file locks
# Run this in Administrator PowerShell

Write-Host "Building with alternative target directory to avoid file locks..." -ForegroundColor Cyan

Set-Location "D:\pomodoroapp\src-tauri"

# Set alternative target directory
$env:CARGO_TARGET_DIR = "target_build"
$env:CARGO_INCREMENTAL = "0"

# Clean first
Write-Host "`n[1/3] Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path "target_build") {
    Remove-Item -Path "target_build" -Recurse -Force -ErrorAction SilentlyContinue
}

# Build
Write-Host "[2/3] Building release version..." -ForegroundColor Yellow
cargo build --release --jobs 1

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[3/3] Build successful!" -ForegroundColor Green
    Write-Host "`nExecutable location:" -ForegroundColor Cyan
    Write-Host "  src-tauri\target_build\release\cute-pomodoro-timer.exe" -ForegroundColor White
    
    # Copy to standard location for npm run tauri:build
    if (Test-Path "target_build\release\cute-pomodoro-timer.exe") {
        if (!(Test-Path "target\release")) {
            New-Item -Path "target\release" -ItemType Directory -Force | Out-Null
        }
        Copy-Item -Path "target_build\release\cute-pomodoro-timer.exe" -Destination "target\release\cute-pomodoro-timer.exe" -Force
        Write-Host "`nCopied to standard location: target\release\cute-pomodoro-timer.exe" -ForegroundColor Green
    }
} else {
    Write-Host "`nBuild failed. Check errors above." -ForegroundColor Red
}

Set-Location "D:\pomodoroapp"
Write-Host "`nDone!" -ForegroundColor Green

