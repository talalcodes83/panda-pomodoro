# 🍎 Building for Mac

## Option 1: GitHub Actions (Recommended) ✅

The easiest way to build Mac apps from Windows is using GitHub Actions.

### Setup

1. The workflow file `.github/workflows/build.yml` is already created
2. Push your code to GitHub
3. Create a release tag:
   ```powershell
   git tag v1.0.0
   git push origin v1.0.0
   ```
4. GitHub Actions will automatically build for Windows, Mac, and Linux
5. Download the `.dmg` file from the GitHub Releases page

### Manual Trigger

You can also manually trigger the build:
1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **Build All Platforms** workflow
4. Click **Run workflow**

---

## Option 2: Build on a Mac

If you have access to a Mac:

```bash
# Install dependencies
npm install

# Build frontend
npm run build

# Build Tauri app (creates .dmg)
npm run tauri build
```

The Mac app will be in:
```
src-tauri/target/release/bundle/dmg/
```

---

## Option 3: Mac VM (Not Recommended)

You can use a macOS VM, but this:
- Violates Apple's EULA (macOS can only run on Apple hardware)
- Is slow and complicated
- Not recommended for production

---

## Current Status

✅ Windows build - Working
🍎 Mac build - Requires GitHub Actions or Mac
🐧 Linux build - Requires GitHub Actions or Linux

The GitHub Actions workflow will handle all three platforms automatically!

