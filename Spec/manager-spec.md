# Manager 端規格文件（Swarm 管理節點 / 筆電）

## 一、架構規劃（Plan）

**角色**：Swarm Manager（筆電）  
**服務內容**：`web`、`api`  
**主要職責**：
- 建立並管理整個 Docker Swarm 叢集  
- 負責啟動 stack、監控節點狀態  
- 對外開放 Web 入口（port 80）  
- 透過 overlay 網路與 worker 上的 DB 溝通

### 系統拓樸
```
[Client/Browser]
       ↓ HTTP (port 80)
[Manager Node: Laptop]
  ├── web (Nginx)
  ├── api (Flask)
       ↓ Overlay Network (appnet)
[Worker Node: Lab Linux]
  └── db (PostgreSQL)
```

### 網路設計
- Overlay network 名稱：`appnet`
- Service Discovery：
  - web → api 使用 DNS 名稱 `api`
  - api → db 使用 DNS 名稱 `db`
- Ingress Port：`80:80`
- 健康檢查路由：`/healthz` 回傳 `{status:"ok"}`

### 放置與持久化
- Manager 端執行 web 與 api
- Worker 端僅執行 db
- DB 於 lab node 使用持久化資料卷 `/var/lib/postgres-data`

---

## 二、工作項目（Tasks）

| 步驟 | 指令 | 說明 |
|------|------|------|
| 1 | `docker swarm init` | 初始化 swarm 叢集 |
| 2 | （複製 join token 給 worker） | 讓 worker 加入 swarm |
| 3 | `docker node update --label-add role=db=true <lab-node>` | 標記 worker 節點為 db |
| 4 | `docker stack deploy -c swarm/stack.yaml mcapp` | 部署 stack |
| 5 | `docker node ls` | 確認 manager + worker 節點出現 |
| 6 | `docker service ps mcapp_db` | 驗證 DB 僅在 lab node 執行 |
| 7 | `curl http://localhost/` | 確認 Web 頁面與負載平衡 |
| 8 | `curl http://localhost/healthz` | 健康檢查 OK |
| 9 | 重啟 DB 服務 | 驗證資料持久性 |
| 10 | 記錄指令輸出 | 儲存於 `docs/EVIDENCE.md` |

---

## 三、驗收條件（Acceptance）
- Web 可於 port 80 成功存取
- DB 僅在 worker 節點執行
- API 可正常連線至 DB
- DB 資料於重啟後仍存在
- `/healthz` 回傳 OK
