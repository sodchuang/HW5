# Software Design Document (SDD)
## 3-Tier Names Database Web Application

### Document Information
- **Project Name**: HW4 - 3-Tier Names Database Application
- **Version**: 1.0
- **Date**: 2025-10-10
- **Author**: Development Team
- **Repository**: HW4 - sodchuang/HW4

---

## 1. 專案概述 (Project Overview)

### 1.1 專案描述
本專案是一個三層式 (3-tier) Web 應用程式，使用 Docker Compose 進行容器化部署。應用程式提供簡單的名字資料庫管理功能，允許使用者透過 Web 介面執行新增、查詢和刪除名字的操作。

### 1.2 專案目標
- 實現完整的三層式架構 (Presentation Layer、Business Logic Layer、Data Layer)
- 展示 Docker 容器化技術的應用
- 提供 RESTful API 設計實作
- 建立可維護且可擴展的程式碼結構

### 1.3 核心功能
- **新增名字**: 使用者可以透過 Web 介面輸入名字並儲存到資料庫
- **列出所有名字**: 顯示資料庫中所有已儲存的名字及其建立時間
- **刪除名字**: 使用者可以選擇並刪除特定的名字記錄

---

## 2. 系統架構 (System Architecture)

### 2.1 三層式架構

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│                     (Frontend Tier)                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Nginx Web Server                       │   │
│  │  • HTML/CSS/JavaScript Static Files                 │   │
│  │  • Reverse Proxy for API requests                   │   │
│  │  • Port 8080 (外部) → Port 80 (內部)                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/HTTPS
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Business Logic Layer                      │
│                     (Backend Tier)                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │             FastAPI Application                     │   │
│  │  • REST API Endpoints (/api/names)                  │   │
│  │  • Business Logic & Validation                      │   │
│  │  • SQLAlchemy ORM Integration                       │   │
│  │  • Port 8000 (內部)                                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Database Connection
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                            │
│                    (Database Tier)                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              SQLite Database                        │   │
│  │  • names 資料表                                     │   │
│  │  • 持久化儲存 (Volume Mount)                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 容器架構

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose Network                   │
│                        (hw_net)                            │
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   frontend   │    │   backend    │    │      db      │  │
│  │              │    │              │    │              │  │
│  │ nginx:alpine │    │ python:3.11  │    │   busybox    │  │
│  │              │    │              │    │              │  │
│  │ Port: 8080   │    │ Port: 8000   │    │  (Volume)    │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         │                     │                     │      │
│         └─────────────────────┼─────────────────────┘      │
│                               │                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Shared Volume: db_data                 │   │
│  │          /data (db) ↔ /app/data (backend)           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 資料流程

1. **使用者請求** → Frontend (Nginx) → 靜態檔案服務
2. **API 請求** → Frontend (Nginx) → Backend (FastAPI) → Database (SQLite)
3. **回應資料** → Database → Backend → Frontend → 使用者

---

## 3. 技術規格 (Technical Specifications)

### 3.1 技術堆疊

| 層級 | 技術 | 版本 | 用途 |
|------|------|------|------|
| Frontend | Nginx | alpine | Web 服務器 & 反向代理 |
| Frontend | HTML5/CSS3/JavaScript | ES6+ | 使用者介面 |
| Backend | Python | 3.11 | 程式語言 |
| Backend | FastAPI | 0.103.0 | Web 框架 |
| Backend | SQLAlchemy | 2.0.21 | ORM |
| Backend | Uvicorn/Gunicorn | 0.23.0/20.1.0 | ASGI 服務器 |
| Database | SQLite | 3.x | 資料庫 |
| Container | Docker | Latest | 容器化 |
| Orchestration | Docker Compose | 3.8 | 容器編排 |

### 3.2 API 規格

#### 3.2.1 API Endpoints

| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/names` | 取得所有名字列表 | None | `[{"id": int, "name": str, "created_at": str}]` |
| POST | `/api/names` | 新增名字 | `{"name": str}` | `{"id": int, "name": str, "created_at": str}` |
| DELETE | `/api/names/{id}` | 刪除指定名字 | None | `{"deleted_id": int}` |
| GET | `/health` | 健康檢查 | None | `{"status": "ok"}` |

#### 3.2.2 資料驗證規則

- **名字長度**: 1-50 字元
- **名字內容**: 不可為空字串或僅包含空白字元
- **回應格式**: JSON
- **錯誤處理**: HTTP 狀態碼 + 錯誤訊息

### 3.3 資料庫結構

```sql
CREATE TABLE names (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 3.4 容器配置

#### Frontend Container
- **Base Image**: `nginx:alpine`
- **Port Mapping**: `8080:80`
- **Volume**: `./frontend/static` → `/usr/share/nginx/html`
- **Config**: `./frontend/nginx.conf` → `/etc/nginx/conf.d/default.conf`

#### Backend Container
- **Base Image**: `python:3.11-slim`
- **Port**: `8000` (內部)
- **Volume**: `db_data:/app/data`
- **Dependencies**: requirements.txt

#### Database Container
- **Base Image**: `busybox`
- **Volume**: `db_data:/data`
- **Purpose**: 提供持久化儲存空間

---

## 4. 開發計畫 (Development Plan)

### 4.1 專案階段規劃

#### Phase 1: 基礎架構建立 (週 1-2)
**目標**: 建立基本的 Docker 環境和三層式架構

**Tasks**:
1. **Docker 環境設置**
   - 建立 `docker-compose.yml` 配置
   - 設定網路和 Volume 配置
   - 測試容器間通訊

2. **資料庫層實作**
   - 設計 SQLite 資料庫結構
   - 建立 `names` 資料表
   - 實作資料持久化機制

3. **後端 API 框架**
   - 建立 FastAPI 專案結構
   - 實作基本的 CRUD API endpoints
   - 整合 SQLAlchemy ORM

**Deliverables**:
- 可運行的 Docker Compose 環境
- 基本的資料庫結構
- REST API 框架

#### Phase 2: 核心功能實作 (週 3-4)
**目標**: 實作完整的業務邏輯和 API 功能

**Tasks**:
1. **API 功能完善**
   - 實作 GET `/api/names` (列出所有名字)
   - 實作 POST `/api/names` (新增名字)
   - 實作 DELETE `/api/names/{id}` (刪除名字)
   - 實作 GET `/health` (健康檢查)

2. **資料驗證與錯誤處理**
   - 實作輸入資料驗證
   - 建立統一的錯誤回應格式
   - 處理資料庫連線錯誤

3. **資料庫整合**
   - 建立 SQLAlchemy Models
   - 實作資料庫連線池
   - 資料庫遷移機制

**Deliverables**:
- 完整的 REST API 功能
- 資料驗證機制
- 錯誤處理系統

#### Phase 3: 前端介面開發 (週 5-6)
**目標**: 建立使用者友善的 Web 介面

**Tasks**:
1. **HTML/CSS 介面設計**
   - 建立響應式網頁設計
   - 實作使用者輸入表單
   - 設計名字列表顯示介面

2. **JavaScript 功能實作**
   - 實作 AJAX API 呼叫
   - 建立動態 DOM 操作
   - 實作使用者互動功能

3. **Nginx 配置**
   - 設定靜態檔案服務
   - 配置 API 反向代理
   - 最佳化效能設定

**Deliverables**:
- 完整的前端使用者介面
- Nginx 反向代理配置
- 前後端整合功能

#### Phase 4: 整合測試與部署 (週 7-8)
**目標**: 系統整合、測試與生產環境準備

**Tasks**:
1. **系統整合測試**
   - 端到端功能測試
   - 容器間通訊測試
   - 負載測試

2. **部署準備**
   - 生產環境配置
   - 安全性設定
   - 監控機制建立

3. **文件完善**
   - API 文件撰寫
   - 部署指南
   - 維護手冊

**Deliverables**:
- 完整測試報告
- 部署文件
- 系統維護指南

### 4.2 里程碑與時程

| 里程碑 | 完成日期 | 主要成果 |
|--------|----------|----------|
| M1: 架構建立 | Week 2 | Docker 環境 + 基本 API |
| M2: 核心功能 | Week 4 | 完整 CRUD 功能 |
| M3: 前端完成 | Week 6 | 使用者介面 + 整合 |
| M4: 系統上線 | Week 8 | 生產環境部署 |

### 4.3 風險管理

| 風險項目 | 影響程度 | 發生機率 | 緩解策略 |
|----------|----------|----------|----------|
| Docker 相容性問題 | 高 | 中 | 使用穩定版本 + 測試環境驗證 |
| API 效能瓶頸 | 中 | 低 | 實作快取機制 + 資料庫最佳化 |
| 前端相容性 | 低 | 中 | 跨瀏覽器測試 + Polyfill |
| 資料庫容量限制 | 中 | 低 | 實作資料清理機制 |

---

## 5. 程式碼品質標準 (Code Quality Standards)

### 5.1 編碼規範

#### 5.1.1 Python (Backend)
- **Style Guide**: PEP 8
- **Line Length**: 最大 88 字元 (Black formatter)
- **Import Ordering**: 標準庫 → 第三方庫 → 本地模組
- **Naming Conventions**:
  - 函數/變數: `snake_case`
  - 類別: `PascalCase`
  - 常數: `UPPER_SNAKE_CASE`

```python
# Good Example
class NameModel(Base):
    __tablename__ = "names"
    
    def get_all_names(self) -> List[Dict]:
        """取得所有名字記錄"""
        return self.query.all()

# Configuration Constants
DATABASE_URL = "sqlite:///names.db"
MAX_NAME_LENGTH = 50
```

#### 5.1.2 JavaScript (Frontend)
- **Style Guide**: Airbnb JavaScript Style Guide
- **ES Version**: ES6+
- **Naming Conventions**:
  - 變數/函數: `camelCase`
  - 常數: `UPPER_SNAKE_CASE`

```javascript
// Good Example
const API_BASE_URL = '/api';

async function fetchNamesList() {
  try {
    const response = await fetch(`${API_BASE_URL}/names`);
    return await response.json();
  } catch (error) {
    console.error('Failed to fetch names:', error);
    throw error;
  }
}
```

#### 5.1.3 HTML/CSS (Frontend)
- **HTML**: HTML5 語意化標籤
- **CSS**: BEM 命名方法論
- **Accessibility**: WCAG 2.1 AA 標準

### 5.2 程式碼審查流程

#### 5.2.1 審查檢查清單

**功能性檢查**:
- [ ] 功能是否符合需求規格
- [ ] API 回應格式是否正確
- [ ] 錯誤處理是否完善
- [ ] 輸入驗證是否充分

**程式碼品質檢查**:
- [ ] 程式碼是否遵循編碼規範
- [ ] 函數是否單一職責
- [ ] 變數命名是否清晰
- [ ] 註解是否充分且準確

**安全性檢查**:
- [ ] 是否有 SQL 注入風險
- [ ] 輸入是否經過適當驗證
- [ ] 敏感資訊是否正確處理
- [ ] CORS 設定是否適當

**效能檢查**:
- [ ] 資料庫查詢是否最佳化
- [ ] 是否有不必要的 API 呼叫
- [ ] 記憶體使用是否合理
- [ ] 回應時間是否在可接受範圍內

#### 5.2.2 審查流程

1. **提交審查**
   - 建立 Pull Request
   - 填寫變更說明
   - 指派審查者

2. **程式碼審查**
   - 靜態程式碼分析
   - 人工程式碼審查
   - 安全性掃描

3. **測試驗證**
   - 自動化測試執行
   - 手動功能測試
   - 整合測試

4. **合併程式碼**
   - 審查通過
   - 所有測試通過
   - 合併到主分支

### 5.3 靜態程式碼分析工具

#### 5.3.1 Python 工具
```bash
# Code Formatting
black . --line-length 88
isort . --profile black

# Linting
flake8 . --max-line-length 88
pylint backend/

# Type Checking
mypy backend/ --strict
```

#### 5.3.2 JavaScript 工具
```bash
# Linting
eslint frontend/static/ --ext .js

# Code Formatting
prettier --write frontend/static/**/*.{js,html,css}
```

### 5.4 程式碼複雜度控制

- **函數長度**: 最大 50 行
- **類別長度**: 最大 300 行
- **圈複雜度**: 最大 10
- **嵌套層級**: 最大 4 層

---

## 6. 測試覆蓋率策略 (Test Coverage Strategy)

### 6.1 測試策略概述

#### 6.1.1 測試金字塔

```
        ┌─────────────────────┐
        │   E2E Tests (5%)    │  ← 端到端測試
        └─────────────────────┘
      ┌───────────────────────────┐
      │ Integration Tests (15%)   │  ← 整合測試
      └───────────────────────────┘
    ┌─────────────────────────────────┐
    │    Unit Tests (80%)             │  ← 單元測試
    └─────────────────────────────────┘
```

#### 6.1.2 測試覆蓋率目標

| 測試類型 | 覆蓋率目標 | 說明 |
|----------|------------|------|
| 單元測試 | ≥ 85% | 函數、類別層級的測試 |
| 整合測試 | ≥ 70% | API 端點、資料庫互動 |
| 端到端測試 | ≥ 90% | 主要使用者流程 |
| 總體覆蓋率 | ≥ 80% | 程式碼行數覆蓋率 |

### 6.2 單元測試 (Unit Tests)

#### 6.2.1 Backend 單元測試

**測試框架**: pytest + pytest-cov
**測試檔案結構**:
```
backend/
├── app.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_models.py
│   ├── test_api.py
│   └── test_utils.py
└── requirements-dev.txt
```

**測試案例範例**:
```python
# tests/test_api.py
import pytest
from fastapi.testclient import TestClient
from app import app

client = TestClient(app)

class TestNamesAPI:
    
    def test_add_name_success(self):
        """測試成功新增名字"""
        response = client.post("/api/names", json={"name": "Test Name"})
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Test Name"
        assert "id" in data
        assert "created_at" in data
    
    def test_add_name_empty_string(self):
        """測試新增空字串名字應該失敗"""
        response = client.post("/api/names", json={"name": ""})
        assert response.status_code == 400
        assert "Name cannot be empty" in response.json()["detail"]
    
    def test_add_name_too_long(self):
        """測試新增過長名字應該失敗"""
        long_name = "x" * 51
        response = client.post("/api/names", json={"name": long_name})
        assert response.status_code == 400
        assert "Name too long" in response.json()["detail"]
    
    def test_list_names_empty(self):
        """測試列出空名字列表"""
        response = client.get("/api/names")
        assert response.status_code == 200
        assert response.json() == []
    
    def test_delete_name_not_found(self):
        """測試刪除不存在的名字"""
        response = client.delete("/api/names/999")
        assert response.status_code == 404
        assert "Not found" in response.json()["detail"]
```

**測試執行指令**:
```bash
# 執行所有測試
pytest backend/tests/ -v

# 執行測試並產生覆蓋率報告
pytest backend/tests/ --cov=backend --cov-report=html

# 執行特定測試檔案
pytest backend/tests/test_api.py -v
```

#### 6.2.2 Frontend 單元測試

**測試框架**: Jest + jsdom
**測試檔案結構**:
```
frontend/
├── static/
│   └── index.html
├── tests/
│   ├── api.test.js
│   ├── dom.test.js
│   └── utils.test.js
├── package.json
└── jest.config.js
```

**測試案例範例**:
```javascript
// tests/api.test.js
import { api, loadNames, escapeHtml } from '../static/index.html';

describe('API Functions', () => {
  beforeEach(() => {
    fetch.mockClear();
  });

  test('api function handles successful response', async () => {
    const mockData = [{ id: 1, name: 'Test', created_at: '2023-01-01' }];
    fetch.mockResolvedValueOnce({
      ok: true,
      headers: {
        get: () => 'application/json'
      },
      json: async () => mockData
    });

    const result = await api('/api/names', { method: 'GET' });
    expect(result).toEqual(mockData);
  });

  test('escapeHtml function prevents XSS', () => {
    const unsafeString = '<script>alert("xss")</script>';
    const safeString = escapeHtml(unsafeString);
    expect(safeString).toBe('&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;');
  });
});
```

### 6.3 整合測試 (Integration Tests)

#### 6.3.1 API 整合測試

**目標**: 測試完整的 API 請求-回應週期，包含資料庫操作

```python
# tests/test_integration.py
import pytest
import tempfile
import os
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app import app, get_db, Base

class TestAPIIntegration:
    
    @pytest.fixture
    def test_db(self):
        """建立測試資料庫"""
        db_fd, db_path = tempfile.mkstemp()
        engine = create_engine(f"sqlite:///{db_path}")
        Base.metadata.create_all(bind=engine)
        TestingSessionLocal = sessionmaker(bind=engine)
        
        def override_get_db():
            try:
                db = TestingSessionLocal()
                yield db
            finally:
                db.close()
        
        app.dependency_overrides[get_db] = override_get_db
        yield TestingSessionLocal
        
        os.close(db_fd)
        os.unlink(db_path)
    
    def test_full_crud_workflow(self, test_db):
        """測試完整的 CRUD 工作流程"""
        client = TestClient(app)
        
        # 1. 新增名字
        response = client.post("/api/names", json={"name": "Integration Test"})
        assert response.status_code == 200
        created_name = response.json()
        name_id = created_name["id"]
        
        # 2. 查詢所有名字
        response = client.get("/api/names")
        assert response.status_code == 200
        names = response.json()
        assert len(names) == 1
        assert names[0]["name"] == "Integration Test"
        
        # 3. 刪除名字
        response = client.delete(f"/api/names/{name_id}")
        assert response.status_code == 200
        
        # 4. 確認刪除成功
        response = client.get("/api/names")
        assert response.status_code == 200
        assert response.json() == []
```

#### 6.3.2 容器整合測試

**目標**: 測試 Docker 容器間的通訊和資料流

```python
# tests/test_docker_integration.py
import requests
import pytest
import time
import subprocess

class TestDockerIntegration:
    
    @pytest.fixture(scope="class")
    def docker_services(self):
        """啟動 Docker Compose 服務"""
        subprocess.run(["docker-compose", "up", "-d"], check=True)
        time.sleep(10)  # 等待服務啟動
        yield
        subprocess.run(["docker-compose", "down"], check=True)
    
    def test_frontend_accessibility(self, docker_services):
        """測試前端服務可訪問性"""
        response = requests.get("http://localhost:8080")
        assert response.status_code == 200
        assert "Names DB" in response.text
    
    def test_api_through_nginx(self, docker_services):
        """測試透過 Nginx 存取 API"""
        # 新增名字
        response = requests.post(
            "http://localhost:8080/api/names",
            json={"name": "Docker Test"}
        )
        assert response.status_code == 200
        
        # 查詢名字
        response = requests.get("http://localhost:8080/api/names")
        assert response.status_code == 200
        names = response.json()
        assert len(names) >= 1
        assert any(name["name"] == "Docker Test" for name in names)
```

### 6.4 端到端測試 (E2E Tests)

#### 6.4.1 測試工具與框架

**工具**: Playwright + Python
**測試範圍**: 完整使用者操作流程

```python
# tests/test_e2e.py
import pytest
from playwright.sync_api import sync_playwright

class TestE2EWorkflow:
    
    @pytest.fixture
    def browser_page(self):
        """建立瀏覽器頁面"""
        with sync_playwright() as p:
            browser = p.chromium.launch()
            page = browser.new_page()
            yield page
            browser.close()
    
    def test_complete_user_workflow(self, browser_page):
        """測試完整使用者工作流程"""
        page = browser_page
        
        # 1. 開啟首頁
        page.goto("http://localhost:8080")
        assert page.title() == "HW3 - Names DB"
        
        # 2. 新增名字
        page.fill("#nameInput", "E2E Test Name")
        page.click("#addBtn")
        
        # 3. 等待名字出現在列表中
        page.wait_for_selector("text=E2E Test Name")
        
        # 4. 驗證名字已新增
        names_list = page.query_selector("#namesList")
        assert "E2E Test Name" in names_list.inner_text()
        
        # 5. 刪除名字
        delete_btn = page.query_selector("button:has-text('刪除')")
        delete_btn.click()
        
        # 6. 確認刪除對話框
        page.on("dialog", lambda dialog: dialog.accept())
        
        # 7. 驗證名字已刪除
        page.wait_for_selector("text=目前沒有資料")
    
    def test_input_validation_ui(self, browser_page):
        """測試前端輸入驗證"""
        page = browser_page
        page.goto("http://localhost:8080")
        
        # 測試空字串驗證
        page.fill("#nameInput", "")
        page.click("#addBtn")
        page.wait_for_selector("text=名字不能為空")
        
        # 測試過長字串驗證
        long_name = "x" * 51
        page.fill("#nameInput", long_name)
        page.click("#addBtn")
        page.wait_for_selector("text=名字長度超過 50")
```

### 6.5 測試自動化與 CI/CD 整合

#### 6.5.1 測試執行腳本

```bash
#!/bin/bash
# scripts/run_tests.sh

echo "=== 執行後端單元測試 ==="
cd backend
pytest tests/ --cov=. --cov-report=xml --cov-report=term-missing

echo "=== 執行前端測試 ==="
cd ../frontend
npm test -- --coverage --watchAll=false

echo "=== 執行整合測試 ==="
cd ..
docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit

echo "=== 執行 E2E 測試 ==="
docker-compose up -d
sleep 10
pytest tests/test_e2e.py
docker-compose down

echo "=== 測試完成 ==="
```

#### 6.5.2 測試覆蓋率報告

**覆蓋率報告工具**:
- **Backend**: pytest-cov + coverage.py
- **Frontend**: Jest built-in coverage
- **整合報告**: codecov.io

```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v3
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install -r backend/requirements.txt
        pip install -r backend/requirements-dev.txt
    
    - name: Run backend tests
      run: |
        cd backend
        pytest --cov=. --cov-report=xml
    
    - name: Run integration tests
      run: |
        docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./backend/coverage.xml
```

### 6.6 測試資料管理

#### 6.6.1 測試資料策略

**測試資料類型**:
- **靜態測試資料**: 預定義的測試案例
- **動態測試資料**: 測試過程中產生的資料
- **模擬資料**: 外部服務的模擬回應

**資料清理策略**:
```python
# conftest.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

@pytest.fixture(autouse=True)
def cleanup_test_data():
    """每次測試後清理測試資料"""
    yield
    # 清理測試資料庫
    engine = create_engine("sqlite:///test.db")
    with engine.connect() as conn:
        conn.execute("DELETE FROM names WHERE name LIKE 'Test%'")
        conn.commit()
```

---

## 7. 可維護性準則 (Maintainability Guidelines)

### 7.1 程式碼維護性原則

#### 7.1.1 SOLID 原則應用

**Single Responsibility Principle (單一職責原則)**:
```python
# Good: 職責分離
class NameValidator:
    """負責名字驗證的類別"""
    @staticmethod
    def validate_name(name: str) -> bool:
        return bool(name and name.strip() and len(name) <= 50)

class NameRepository:
    """負責資料庫操作的類別"""
    def __init__(self, db_session):
        self.db = db_session
    
    def create_name(self, name: str) -> Name:
        name_obj = Name(name=name.strip())
        self.db.add(name_obj)
        self.db.commit()
        return name_obj
```

**Open/Closed Principle (開放封閉原則)**:
```python
# Good: 透過介面擴展功能
from abc import ABC, abstractmethod

class DatabaseInterface(ABC):
    @abstractmethod
    def save(self, data): pass
    
    @abstractmethod
    def find_all(self): pass

class SQLiteDatabase(DatabaseInterface):
    def save(self, data):
        # SQLite 實作
        pass
    
    def find_all(self):
        # SQLite 實作
        pass

class PostgreSQLDatabase(DatabaseInterface):
    def save(self, data):
        # PostgreSQL 實作
        pass
    
    def find_all(self):
        # PostgreSQL 實作
        pass
```

#### 7.1.2 程式碼模組化

**目錄結構最佳化**:
```
backend/
├── app.py                 # 主應用程式入口
├── models/               # 資料模型
│   ├── __init__.py
│   └── name.py
├── repositories/         # 資料存取層
│   ├── __init__.py
│   └── name_repository.py
├── services/            # 業務邏輯層
│   ├── __init__.py
│   └── name_service.py
├── api/                 # API 路由
│   ├── __init__.py
│   └── names.py
├── utils/               # 工具函數
│   ├── __init__.py
│   ├── validators.py
│   └── exceptions.py
└── config/              # 配置管理
    ├── __init__.py
    └── settings.py
```

**模組分離範例**:
```python
# models/name.py
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import declarative_base
from datetime import datetime

Base = declarative_base()

class Name(Base):
    __tablename__ = "names"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

# services/name_service.py
from typing import List, Optional
from repositories.name_repository import NameRepository
from utils.validators import NameValidator
from utils.exceptions import ValidationError

class NameService:
    def __init__(self, repository: NameRepository):
        self.repository = repository
        self.validator = NameValidator()
    
    def create_name(self, name: str) -> dict:
        if not self.validator.validate_name(name):
            raise ValidationError("Invalid name format")
        
        name_obj = self.repository.create(name.strip())
        return {
            "id": name_obj.id,
            "name": name_obj.name,
            "created_at": name_obj.created_at.isoformat()
        }
    
    def get_all_names(self) -> List[dict]:
        names = self.repository.find_all()
        return [
            {
                "id": name.id,
                "name": name.name,
                "created_at": name.created_at.isoformat()
            }
            for name in names
        ]
```

### 7.2 配置管理

#### 7.2.1 環境配置分離

```python
# config/settings.py
import os
from typing import Optional

class Settings:
    # 資料庫配置
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "sqlite:///./names.db"
    )
    
    # API 配置
    API_HOST: str = os.getenv("API_HOST", "0.0.0.0")
    API_PORT: int = int(os.getenv("API_PORT", "8000"))
    
    # 應用配置
    MAX_NAME_LENGTH: int = int(os.getenv("MAX_NAME_LENGTH", "50"))
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"
    
    # 安全配置
    CORS_ORIGINS: list = os.getenv(
        "CORS_ORIGINS", 
        "http://localhost:8080"
    ).split(",")

# 不同環境的配置
class DevelopmentSettings(Settings):
    DEBUG: bool = True
    DATABASE_URL: str = "sqlite:///./dev_names.db"

class ProductionSettings(Settings):
    DEBUG: bool = False
    DATABASE_URL: str = os.getenv("PROD_DATABASE_URL")

class TestingSettings(Settings):
    DATABASE_URL: str = "sqlite:///:memory:"

# 配置工廠
def get_settings() -> Settings:
    env = os.getenv("ENVIRONMENT", "development")
    
    if env == "production":
        return ProductionSettings()
    elif env == "testing":
        return TestingSettings()
    else:
        return DevelopmentSettings()
```

#### 7.2.2 Docker 環境配置

```yaml
# docker-compose.yml (開發環境)
version: "3.8"

services:
  backend:
    build: ./backend
    environment:
      - ENVIRONMENT=development
      - DEBUG=true
      - DATABASE_URL=sqlite:///./data/dev_names.db
    volumes:
      - ./backend:/app
      - db_data:/app/data

# docker-compose.prod.yml (生產環境)
version: "3.8"

services:
  backend:
    build: 
      context: ./backend
      dockerfile: Dockerfile.prod
    environment:
      - ENVIRONMENT=production
      - DEBUG=false
      - DATABASE_URL=postgresql://user:password@db:5432/names_db
    restart: unless-stopped
```

### 7.3 錯誤處理與日誌管理

#### 7.3.1 統一錯誤處理

```python
# utils/exceptions.py
class AppException(Exception):
    """應用程式基礎例外類別"""
    def __init__(self, message: str, error_code: str = None):
        self.message = message
        self.error_code = error_code
        super().__init__(self.message)

class ValidationError(AppException):
    """驗證錯誤"""
    pass

class NotFoundError(AppException):
    """資源未找到錯誤"""
    pass

class DatabaseError(AppException):
    """資料庫錯誤"""
    pass

# api/error_handlers.py
from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse
from utils.exceptions import ValidationError, NotFoundError, DatabaseError

async def validation_error_handler(request: Request, exc: ValidationError):
    return JSONResponse(
        status_code=400,
        content={
            "error": "Validation Error",
            "message": exc.message,
            "error_code": exc.error_code
        }
    )

async def not_found_error_handler(request: Request, exc: NotFoundError):
    return JSONResponse(
        status_code=404,
        content={
            "error": "Not Found",
            "message": exc.message,
            "error_code": exc.error_code
        }
    )
```

#### 7.3.2 日誌系統

```python
# utils/logging.py
import logging
import sys
from datetime import datetime
from config.settings import get_settings

settings = get_settings()

def setup_logging():
    """設定日誌系統"""
    
    # 日誌格式
    log_format = (
        "%(asctime)s - %(name)s - %(levelname)s - "
        "%(funcName)s:%(lineno)d - %(message)s"
    )
    
    # 設定日誌等級
    log_level = logging.DEBUG if settings.DEBUG else logging.INFO
    
    # 設定日誌處理器
    logging.basicConfig(
        level=log_level,
        format=log_format,
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler('app.log', encoding='utf-8')
        ]
    )
    
    # 取得應用程式日誌器
    logger = logging.getLogger("names_app")
    return logger

# 在主要應用程式中使用
logger = setup_logging()

# services/name_service.py 中的使用範例
class NameService:
    def __init__(self, repository: NameRepository):
        self.repository = repository
        self.logger = logging.getLogger(__name__)
    
    def create_name(self, name: str) -> dict:
        self.logger.info(f"Creating name: {name}")
        
        try:
            # 驗證邏輯
            result = self.repository.create(name)
            self.logger.info(f"Name created successfully: {result.id}")
            return result
            
        except Exception as e:
            self.logger.error(f"Failed to create name: {str(e)}")
            raise
```

### 7.4 文件化標準

#### 7.4.1 API 文件

**OpenAPI/Swagger 整合**:
```python
# api/names.py
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import List

router = APIRouter(prefix="/api", tags=["names"])

class NameCreate(BaseModel):
    """建立名字的請求模型"""
    name: str = Field(
        ..., 
        min_length=1,
        max_length=50,
        description="名字內容，長度需在 1-50 字元之間",
        example="張三"
    )

class NameResponse(BaseModel):
    """名字回應模型"""
    id: int = Field(..., description="名字的唯一識別碼")
    name: str = Field(..., description="名字內容")
    created_at: str = Field(..., description="建立時間 (ISO 格式)")
    
    class Config:
        schema_extra = {
            "example": {
                "id": 1,
                "name": "張三",
                "created_at": "2023-10-10T10:30:00"
            }
        }

@router.post("/names", response_model=NameResponse)
async def create_name(
    name_data: NameCreate,
    service: NameService = Depends(get_name_service)
):
    """
    建立新的名字記錄
    
    - **name**: 要儲存的名字 (必填，1-50字元)
    
    **回應**:
    - 201: 成功建立名字
    - 400: 輸入資料驗證失敗
    - 500: 伺服器內部錯誤
    """
    try:
        result = service.create_name(name_data.name)
        return result
    except ValidationError as e:
        raise HTTPException(status_code=400, detail=e.message)
```

#### 7.4.2 程式碼文件

**Docstring 標準**:
```python
def validate_name(name: str) -> bool:
    """
    驗證名字格式是否有效
    
    Args:
        name (str): 要驗證的名字字串
        
    Returns:
        bool: 如果名字有效回傳 True，否則回傳 False
        
    Raises:
        TypeError: 當 name 不是字串類型時
        
    Example:
        >>> validate_name("張三")
        True
        >>> validate_name("")
        False
        >>> validate_name("x" * 51)
        False
    """
    if not isinstance(name, str):
        raise TypeError("Name must be a string")
    
    return bool(name and name.strip() and len(name) <= 50)
```

#### 7.4.3 部署文件

**README.md 結構**:
```markdown
# Names Database Application

## 專案簡介
三層式 Web 應用程式，提供名字資料庫管理功能。

## 快速開始

### 環境需求
- Docker 20.0+
- Docker Compose 2.0+

### 本地開發
```bash
# 1. 複製專案
git clone <repository-url>
cd names-app

# 2. 啟動開發環境
docker-compose up -d

# 3. 存取應用程式
open http://localhost:8080
```

### 生產部署
```bash
# 1. 使用生產配置
docker-compose -f docker-compose.prod.yml up -d

# 2. 健康檢查
curl http://localhost:8080/health
```

## API 文件
詳細 API 文件請參考: http://localhost:8000/docs

## 測試
```bash
# 執行所有測試
./scripts/run_tests.sh

# 執行特定測試
pytest backend/tests/test_api.py -v
```

## 維護指南
詳細維護說明請參考 [MAINTENANCE.md](./MAINTENANCE.md)
```

### 7.5 重構策略

#### 7.5.1 程式碼異味檢測

**常見程式碼異味與解決方案**:

| 異味類型 | 檢測方式 | 重構方法 |
|----------|----------|----------|
| 長方法 | 行數 > 50 | 提取方法 |
| 大類別 | 行數 > 300 | 拆分類別 |
| 重複程式碼 | 靜態分析 | 提取共同邏輯 |
| 長參數列表 | 參數 > 5 | 參數物件化 |
| 複雜條件 | 圈複雜度 > 10 | 提取條件方法 |

#### 7.5.2 重構檢查清單

**重構前檢查**:
- [ ] 是否有足夠的測試覆蓋率 (≥80%)
- [ ] 所有測試是否通過
- [ ] 是否已備份當前版本
- [ ] 是否已通知相關團隊成員

**重構過程**:
- [ ] 小步驟漸進式重構
- [ ] 每個步驟後執行測試
- [ ] 保持功能性不變
- [ ] 及時提交版本控制

**重構後驗證**:
- [ ] 所有測試仍然通過
- [ ] 效能未明顯下降
- [ ] API 回應格式未改變
- [ ] 文件已更新

### 7.6 監控與效能最佳化

#### 7.6.1 效能監控

```python
# utils/monitoring.py
import time
import logging
from functools import wraps
from typing import Callable

logger = logging.getLogger(__name__)

def monitor_performance(func: Callable) -> Callable:
    """效能監控裝飾器"""
    @wraps(func)
    async def wrapper(*args, **kwargs):
        start_time = time.time()
        
        try:
            result = await func(*args, **kwargs)
            execution_time = time.time() - start_time
            
            logger.info(
                f"Function {func.__name__} executed in "
                f"{execution_time:.4f} seconds"
            )
            
            # 效能警告
            if execution_time > 1.0:
                logger.warning(
                    f"Slow operation detected: {func.__name__} "
                    f"took {execution_time:.4f} seconds"
                )
            
            return result
            
        except Exception as e:
            execution_time = time.time() - start_time
            logger.error(
                f"Function {func.__name__} failed after "
                f"{execution_time:.4f} seconds: {str(e)}"
            )
            raise
            
    return wrapper

# 使用範例
@monitor_performance
async def get_all_names():
    # API 邏輯
    pass
```

#### 7.6.2 健康檢查端點

```python
# api/health.py
from fastapi import APIRouter
from sqlalchemy.exc import SQLAlchemyError
from utils.database import get_db_session

router = APIRouter()

@router.get("/health")
async def health_check():
    """系統健康檢查"""
    health_status = {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "services": {}
    }
    
    # 資料庫連線檢查
    try:
        db = get_db_session()
        db.execute("SELECT 1")
        health_status["services"]["database"] = "healthy"
    except SQLAlchemyError:
        health_status["services"]["database"] = "unhealthy"
        health_status["status"] = "degraded"
    
    # 磁碟空間檢查
    import shutil
    disk_usage = shutil.disk_usage("/")
    free_space_gb = disk_usage.free / (1024**3)
    
    if free_space_gb < 1.0:  # 少於 1GB
        health_status["services"]["disk"] = "low_space"
        health_status["status"] = "degraded"
    else:
        health_status["services"]["disk"] = "healthy"
    
    return health_status
```

---

## 8. 結論與建議 (Conclusion and Recommendations)

### 8.1 專案總結

本 SDD 文件詳細規劃了一個三層式 Names Database Web 應用程式的完整設計與實作策略。透過 Docker Compose 的容器化部署，我們成功建立了一個可擴展、可維護且符合現代軟體開發標準的應用程式架構。

**主要成就**:
- ✅ 完整的三層式架構實作 (Frontend, Backend, Database)
- ✅ RESTful API 設計與實作
- ✅ 容器化部署與編排
- ✅ 完善的測試策略 (Unit, Integration, E2E)
- ✅ 程式碼品質管控機制
- ✅ 可維護性設計原則

### 8.2 技術債務管理

#### 8.2.1 已知技術債務

| 項目 | 優先級 | 影響範圍 | 建議處理時程 |
|------|--------|----------|--------------|
| SQLite → PostgreSQL 遷移 | 中 | 資料層 | Phase 2 |
| 前端框架現代化 | 低 | 前端層 | Phase 3 |
| API 版本控制機制 | 中 | 後端層 | Phase 2 |
| 容器安全性強化 | 高 | 部署層 | Phase 1 |

#### 8.2.2 技術升級路徑

**短期目標 (1-3 個月)**:
- 實作 API 版本控制
- 強化容器安全性
- 完善監控與告警機制

**中期目標 (3-6 個月)**:
- 資料庫升級至 PostgreSQL
- 實作快取層 (Redis)
- 建立 CI/CD 流水線

**長期目標 (6-12 個月)**:
- 微服務架構遷移
- 實作分散式追蹤
- 建立災難復原機制

### 8.3 擴展性建議

#### 8.3.1 水平擴展策略

```yaml
# docker-compose.scale.yml
version: "3.8"

services:
  backend:
    deploy:
      replicas: 3
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/names_db

  frontend:
    deploy:
      replicas: 2
    
  nginx-lb:
    image: nginx:alpine
    ports:
      - "80:80"
    configs:
      - source: nginx_lb_config
        target: /etc/nginx/nginx.conf
    depends_on:
      - frontend
```

#### 8.3.2 效能最佳化建議

**資料庫最佳化**:
- 建立適當的索引策略
- 實作連線池管理  
- 考慮讀寫分離架構

**應用程式最佳化**:
- 實作應用層快取
- 非同步處理長時間操作
- API 回應壓縮

**前端最佳化**:
- 實作懶加載機制
- 靜態資源 CDN 分發
- 客戶端快取策略

### 8.4 安全性強化建議

#### 8.4.1 應用程式安全

**認證與授權**:
```python
# 實作 JWT 認證機制
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer
import jwt

security = HTTPBearer()

async def verify_token(token: str = Depends(security)):
    try:
        payload = jwt.decode(token.credentials, SECRET_KEY, algorithms=["HS256"])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expired"
        )
```

**輸入驗證強化**:
```python
from pydantic import validator
import re

class NameCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=50)
    
    @validator('name')
    def validate_name_content(cls, v):
        # 防止 XSS 攻擊
        if re.search(r'[<>"\']', v):
            raise ValueError('Name contains invalid characters')
        
        # 防止 SQL 注入（雖然使用 ORM 但額外防護）
        if re.search(r'(union|select|insert|delete|update|drop)', v, re.I):
            raise ValueError('Name contains potentially harmful content')
            
        return v.strip()
```

#### 8.4.2 容器安全

**Docker 安全配置**:
```dockerfile
# Dockerfile.secure
FROM python:3.11-slim

# 建立非 root 使用者
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 更新系統套件
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 設定工作目錄與權限
WORKDIR /app
COPY --chown=appuser:appuser . .

USER appuser

# 移除不必要的權限
RUN chmod -R go-rwx /app
```

### 8.5 團隊協作建議

#### 8.5.1 開發流程

**Git Flow 策略**:
```
main (生產分支)
  ↑
develop (開發分支)
  ↑
feature/xxx (功能分支)
hotfix/xxx (熱修復分支)
release/xxx (發布分支)
```

**Code Review 檢查項目**:
- [ ] 功能是否符合需求
- [ ] 程式碼品質是否達標
- [ ] 測試覆蓋率是否足夠
- [ ] 安全性檢查
- [ ] 效能影響評估
- [ ] 文件是否更新

#### 8.5.2 知識管理

**文件維護策略**:
- 技術決策記錄 (ADR)
- API 變更日誌
- 故障排除手冊
- 上線清單

### 8.6 最終建議

1. **持續整合/持續部署**: 建立自動化 CI/CD 流水線，確保程式碼品質與部署一致性

2. **監控與告警**: 實作完整的 APM (Application Performance Monitoring) 系統

3. **災難復原**: 建立資料備份與復原機制，制定 RTO/RPO 指標

4. **團隊培訓**: 定期進行技術分享與程式碼審查，提升團隊整體技術水準

5. **用戶回饋**: 建立用戶回饋機制，持續改進產品功能與使用體驗

透過遵循本 SDD 文件的指導原則，我們相信能夠建立一個高品質、可維護且可擴展的 Web 應用程式，為未來的功能擴展和技術演進奠定良好基礎。