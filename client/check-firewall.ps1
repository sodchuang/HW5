# Simple Firewall Check and PostgreSQL Port Configuration

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PostgreSQL Port 5432 Configuration Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

Write-Host "Administrator Check: " -NoNewline
if ($isAdmin) {
    Write-Host "✅ Running as Administrator" -ForegroundColor Green
} else {
    Write-Host "❌ Not running as Administrator" -ForegroundColor Red
    Write-Host "For firewall configuration, please run PowerShell as Administrator" -ForegroundColor Yellow
}

# Check PostgreSQL port listening status
Write-Host "`nPostgreSQL Port Status:" -ForegroundColor Yellow
$listening = Get-NetTCPConnection -LocalPort 5432 -State Listen -ErrorAction SilentlyContinue
if ($listening) {
    Write-Host "✅ PostgreSQL is listening on port 5432" -ForegroundColor Green
    $listening | Format-Table LocalAddress, LocalPort, State, OwningProcess -AutoSize
} else {
    Write-Host "❌ PostgreSQL is not listening on port 5432" -ForegroundColor Red
}

# Check firewall rules
Write-Host "Firewall Rules for PostgreSQL:" -ForegroundColor Yellow
$postgresRules = Get-NetFirewallRule -DisplayName "*PostgreSQL*" -ErrorAction SilentlyContinue
if ($postgresRules) {
    $postgresRules | Format-Table DisplayName, Direction, Action, Enabled -AutoSize
} else {
    Write-Host "No existing PostgreSQL firewall rules found" -ForegroundColor Yellow
}

# Manual firewall configuration instructions
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Manual Firewall Configuration" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "If Manager cannot connect, run these commands as Administrator:" -ForegroundColor Yellow
Write-Host ""
Write-Host "# Allow inbound connections on port 5432" -ForegroundColor Cyan
Write-Host 'New-NetFirewallRule -DisplayName "PostgreSQL-In" -Direction Inbound -Protocol TCP -LocalPort 5432 -Action Allow' -ForegroundColor White
Write-Host ""
Write-Host "# Allow outbound connections on port 5432" -ForegroundColor Cyan  
Write-Host 'New-NetFirewallRule -DisplayName "PostgreSQL-Out" -Direction Outbound -Protocol TCP -LocalPort 5432 -Action Allow' -ForegroundColor White

# Check Docker network
Write-Host "`nDocker Network Information:" -ForegroundColor Yellow
docker network ls | Select-String "worker"

# Test connection
Write-Host "`nTesting local connection:" -ForegroundColor Yellow
Test-NetConnection -ComputerName localhost -Port 5432 -WarningAction SilentlyContinue

# Get IP addresses
Write-Host "`nLocal IP Addresses:" -ForegroundColor Yellow
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"} | Select-Object IPAddress, InterfaceAlias

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Connection Information for Manager:" -ForegroundColor Green
Write-Host "Host: 192.168.0.34" -ForegroundColor Cyan
Write-Host "Port: 5432" -ForegroundColor Cyan
Write-Host "Database: worker_names" -ForegroundColor Cyan
Write-Host "User: worker" -ForegroundColor Cyan
Write-Host "Password: worker_password" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan