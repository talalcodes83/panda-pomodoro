# Root Cause: "Access is denied" (os error 5)

## What's Happening

The error occurs when Cargo tries to **rename/copy** the build script executable:
```
build_script_build-3467bcec5ff51c2b.exe → build-script-build.exe
```

This happens **during compilation** of the `windows_x86_64_msvc` crate.

## Why It Happens (Root Causes)

1. **Antivirus/Windows Defender Locking Files**
   - Real-time scanning locks `.exe` files during compilation
   - File is locked when Cargo tries to rename/copy it
   - Even with Norton off, Windows Defender may still be active

2. **File System Permissions**
   - Sometimes even Administrator doesn't have full permissions
   - Windows file system security can block operations

3. **File Already Locked by Another Process**
   - Another Rust build process running
   - File explorer indexing the directory
   - IDE or editor has files open

4. **Windows File Locking Mechanism**
   - Windows locks files more aggressively than Linux/Mac
   - Build scripts create temporary `.exe` files that get locked

5. **Build Script Timing Issue**
   - Cargo compiles build script → creates `.exe`
   - Tries to rename immediately
   - Antivirus scans → locks file → rename fails

## Solutions That Actually Work

### Solution 1: Different Target Directory ⭐ Best
```powershell
$env:CARGO_TARGET_DIR = "target_build"
cargo build --release
```
**Why it works**: Fresh directory, less likely to have locked files

### Solution 2: Single-Threaded Build
```powershell
$env:CARGO_BUILD_JOBS = "1"
cargo build --release --jobs 1
```
**Why it works**: Less file contention, slower but more reliable

### Solution 3: Disable Incremental Compilation
```toml
[profile.release]
incremental = false
```
**Why it works**: Avoids partial build artifacts that might be locked

### Solution 4: Build Debug First
```powershell
cargo build        # Debug - usually works
cargo build --release
```
**Why it works**: Debug builds are less optimized, fewer file operations

### Solution 5: Complete Antivirus Disable
Not just "Real-time protection" OFF, but:
- Windows Defender: All protection OFF
- Cloud-delivered protection: OFF  
- Automatic sample submission: OFF
- Tamper protection: OFF

### Solution 6: Add Folder Exclusions
Add these to Windows Defender:
- `D:\pomodoroapp\src-tauri\target`
- `D:\pomodoroapp\src-tauri\target\release`
- `D:\pomodoroapp\src-tauri\target\release\build`

## Current Status

I've started a build with these workarounds:
- ✅ Cleaned build cache
- ✅ Using alternative target directory (`target_build`)
- ✅ Single-threaded build (`--jobs 1`)
- ✅ Disabled incremental compilation
- ✅ Added RUSTFLAGS workaround

The build is running in the background. If it succeeds, the executable will be at:
```
D:\pomodoroapp\src-tauri\target_build\release\cute-pomodoro-timer.exe
```

