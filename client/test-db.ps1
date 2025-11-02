# Worker PostgreSQL 資料庫測試腳本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Worker PostgreSQL 資料庫測試" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 檢查服務是否運行
Write-Host "🔍 檢查PostgreSQL服務狀態..." -ForegroundColor Yellow

try {
    $services = docker service ls --filter "name=worker-db-stack_postgres-db" --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}"
    
    if ($services -match "worker-db-stack_postgres-db") {
        Write-Host "✅ PostgreSQL服務正在運行" -ForegroundColor Green
        Write-Host $services
    } else {
        Write-Host "❌ PostgreSQL服務未找到" -ForegroundColor Red
        Write-Host "請先執行 .\deploy.ps1 部署資料庫" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ 無法檢查服務狀態: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 獲取容器ID
Write-Host "🔍 獲取PostgreSQL容器..." -ForegroundColor Yellow
try {
    $containerId = docker ps -q -f "name=postgres-db"
    if (-not $containerId) {
        Write-Host "❌ 找不到PostgreSQL容器" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ 找到PostgreSQL容器: $containerId" -ForegroundColor Green
} catch {
    Write-Host "❌ 獲取容器ID失敗: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 測試資料庫連接
Write-Host "🔌 測試資料庫連接..." -ForegroundColor Yellow
try {
    $result = docker exec $containerId psql -U worker -d worker_names -c "\l" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 資料庫連接成功" -ForegroundColor Green
    } else {
        Write-Host "❌ 資料庫連接失敗" -ForegroundColor Red
        Write-Host $result
        exit 1
    }
} catch {
    Write-Host "❌ 連接測試失敗: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 檢查資料表
Write-Host "📋 檢查資料表結構..." -ForegroundColor Yellow
try {
    Write-Host "資料表清單:" -ForegroundColor Cyan
    docker exec $containerId psql -U worker -d worker_names -c "\dt"
    
    Write-Host "`nnames 表結構:" -ForegroundColor Cyan  
    docker exec $containerId psql -U worker -d worker_names -c "\d names"
    
    Write-Host "`n資料表記錄數:" -ForegroundColor Cyan
    docker exec $containerId psql -U worker -d worker_names -c "SELECT COUNT(*) as total_records FROM names;"
    
} catch {
    Write-Host "❌ 檢查資料表失敗: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 檢查資料範例
Write-Host "📊 顯示範例資料..." -ForegroundColor Yellow
try {
    Write-Host "names 表前5筆資料:" -ForegroundColor Cyan
    docker exec $containerId psql -U worker -d worker_names -c "SELECT * FROM names ORDER BY created_at DESC LIMIT 5;"
} catch {
    Write-Host "❌ 查詢資料失敗: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 顯示連接資訊
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔌 PostgreSQL 連接資訊" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "主機: localhost (或Lab Machine IP)" -ForegroundColor White
Write-Host "埠口: 5432" -ForegroundColor White  
Write-Host "資料庫: worker_names" -ForegroundColor White
Write-Host "用戶: worker" -ForegroundColor White
Write-Host "密碼: worker_password" -ForegroundColor White
Write-Host "資料路徑: ./postgres-data" -ForegroundColor White
Write-Host ""
Write-Host "連接字串範例:" -ForegroundColor Yellow
Write-Host "postgresql://worker:worker_password@localhost:5432/worker_names" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Manager可以使用此連接資訊來連接資料庫" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan