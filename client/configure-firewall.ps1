# Windows Firewall Configuration for PostgreSQL Worker
# 需要以管理員身分執行此腳本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows 防火牆配置 - PostgreSQL Worker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 檢查是否以管理員身分執行
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ 此腳本需要管理員權限執行" -ForegroundColor Red
    Write-Host "請以管理員身分開啟PowerShell後重新執行" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ 管理員權限確認" -ForegroundColor Green

# 檢查現有防火牆規則
$existingRule = Get-NetFirewallRule -DisplayName "PostgreSQL Worker Database" -ErrorAction SilentlyContinue
if ($existingRule) {
    Write-Host "🔧 移除現有防火牆規則..." -ForegroundColor Yellow
    Remove-NetFirewallRule -DisplayName "PostgreSQL Worker Database"
}

# 建立新的防火牆規則
Write-Host "🔥 建立PostgreSQL防火牆規則..." -ForegroundColor Yellow
try {
    New-NetFirewallRule -DisplayName "PostgreSQL Worker Database" `
                        -Direction Inbound `
                        -Protocol TCP `
                        -LocalPort 5432 `
                        -Action Allow `
                        -Profile Any `
                        -Description "允許Manager連接到Worker PostgreSQL資料庫"
    
    Write-Host "✅ 防火牆規則建立成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 防火牆規則建立失敗: $($_.Exception.Message)" -ForegroundColor Red
}

# 檢查埠口狀態
Write-Host "`n📊 檢查埠口狀態..." -ForegroundColor Yellow
$portStatus = Test-NetConnection -ComputerName localhost -Port 5432 -InformationLevel Quiet
if ($portStatus) {
    Write-Host "✅ 埠口 5432 可正常存取" -ForegroundColor Green
} else {
    Write-Host "❌ 埠口 5432 無法存取" -ForegroundColor Red
}

# 顯示防火牆規則
Write-Host "`n🔧 PostgreSQL 防火牆規則:" -ForegroundColor Yellow
Get-NetFirewallRule -DisplayName "PostgreSQL Worker Database" | Select-Object DisplayName, Direction, Action, Enabled

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✅ 防火牆配置完成！" -ForegroundColor Green
Write-Host "🔌 Manager 現在可以連接到:" -ForegroundColor Cyan
Write-Host "   Host: $(hostname).local 或 $(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -match '^192\.168\.'} | Select-Object -First 1 -ExpandProperty IPAddress)" -ForegroundColor White
Write-Host "   Port: 5432" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan