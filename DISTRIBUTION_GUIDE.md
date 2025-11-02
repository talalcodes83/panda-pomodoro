# Distribution Guide - Sharing Your App

## Where Your Executable Will Be

After build completes:
```
D:\pomodoroapp\src-tauri\target_build\release\cute-pomodoro-timer.exe
```

## Option 1: Create Installer (Recommended) ⭐

After build completes, create a proper installer:

```powershell
cd D:\pomodoroapp
npm run tauri:build
```

This creates installers in:
- **MSI Installer**: `src-tauri\target\release\bundle\msi\CutePomodoroTimer_1.0.0_x64_en-US.msi`
- **NSIS Installer**: `src-tauri\target\release\bundle\nsis\CutePomodoroTimer_1.0.0_x64-setup.exe`

**Best for distribution!** Users can install it properly.

## Option 2: Share Executable Directly

### Hosting Options:

#### A. GitHub Releases (Free, Recommended)
1. Create a GitHub repository
2. Go to **Releases** → **Create a new release**
3. Upload the `.exe` file
4. Share the download link

#### B. Google Drive / OneDrive
1. Upload `cute-pomodoro-timer.exe` to Google Drive or OneDrive
2. Right-click → **Get link** → Share link
3. Anyone with link can download

#### C. WeTransfer (Free, Easy)
1. Go to [wetransfer.com](https://wetransfer.com)
2. Upload the `.exe` file
3. Get a shareable link (expires in 7 days)

#### D. Dropbox / MediaFire
- Upload and get shareable link

## Option 3: USB/Email

- Copy `.exe` to USB drive
- Email the `.exe` (may be blocked by some email providers)
- File sharing services

## Option 4: Create ZIP Package

Create a portable package:
1. Create folder: `PandaPomodoro`
2. Copy `cute-pomodoro-timer.exe` into folder
3. Add `README.txt` with instructions
4. Zip the folder
5. Share the ZIP file

## Important Notes

⚠️ **Windows Defender Warning**
- Windows may flag the `.exe` as "unknown publisher"
- Users may need to click "More info" → "Run anyway"
- This is normal for unsigned executables

✅ **To Avoid Warnings (Advanced)**
- Code signing certificate (costs money, $100+/year)
- Microsoft Store (free but requires registration)
- For now, users can bypass the warning

## Recommended Approach

1. **Build installer** with `npm run tauri:build`
2. **Host MSI/NSIS installer** on:
   - GitHub Releases (best for updates)
   - Google Drive (easy sharing)
   - Personal website

3. **Instructions for users:**
   - Download the installer
   - Run installer
   - If Windows blocks it: "More info" → "Run anyway"

## Quick Share Script

After build completes, I can help you:
1. Zip the executable
2. Prepare download instructions
3. Set up GitHub release (if you want)

Let me know when build completes and I'll help you prepare the distribution package!



