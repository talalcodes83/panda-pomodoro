# 📦 Build Output Locations

After a successful build, your executable will be at:

## Release Build (Normal)
```
src-tauri\target\release\cute-pomodoro-timer.exe
```

## Debug Build
```
src-tauri\target\debug\cute-pomodoro-timer.exe
```

## If Using Alternative Target Directory
```
src-tauri\target_temp\release\cute-pomodoro-timer.exe
```

## Final Installers (for distribution)
After running `npm run tauri:build`, the installers will be at:

- **MSI Installer**: `src-tauri\target\release\bundle\msi\`
- **NSIS Installer**: `src-tauri\target\release\bundle\nsis\`

## How to Find Your Executable

**In PowerShell:**
```powershell
Get-ChildItem -Path "src-tauri\target\release" -Filter "*.exe" -Recurse
```

**Or manually navigate to:**
```
D:\pomodoroapp\src-tauri\target\release\
```

Look for `cute-pomodoro-timer.exe` - that's your app!

