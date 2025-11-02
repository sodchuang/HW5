#!/usr/bin/env python3
import psycopg2
import sys

def test_connection():
    # Manager 連接參數
    connection_params = {
        'host': '192.168.0.34',  # Worker IP
        'port': 5432,
        'database': 'worker_names',
        'user': 'worker',
        'password': 'worker_password'
    }
    
    print("🔌 Testing PostgreSQL connection from Manager to Worker...")
    print(f"   Host: {connection_params['host']}")
    print(f"   Port: {connection_params['port']}")
    print(f"   Database: {connection_params['database']}")
    print(f"   User: {connection_params['user']}")
    
    try:
        # 建立連接
        conn = psycopg2.connect(**connection_params)
        cursor = conn.cursor()
        
        print("✅ Connection successful!")
        
        # 測試查詢
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        print(f"📋 PostgreSQL Version: {version}")
        
        cursor.execute("SELECT COUNT(*) FROM names;")
        count = cursor.fetchone()[0]
        print(f"📊 Records in names table: {count}")
        
        cursor.execute("SELECT name FROM names ORDER BY created_at DESC LIMIT 3;")
        names = cursor.fetchall()
        print("📝 Sample names:")
        for name in names:
            print(f"   - {name[0]}")
        
        cursor.close()
        conn.close()
        print("✅ All tests passed! Manager can connect to Worker successfully!")
        
        return True
        
    except Exception as e:
        print(f"❌ Connection failed: {str(e)}")
        return False

if __name__ == "__main__":
    success = test_connection()
    sys.exit(0 if success else 1)