# Worker (Lab Machine) 資料庫部署腳本 (PowerShell)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Worker (Lab Machine) 資料庫部署腳本" -ForegroundColor Cyan  
Write-Host "只部署PostgreSQL資料庫服務" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

# 檢查Docker是否運行
try {
    docker info | Out-Null
    Write-Host "✅ Docker 運行正常" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker 未運行，請先啟動 Docker Desktop" -ForegroundColor Red
    exit 1
}

# 獲取本機IP地址
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1" -and $_.PrefixOrigin -eq "Dhcp"} | Select-Object -First 1).IPAddress
Write-Host "🌐 檢測到本機IP: $localIP" -ForegroundColor Cyan

# 檢查Docker Swarm狀態
$swarmStatus = docker info | Select-String "Swarm: active"
if (-not $swarmStatus) {
    Write-Host "🔄 初始化 Docker Swarm..." -ForegroundColor Yellow
    Write-Host "   使用IP地址: $localIP" -ForegroundColor Yellow
    docker swarm init --advertise-addr $localIP
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker Swarm 初始化成功" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker Swarm 初始化失敗" -ForegroundColor Red
        Write-Host "💡 嘗試使用127.0.0.1重新初始化..." -ForegroundColor Yellow
        docker swarm init --advertise-addr 127.0.0.1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Docker Swarm 初始化完全失敗" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "✅ Docker Swarm 已啟用" -ForegroundColor Green
}

# 建立PostgreSQL資料目錄
Write-Host "🔄 建立PostgreSQL資料目錄..." -ForegroundColor Yellow
if (-not (Test-Path "/var/lib/postgres-data")) {
    try {
        New-Item -ItemType Directory -Path "/var/lib/postgres-data" -Force | Out-Null
        Write-Host "✅ PostgreSQL資料目錄已建立: /var/lib/postgres-data" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  無法建立 /var/lib/postgres-data，使用本地目錄..." -ForegroundColor Yellow
        if (-not (Test-Path "postgres-data")) {
            New-Item -ItemType Directory -Path "postgres-data" -Force | Out-Null
        }
        Write-Host "✅ 使用本地資料目錄: ./postgres-data" -ForegroundColor Green
    }
} else {
    Write-Host "✅ PostgreSQL資料目錄已存在" -ForegroundColor Green
}

# 清理舊服務 (如果存在)
$existingStack = docker stack ls | Select-String "worker-db-stack"
if ($existingStack) {
    Write-Host "🔄 清理舊資料庫服務..." -ForegroundColor Yellow
    docker stack rm worker-db-stack
    Write-Host "⏳ 等待服務完全清理..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
}

# 部署PostgreSQL資料庫服務
Write-Host "🔄 部署 Worker 資料庫服務..." -ForegroundColor Yellow
docker stack deploy -c docker-compose-hw5.yml worker-db-stack

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 服務部署成功" -ForegroundColor Green
} else {
    Write-Host "❌ 服務部署失敗" -ForegroundColor Red
    exit 1
}

# 等待服務啟動
Write-Host "⏳ 等待服務啟動..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# 檢查服務狀態
Write-Host "🔍 檢查服務狀態..." -ForegroundColor Yellow
docker service ls

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✅ Worker 資料庫部署完成！" -ForegroundColor Green
Write-Host "🗄️  PostgreSQL 資料庫: localhost:5432" -ForegroundColor Cyan
Write-Host "📋 資料庫名稱: worker_names" -ForegroundColor Cyan
Write-Host "👤 用戶名稱: worker" -ForegroundColor Cyan
Write-Host "🔑 密碼: worker_password" -ForegroundColor Cyan
Write-Host "📂 資料儲存: /var/lib/postgres-data" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host "📊 服務狀態: docker service ls" -ForegroundColor Cyan
Write-Host "📝 資料庫日誌: docker service logs worker-db-stack_postgres-db" -ForegroundColor Cyan
Write-Host "🔧 連接測試: docker exec -it [container_id] psql -U worker -d worker_names" -ForegroundColor Cyan
Write-Host "🛑 停止服務: docker stack rm worker-db-stack" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "💡 提示: 此Worker只提供資料庫服務，Manager需要連接到此資料庫來提供Web和API服務" -ForegroundColor Yellow