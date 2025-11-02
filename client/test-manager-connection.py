#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
簡單的 Manager 端連線測試
測試連接到 Worker 端 PostgreSQL 資料庫
"""

import socket
import sys

def test_tcp_connection(host, port):
    """測試 TCP 連線"""
    try:
        print(f"🔄 測試 TCP 連線到 {host}:{port}...")
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        result = sock.connect_ex((host, port))
        sock.close()
        
        if result == 0:
            print(f"✅ TCP 連線成功!")
            return True
        else:
            print(f"❌ TCP 連線失敗 (錯誤碼: {result})")
            return False
            
    except Exception as e:
        print(f"❌ 連線測試失敗: {e}")
        return False

def test_postgresql_connection():
    """測試 PostgreSQL 連線"""
    try:
        import psycopg2
        print("✅ psycopg2 套件已安裝")
    except ImportError:
        print("❌ psycopg2 套件未安裝，請執行: pip install psycopg2-binary")
        return False
    
    # 連線設定
    config = {
        'host': '192.168.0.34',
        'port': 5432,
        'database': 'worker_names',
        'user': 'worker',
        'password': 'worker_password'
    }
    
    try:
        print(f"🔄 連接到 PostgreSQL...")
        print(f"   主機: {config['host']}:{config['port']}")
        print(f"   資料庫: {config['database']}")
        
        conn = psycopg2.connect(**config)
        cursor = conn.cursor()
        
        # 測試查詢
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        print(f"✅ PostgreSQL 連線成功!")
        print(f"   版本: {version}")
        
        # 測試資料查詢
        cursor.execute("SELECT COUNT(*) FROM names;")
        count = cursor.fetchone()[0]
        print(f"   資料表記錄數: {count}")
        
        # 顯示一些範例資料
        cursor.execute("SELECT id, name, created_at FROM names LIMIT 3;")
        records = cursor.fetchall()
        print("   範例資料:")
        for record in records:
            print(f"     ID: {record[0]}, 姓名: {record[1]}, 時間: {record[2]}")
        
        cursor.close()
        conn.close()
        return True
        
    except psycopg2.Error as e:
        print(f"❌ PostgreSQL 連線失敗: {e}")
        return False
    except Exception as e:
        print(f"❌ 未知錯誤: {e}")
        return False

def main():
    print("=" * 60)
    print("🏢 Manager 端連線測試")
    print("測試連接到 Worker 端 (192.168.0.34:5432)")
    print("=" * 60)
    
    # 測試 TCP 連線
    if not test_tcp_connection('192.168.0.34', 5432):
        print("\n⚠️  TCP 連線失敗，可能的原因:")
        print("   1. Worker 端 PostgreSQL 服務未運行")
        print("   2. 網路無法連通")
        print("   3. 防火牆阻擋連線")
        return False
    
    print()
    
    # 測試 PostgreSQL 連線
    if not test_postgresql_connection():
        print("\n⚠️  PostgreSQL 連線失敗，可能的原因:")
        print("   1. PostgreSQL 認證設定問題")
        print("   2. 資料庫設定不允許遠端連線")
        print("   3. pg_hba.conf 設定問題")
        return False
    
    print("\n" + "=" * 60)
    print("🎉 所有測試通過！Manager 端可以正常連接到 Worker 端")
    print("=" * 60)
    return True

if __name__ == "__main__":
    try:
        success = main()
        if not success:
            sys.exit(1)
    except KeyboardInterrupt:
        print("\n\n⚠️  測試被使用者中斷")
        sys.exit(1)