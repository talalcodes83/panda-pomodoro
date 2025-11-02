# Switch to GNU toolchain (no Visual Studio required)
Write-Host "Switching to GNU toolchain..." -ForegroundColor Yellow

# Install Rust with GNU toolchain
$rustupUrl = "https://win.rustup.rs/x86_64"
$rustupInstaller = "$env:TEMP\rustup-init.exe"

Write-Host "Downloading Rust installer..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $rustupUrl -OutFile $rustupInstaller

Write-Host "Installing GNU toolchain..." -ForegroundColor Yellow
# This will prompt - select option 2 for GNU toolchain
Start-Process -FilePath $rustupInstaller -Wait

Remove-Item $rustupInstaller -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Please close and reopen your terminal!" -ForegroundColor Green









