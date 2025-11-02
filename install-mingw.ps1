# Install MinGW manually
Write-Host "Downloading MinGW-w64..." -ForegroundColor Yellow

$downloadUrl = "https://github.com/niXman/mingw-builds-binaries/releases/download/13.2.0-rt_v11-rev0/x86_64-13.2.0-release-posix-seh-ucrt-rt_v11-rev0.7z"
$downloadPath = "$env:TEMP\mingw.7z"
$extractPath = "C:\mingw64"

Write-Host "This will download and extract MinGW to C:\mingw64" -ForegroundColor Cyan
Write-Host "Make sure Norton has an exception for this!" -ForegroundColor Yellow

# Download MinGW
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# Extract (requires 7-zip)
if (Get-Command "7z.exe" -ErrorAction SilentlyContinue) {
    Write-Host "Extracting with 7-zip..." -ForegroundColor Yellow
    & 7z.exe x $downloadPath -o"C:\" -y
} else {
    Write-Host "7-zip not found. Please extract manually:" -ForegroundColor Red
    Write-Host "1. Install 7-zip" -ForegroundColor Yellow
    Write-Host "2. Extract $downloadPath to C:\" -ForegroundColor Yellow
    Write-Host "3. Add C:\mingw64\bin to PATH" -ForegroundColor Yellow
    exit
}

Write-Host "Adding to PATH..." -ForegroundColor Yellow
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$extractPath\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$extractPath\bin", "User")
}

Write-Host "MinGW installed! Please restart your terminal." -ForegroundColor Green







