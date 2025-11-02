# 🚀 How to Push to GitHub

Your code is **committed and ready**! Now follow these steps:

## Step 1: Create GitHub Repository

1. **Go to GitHub**: https://github.com/new
2. **Repository name**: `panda-pomodoro` (or any name you prefer)
3. **Description**: "Panda-Pomodoro Timer - A cute pixel art pomodoro timer with music player"
4. **Make it Public or Private** (your choice)
5. **⚠️ IMPORTANT**: Do NOT check:
   - ❌ "Add a README file"
   - ❌ "Add .gitignore"  
   - ❌ "Choose a license"
   
   (We already have these files!)

6. Click **"Create repository"**

## Step 2: Connect and Push

After creating the repository, **copy the repository URL** that GitHub shows you.

Then run these commands in PowerShell:

```powershell
cd D:\pomodoroapp

# Replace YOUR_USERNAME with your GitHub username
git remote add origin https://github.com/YOUR_USERNAME/panda-pomodoro.git

# Push to master branch (your current branch)
git push -u origin master
```

**OR** if you want to use the `main` branch instead:

```powershell
cd D:\pomodoroapp
git remote add origin https://github.com/YOUR_USERNAME/panda-pomodoro.git
git branch -M main
git push -u origin main
```

## Step 3: Verify

After pushing, visit your repository on GitHub:
```
https://github.com/YOUR_USERNAME/panda-pomodoro
```

You should see all your code! 🎉

---

## Quick One-Liner

If you already know your GitHub username and repo name:

```powershell
cd D:\pomodoroapp; git remote add origin https://github.com/YOUR_USERNAME/panda-pomodoro.git; git push -u origin master
```

(Replace `YOUR_USERNAME` with your actual GitHub username)

---

## Troubleshooting

### "remote origin already exists"
Run this first:
```powershell
git remote remove origin
```
Then add it again.

### "Authentication failed"
You'll need to authenticate with GitHub:
- Use a Personal Access Token (PAT) instead of password
- Or set up SSH keys
- Or use GitHub CLI: `gh auth login`

---

**Ready to share your code with the world!** 🌟


