# Worker 名字管理系統部署指南

## 系統需求
- Windows 10/11 或 Windows Server 2019+
- Docker Desktop for Windows 或 Docker Engine
- Docker Swarm 模式已啟用
- 至少 2GB 可用記憶體
- 至少 1GB 可用磁碟空間

## 快速部署

### 1. 初始化 Docker Swarm (如果尚未初始化)
```powershell
docker swarm init
```

### 2. 建立資料目錄
```powershell
mkdir data
```

### 3. 部署服務堆疊
```powershell
docker stack deploy -c docker-compose-hw5.yml worker-stack
```

### 4. 檢查服務狀態
```powershell
docker service ls
docker service ps worker-stack_worker-backend
docker service ps worker-stack_worker-frontend
```

### 5. 訪問應用程式
開啟瀏覽器並訪問: http://localhost:8080

## 管理命令

### 查看服務日誌
```powershell
# 查看後端日誌
docker service logs worker-stack_worker-backend

# 查看前端日誌  
docker service logs worker-stack_worker-frontend
```

### 擴展服務
```powershell
# 擴展後端服務到3個實例
docker service scale worker-stack_worker-backend=3

# 擴展前端服務到3個實例
docker service scale worker-stack_worker-frontend=3
```

### 更新服務
```powershell
# 重新部署 (滾動更新)
docker stack deploy -c docker-compose-hw5.yml worker-stack
```

### 停止服務
```powershell
# 停止整個堆疊
docker stack rm worker-stack
```

### 清理系統
```powershell
# 清理未使用的映像
docker system prune -f

# 清理未使用的卷
docker volume prune -f
```

## 監控和故障排除

### 健康檢查
- 前端健康檢查: http://localhost:8080/health
- 後端健康檢查: http://localhost:8080/api/health

### 查看容器狀態
```powershell
# 查看所有運行中的容器
docker ps

# 查看特定服務的容器
docker ps --filter label=com.docker.swarm.service.name=worker-stack_worker-backend
```

### 進入容器除錯
```powershell
# 進入後端容器
docker exec -it <container_id> /bin/bash

# 進入前端容器  
docker exec -it <container_id> /bin/sh
```

### 常見問題

#### 1. 服務無法啟動
- 檢查 Docker Swarm 是否已初始化
- 確認埠口 8080 沒有被占用
- 檢查資料目錄權限

#### 2. 無法連接後端API
- 檢查網路連通性: `docker network ls`
- 查看後端服務日誌
- 確認健康檢查是否通過

#### 3. 資料持久化問題
- 確認資料目錄存在且可寫入
- 檢查卷掛載配置

## 性能調優

### 資源限制調整
修改 `docker-compose-hw5.yml` 中的資源配置:

```yaml
deploy:
  resources:
    limits:
      memory: 1G      # 增加記憶體限制
      cpus: '1.0'     # 增加CPU限制
    reservations:
      memory: 512M    # 增加記憶體預留
      cpus: '0.5'     # 增加CPU預留
```

### 副本數調整
根據負載需求調整服務副本數:

```yaml
deploy:
  replicas: 3  # 增加到3個副本
```

## 安全建議

1. **網路安全**: 在生產環境中使用防火牆限制對外暴露的埠口
2. **資料備份**: 定期備份 `./data` 目錄
3. **監控**: 設置適當的監控和告警機制
4. **更新**: 定期更新 Docker 映像和基礎系統

## 備份與恢復

### 備份資料
```powershell
# 建立資料備份
xcopy data backup-$(Get-Date -Format "yyyyMMdd") /E /I
```

### 恢復資料
```powershell
# 停止服務
docker stack rm worker-stack

# 恢復資料
xcopy backup-20241102 data /E /Y

# 重新啟動服務
docker stack deploy -c docker-compose-hw5.yml worker-stack
```