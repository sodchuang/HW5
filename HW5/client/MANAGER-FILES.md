# Manager端文件清單與說明

## 📋 Manager端完整文件列表

### 🔧 核心程式
- `manager-client.py` - 完整的 Manager 端 PostgreSQL 客戶端程式
- `network-test.py` - 網路連線測試工具
- `simple-test.py` - 簡單的資料庫連線測試

### 🖥️ 啟動工具
- `start-manager.bat` - Manager 端主選單啟動器
- `setup-manager.bat` - Manager 端環境設定腳本

### 🛡️ 防火牆工具
- `check-firewall.ps1` - 檢查 Windows 防火牆狀態
- `setup-firewall-admin.ps1` - 設定 PostgreSQL 防火牆規則 (需管理員權限)

### 📚 說明文件
- `README-Manager.md` - Manager 端完整使用說明
- `HW5-Worker-Spec.md` - Worker 端規格文件 (參考用)

## 🚀 快速開始

### 1. 執行主選單
```cmd
start-manager.bat
```

### 2. 直接測試網路連線
```cmd
python network-test.py
```

### 3. 直接啟動 Manager 客戶端
```cmd
python manager-client.py
```

## 📊 連線設定

```
主機: 192.168.0.34
端口: 5432
資料庫: worker_names
使用者: worker
密碼: worker_password
```

## ✅ 測試結果

✅ **TCP 連線測試**: PASSED - 可以連接到 Worker 端 PostgreSQL
✅ **網路通訊**: PASSED - 192.168.0.34:5432 可達
✅ **防火牆工具**: READY - 腳本已準備就緒
✅ **Manager 客戶端**: READY - 完整功能客戶端已完成

## 📁 檔案結構
```
client/
├── manager-client.py          # 主要 Manager 客戶端
├── network-test.py            # 網路測試工具
├── simple-test.py             # 簡單測試
├── start-manager.bat          # 主選單
├── check-firewall.ps1         # 防火牆檢查
├── setup-firewall-admin.ps1   # 防火牆設定
└── README-Manager.md          # 使用說明
```

## 🔄 使用流程

1. **網路測試** → 確認到 Worker 端連線
2. **安裝驅動** → `pip install psycopg2-binary`
3. **設定防火牆** → 開放 5432 端口 (如需要)
4. **啟動客戶端** → 連接並操作資料庫

---
🎯 **Ready for Production**: Manager 端已準備就緒，可連接到 Worker 端 PostgreSQL 資料庫！