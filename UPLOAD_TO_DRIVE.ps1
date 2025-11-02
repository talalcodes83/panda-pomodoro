# Quick script to prepare for Google Drive upload
Write-Host ""
Write-Host "PANDA-POMODORO - GOOGLE DRIVE UPLOAD" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$zipPath = "dist_portable\PandaPomodoro-v1.0.0.zip"

if (Test-Path $zipPath) {
    $zip = Get-Item $zipPath
    Write-Host ""
    Write-Host "Package ready!" -ForegroundColor Green
    Write-Host "Location: $($zip.FullName)" -ForegroundColor White
    Write-Host "Size: $([math]::Round($zip.Length / 1MB, 2)) MB" -ForegroundColor Yellow
    
    Write-Host ""
    Write-Host "To upload to Google Drive:" -ForegroundColor Cyan
    Write-Host "1. Go to: https://drive.google.com" -ForegroundColor White
    Write-Host "2. Click New button, then File upload" -ForegroundColor White
    Write-Host "3. Select this ZIP file" -ForegroundColor White
    Write-Host "4. Right-click the file, click Share, then Get link" -ForegroundColor White
    
    Write-Host ""
    Write-Host "Opening file location..." -ForegroundColor Yellow
    Start-Process explorer.exe -ArgumentList "/select,`"$($zip.FullName)`""
    
    Write-Host ""
    Write-Host "File location opened! Upload the ZIP to Google Drive." -ForegroundColor Green
} else {
    Write-Host "ZIP file not found at: $zipPath" -ForegroundColor Red
    Write-Host "Make sure the build completed successfully." -ForegroundColor Yellow
}
