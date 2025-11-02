# Names Manager - Docker Swarm 部署指南

## 概述

這是基於 HW4 延伸的 manager 端實作，專注於名字管理功能，使用 Docker Swarm 架構。

## 系統架構

```
[Client/Browser]
       ↓ HTTP (port 80)
[Manager Node: 筆電]
  ├── web (Nginx) - 提供靜態檔案和反向代理
  ├── api (FastAPI) - 名字管理 API
       ↓ Overlay Network (appnet)
[Worker Node: Lab Linux]
  └── db (PostgreSQL) - 資料庫服務
```

## 目錄結構

```
manager/
├── swarm/
│   └── stack.yaml          # Docker Swarm stack 配置
├── api/
│   ├── app.py             # FastAPI 應用程式
│   ├── requirements.txt   # Python 依賴
│   └── Dockerfile         # API 映像檔配置
├── web/
│   ├── static/
│   │   └── index.html     # 前端介面
│   ├── nginx.conf         # Nginx 配置
│   └── Dockerfile         # Web 映像檔配置
├── db/
│   └── init.sql           # 資料庫初始化腳本
├── deploy.ps1             # 部署腳本
├── cleanup.ps1            # 清理腳本
└── README.md              # 本文件
```

## 功能特色

- **簡化的名字管理**: 專注於 CRUD 操作
- **Docker Swarm 架構**: Manager/Worker 節點分離
- **跨節點通訊**: 使用 overlay 網路
- **健康檢查**: 內建服務健康監控
- **持久化資料**: PostgreSQL 資料持久化
- **負載平衡**: Nginx 反向代理

## 部署前準備

### Manager 端 (筆電)
1. 安裝 Docker Desktop
2. 啟用 Swarm 模式
3. 確保 PowerShell 執行政策允許腳本執行

### Worker 端 (Lab Linux)
1. 安裝 Docker Engine
2. 建立持久化資料目錄:
   ```bash
   sudo mkdir -p /var/lib/postgres-data
   sudo chown 999:999 /var/lib/postgres-data
   ```

## 部署步驟

### 1. 初始化 Swarm (Manager 端)
```powershell
docker swarm init
```

### 2. 加入 Worker 節點
在 worker 端執行 manager 端提供的 join 指令:
```bash
docker swarm join --token <token> <manager-ip>:2377
```

### 3. 標記 Worker 節點
```powershell
# 查看節點
docker node ls

# 標記 worker 節點用於資料庫
docker node update --label-add role=db <worker-node-id>
```

### 4. 建立映像檔並部署
```powershell
# 執行部署腳本
.\deploy.ps1
```

或手動執行:
```powershell
# 建立映像檔
docker build -t mcapp_api:latest ./api/
docker build -t mcapp_web:latest ./web/

# 部署 stack
docker stack deploy -c ./swarm/stack.yaml mcapp
```

## 驗證部署

### 檢查服務狀態
```powershell
docker service ls
docker stack ps mcapp
docker node ls
```

### 測試功能
- Web 介面: http://localhost
- API 文件: http://localhost/api/docs
- 健康檢查: http://localhost/healthz
- API 健康檢查: http://localhost/api/health

### 驗證資料庫位置
```powershell
# 確認 DB 僅在 worker 節點執行
docker service ps mcapp_db
```

## API 端點

| 方法 | 路徑 | 說明 |
|------|------|------|
| GET | `/api/names` | 取得所有名字 |
| POST | `/api/names` | 新增名字 |
| GET | `/api/names/{id}` | 取得特定名字 |
| PUT | `/api/names/{id}` | 更新名字 |
| DELETE | `/api/names/{id}` | 刪除名字 |
| GET | `/api/health` | API 健康檢查 |
| GET | `/healthz` | 簡單健康檢查 |

## 資料持久化

- 資料庫資料儲存在 worker 節點的 `/var/lib/postgres-data`
- 使用 bind mount 確保資料持久化
- 重啟服務不會遺失資料

## 網路配置

- **網路名稱**: `appnet` (overlay)
- **服務發現**: 
  - web → api (使用 DNS 名稱 `api`)
  - api → db (使用 DNS 名稱 `db`)
- **對外端口**: 80 (HTTP)

## 清理環境

```powershell
# 執行清理腳本
.\cleanup.ps1
```

或手動清理:
```powershell
docker stack rm mcapp
docker image prune -f
docker network prune -f
docker volume prune -f
```

## 故障排除

### 常見問題

1. **服務無法啟動**
   ```powershell
   docker service logs mcapp_api
   docker service logs mcapp_web
   docker service logs mcapp_db
   ```

2. **資料庫連線失敗**
   - 檢查 worker 節點是否正常運行
   - 確認資料庫初始化是否完成
   - 檢查網路連線

3. **網頁無法存取**
   - 確認 port 80 沒有被占用
   - 檢查 nginx 配置是否正確
   - 驗證服務間通訊

### 偵錯指令

```powershell
# 檢查服務狀態
docker service ps mcapp_api --no-trunc
docker service ps mcapp_web --no-trunc
docker service ps mcapp_db --no-trunc

# 檢查日誌
docker service logs -f mcapp_api
docker service logs -f mcapp_web
docker service logs -f mcapp_db

# 進入容器偵錯
docker exec -it $(docker ps -q -f name=mcapp_api) /bin/bash
```

## 安全考量

- 生產環境請更改預設密碼
- 考慮使用 Docker secrets 管理敏感資料
- 設定適當的防火牆規則
- 定期更新映像檔和相依套件

## 效能調整

- 根據負載調整 replicas 數量
- 設定適當的資源限制
- 調整 nginx 和資料庫參數
- 監控系統資源使用情況