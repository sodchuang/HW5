# Worker PostgreSQL Database Test Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Worker PostgreSQL Database Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if PostgreSQL service is running
Write-Host "🔍 Checking PostgreSQL service status..." -ForegroundColor Yellow

try {
    $services = docker service ls --filter "name=worker-db-stack_postgres-db" --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}"
    
    if ($services -match "worker-db-stack_postgres-db") {
        Write-Host "✅ PostgreSQL service is running" -ForegroundColor Green
        Write-Host $services
    } else {
        Write-Host "❌ PostgreSQL service not found" -ForegroundColor Red
        Write-Host "Please run .\deploy-clean.ps1 to deploy the database" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Cannot check service status: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Get container ID
Write-Host "🔍 Getting PostgreSQL container..." -ForegroundColor Yellow
try {
    $containerId = docker ps -q -f "name=postgres-db"
    if (-not $containerId) {
        Write-Host "❌ PostgreSQL container not found" -ForegroundColor Red
        Write-Host "Waiting for container to start..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        $containerId = docker ps -q -f "name=postgres-db"
        if (-not $containerId) {
            Write-Host "❌ Still no PostgreSQL container found" -ForegroundColor Red
            exit 1
        }
    }
    Write-Host "✅ Found PostgreSQL container: $containerId" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to get container ID: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test database connection
Write-Host "🔌 Testing database connection..." -ForegroundColor Yellow
try {
    $result = docker exec $containerId psql -U worker -d worker_names -c "\l" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database connection successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Database connection failed" -ForegroundColor Red
        Write-Host $result
        exit 1
    }
} catch {
    Write-Host "❌ Connection test failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check database tables
Write-Host "📋 Checking database structure..." -ForegroundColor Yellow
try {
    Write-Host "Database tables:" -ForegroundColor Cyan
    docker exec $containerId psql -U worker -d worker_names -c "\dt"
    
    Write-Host "`nNames table structure:" -ForegroundColor Cyan  
    docker exec $containerId psql -U worker -d worker_names -c "\d names"
    
    Write-Host "`nRecord count:" -ForegroundColor Cyan
    docker exec $containerId psql -U worker -d worker_names -c "SELECT COUNT(*) as total_records FROM names;"
    
} catch {
    Write-Host "❌ Failed to check database structure: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Show sample data
Write-Host "📊 Sample data..." -ForegroundColor Yellow
try {
    Write-Host "First 5 records from names table:" -ForegroundColor Cyan
    docker exec $containerId psql -U worker -d worker_names -c "SELECT * FROM names ORDER BY created_at DESC LIMIT 5;"
} catch {
    Write-Host "❌ Failed to query data: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Display connection information
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔌 PostgreSQL Connection Information" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Host: localhost (or Lab Machine IP)" -ForegroundColor White
Write-Host "Port: 5432" -ForegroundColor White  
Write-Host "Database: worker_names" -ForegroundColor White
Write-Host "User: worker" -ForegroundColor White
Write-Host "Password: worker_password" -ForegroundColor White
Write-Host "Data Path: ./postgres-data" -ForegroundColor White
Write-Host ""
Write-Host "Connection String Example:" -ForegroundColor Yellow
Write-Host "postgresql://worker:worker_password@localhost:5432/worker_names" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Manager can use this connection information to connect to the database" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan