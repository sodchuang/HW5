# Windows 防火牆配置腳本 - 開放PostgreSQL 5432埠

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows 防火牆配置 - PostgreSQL埠口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 檢查是否以管理員身分執行
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "❌ 請以管理員身分執行此腳本" -ForegroundColor Red
    Write-Host "右鍵點擊 PowerShell 選擇 '以管理員身分執行'" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ 管理員權限確認" -ForegroundColor Green

# 開放PostgreSQL 5432埠 - 輸入規則
Write-Host "🔧 設定防火牆規則 - PostgreSQL 5432埠 (輸入)..." -ForegroundColor Yellow
try {
    New-NetFirewallRule -DisplayName "PostgreSQL Worker Database - Inbound" `
                        -Direction Inbound `
                        -Protocol TCP `
                        -LocalPort 5432 `
                        -Action Allow `
                        -Profile Domain,Private,Public `
                        -Description "Allow Manager connections to Worker PostgreSQL database"
    Write-Host "✅ 輸入規則已建立" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -match "already exists") {
        Write-Host "ℹ️  輸入規則已存在，正在更新..." -ForegroundColor Yellow
        Remove-NetFirewallRule -DisplayName "PostgreSQL Worker Database - Inbound" -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName "PostgreSQL Worker Database - Inbound" `
                            -Direction Inbound `
                            -Protocol TCP `
                            -LocalPort 5432 `
                            -Action Allow `
                            -Profile Domain,Private,Public `
                            -Description "Allow Manager connections to Worker PostgreSQL database"
        Write-Host "✅ 輸入規則已更新" -ForegroundColor Green
    } else {
        Write-Host "❌ 建立輸入規則失敗: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 開放PostgreSQL 5432埠 - 輸出規則
Write-Host "🔧 設定防火牆規則 - PostgreSQL 5432埠 (輸出)..." -ForegroundColor Yellow
try {
    New-NetFirewallRule -DisplayName "PostgreSQL Worker Database - Outbound" `
                        -Direction Outbound `
                        -Protocol TCP `
                        -LocalPort 5432 `
                        -Action Allow `
                        -Profile Domain,Private,Public `
                        -Description "Allow outbound connections from Worker PostgreSQL database"
    Write-Host "✅ 輸出規則已建立" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -match "already exists") {
        Write-Host "ℹ️  輸出規則已存在，正在更新..." -ForegroundColor Yellow
        Remove-NetFirewallRule -DisplayName "PostgreSQL Worker Database - Outbound" -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName "PostgreSQL Worker Database - Outbound" `
                            -Direction Outbound `
                            -Protocol TCP `
                            -LocalPort 5432 `
                            -Action Allow `
                            -Profile Domain,Private,Public `
                            -Description "Allow outbound connections from Worker PostgreSQL database"
        Write-Host "✅ 輸出規則已更新" -ForegroundColor Green
    } else {
        Write-Host "❌ 建立輸出規則失敗: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 檢查防火牆狀態
Write-Host "`n📊 檢查防火牆狀態..." -ForegroundColor Yellow
$firewallProfiles = Get-NetFirewallProfile
foreach ($profile in $firewallProfiles) {
    $status = if ($profile.Enabled) { "啟用" } else { "停用" }
    Write-Host "$($profile.Name) Profile: $status" -ForegroundColor White
}

# 顯示相關規則
Write-Host "`n📋 PostgreSQL 防火牆規則:" -ForegroundColor Yellow
Get-NetFirewallRule -DisplayName "*PostgreSQL*" | Format-Table DisplayName, Direction, Action, Enabled -AutoSize

# 測試埠口
Write-Host "`n🔍 測試 5432 埠口監聽狀態..." -ForegroundColor Yellow
$listening = Get-NetTCPConnection -LocalPort 5432 -State Listen -ErrorAction SilentlyContinue
if ($listening) {
    Write-Host "✅ PostgreSQL 正在監聽 5432 埠口" -ForegroundColor Green
    $listening | Format-Table LocalAddress, LocalPort, State -AutoSize
} else {
    Write-Host "❌ PostgreSQL 未監聽 5432 埠口" -ForegroundColor Red
    Write-Host "請確保 Worker 資料庫服務正在運行" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✅ 防火牆配置完成！" -ForegroundColor Green
Write-Host "Manager 現在應該可以連接到 Worker 資料庫" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan