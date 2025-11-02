# Script to download and bundle yt-dlp.exe with the app

Write-Host "Downloading yt-dlp.exe for bundling..." -ForegroundColor Cyan

$ytdlpUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
$outputPath = "dist_portable\PandaPomodoro\yt-dlp.exe"

# Create directory if needed
New-Item -ItemType Directory -Path "dist_portable\PandaPomodoro" -Force | Out-Null

# Download yt-dlp.exe
try {
    Write-Host "Downloading from: $ytdlpUrl" -ForegroundColor Yellow
    Invoke-WebRequest -Uri $ytdlpUrl -OutFile $outputPath -UseBasicParsing
    Write-Host "✅ Downloaded yt-dlp.exe" -ForegroundColor Green
    
    $file = Get-Item $outputPath
    Write-Host "Size: $([math]::Round($file.Length / 1MB, 2)) MB" -ForegroundColor Cyan
    
    Write-Host "`n✅ yt-dlp.exe bundled with app!" -ForegroundColor Green
    Write-Host "Users won't need Python or separate yt-dlp installation!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download: $_" -ForegroundColor Red
    Write-Host "`nManual option:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/yt-dlp/yt-dlp/releases/latest" -ForegroundColor White
    Write-Host "2. Download yt-dlp.exe" -ForegroundColor White
    Write-Host "3. Place it in: dist_portable\PandaPomodoro\yt-dlp.exe" -ForegroundColor White
}



