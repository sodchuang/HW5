# Test external connection to Worker PostgreSQL

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "External Connection Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Get local IP addresses
$localIPs = @()
$networkAdapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"}
foreach($adapter in $networkAdapters) {
    if($adapter.IPAddress -match "^192\.168\.|^10\.|^172\.(1[6-9]|2[0-9]|3[01])\.")  {
        $localIPs += $adapter.IPAddress
    }
}

Write-Host "🔍 Local IP addresses found:" -ForegroundColor Yellow
$localIPs | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }

# Test each IP
foreach($ip in $localIPs) {
    Write-Host "`n🔌 Testing connection to $ip`:5432..." -ForegroundColor Yellow
    
    try {
        # Test with PowerShell TCP connection
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connect = $tcpClient.BeginConnect($ip, 5432, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(3000, $false)
        
        if($wait) {
            $tcpClient.EndConnect($connect)
            Write-Host "✅ TCP connection to $ip`:5432 successful" -ForegroundColor Green
            $tcpClient.Close()
            
            # Test PostgreSQL connection
            Write-Host "🔍 Testing PostgreSQL authentication..." -ForegroundColor Yellow
            $env:PGPASSWORD = "worker_password"
            
            $result = docker run --rm --network host postgres:15-alpine psql -h $ip -p 5432 -U worker -d worker_names -c "SELECT 'Connection successful' as status, COUNT(*) as record_count FROM names;" 2>&1
            
            if($LASTEXITCODE -eq 0) {
                Write-Host "✅ PostgreSQL connection successful!" -ForegroundColor Green
                Write-Host $result
            } else {
                Write-Host "❌ PostgreSQL authentication failed:" -ForegroundColor Red
                Write-Host $result
            }
        } else {
            Write-Host "❌ TCP connection to $ip`:5432 failed (timeout)" -ForegroundColor Red
            $tcpClient.Close()
        }
    } catch {
        Write-Host "❌ Connection error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "🔧 Manager Connection Instructions" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "Use one of these connection strings in your Manager application:" -ForegroundColor Yellow
foreach($ip in $localIPs) {
    Write-Host "postgresql://worker:worker_password@$ip`:5432/worker_names" -ForegroundColor Cyan
}

Write-Host "`n📋 Environment Variables for Manager:" -ForegroundColor Yellow
Write-Host "DB_HOST=" + $localIPs[0] -ForegroundColor Cyan
Write-Host "DB_PORT=5432" -ForegroundColor Cyan  
Write-Host "DB_NAME=worker_names" -ForegroundColor Cyan
Write-Host "DB_USER=worker" -ForegroundColor Cyan
Write-Host "DB_PASSWORD=worker_password" -ForegroundColor Cyan

Write-Host "`n🛠️  Docker Swarm Network Info:" -ForegroundColor Yellow
docker network inspect worker-db-stack_worker_net --format "{{.IPAM.Config}}"

Write-Host "`n📊 Service Status:" -ForegroundColor Yellow
docker service ps worker-db-stack_postgres-db --no-trunc