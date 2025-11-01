# Load Visual Studio environment and run Tauri dev

# Try to find vcvars64.bat
$vcvarsPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
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
    Write-Host "Visual Studio Build Tools not found!" -ForegroundColor Red
    Write-Host "Please install Visual Studio Build Tools from:" -ForegroundColor Yellow
    Write-Host "https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022" -ForegroundColor Cyan
    exit 1
}

# Load Visual Studio environment
Write-Host "Loading Visual Studio environment..." -ForegroundColor Yellow
& cmd /c "`"$vcvarsPath`" && set" | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        Set-Item -Path "env:$($matches[1])" -Value $matches[2]
    }
}

Write-Host "Running Tauri dev..." -ForegroundColor Green
npm run tauri:dev




