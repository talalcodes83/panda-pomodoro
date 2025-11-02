# Build script - try debug mode first, then release
# Sometimes debug mode works when release doesn't

Write-Host "Building in DEBUG mode first..." -ForegroundColor Cyan
Set-Location src-tauri

# Build debug version first
cargo build

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nDebug build succeeded! Now trying release..." -ForegroundColor Green
    cargo build --release
} else {
    Write-Host "`nDebug build failed. Check errors above." -ForegroundColor Red
}

Set-Location ..
Write-Host "`nBuild complete!" -ForegroundColor Green

