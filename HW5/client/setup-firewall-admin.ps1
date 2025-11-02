# =============================================================================
# PostgreSQL Firewall Configuration Script
# Run this as Administrator to allow Manager connections
# =============================================================================

# Check Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "Configuring Windows Firewall for PostgreSQL..." -ForegroundColor Green

try {
    # Remove existing PostgreSQL rules if any
    $existingRules = Get-NetFirewallRule -DisplayName "*PostgreSQL*" -ErrorAction SilentlyContinue
    if ($existingRules) {
        Write-Host "Removing existing PostgreSQL firewall rules..." -ForegroundColor Yellow
        $existingRules | Remove-NetFirewallRule
    }

    # Add inbound rule for PostgreSQL
    Write-Host "Adding inbound rule for PostgreSQL port 5432..." -ForegroundColor Cyan
    New-NetFirewallRule -DisplayName "PostgreSQL Database Inbound" -Direction Inbound -Protocol TCP -LocalPort 5432 -Action Allow -Profile Any

    # Add outbound rule for PostgreSQL  
    Write-Host "Adding outbound rule for PostgreSQL port 5432..." -ForegroundColor Cyan
    New-NetFirewallRule -DisplayName "PostgreSQL Database Outbound" -Direction Outbound -Protocol TCP -LocalPort 5432 -Action Allow -Profile Any

    # Add rule for remote connections
    Write-Host "Adding rule for remote PostgreSQL connections..." -ForegroundColor Cyan
    New-NetFirewallRule -DisplayName "PostgreSQL Remote Access" -Direction Inbound -Protocol TCP -RemotePort 5432 -Action Allow -Profile Any

    Write-Host "`n✅ Firewall configuration completed successfully!" -ForegroundColor Green
    Write-Host "PostgreSQL port 5432 is now open for connections" -ForegroundColor Green

} catch {
    Write-Host "❌ Error configuring firewall: $($_.Exception.Message)" -ForegroundColor Red
    pause
    exit 1
}

# Verify the rules were created
Write-Host "`nVerifying firewall rules..." -ForegroundColor Yellow
$postgresRules = Get-NetFirewallRule -DisplayName "*PostgreSQL*"
$postgresRules | Format-Table DisplayName, Direction, Action, Enabled -AutoSize

Write-Host "`nFirewall configuration is complete." -ForegroundColor Green
Write-Host "You can now connect from Manager machines using:" -ForegroundColor Cyan
Write-Host "  Host: 192.168.0.34" -ForegroundColor White
Write-Host "  Port: 5432" -ForegroundColor White
Write-Host "  Database: worker_names" -ForegroundColor White
Write-Host "  Username: worker" -ForegroundColor White
Write-Host "  Password: worker_password" -ForegroundColor White

pause