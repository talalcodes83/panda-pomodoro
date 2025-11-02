# Character Animations Folder

Save your pixel art character animations here.

## Animation Files Needed

### Study Mode Animation
- `study-idle.png` - Idle state during study
- `study-running.png` - Active/focused state during study
- OR use a sprite sheet: `study-spritesheet.png` (multiple frames in one image)

### Break Mode Animation
- `break-idle.png` - Idle state during break
- `break-happy.png` - Happy/active state during break
- OR use a sprite sheet: `break-spritesheet.png` (multiple frames in one image)

## Animation Approach Options

### Option 1: Sprite Sheets (Recommended)
Create sprite sheets with multiple frames:
- Horizontal or vertical strip of frames
- Example: 4 frames of animation in a single PNG
- We can use CSS animation to cycle through frames

### Option 2: Individual Frames
Save each frame as separate PNGs:
- `study-frame1.png`, `study-frame2.png`, etc.
- Code will cycle through them

### Option 3: Single Image per State
Simple approach:
- `study.png` - for study mode
- `break.png` - for break mode
- No animation, just static images that change based on mode

## Current Character Size
- Container: 80px × 80px
- Character: 60px × 60px

You can create larger sprites if you want - we'll adjust the container size to fit them!

## Naming Convention
Use descriptive names:
- `study-[state].png` or `study-[frame].png`
- `break-[state].png` or `break-[frame].png`

Or sprite sheets:
- `study-spritesheet.png`
- `break-spritesheet.png`

