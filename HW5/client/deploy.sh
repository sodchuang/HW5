#!/bin/bash

echo "=========================================="
echo "Worker 名字管理系統部署腳本"
echo "=========================================="

# 檢查Docker是否運行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未運行，請先啟動 Docker Desktop"
    exit 1
fi

echo "✅ Docker 運行正常"

# 檢查Docker Swarm狀態
if ! docker info | grep -q "Swarm: active"; then
    echo "🔄 初始化 Docker Swarm..."
    docker swarm init --advertise-addr 127.0.0.1
    if [ $? -eq 0 ]; then
        echo "✅ Docker Swarm 初始化成功"
    else
        echo "❌ Docker Swarm 初始化失敗"
        exit 1
    fi
else
    echo "✅ Docker Swarm 已啟用"
fi

# 建立資料目錄
echo "🔄 建立資料目錄..."
mkdir -p data
echo "✅ 資料目錄已建立"

# 清理舊服務 (如果存在)
if docker stack ls | grep -q "worker-stack"; then
    echo "🔄 清理舊服務..."
    docker stack rm worker-stack
    echo "⏳ 等待服務完全清理..."
    sleep 10
fi

# 部署新服務
echo "🔄 部署 Worker 服務..."
docker stack deploy -c docker-compose-hw5.yml worker-stack

if [ $? -eq 0 ]; then
    echo "✅ 服務部署成功"
else
    echo "❌ 服務部署失敗"
    exit 1
fi

# 等待服務啟動
echo "⏳ 等待服務啟動..."
sleep 15

# 檢查服務狀態
echo "🔍 檢查服務狀態..."
docker service ls

echo ""
echo "=========================================="
echo "✅ 部署完成！"
echo "🌐 訪問地址: http://localhost:8080"
echo "📊 服務狀態: docker service ls"
echo "📝 服務日誌: docker service logs worker-stack_worker-backend"
echo "🛑 停止服務: docker stack rm worker-stack"
echo "=========================================="