# Build Fix - "Access is denied" Error

Even with Norton off, you're getting the error. Try these:

## Solution 1: Run PowerShell as Administrator ⭐ RECOMMENDED
1. **Close this terminal completely**
2. **Right-click PowerShell** → **Run as Administrator**
3. Navigate: `cd D:\pomodoroapp`
4. Build: `npm run tauri:build`

## Solution 2: Disable Windows Defender Temporarily
1. Open **Windows Security** (search "Windows Security" in Start menu)
2. **Virus & threat protection** → **Manage settings**
3. Turn **OFF** "Real-time protection" (temporarily)
4. Build, then turn it back ON

## Solution 3: Add Exclusions to Windows Defender
1. **Windows Security** → **Virus & threat protection** → **Manage settings**
2. Scroll to **Exclusions** → **Add or remove exclusions**
3. Add folder: `D:\pomodoroapp\src-tauri\target`

## Solution 4: Check for Other Antivirus
- Check if you have **McAfee**, **Avast**, **AVG**, or other antivirus running
- Temporarily disable them during build

## Solution 5: Build in Debug Mode First
```powershell
cd src-tauri
cargo build  # Debug mode
# If that works, try release:
cargo build --release
```

## Solution 6: Clean Build
```powershell
cd src-tauri
cargo clean
cd ..
npm run tauri:build
```

Most likely fix: **Run PowerShell as Administrator** - this usually solves it!

