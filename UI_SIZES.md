# UI Element Sizes for Pixel Art

## Window/App Sizes
- **Main App Window**: 300px × 550px
- **Music Player Container**: 300px × 500px
  - Position: top: 50px, right: 0
  - Padding: 15px (all sides)
  - Border: 4px solid
  - Border radius: 8px

## Music Player Elements

### Header
- **Player Header** ("🎵 Music Player")
  - Font size: 16px
  - Margin bottom: 15px

### Download Section
- **Download Input Wrapper**
  - Gap between input and button: 8px
  
- **YouTube URL Input Field**
  - Width: flex (takes remaining space after button)
  - Height: auto (based on padding + font)
  - Padding: 8px (all sides)
  - Border: 3px solid
  - Border radius: 4px
  - Font size: 12px
  - Gap between input and button: 8px

- **Download Button (Square)**
  - Width: 40px
  - Height: 40px
  - Padding: 0
  - Border: 3px solid
  - Border radius: 4px
  - Font size: 16px
  - Box shadow: 0 3px 0

- **Download Progress Text**
  - Font size: 11px
  - Margin top: 5px

### Playlist Section

- **Playlist Header** ("Study Music" + track count)
  - Font size: 12px (main text)
  - Font size: 11px (track count)
  - Margin bottom: 10px

- **Playlist Container** (scrollable area)
  - Max height: 350px
  - Margin bottom: 10px
  - Border: 2px solid
  - Border radius: 6px
  - Padding: 5px (all sides)
  - Scrollbar width: 8px

- **Playlist Item** (each track)
  - Padding: 8px (all sides)
  - Margin bottom: 5px (between items)
  - Border: 2px solid
  - Border radius: 4px
  
- **Track Title** (in playlist item)
  - Font size: 11px
  
- **Remove Button** (✕ in playlist item)
  - Width: 20px
  - Height: 20px
  - Padding: 0
  - Font size: 14px
  - Margin left: 8px

### Current Track Display

- **Current Track Container**
  - Padding: 10px (all sides)
  - Margin bottom: 15px
  - Border: 2px solid
  - Border radius: 6px

- **Track Name** (current playing track)
  - Font size: 13px
  - Margin bottom: 8px

- **Progress Bar Container**
  - Width: 100%
  - Margin bottom: 5px

- **Progress Bar** (track progress)
  - Width: 100%
  - Height: 8px
  - Border: 2px solid
  - Border radius: 4px (outer)
  - Border radius: 2px (fill inner)

- **Time Info** (current/total time)
  - Font size: 10px
  - Margin top: 3px
  - Gap between times: space-between (full width)

### Player Controls

- **Controls Container**
  - Gap between buttons: 10px
  - Margin bottom: 10px

- **Previous/Next Buttons**
  - Width: 36px
  - Height: 36px
  - Border: 3px solid
  - Border radius: 6px
  - Font size: 14px
  - Box shadow: 0 3px 0

- **Play/Pause Button**
  - Width: 44px
  - Height: 44px
  - Border: 3px solid
  - Border radius: 6px
  - Font size: 18px
  - Box shadow: 0 3px 0

### Volume Control

- **Volume Control Container**
  - Gap: 8px (between icon, slider, and percentage)
  - Margin bottom: 10px
  - Font size: 12px

- **Volume Slider**
  - Width: flex (takes available space)
  - Height: standard range input height

### Empty States

- **Empty State Container**
  - Padding: 20px (all sides)
  - Margin bottom: 15px
  - Border: 2px solid
  - Border radius: 6px
  - Font size: 12px

- **Empty Playlist**
  - Padding: 20px (all sides)
  - Font size: 12px

## Music Toggle Button (on main app)

- **Music Toggle Button**
  - Width: 32px
  - Height: 32px
  - Position: absolute, top: 10px, right: 10px
  - Border: 2px solid
  - Border radius: 6px
  - Font size: 18px
  - Box shadow: 0 2px 4px

## Spacing Summary

### Padding Values
- Music Player: 15px
- Download Input: 8px
- Current Track: 10px
- Playlist Container: 5px
- Playlist Items: 8px
- Empty States: 20px

### Margin Values
- Player Header bottom: 15px
- Download Section bottom: 15px
- Playlist Header bottom: 10px
- Current Track bottom: 15px
- Controls bottom: 10px
- Volume Control bottom: 10px
- Playlist bottom: 10px
- Playlist Items: 5px (between items)
- Progress Bar bottom: 5px
- Time Info top: 3px
- Download Progress top: 5px

### Gap Values
- Download Input Wrapper: 8px
- Player Controls: 10px
- Volume Control: 8px

### Border Values
- Music Player: 4px
- Download Input: 3px
- Download Button: 3px
- Control Buttons: 3px
- Progress Bar: 2px
- Current Track: 2px
- Playlist Container: 2px
- Playlist Items: 2px
- Empty States: 2px
- Music Toggle: 2px

### Border Radius Values
- Music Player: 8px
- Download Input: 4px
- Download Button: 4px
- Control Buttons: 6px
- Progress Bar: 4px outer, 2px inner fill
- Current Track: 6px
- Playlist Container: 6px
- Playlist Items: 4px
- Empty States: 6px
- Music Toggle: 6px
- Scrollbar Track: 4px
- Scrollbar Thumb: 4px

## Font Sizes
- Player Header: 16px
- Download Input: 12px
- Download Button: 16px
- Download Progress: 11px
- Playlist Header: 12px
- Track Count: 11px
- Track Title (playlist): 11px
- Track Name (current): 13px
- Time Info: 10px
- Control Buttons: 14px (prev/next), 18px (play)
- Remove Button: 14px
- Volume Control: 12px
- Empty States: 12px
- Music Toggle: 18px

## Color Reference
- Music Player Background: Gradient (#667eea to #764ba2)
- Border Color: #333 (dark gray/black)
- Download Button: #4ade80 (green), hover: #22c55e
- Play Button: #4ade80 (green), hover: #22c55e
- Progress Fill: Gradient (#4ade80 to #22c55e)
- Control Buttons (prev/next): #fff (white), hover: #f0f0f0
- Text Color: #fff (white) with text-shadow: 1-2px 1-2px 0 #333
- Active Track: rgba(74, 222, 128, 0.3) with border #4ade80

