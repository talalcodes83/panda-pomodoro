# Where Is The Build Building?

## Default Build Location
By default, Cargo builds to:
```
D:\pomodoroapp\src-tauri\target\release\
```

The executable will be at:
```
D:\pomodoroapp\src-tauri\target\release\cute-pomodoro-timer.exe
```

## If Using Alternative Target Directory
If you set `CARGO_TARGET_DIR=target_temp`, it builds to:
```
D:\pomodoroapp\src-tauri\target_temp\release\
```

## To Check Current Build Location

**In PowerShell:**
```powershell
cd D:\pomodoroapp\src-tauri
# Check environment variable
echo $env:CARGO_TARGET_DIR

# Check if target directory exists
Test-Path "target\release"
Test-Path "target_temp\release"

# See recent files
Get-ChildItem -Path "target\release" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 10
```

## Build Process Status

**Check if build is running:**
```powershell
Get-Process | Where-Object { $_.ProcessName -match "cargo|rustc" }
```

**Watch build output in real-time:**
```powershell
cd D:\pomodoroapp\src-tauri
cargo build --release
```

## Summary
- **Default**: `src-tauri\target\release\`
- **Alternative**: `src-tauri\target_temp\release\` (if CARGO_TARGET_DIR is set)
- **Executable name**: `cute-pomodoro-timer.exe`

