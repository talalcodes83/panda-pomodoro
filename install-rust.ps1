# Install Rust on Windows
Write-Host "Installing Rust..." -ForegroundColor Green

# Download and run rustup-init.exe
$rustupUrl = "https://win.rustup.rs/x86_64"
$rustupInstaller = "$env:TEMP\rustup-init.exe"

Write-Host "Downloading Rust installer..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $rustupUrl -OutFile $rustupInstaller

Write-Host "Running installer..." -ForegroundColor Yellow
Write-Host "Press Enter to accept defaults when prompted" -ForegroundColor Cyan
Start-Process -FilePath $rustupInstaller -ArgumentList "-y" -Wait

Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item $rustupInstaller -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Rust installation complete!" -ForegroundColor Green
Write-Host "Please close and reopen your terminal, then run: rustc --version" -ForegroundColor Yellow









