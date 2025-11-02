# Manager 端清理指令 (Windows PowerShell)

Write-Host "停止並移除 mcapp stack..." -ForegroundColor Yellow
docker stack rm mcapp-manager

Write-Host "等待服務完全停止..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "清理未使用的映像檔..." -ForegroundColor Yellow
docker image prune -f

Write-Host "清理未使用的網路..." -ForegroundColor Yellow
docker network prune -f

Write-Host "清理未使用的 volume..." -ForegroundColor Yellow
docker volume prune -f

Write-Host "顯示目前狀態..." -ForegroundColor Green
docker service ls
docker stack ls

Write-Host ""
Write-Host "清理完成！" -ForegroundColor Green