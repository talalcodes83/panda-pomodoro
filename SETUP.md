# Setup Instructions

## Prerequisites

Before running the app, you need to install:

### 1. Node.js
- Download from https://nodejs.org/ (v18 or higher)
- Verify installation: `node --version`

### 2. Rust
- Install from https://www.rust-lang.org/tools/install
- Verify installation: `rustc --version`
- This may take a while to install

### 3. yt-dlp (for YouTube downloads)
- **Windows**: 
  - `winget install yt-dlp` 
  - Or download from https://github.com/yt-dlp/yt-dlp/releases
- **macOS**: `brew install yt-dlp`
- **Linux**: 
  - `sudo apt install yt-dlp` 
  - Or `pip install yt-dlp`

### 4. Install Dependencies

```bash
npm install
```

This will install all Node.js dependencies including Tauri CLI.

## Running the App

### Development Mode

```bash
npm run tauri:dev
```

This will:
1. Start the Vite dev server (frontend)
2. Compile Rust backend
3. Launch the app

**Note:** First run will take longer as Rust needs to compile.

### Building for Distribution

```bash
npm run tauri:build
```

Built applications will be in:
- Windows: `src-tauri/target/release/bundle/msi/`
- macOS: `src-tauri/target/release/bundle/dmg/`
- Linux: `src-tauri/target/release/bundle/appimage/`

## Troubleshooting

### Rust Installation Issues
- Make sure Rust is properly installed: `rustc --version`
- If on Windows, you may need Visual Studio Build Tools

### yt-dlp Not Found
- Make sure yt-dlp is in your PATH
- Test with: `yt-dlp --version`
- On Windows, you might need to restart terminal after installation

### Build Errors
- Clear cache: `rm -rf node_modules src-tauri/target`
- Reinstall: `npm install`
- Make sure all prerequisites are installed

## Development Tips

- The frontend runs on `http://localhost:1420` during development
- Hot reload is enabled for Svelte components
- Rust backend changes require app restart









