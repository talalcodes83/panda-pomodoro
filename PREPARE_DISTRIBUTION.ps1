# Script to prepare app for distribution
# Run this after build completes

Write-Host "Preparing app for distribution..." -ForegroundColor Cyan

$exePath = "src-tauri\target_build\release\cute-pomodoro-timer.exe"
$exePathAlt = "src-tauri\target\release\cute-pomodoro-timer.exe"

# Find executable
if (Test-Path $exePath) {
    $exe = $exePath
} elseif (Test-Path $exePathAlt) {
    $exe = $exePathAlt
} else {
    Write-Host "ERROR: Executable not found!" -ForegroundColor Red
    Write-Host "Make sure build completed successfully." -ForegroundColor Yellow
    exit 1
}

Write-Host "Found executable: $exe" -ForegroundColor Green

# Create distribution folder
$distFolder = "dist\PandaPomodoro"
New-Item -ItemType Directory -Path $distFolder -Force | Out-Null

# Copy executable
Copy-Item -Path $exe -Destination "$distFolder\PandaPomodoro.exe" -Force
Write-Host "Copied executable to distribution folder" -ForegroundColor Green

# Create README
$readme = @"
PANDA-POMODORO TIMER v1.0.0
By Talal

INSTALLATION:
1. Run PandaPomodoro.exe
2. If Windows Defender blocks it:
   - Click "More info"
   - Click "Run anyway"

FEATURES:
- Pomodoro timer with study/break cycles
- Music player with playlist support
- Pixel art style interface

USAGE:
- Click Play to start timer
- Click music icon (top-right) to open music player
- Drag window to move (click anywhere except buttons)

Enjoy!
"@

$readme | Out-File -FilePath "$distFolder\README.txt" -Encoding UTF8
Write-Host "Created README.txt" -ForegroundColor Green

# Create ZIP
$zipPath = "dist\PandaPomodoro-v1.0.0.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path "$distFolder\*" -DestinationPath $zipPath -Force
Write-Host "`nCreated ZIP: $zipPath" -ForegroundColor Green

# Show file info
$exeInfo = Get-Item $exe
$zipInfo = Get-Item $zipPath

Write-Host "`nDistribution files ready:" -ForegroundColor Cyan
Write-Host "  Executable: $($exeInfo.Length / 1MB | ForEach-Object { [math]::Round($_, 2) }) MB" -ForegroundColor White
Write-Host "  ZIP file: $($zipInfo.Length / 1MB | ForEach-Object { [math]::Round($_, 2) }) MB" -ForegroundColor White
Write-Host "`nShare the ZIP file from: $zipPath" -ForegroundColor Yellow

Write-Host "`n✅ Ready for distribution!" -ForegroundColor Green



