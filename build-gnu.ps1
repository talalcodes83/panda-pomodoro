# Build script that forces GNU toolchain for everything

$env:Path = "$env:USERPROFILE\.cargo\bin;" + $env:Path

# Force GNU toolchain for build scripts (host) and target
$env:CARGO_BUILD_TARGET = "x86_64-pc-windows-gnu"
$env:RUSTC = "$env:USERPROFILE\.cargo\bin\rustc.exe"
$env:CARGO_BUILD_RUSTC = "$env:USERPROFILE\.cargo\bin\rustc.exe"

# Set toolchain to GNU
rustup override set stable-x86_64-pc-windows-gnu

cd D:\pomodoroapp
npm run tauri:dev




