# Manager 端部署指令 (Windows PowerShell)
# 執行前請確保已安裝 Docker Desktop 並啟用 Swarm 模式

# 1. 初始化 Docker Swarm (如果尚未初始化)
Write-Host "初始化 Docker Swarm..." -ForegroundColor Green
docker swarm init

# 2. 建立應用程式映像檔
Write-Host "建立 API 映像檔..." -ForegroundColor Green
docker build -t mcapp_api:latest ./api/

Write-Host "建立 Web 映像檔..." -ForegroundColor Green  
docker build -t mcapp_web:latest ./web/

# 3. 在 worker 節點上建立持久化資料目錄
Write-Host "請在 worker 節點執行以下指令:" -ForegroundColor Yellow
Write-Host "sudo mkdir -p /var/lib/postgres-data" -ForegroundColor Cyan
Write-Host "sudo chown 999:999 /var/lib/postgres-data" -ForegroundColor Cyan
Write-Host ""

# 4. 顯示 join token 給 worker 節點
Write-Host "Worker 節點加入指令:" -ForegroundColor Yellow
docker swarm join-token worker
Write-Host ""
Write-Host "注意: Worker 節點需要部署自己的 db 服務並加入相同的 appnet 網路" -ForegroundColor Yellow
Write-Host ""

# 5. 建立共享網路 (如果不存在)
Write-Host "建立共享 overlay 網路..." -ForegroundColor Green
docker network create --driver overlay --attachable appnet 2>$null

# 6. 部署 manager-side stack (僅 web 和 api)
Write-Host "部署 manager 端服務..." -ForegroundColor Green
docker stack deploy -c ./swarm/manager-stack.yaml mcapp-manager

# 7. 驗證部署
Write-Host "等待服務啟動..." -ForegroundColor Green
Start-Sleep -Seconds 10

Write-Host "檢查 manager 端服務狀態..." -ForegroundColor Green
docker service ls

Write-Host "檢查節點狀態..." -ForegroundColor Green
docker node ls

Write-Host "檢查 manager stack 狀態..." -ForegroundColor Green
docker stack ps mcapp-manager

Write-Host "檢查共享網路..." -ForegroundColor Green
docker network ls | findstr appnet

Write-Host ""
Write-Host "Manager 端部署完成！" -ForegroundColor Green
Write-Host "Web 介面: http://localhost" -ForegroundColor Cyan
Write-Host "API 文件: http://localhost/api/docs" -ForegroundColor Cyan
Write-Host "健康檢查: http://localhost/healthz" -ForegroundColor Cyan
Write-Host ""
Write-Host "注意: 需要 worker 節點部署 db 服務才能完整運作" -ForegroundColor Yellow