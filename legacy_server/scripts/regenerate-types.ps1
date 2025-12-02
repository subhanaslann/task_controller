# PowerShell script to regenerate Prisma types
# Run with: .\scripts\regenerate-types.ps1

Write-Host "🔄 Regenerating Prisma Client types...`n" -ForegroundColor Cyan

try {
    # Change to server directory
    Set-Location $PSScriptRoot\..

    # Generate Prisma Client
    Write-Host "📦 Running prisma generate..." -ForegroundColor Yellow
    npx prisma generate

    Write-Host "`n✅ Prisma types regenerated successfully!" -ForegroundColor Green
    Write-Host "`n💡 To apply changes:" -ForegroundColor Cyan
    Write-Host "   1. Restart your TypeScript language server (VS Code: Ctrl+Shift+P > 'TypeScript: Restart TS Server')"
    Write-Host "   2. Or restart your IDE"
    Write-Host "   3. Then run: npm run dev"

} catch {
    Write-Host "`n❌ Error regenerating types: $_" -ForegroundColor Red
    exit 1
}
