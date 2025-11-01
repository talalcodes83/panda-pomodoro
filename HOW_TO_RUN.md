# 🚀 How to Run the Pomodoro Timer App

## ✅ The Easiest Way (Recommended)

**Option 1: Using the PowerShell script (handles VS setup automatically)**

```powershell
cd D:\pomodoroapp
.\build-with-vs.ps1
```

That's it! The script will:
1. ✅ Load Visual Studio environment automatically
2. ✅ Set up Rust toolchain
3. ✅ Start the Vite dev server (on port 5173)
4. ✅ Launch the app window

**Option 2: Using npm directly**

```powershell
cd D:\pomodoroapp
npm run tauri:dev
```

**Note:** If you use `npm run tauri:dev` directly, make sure your Visual Studio environment is loaded first (the PowerShell script does this automatically). If you get "link.exe not found" errors, use Option 1 instead.

**Wait for it to finish compiling** (first time takes 5-10 minutes), then the app window will open automatically!

**Note:** Port changed from 1420 to 5173 to avoid conflicts.

---

## 📝 What You'll See

1. **Terminal output**: Lots of "Compiling..." messages
2. **Vite starts**: "VITE v5.x.x ready in X ms"
3. **Rust compiles**: "Finished dev profile" message
4. **App opens**: A 300×400px window with your pomodoro timer! 🎉

---

## 🛑 If Port 5173 is Busy

The app now uses port 5173 (Vite default). If you see "Port is already in use", Vite will automatically try the next available port (5174, 5175, etc.) since `strictPort: false` is set.

---

## 🎮 Using the App

- **Drag the window**: Click and hold the timer background (not buttons) to drag
- **Close**: Click the red ✕ button (4th button on the bottom row)
- **Start timer**: Click ▶ button
- **Pause**: Click ⏸ button  
- **Reset**: Click ↻ button
- **Settings**: Click ⚙ button

---

## 🏗️ Building for Distribution

To create a distributable app:

```powershell
cd D:\pomodoroapp
.\build-with-vs.ps1
```

Or manually:
```powershell
npm run tauri:build
```

The built app will be in `src-tauri/target/release/bundle/`

---

## ⚠️ Troubleshooting

### "link.exe not found"
- Make sure Visual Studio Build Tools are installed
- Run `.\build-with-vs.ps1` (it loads VS environment)

### "Rust not found"
- Make sure Rust is installed: `rustc --version`
- Restart your terminal

### "Port already in use"
- The app uses port 5173, but will automatically try 5174, 5175, etc. if busy
- Or kill processes: `Get-Process -Name "node" | Stop-Process -Force`

### "Access is denied" during release build
If you get "Access is denied (os error 5)" when building for release:
1. **Add exclusion in Windows Defender:**
   - Open Windows Security → Virus & threat protection
   - Click "Manage settings" under Virus & threat protection settings
   - Scroll to "Exclusions" → "Add or remove exclusions"
   - Click "Add an exclusion" → "Folder" → Select `D:\pomodoroapp`
2. **Or use dev mode for development:**
   - Dev mode works fine: `npm run tauri:dev`
   - Release builds are only needed for distribution
3. **Clean and retry:**
   ```powershell
   Remove-Item -Recurse -Force "D:\pomodoroapp\src-tauri\target\release" -ErrorAction SilentlyContinue
   npm run tauri:build
   ```

---

**That's it! Just run `.\build-with-vs.ps1` and wait for the app window to open! 🎉**

