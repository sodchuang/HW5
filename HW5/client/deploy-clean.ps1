# Worker PostgreSQL Database Deployment Script

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Worker PostgreSQL Database Deployment" -ForegroundColor Cyan  
Write-Host "Lab Machine Database Service Only" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

# Check Docker status
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop" -ForegroundColor Red
    exit 1
}

# Check Docker Swarm status
$swarmStatus = docker info | Select-String "Swarm: active"
if (-not $swarmStatus) {
    Write-Host "🔄 Initializing Docker Swarm..." -ForegroundColor Yellow
    docker swarm init --advertise-addr 127.0.0.1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker Swarm initialized successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker Swarm initialization failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Docker Swarm is active" -ForegroundColor Green
}

# Create PostgreSQL data directory
Write-Host "🔄 Creating PostgreSQL data directory..." -ForegroundColor Yellow
if (-not (Test-Path "postgres-data")) {
    New-Item -ItemType Directory -Path "postgres-data" -Force | Out-Null
    Write-Host "✅ PostgreSQL data directory created: ./postgres-data" -ForegroundColor Green
} else {
    Write-Host "✅ PostgreSQL data directory already exists" -ForegroundColor Green
}

# Clean up old services if they exist
$existingStack = docker stack ls | Select-String "worker-db-stack"
if ($existingStack) {
    Write-Host "🔄 Cleaning up old database services..." -ForegroundColor Yellow
    docker stack rm worker-db-stack
    Write-Host "⏳ Waiting for services to be completely removed..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
}

# Deploy PostgreSQL database service
Write-Host "🔄 Deploying Worker database service..." -ForegroundColor Yellow
docker stack deploy -c docker-compose-hw5.yml worker-db-stack

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Service deployment successful" -ForegroundColor Green
} else {
    Write-Host "❌ Service deployment failed" -ForegroundColor Red
    exit 1
}

# Wait for service to start
Write-Host "⏳ Waiting for service to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Check service status
Write-Host "🔍 Checking service status..." -ForegroundColor Yellow
docker service ls

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✅ Worker Database Deployment Complete!" -ForegroundColor Green
Write-Host "🗄️  PostgreSQL Database: localhost:5432" -ForegroundColor Cyan
Write-Host "📋 Database Name: worker_names" -ForegroundColor Cyan
Write-Host "👤 Username: worker" -ForegroundColor Cyan
Write-Host "🔑 Password: worker_password" -ForegroundColor Cyan
Write-Host "📂 Data Storage: ./postgres-data" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host "📊 Check Status: docker service ls" -ForegroundColor Cyan
Write-Host "📝 View Logs: docker service logs worker-db-stack_postgres-db" -ForegroundColor Cyan
Write-Host "🔧 Test Connection: .\test-db.ps1" -ForegroundColor Cyan
Write-Host "🛑 Stop Service: docker stack rm worker-db-stack" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "💡 Note: This Worker only provides database service." -ForegroundColor Yellow
Write-Host "   Manager needs to connect to this database for Web and API services." -ForegroundColor Yellow