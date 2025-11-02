# Button Pixel Art Checklist

## Main Timer Controls (src/components/Controls.svelte)

### Play/Pause Button
- [ ] Size: **40px × 40px**
- [ ] Border: **3px solid** (#333)
- [ ] Border radius: **6px**
- [ ] States needed:
  - [ ] Default (white background #fff)
  - [ ] Running (green background #4ade80)
  - [ ] Hover (lighter green #22c55e)
  - [ ] Pressed (translateY 3px)

### Reset Button
- [ ] Size: **40px × 40px**
- [ ] Border: **3px solid** (#333)
- [ ] Border radius: **6px**
- [ ] Background: **#fff** (white)
- [ ] Hover: **#f0f0f0**

### Settings Button
- [ ] Size: **40px × 40px**
- [ ] Border: **3px solid** (#333)
- [ ] Border radius: **6px**
- [ ] Background: **#fff** (white)
- [ ] Hover: **#f0f0f0**

### Close Button
- [ ] Size: **40px × 40px**
- [ ] Border: **3px solid** (#333)
- [ ] Border radius: **6px**
- [ ] Background: **#f5576c** (red)
- [ ] Hover: **#e63946** (darker red)

---

## Music Player Controls (src/components/MusicPlayer.svelte)

### Download Button (Square)
- [ ] Size: **40px × 40px**
- [ ] Border: **3px solid** (#333)
- [ ] Border radius: **4px**
- [ ] Background: **#4ade80** (green)
- [ ] Hover: **#22c55e** (darker green)
- [ ] Disabled: **opacity 0.6**
- [ ] Box shadow: **0 3px 0** rgba(0, 0, 0, 0.2)

### Previous Track Button
- [ ] Size: **36px × 36px**
- [ ] Border: **3px solid** (#333)
- [ ] Border radius: **6px**
- [ ] Background: **#fff** (white)
- [ ] Hover: **#f0f0f0**
- [ ] Box shadow: **0 3px 0** rgba(0, 0, 0, 0.2)

### Play/Pause Button (Music Player)
- [ ] Size: **44px × 44px** (larger than prev/next)
- [ ] Border: **3px solid** (#333)
- [ ] Border radius: **6px**
- [ ] Background: **#4ade80** (green)
- [ ] Hover: **#22c55e** (darker green)
- [ ] Disabled: **opacity 0.6**
- [ ] Box shadow: **0 3px 0** rgba(0, 0, 0, 0.2)

### Next Track Button
- [ ] Size: **36px × 36px**
- [ ] Border: **3px solid** (#333)
- [ ] Border radius: **6px**
- [ ] Background: **#fff** (white)
- [ ] Hover: **#f0f0f0**
- [ ] Box shadow: **0 3px 0** rgba(0, 0, 0, 0.2)

### Remove Track Button (✕)
- [ ] Size: **20px × 20px**
- [ ] Border: **none**
- [ ] Background: **transparent** or rgba
- [ ] Font size: **14px**
- [ ] Hover: **rgba(255, 255, 255, 0.2)**

---

## Settings Panel Buttons (src/components/SettingsPanel.svelte)

### Save Button
- [ ] Size: **flex: 1** (takes half width)
- [ ] Height: **auto** (based on padding)
- [ ] Padding: **10px** (all sides)
- [ ] Border: **3px solid** (#333)
- [ ] Border radius: **4px**
- [ ] Background: **#fff** (white)
- [ ] Hover: **#f0f0f0**
- [ ] Font size: **12px**
- [ ] Box shadow: **0 3px 0** rgba(0, 0, 0, 0.2)

### Close Button (Settings)
- [ ] Size: **flex: 1** (takes half width)
- [ ] Height: **auto** (based on padding)
- [ ] Padding: **10px** (all sides)
- [ ] Border: **3px solid** (#333)
- [ ] Border radius: **4px**
- [ ] Background: **#fff** (white)
- [ ] Hover: **#f0f0f0**
- [ ] Font size: **12px**
- [ ] Box shadow: **0 3px 0** rgba(0, 0, 0, 0.2)

---

## Music Toggle Button (src/App.svelte)

### Music Toggle Button (🎵/🎶)
- [ ] Size: **32px × 32px**
- [ ] Border: **2px solid** (#333)
- [ ] Border radius: **6px**
- [ ] Background: **rgba(255, 255, 255, 0.9)**
- [ ] Hover: **#fff** (white)
- [ ] Font size: **18px**
- [ ] Box shadow: **0 2px 4px** rgba(0, 0, 0, 0.2)
- [ ] Position: **absolute, top: 10px, right: 10px**

---

## Common Button Features

All buttons share these characteristics:
- [ ] Font family: **'Courier New', monospace**
- [ ] Cursor: **pointer**
- [ ] Transition: **all 0.2s**
- [ ] Pressed state: **translateY 3px** (moves down on click)
- [ ] Shadow on press: **0 0 0** (flattened)

---

## Size Summary (Quick Reference)

| Button | Width | Height | Border | Border Radius |
|--------|-------|--------|--------|---------------|
| Timer Play/Pause | 40px | 40px | 3px | 6px |
| Timer Reset | 40px | 40px | 3px | 6px |
| Timer Settings | 40px | 40px | 3px | 6px |
| Timer Close | 40px | 40px | 3px | 6px |
| Download | 40px | 40px | 3px | 4px |
| Music Prev/Next | 36px | 36px | 3px | 6px |
| Music Play/Pause | 44px | 44px | 3px | 6px |
| Remove Track | 20px | 20px | none | - |
| Settings Save/Close | flex | auto | 3px | 4px |
| Music Toggle | 32px | 32px | 2px | 6px |

---

## Art Tips for Aseprite

1. **Work at exact pixel sizes** - Use the sizes above
2. **Account for borders** - Borders are OUTSIDE the button size (so a 40×40px button with 3px border is 46×46px total)
3. **Create separate layers** for each state:
   - Default
   - Hover
   - Active/Pressed
   - Disabled (where applicable)
4. **Colors to use:**
   - Border: #333 (dark gray)
   - White buttons: #fff → #f0f0f0 on hover
   - Green buttons: #4ade80 → #22c55e on hover
   - Red close: #f5576c → #e63946 on hover
5. **Shadows:**
   - 3D effect: 0 3px 0 rgba(0, 0, 0, 0.2) (for raised look)
   - Flat when pressed: 0 0 0
6. **Border radius:**
   - 6px for most buttons
   - 4px for download and settings buttons
7. **Export formats:**
   - PNG with transparency
   - One file per button state (or sprite sheet)


