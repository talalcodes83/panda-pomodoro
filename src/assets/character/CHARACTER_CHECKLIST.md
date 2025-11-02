# Character Animation Checklist

Save your pixel art character animations in this folder!

## Animation Files Needed

### Study Mode
- [ ] `study-idle.png` - Character when study timer is idle/paused
- [ ] `study-running.png` - Character when study timer is running

### Break Mode  
- [ ] `break-idle.png` - Character when break timer is idle/paused
- [ ] `break-happy.png` - Character when break timer is running

## Character Size

**Recommended:**
- **120×120px** (current container size)
- Can be larger if needed - container will adjust

**Current Container:**
- Width: **120px**
- Height: **120px**
- Will display with pixel-perfect rendering (no smoothing)

## Animation States

### Study Mode
- **Idle** → Shows `study-idle.png`
- **Running** → Shows `study-running.png`

### Break Mode
- **Idle** → Shows `break-idle.png`
- **Running** → Shows `break-happy.png`

### Complete Mode
- Uses `study-idle.png` for now

## Integration

Once you save the files, I'll integrate them. The component will:
1. Check if animation files exist
2. If found → Use pixel art images
3. If not found → Falls back to CSS smiley face

## Tips

- Export from Aseprite at exact pixel size (120×120px)
- Use transparent background
- Keep animation style consistent between study and break
- PNG format with transparency

