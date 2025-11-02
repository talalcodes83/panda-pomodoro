# Script to update the portable bundle with latest build
# Run this after building the app

Write-Host "Updating portable bundle with latest build..." -ForegroundColor Cyan

$exePath = "src-tauri\target_build\x86_64-pc-windows-msvc\release\CutePomodoroTimer.exe"
$exePathAlt = "src-tauri\target\release\CutePomodoroTimer.exe"

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
$distFolder = "dist_portable\PandaPomodoro"
New-Item -ItemType Directory -Path $distFolder -Force | Out-Null

# Copy executable
Copy-Item -Path $exe -Destination "$distFolder\PandaPomodoro.exe" -Force
Write-Host "Copied executable to distribution folder" -ForegroundColor Green

# Copy dist folder contents (frontend assets)
$distSrc = "dist"
$distDest = "$distFolder\dist"
if (Test-Path $distSrc) {
    if (Test-Path $distDest) {
        Remove-Item -Path $distDest -Recurse -Force
    }
    Copy-Item -Path "$distSrc\*" -Destination $distDest -Recurse -Force
    Write-Host "Copied frontend assets" -ForegroundColor Green
}

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
- Auto-play next track when current ends
- Loops back to first track after last track
- Pixel art style interface

USAGE:
- Click Play to start timer
- Click music icon (top-right) to open music player
- Drag window to move (click anywhere except buttons)
- Music automatically plays next track and loops

Enjoy!
"@

$readme | Out-File -FilePath "$distFolder\README.txt" -Encoding UTF8
Write-Host "Created README.txt" -ForegroundColor Green

# Bundle yt-dlp.exe if not already there
$ytdlpPath = "$distFolder\yt-dlp.exe"
if (-not (Test-Path $ytdlpPath)) {
    Write-Host "`nBundling yt-dlp.exe..." -ForegroundColor Yellow
    .\bundle-ytdlp.ps1
}

# Create ZIP
$zipPath = "dist_portable\PandaPomodoro-v1.0.0.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path "$distFolder\*" -DestinationPath $zipPath -Force
Write-Host "`nCreated ZIP: $zipPath" -ForegroundColor Green

# Show file info
$exeInfo = Get-Item $exe
$zipInfo = Get-Item $zipPath

Write-Host "`nUpdated bundle ready:" -ForegroundColor Cyan
Write-Host "  Executable: $([math]::Round($exeInfo.Length / 1MB, 2)) MB" -ForegroundColor White
Write-Host "  ZIP file: $([math]::Round($zipInfo.Length / 1MB, 2)) MB" -ForegroundColor White
Write-Host "`nLocation: dist_portable\PandaPomodoro\" -ForegroundColor Yellow
Write-Host "ZIP: dist_portable\PandaPomodoro-v1.0.0.zip" -ForegroundColor Yellow

Write-Host "`n✅ Bundle updated with latest changes!" -ForegroundColor Green

