# Manager端 - Worker數據庫連線套件

這個套件包含連接到 Worker 端 PostgreSQL 數據庫的所有必要文件。

## 文件說明

### 1. 網路測試 (`network-test.py`)
- 測試到 Worker 端的 TCP 連線
- 驗證網路連通性
- 不需要額外套件，可直接執行

### 2. PostgreSQL 客戶端 (`manager-client.py`)
- 完整的數據庫管理工具
- 支援新增、查詢、搜尋姓名
- 需要安裝 psycopg2-binary 套件

### 3. 簡單連線測試 (`simple-test.py`)
- 基本的 PostgreSQL 連線測試
- 顯示數據庫內容

### 4. 防火牆設定工具
- `check-firewall.ps1`: 檢查防火牆狀態
- `setup-firewall-admin.ps1`: 配置防火牆規則（需要管理員權限）

## 使用步驟

### Step 1: 網路連線測試
```
python network-test.py
```
確認到 Worker 端的網路連線正常。

### Step 2: 安裝 PostgreSQL 驅動
```
pip install psycopg2-binary
```

### Step 3: 執行 Manager 客戶端
```
python manager-client.py
```

## Worker 端連線資訊

- **主機**: 192.168.0.34
- **端口**: 5432
- **數據庫**: worker_names
- **用戶名**: worker
- **密碼**: worker_password

## 故障排除

如果連線失敗，請檢查：

1. **Worker 端服務狀態**
   ```
   docker stack ls
   docker service ls
   ```

2. **防火牆設定**
   - 執行 `setup-firewall-admin.ps1` (需要管理員權限)
   - 開放 PostgreSQL 端口 5432

3. **網路連通性**
   ```
   ping 192.168.0.34
   telnet 192.168.0.34 5432
   ```

## Manager 客戶端功能

- ✅ 連接到 Worker 數據庫
- ✅ 查看所有姓名記錄
- ✅ 新增姓名
- ✅ 搜尋姓名（支援模糊搜尋）
- ✅ 顯示統計資訊
- ✅ 互動式命令介面

## 示例用法

```python
# 創建管理器實例
manager = NameManager()

# 連接數據庫
if manager.connect():
    # 查看所有姓名
    manager.get_all_names()
    
    # 新增姓名
    manager.add_name("張三")
    
    # 搜尋姓名
    manager.search_names("張")
    
    # 關閉連線
    manager.disconnect()
```

---
© 2025 Worker-Manager Database System