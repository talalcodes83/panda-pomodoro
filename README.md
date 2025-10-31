# 🍅 Cute Pomodoro Timer

A delightful pixel art style pomodoro timer built with **Tauri + Svelte + TypeScript**. Features cute animations, sound effects, and a built-in music player with YouTube download capability!

![Pomodoro Timer](https://img.shields.io/badge/version-1.0.0-blue) ![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

- **Cute Pixel Art Character** - An adorable animated character that responds to your study sessions
- **Always on Top** - Stays visible on your screen while you work (300x400px window)
- **Customizable Timers** - Set your own study time, break time, and total rounds
- **Sound Effects** - Gentle audio feedback for timer events
- **Music Player** - Play background music while studying
- **YouTube Download** - Download music from YouTube and save as local playlists
- **Progress Tracking** - Visual progress bar and round indicators
- **Smooth Animations** - Delightful character animations that react to timer states
- **Settings Panel** - Easy-to-use settings for personalization
- **Compact Design** - Small square window that doesn't take up much space

## 🛠️ Tech Stack

- **Tauri** - Lightweight desktop framework (Rust backend)
- **Svelte** - Modern, fast frontend framework
- **TypeScript** - Type-safe JavaScript
- **Vite** - Fast build tool

## 📋 Prerequisites

1. **Node.js** (v18 or higher) - [Download](https://nodejs.org/)
2. **Rust** - [Install Rust](https://www.rust-lang.org/tools/install)
3. **yt-dlp** (for YouTube downloads) - [Install yt-dlp](https://github.com/yt-dlp/yt-dlp#installation)

### Installing yt-dlp

- **Windows**: `winget install yt-dlp` or download from [GitHub releases](https://github.com/yt-dlp/yt-dlp/releases)
- **macOS**: `brew install yt-dlp`
- **Linux**: `sudo apt install yt-dlp` or `pip install yt-dlp`

## 🚀 Getting Started

### Installation

1. Clone the repository:
```bash
git clone https://github.com/talalcodes83/cute-pomodoro-timer.git
cd cute-pomodoro-timer
```

2. Install dependencies:
```bash
npm install
```

3. Run the app in development mode:
```bash
npm run tauri:dev
```

### Building for Distribution

Build the app for your platform:

```bash
# Development build
npm run tauri:dev

# Production build
npm run tauri:build
```

Built applications will be in `src-tauri/target/release/bundle/`.

## 🎨 Customization

### Adding Pixel Art

You can replace the CSS character with your own pixel art sprites. Edit `src/components/Character.svelte` to use image sprites or add animation frames.

### Custom Sound Effects

Add your sound files to a `sounds/` directory and update the sound loading logic in the timer store.

### Colors and Themes

Modify the gradient backgrounds in `src/components/PomodoroTimer.svelte`:
- `.study-mode` - Study session colors
- `.break-mode` - Break session colors
- `.complete-mode` - All rounds complete colors

## 📖 Usage

### Timer Controls

1. **Start Timer**: Click the play button (▶) to start your study session
2. **Pause**: Click the pause button (⏸) to pause the timer
3. **Reset**: Click the reset button (↻) to restart the current session
4. **Settings**: Click the settings button (⚙) to customize:
   - Study time (minutes)
   - Break time (minutes)
   - Total rounds
   - Sound effects on/off

### Music Player

1. **Toggle Player**: Click the music icon (🎵) to show/hide the music player
2. **Download Music**: Enter a YouTube URL and click "Download" to save music locally
3. **Play Music**: Use the player controls to play/pause, skip tracks, and adjust volume
4. **Manage Playlist**: Tracks are automatically saved to playlists in your app data directory

The timer will automatically switch between study and break sessions based on your settings.

## 📝 Default Settings

- Study Time: 25 minutes
- Break Time: 5 minutes
- Total Rounds: 4
- Sound Effects: Enabled

## 🗂️ Project Structure

```
├── src/                    # Frontend (Svelte + TypeScript)
│   ├── components/         # Svelte components
│   ├── stores/            # Svelte stores (state management)
│   └── main.ts           # Entry point
├── src-tauri/            # Backend (Rust)
│   ├── src/
│   │   ├── main.rs       # Tauri main file
│   │   └── commands.rs   # Tauri commands
│   └── Cargo.toml        # Rust dependencies
└── package.json          # Node dependencies
```

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## 📄 License

This project is licensed under the MIT License.

## 👤 Author

**talalcodes83**

## 🙏 Acknowledgments

- Inspired by the Pomodoro Technique by Francesco Cirillo
- Built with [Tauri](https://tauri.app/) - A framework for building tiny, fast binaries with great developer experience
- Built with [Svelte](https://svelte.dev/) - Cybernetically enhanced web apps

---

Made with ❤️ for productive and enjoyable study sessions!

