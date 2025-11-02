# Button Assets Creation Checklist

Save your PNG files directly in this folder structure. Use this as a checklist while creating pixel art!

## 📁 `timer/` folder - Main Timer Controls

### Play/Pause Button (40×40px)
- [ ] `play-default.png` - White background, play icon (▶)
- [ ] `play-hover.png` - Light gray hover (#f0f0f0)
- [ ] `pause-default.png` - Green background (#4ade80), pause icon (⏸)
- [ ] `pause-hover.png` - Darker green hover (#22c55e)

### Reset Button (40×40px)
- [ ] `reset-default.png` - White background, reset icon (↻)
- [ ] `reset-hover.png` - Light gray hover (#f0f0f0)

### Settings Button (40×40px)
- [ ] `settings-default.png` - White background, settings icon (⚙)
- [ ] `settings-hover.png` - Light gray hover (#f0f0f0)

### Close Button (40×40px)
- [ ] `close-default.png` - Red background (#f5576c), close icon (✕)
- [ ] `close-hover.png` - Darker red hover (#e63946)

---

## 📁 `music/` folder - Music Player Controls

### Previous Track Button (36×36px)
- [ ] `prev-default.png` - White background, prev icon (⏮)
- [ ] `prev-hover.png` - Light gray hover (#f0f0f0)

### Next Track Button (36×36px)
- [ ] `next-default.png` - White background, next icon (⏭)
- [ ] `next-hover.png` - Light gray hover (#f0f0f0)

### Play Button - Music Player (44×44px) - **LARGEST**
- [ ] `play-music-default.png` - Green background (#4ade80), play icon (▶)
- [ ] `play-music-hover.png` - Darker green hover (#22c55e)

### Pause Button - Music Player (44×44px)
- [ ] `pause-music-default.png` - Green background (#4ade80), pause icon (⏸)
- [ ] `pause-music-hover.png` - Darker green hover (#22c55e)

### Download Button (40×40px)
- [ ] `download-default.png` - Green background (#4ade80), download icon
- [ ] `download-hover.png` - Darker green hover (#22c55e)
- [ ] `download-disabled.png` - Grayed out, opacity 0.6

### Remove Track Button (20×20px) - **SMALLEST**
- [ ] `remove-default.png` - Transparent, X icon (✕)
- [ ] `remove-hover.png` - Slight highlight or glow

---

## 📁 `settings/` folder - Settings Panel Buttons

### Save Button (flex width, 10px padding)
- [ ] `save-default.png` - White background, "Save" text
- [ ] `save-hover.png` - Light gray hover (#f0f0f0)

### Close Button - Settings (flex width, 10px padding)
- [ ] `close-settings-default.png` - White background, "Close" text
- [ ] `close-settings-hover.png` - Light gray hover (#f0f0f0)

---

## 📁 `other/` folder - Other Buttons

### Music Toggle Button (32×32px)
- [ ] `music-toggle-default.png` - Semi-transparent white (rgba 0.9), music icon (🎵)
- [ ] `music-toggle-hover.png` - Full white (#fff)

---

## 🎨 Art Style Guide

### Colors to Use:
- **Border**: #333 (dark gray/black) - **3px solid** for most, **2px** for music toggle
- **White buttons**: #fff → #f0f0f0 (hover)
- **Green buttons**: #4ade80 → #22c55e (hover)
- **Red close**: #f5576c → #e63946 (hover)

### Border Radius:
- **6px**: Most buttons (timer controls, music prev/next, music play/pause)
- **4px**: Download button, settings buttons

### Shadows (for 3D effect):
- **Default**: `0 3px 0 rgba(0, 0, 0, 0.2)`
- **Pressed**: `0 0 0` (flat)
- **Music toggle**: `0 2px 4px rgba(0, 0, 0, 0.2)`

### Remember:
- Borders are **OUTSIDE** the button size
- 40px button + 3px border = **46px total width**
- Create transparent backgrounds for PNG files
- Test at actual pixel size!

---

## Quick Reference Table

| Button | Folder | Size | States Needed |
|--------|--------|------|---------------|
| Play/Pause (Timer) | timer/ | 40×40 | 2-4 states |
| Reset | timer/ | 40×40 | 2 states |
| Settings | timer/ | 40×40 | 2 states |
| Close (Timer) | timer/ | 40×40 | 2 states |
| Previous | music/ | 36×36 | 2 states |
| Next | music/ | 36×36 | 2 states |
| Play (Music) | music/ | **44×44** | 2 states |
| Pause (Music) | music/ | **44×44** | 2 states |
| Download | music/ | 40×40 | 3 states |
| Remove | music/ | **20×20** | 2 states |
| Save | settings/ | flex | 2 states |
| Close (Settings) | settings/ | flex | 2 states |
| Music Toggle | other/ | 32×32 | 2 states |

---

## ✅ When You're Done

Once you've saved all your PNG files here, I can help you integrate them into the components. Just let me know when you're ready!

