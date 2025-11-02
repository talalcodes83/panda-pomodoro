# Quick Build Fix - Build Stuck

## Manual Build Steps (Run in Administrator PowerShell)

### Option 1: Alternative Target Directory
```powershell
cd D:\pomodoroapp\src-tauri
$env:CARGO_TARGET_DIR = "target_build"
$env:CARGO_BUILD_JOBS = "1"
cargo build --release --jobs 1
```

### Option 2: Build Debug First, Then Release
```powershell
cd D:\pomodoroapp\src-tauri
cargo build          # Debug mode (usually works)
cargo build --release # Then release
```

### Option 3: Clean and Rebuild
```powershell
cd D:\pomodoroapp\src-tauri
cargo clean
cargo build --release
```

### Option 4: Single Command (Try This First!)
```powershell
cd D:\pomodoroapp\src-tauri
cargo build --release
```

If that fails with the same error, try Option 1 (alternative target directory).

## If Build Gets Stuck
1. Press `Ctrl+C` to cancel
2. Kill processes: `Get-Process | Where-Object { $_.ProcessName -match "cargo|rustc" } | Stop-Process -Force`
3. Try again with a different method

## Expected Output Location
- **Normal**: `src-tauri\target\release\cute-pomodoro-timer.exe`
- **Alternative**: `src-tauri\target_build\release\cute-pomodoro-timer.exe`

