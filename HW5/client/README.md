# Worker (Lab Machine) 資料庫系統

專為Lab Machine設計的Worker端資料庫服務，提供PostgreSQL資料庫供Manager (Student Laptop) 連接使用。

## 🏗️ 分散式系統架構

```
┌─────────────────────────────────────────────────────┐
│             Manager (Student Laptop)                │
│  ┌─────────────┐    ┌─────────────┐                │
│  │  Frontend   │    │   Backend   │                │
│  │  (Nginx)    │◄──►│  (FastAPI)  │                │
│  │    :80      │    │    :8000    │                │
│  └─────────────┘    └──────┬──────┘                │
└─────────────────────────────┼─────────────────────────┘
                              │ Database Connection
                              │ (Port 5432)
┌─────────────────────────────▼─────────────────────────┐
│              Worker (Lab Machine)                     │
│                                                       │
│  ┌─────────────────────────────────────────────────┐  │
│  │            PostgreSQL Database                  │  │
│  │              Port: 5432                         │  │
│  │         Data: /var/lib/postgres-data            │  │
│  └─────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┘
```

## 📁 專案結構

```
client/
├── db/                      # 資料庫相關
│   └── init.sql            # PostgreSQL 初始化腳本
├── docker-compose-hw5.yml  # Docker Swarm 部署配置 (只有資料庫)
├── deploy.ps1              # Windows PowerShell 部署腳本
├── deploy.sh               # Bash 部署腳本  
├── DEPLOYMENT.md           # 詳細部署指南
├── HW5-Worker-Spec.md      # Worker 系統規格說明
├── QUICKSTART.md           # 快速啟動指南
└── README.md               # 專案說明文件
```

## 🚀 快速開始 (Worker部署)

### 前置需求
- Windows 10/11 或 Windows Server 2019+
- Docker Desktop for Windows  
- 2GB+ 可用記憶體
- Lab Machine 網路存取權限

### 1. 自動部署 (推薦)
```powershell
# 使用 PowerShell 部署資料庫
.\deploy.ps1
```

### 2. 手動部署
```powershell
# 初始化 Docker Swarm
docker swarm init

# 建立PostgreSQL資料目錄
mkdir postgres-data

# 部署資料庫服務
docker stack deploy -c docker-compose-hw5.yml worker-db-stack
```

### 3. 驗證資料庫運行
```powershell
# 檢查服務狀態
docker service ls

# 測試資料庫連接
docker exec -it $(docker ps -q -f "name=worker-db-stack_postgres-db") psql -U worker -d worker_names -c "\dt"
```

## 🎯 功能特色

### ✅ 已實現功能
- **名字管理**: 新增、查看、刪除名字
- **即時統計**: 顯示總名字數量和系統狀態
- **響應式設計**: 支援桌面和行動裝置
- **健康檢查**: 自動監控服務健康狀態
- **負載均衡**: Docker Swarm 自動負載分散
- **資料持久化**: SQLite 資料庫持久儲存
- **滾動更新**: 零停機時間更新部署

### 🔄 與 HW4 的差異
- ❌ 移除用戶認證系統 (無需登入/註冊)
- ❌ 移除任務管理功能
- ❌ 移除 JWT Token 認證
- ❌ 移除複雜的權限管理
- ✅ 簡化為純名字管理功能
- ✅ 優化 Docker Swarm 部署
- ✅ 改善 Windows 平台相容性

## 🛠️ API 端點

| 方法 | 端點 | 描述 |
|------|------|------|
| GET | `/api/health` | 健康檢查 |
| GET | `/api/names` | 取得所有名字 |
| POST | `/api/names` | 新增名字 |
| GET | `/api/names/{id}` | 取得特定名字 |
| DELETE | `/api/names/{id}` | 刪除名字 |
| GET | `/api/names/count` | 取得名字總數 |

## 🏥 監控和管理

### 服務管理
```powershell
# 查看服務狀態
docker service ls

# 查看服務日誌
docker service logs worker-stack_worker-backend
docker service logs worker-stack_worker-frontend

# 擴展服務
docker service scale worker-stack_worker-backend=3

# 停止服務
docker stack rm worker-stack
```

### 健康檢查
- 前端: http://localhost:8080/health
- 後端: http://localhost:8080/api/health

## 📊 性能特性

### 高可用性
- **多副本部署**: 每個服務預設 2 個副本
- **故障恢復**: 自動重啟失敗的容器
- **滾動更新**: 漸進式更新，避免服務中斷

### 資源管理
- **記憶體限制**: Backend 512MB, Frontend 128MB
- **健康監控**: 30 秒間隔健康檢查
- **優雅關閉**: 支援 SIGTERM 信號處理

### 安全性
- **網路隔離**: 使用 overlay 網路隔離服務
- **資料持久化**: 卷掛載確保資料安全
- **最小權限**: 容器以非 root 用戶運行

## 🔧 故障排除

### 常見問題

1. **埠口衝突**
   ```powershell
   netstat -an | findstr :8080
   ```

2. **服務無法啟動**
   ```powershell
   docker service ps worker-stack_worker-backend --no-trunc
   ```

3. **資料遺失**
   - 檢查 `./data` 目錄權限
   - 確認卷掛載配置正確

### 日誌收集
```powershell
# 匯出所有服務日誌
docker service logs worker-stack_worker-backend > backend.log 2>&1
docker service logs worker-stack_worker-frontend > frontend.log 2>&1
```

## 📈 擴展建議

### 生產環境優化
1. **外部資料庫**: 替換 SQLite 為 PostgreSQL/MySQL
2. **負載均衡器**: 使用 HAProxy 或 NGINX Plus
3. **監控系統**: 整合 Prometheus + Grafana
4. **日誌管理**: 使用 ELK Stack 或 Fluentd
5. **安全強化**: 啟用 TLS/SSL 加密

### 功能擴展
- 名字分類和標籤
- 匯入/匯出功能
- 批次操作
- 搜尋和篩選
- 使用者評論和評分

## 📝 授權

本專案基於 MIT 授權條款。詳見 [LICENSE](LICENSE) 檔案。

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request！

---

**開發者**: HW5 Worker Team  
**版本**: 1.0.0  
**最後更新**: 2024-11-02