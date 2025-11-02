# -*- coding: utf-8 -*-
"""Manager端 PostgreSQL 連線測試"""

import socket

def test_connection():
    print("Manager端連線測試")
    print("目標: 192.168.0.34:5432")
    
    try:
        # TCP 連線測試
        print("正在測試 TCP 連線...")
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        result = sock.connect_ex(('192.168.0.34', 5432))
        sock.close()
        
        if result == 0:
            print("TCP 連線成功!")
        else:
            print(f"TCP 連線失敗 (錯誤碼: {result})")
            return False
        
        # PostgreSQL 連線測試
        try:
            import psycopg2
            print("psycopg2 套件已安裝")
        except ImportError:
            print("需要安裝 psycopg2: pip install psycopg2-binary")
            return False
        
        print("正在連接 PostgreSQL...")
        conn = psycopg2.connect(
            host='192.168.0.34',
            port=5432,
            database='worker_names',
            user='worker',
            password='worker_password'
        )
        
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM names;")
        count = cursor.fetchone()[0]
        print(f"連線成功! 找到 {count} 筆資料")
        
        cursor.execute("SELECT name FROM names LIMIT 3;")
        names = cursor.fetchall()
        print("範例資料:")
        for name in names:
            print(f"  - {name[0]}")
        
        cursor.close()
        conn.close()
        print("測試完成!")
        return True
        
    except Exception as e:
        print(f"連線失敗: {e}")
        return False

if __name__ == "__main__":
    test_connection()