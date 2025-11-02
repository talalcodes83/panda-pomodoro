# Script to push code to GitHub
Write-Host ""
Write-Host "PANDA-POMODORO - PUSH TO GITHUB" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

# Check if already has remote
$hasRemote = git remote -v 2>&1 | Select-String "origin"
if ($hasRemote) {
    Write-Host ""
    Write-Host "GitHub remote already configured!" -ForegroundColor Green
    git remote -v
    Write-Host ""
    Write-Host "Push changes with: git push -u origin master" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Step 1: Staging all changes..." -ForegroundColor Yellow
git add .
Write-Host "Step 2: Committing changes..." -ForegroundColor Yellow
git commit -m "Initial commit: Panda-Pomodoro Timer v1.0.0" 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "Changes committed!" -ForegroundColor Green
} else {
    Write-Host "No changes to commit or commit failed." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 3: Create GitHub Repository" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "1. Go to: https://github.com/new" -ForegroundColor White
Write-Host "2. Repository name: panda-pomodoro (or any name you prefer)" -ForegroundColor White
Write-Host "3. Description: Panda-Pomodoro Timer - A cute pixel art pomodoro timer with music player" -ForegroundColor White
Write-Host "4. Make it Public or Private (your choice)" -ForegroundColor White
Write-Host "5. DO NOT initialize with README, .gitignore, or license" -ForegroundColor Yellow
Write-Host "6. Click Create repository" -ForegroundColor White

Write-Host ""
Write-Host "Step 4: After creating the repo, run:" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "git remote add origin https://github.com/YOUR_USERNAME/panda-pomodoro.git" -ForegroundColor Yellow
Write-Host "git branch -M main" -ForegroundColor Yellow
Write-Host "git push -u origin main" -ForegroundColor Yellow
Write-Host ""
Write-Host "(Replace YOUR_USERNAME with your actual GitHub username)" -ForegroundColor Gray
Write-Host ""
Write-Host "OR if you want to push to master branch:" -ForegroundColor Cyan
Write-Host "git remote add origin https://github.com/YOUR_USERNAME/panda-pomodoro.git" -ForegroundColor Yellow
Write-Host "git push -u origin master" -ForegroundColor Yellow
Write-Host ""


