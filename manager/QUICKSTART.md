# Manager 端快速開始指南

這是 manager 端的快速部署指南，基於 manager-spec.md 規格實作。

## 快速部署

### 1. 前置作業
```powershell
# 確保 Docker Desktop 已安裝並啟動
# 初始化 Swarm (如果尚未初始化)
docker swarm init
```

### 2. 加入 Worker 節點
在 Lab Linux 機器執行:
```bash
# 使用 manager 節點提供的 join token
docker swarm join --token <your-worker-token> <manager-ip>:2377

# 建立資料庫資料目錄
sudo mkdir -p /var/lib/postgres-data
sudo chown 999:999 /var/lib/postgres-data
```

### 3. 設定節點標籤
```powershell
# 查看節點
docker node ls

# 標記 worker 節點 (替換 <node-id> 為實際 ID)
docker node update --label-add role=db <worker-node-id>
```

### 4. 一鍵部署
```powershell
# 在 manager 目錄執行
.\deploy.ps1
```

### 5. 驗證部署
- 網頁介面: http://localhost
- 健康檢查: http://localhost/healthz
- API 文件: http://localhost/api/docs

## 清理環境
```powershell
.\cleanup.ps1
```

## 驗收檢查清單

根據 manager-spec.md 的驗收條件:

- [ ] Web 可於 port 80 成功存取 ✓
- [ ] DB 僅在 worker 節點執行 ✓  
- [ ] API 可正常連線至 DB ✓
- [ ] DB 資料於重啟後仍存在 ✓
- [ ] `/healthz` 回傳 OK ✓

## 測試指令

```powershell
# 1. 檢查 manager + worker 節點
docker node ls

# 2. 驗證 DB 僅在 lab node 執行
docker service ps mcapp_db

# 3. 確認 Web 頁面與負載平衡
curl http://localhost/

# 4. 健康檢查 OK
curl http://localhost/healthz

# 5. 測試重啟資料持久性
docker service update --force mcapp_db
```

架構完成！🎉