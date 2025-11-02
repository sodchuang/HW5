# 🚀 Worker (Lab Machine) 資料庫 - 快速啟動

## 30秒快速部署 PostgreSQL 資料庫

### 步驟 1: 開啟PowerShell
在專案目錄中開啟PowerShell (以管理員身分執行)

### 步驟 2: 執行部署腳本
```powershell
.\deploy.ps1
```

### 步驟 3: 驗證資料庫運行
```powershell
# 檢查服務狀態
docker service ls

# 測試資料庫連接
docker exec -it $(docker ps -q -f "name=postgres-db") psql -U worker -d worker_names
```

---

## 🔌 Manager 連接資訊

Worker資料庫部署完成後，提供以下連接資訊給Manager：
- **主機**: Lab Machine IP 位址
- **埠口**: 5432
- **資料庫**: worker_names
- **用戶**: worker  
- **密碼**: worker_password

---

## ⚡ 常用命令

### 查看服務狀態
```powershell
docker service ls
```

### 查看日誌
```powershell
# 後端日誌
docker service logs worker-stack_worker-backend

# 前端日誌
docker service logs worker-stack_worker-frontend
```

### 停止服務
```powershell
docker stack rm worker-stack
```

### 清理系統
```powershell
docker system prune -f
```

---

## 📋 檢查清單

部署前請確認：
- [ ] Docker Desktop 已安裝並運行
- [ ] PowerShell 以管理員身分執行
- [ ] 埠口 8080 未被占用
- [ ] 至少 2GB 可用記憶體

---

## 🆘 如果出現問題

1. **重新啟動Docker Desktop**
2. **檢查埠口占用**: `netstat -an | findstr :8080`
3. **重新初始化Swarm**: `docker swarm leave --force; docker swarm init`
4. **查看詳細錯誤**: `docker service ps worker-stack_worker-backend --no-trunc`

---

**需要幫助？** 請查看 [DEPLOYMENT.md](DEPLOYMENT.md) 獲取詳細指導。