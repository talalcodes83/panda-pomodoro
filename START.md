# How to Run the Pomodoro Timer App

## Quick Start

### Option 1: Use the build script (Easiest)
```powershell
cd D:\pomodoroapp
.\build-with-vs.ps1
```

This script will:
1. Load Visual Studio environment
2. Set up Rust toolchain
3. Start the dev server
4. Launch the app

### Option 2: Manual command
```powershell
cd D:\pomodoroapp
npm run tauri:dev
```

**Note:** You may need to load Visual Studio environment first if you see linker errors.

## What Happens When You Run It

1. **Vite dev server** starts on `http://localhost:1420`
2. **Rust compilation** begins (first time takes ~5-10 minutes)
3. **App window opens** automatically when compilation finishes
4. **Hot reload** - any changes to files will reload automatically

## Troubleshooting

### If you see "link.exe not found":
Run the build script instead:
```powershell
.\build-with-vs.ps1
```

### If port 1420 is in use:
```powershell
Get-NetTCPConnection -LocalPort 1420 | Stop-Process -Id {OwningProcess} -Force
```

### If Rust can't find VS tools:
Make sure you have Visual Studio Build Tools with C++ components installed.

## Stopping the App

- Click the **red ✕ button** in the app
- Or press `Ctrl+C` in the terminal







