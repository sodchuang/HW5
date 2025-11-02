# Manager 端專用 - Docker Swarm 部署指南

## 概述

這是 **Manager 端專用** 的部署，只包含 web 和 api 服務。資料庫服務由 Worker 端獨立部署。

## Manager 端架構

```
[Client/Browser]
       ↓ HTTP (port 80)
[Manager Node: 筆電]
  ├── web (Nginx) - port 80:80
  ├── api (FastAPI) - 名字管理 API
       ↓ Overlay Network (appnet)
       ↓ 連接到 Worker 端的 db 服務
```

## 服務配置

### Web 服務
- **映像檔**: `mcapp_web:latest`
- **端口**: `80:80`
- **約束**: `node.role == manager`

### API 服務  
- **映像檔**: `mcapp_api:latest`
- **約束**: `node.role == manager`
- **資料庫連接**: `postgresql://postgres:password@db:5432/mcapp`

## 快速部署

### 1. 執行部署腳本
```powershell
.\deploy.ps1
```

### 2. 部署步驟說明
1. 初始化 Swarm (如果未初始化)
2. 建立 web 和 api 映像檔
3. 建立共享 overlay 網路 `appnet`
4. 部署 manager-side stack
5. 顯示 worker join token

## 網路設計

- **網路名稱**: `appnet` (overlay)
- **External**: true (與 worker 端共享)
- **服務發現**: api 可透過 DNS 名稱 `db` 連接到 worker 端資料庫

## 驗證部署

```powershell
# 檢查服務
docker service ls

# 檢查健康狀態
curl http://localhost/healthz

# 檢查網路
docker network ls | findstr appnet
```

## 注意事項

⚠️ **重要**: 
- 此為 Manager 端專用配置
- 需要 Worker 端獨立部署 `db` 服務
- 兩端必須共享 `appnet` overlay 網路
- Manager 端負責對外提供 port 80 服務

## 清理環境

```powershell
.\cleanup.ps1
```