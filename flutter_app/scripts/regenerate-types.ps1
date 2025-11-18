# PowerShell script to regenerate Dart code (JSON serialization, Riverpod, etc.)
# Run with: .\scripts\regenerate-types.ps1

Write-Host "🔄 Regenerating Dart code (JSON serialization, Riverpod)...`n" -ForegroundColor Cyan

try {
    # Change to flutter_app directory
    Set-Location $PSScriptRoot\..

    # Run build_runner
    Write-Host "📦 Running build_runner..." -ForegroundColor Yellow
    dart run build_runner build --delete-conflicting-outputs

    Write-Host "`n✅ Dart code regenerated successfully!" -ForegroundColor Green
    Write-Host "`n💡 To apply changes:" -ForegroundColor Cyan
    Write-Host "   1. Restart your Dart Analysis Server (VS Code: Ctrl+Shift+P > 'Dart: Restart Analysis Server')"
    Write-Host "   2. Or restart your IDE"
    Write-Host "   3. Then run your Flutter app"

} catch {
    Write-Host "`n❌ Error regenerating code: $_" -ForegroundColor Red
    exit 1
}
