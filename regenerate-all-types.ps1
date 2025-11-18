# PowerShell script to regenerate all types (Prisma + Dart)
# Run with: .\regenerate-all-types.ps1

Write-Host "Regenerating all types for the project...`n" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"
$rootDir = $PSScriptRoot

# ========== Backend (Prisma) ==========
Write-Host "========================================" -ForegroundColor Blue
Write-Host "[1/2] Regenerating Backend (Prisma) types..." -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Blue

try {
    Set-Location "$rootDir\server"
    Write-Host "Running: npx prisma generate" -ForegroundColor Gray
    npx prisma generate
    Write-Host "`nSUCCESS: Prisma types regenerated successfully!" -ForegroundColor Green
} catch {
    Write-Host "`nERROR: Failed to regenerate Prisma types: $_" -ForegroundColor Red
    exit 1
}

# ========== Frontend (Flutter/Dart) ==========
Write-Host "`n========================================" -ForegroundColor Blue
Write-Host "[2/2] Regenerating Frontend (Dart) code..." -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Blue

try {
    Set-Location "$rootDir\flutter_app"
    Write-Host "Running: dart run build_runner build --delete-conflicting-outputs" -ForegroundColor Gray
    dart run build_runner build --delete-conflicting-outputs
    Write-Host "`nSUCCESS: Dart code regenerated successfully!" -ForegroundColor Green
} catch {
    Write-Host "`nERROR: Failed to regenerate Dart code: $_" -ForegroundColor Red
    exit 1
}

# ========== Success ==========
Set-Location $rootDir
Write-Host "`n========================================" -ForegroundColor Blue
Write-Host "All types regenerated successfully!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Blue

Write-Host "Next steps to apply changes:" -ForegroundColor Cyan
Write-Host "   1. Restart language servers:" -ForegroundColor White
Write-Host "      - TypeScript: Ctrl+Shift+P > 'TypeScript: Restart TS Server'" -ForegroundColor Gray
Write-Host "      - Dart: Ctrl+Shift+P > 'Dart: Restart Analysis Server'" -ForegroundColor Gray
Write-Host "   2. OR simply restart your IDE (recommended)" -ForegroundColor White
Write-Host "   3. Start your services:" -ForegroundColor White
Write-Host "      - Backend: cd server && npm run dev" -ForegroundColor Gray
Write-Host "      - Flutter: cd flutter_app && flutter run" -ForegroundColor Gray
Write-Host ""
