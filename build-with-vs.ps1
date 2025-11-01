# Build script that loads Visual Studio environment first

# Find vcvars64.bat
$vcvarsPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
)

$vcvarsPath = $null
foreach ($path in $vcvarsPaths) {
    if (Test-Path $path) {
        $vcvarsPath = $path
        Write-Host "Found Visual Studio at: $vcvarsPath" -ForegroundColor Green
        break
    }
}

if (-not $vcvarsPath) {
    Write-Host "ERROR: Visual Studio Build Tools not found!" -ForegroundColor Red
    Write-Host "Please install Visual Studio Build Tools with C++ components" -ForegroundColor Yellow
    exit 1
}

Write-Host "Loading Visual Studio environment..." -ForegroundColor Yellow

# Load Visual Studio environment variables
& cmd /c "`"$vcvarsPath`" && set" | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        $name = $matches[1]
        $value = $matches[2]
        [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
        Set-Item -Path "env:$name" -Value $value
    }
}

Write-Host "Checking for link.exe..." -ForegroundColor Yellow
$linkPath = where.exe link.exe 2>$null
if ($linkPath) {
    Write-Host "Found link.exe: $linkPath" -ForegroundColor Green
} else {
    Write-Host "WARNING: link.exe not found in PATH" -ForegroundColor Red
}

Write-Host "Setting Rust to use MSVC..." -ForegroundColor Yellow
$env:Path = "$env:USERPROFILE\.cargo\bin;" + $env:Path
rustup default stable-x86_64-pc-windows-msvc

Write-Host "Building Tauri app..." -ForegroundColor Green
cd D:\pomodoroapp
npm run tauri:dev



