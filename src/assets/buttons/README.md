# Button Assets Folder

Save your pixel art button PNG files in this folder structure:

## Folder Structure

```
buttons/
├── timer/          # Main timer control buttons
├── music/          # Music player buttons
├── settings/       # Settings panel buttons
└── other/          # Other buttons (music toggle, etc.)
```

## Naming Convention

Use this naming pattern: `{button-name}-{state}.png`

### Timer Buttons (`timer/`)
- `play-default.png` - Play button (idle state)
- `play-running.png` - Play button (active/running state)
- `play-hover.png` - Play button (hover state)
- `pause-default.png` - Pause button
- `pause-hover.png` - Pause button (hover)
- `reset-default.png` - Reset button
- `reset-hover.png` - Reset button (hover)
- `settings-default.png` - Settings button
- `settings-hover.png` - Settings button (hover)
- `close-default.png` - Close button (red)
- `close-hover.png` - Close button (hover)

### Music Player Buttons (`music/`)
- `prev-default.png` - Previous track button
- `prev-hover.png` - Previous track button (hover)
- `next-default.png` - Next track button
- `next-hover.png` - Next track button (hover)
- `play-music-default.png` - Play button (music player)
- `play-music-hover.png` - Play button (hover)
- `pause-music-default.png` - Pause button (music player)
- `pause-music-hover.png` - Pause button (hover)
- `download-default.png` - Download button (green)
- `download-hover.png` - Download button (hover)
- `download-disabled.png` - Download button (disabled)
- `remove-default.png` - Remove track button (20x20px)
- `remove-hover.png` - Remove track button (hover)

### Settings Buttons (`settings/`)
- `save-default.png` - Save button
- `save-hover.png` - Save button (hover)
- `close-settings-default.png` - Close button (settings panel)
- `close-settings-hover.png` - Close button (hover)

### Other Buttons (`other/`)
- `music-toggle-default.png` - Music toggle button (32x32px)
- `music-toggle-hover.png` - Music toggle button (hover)

## File Requirements

- **Format**: PNG with transparency
- **Size**: Exact pixel dimensions (see BUTTON_CHECKLIST.md)
- **Color Space**: RGB
- **Background**: Transparent (for icons/symbols)

## Button Sizes Reference

| Button Type | Width | Height |
|-------------|-------|--------|
| Timer controls | 40px | 40px |
| Music prev/next | 36px | 36px |
| Music play/pause | 44px | 44px |
| Download | 40px | 40px |
| Remove track | 20px | 20px |
| Settings save/close | flex | auto |
| Music toggle | 32px | 32px |

## States to Create

For each button, create these states:
1. **default** - Normal state
2. **hover** - Mouse over state
3. **active/pressed** - Clicked state (optional, can use CSS transform)
4. **disabled** - Disabled state (where applicable)

## Usage in Code

After creating the PNGs, they can be imported in components like:

```svelte
<script>
  import playDefault from '../assets/buttons/timer/play-default.png';
  import playHover from '../assets/buttons/timer/play-hover.png';
</script>

<button 
  style="background-image: url({playDefault});"
  on:mouseenter={() => setHover(true)}
  on:mouseleave={() => setHover(false)}
>
```

Or use CSS:

```css
.button {
  background-image: url('../assets/buttons/timer/play-default.png');
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
}
```

## Tips

- Keep file sizes small for fast loading
- Use 1x resolution (no @2x needed for this pixel art style)
- Maintain consistent art style across all buttons
- Test buttons at actual size before finalizing

