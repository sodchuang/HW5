# Manager端 PostgreSQL 連線測試程式
# 用於連接到 Worker 端的 PostgreSQL 資料庫

import psycopg2
import psycopg2.extras
from datetime import datetime
import json
import sys

class NameManager:
    def __init__(self):
        # Worker 端連線設定
        self.config = {
            'host': '192.168.0.34',        # Worker 端 IP
            'port': 5432,                   # PostgreSQL 端口
            'database': 'worker_names',     # 資料庫名稱
            'user': 'worker',               # 使用者名稱
            'password': 'worker_password'   # 密碼
        }
        self.connection = None
    
    def connect(self):
        """連接到 Worker 端資料庫"""
        try:
            print(f"🔄 連接到 Worker 端資料庫...")
            print(f"   主機: {self.config['host']}:{self.config['port']}")
            print(f"   資料庫: {self.config['database']}")
            
            self.connection = psycopg2.connect(**self.config)
            self.connection.autocommit = True
            
            # 測試連線
            cursor = self.connection.cursor()
            cursor.execute("SELECT version();")
            version = cursor.fetchone()[0]
            cursor.close()
            
            print(f"✅ 連線成功!")
            print(f"   PostgreSQL 版本: {version}")
            return True
            
        except psycopg2.Error as e:
            print(f"❌ 連線失敗: {e}")
            return False
        except Exception as e:
            print(f"❌ 未知錯誤: {e}")
            return False
    
    def get_all_names(self):
        """取得所有姓名記錄"""
        if not self.connection:
            print("❌ 尚未連接到資料庫")
            return []
            
        try:
            cursor = self.connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            cursor.execute("SELECT * FROM names ORDER BY created_at DESC;")
            records = cursor.fetchall()
            cursor.close()
            
            print(f"📋 找到 {len(records)} 筆姓名記錄:")
            for record in records:
                print(f"   ID: {record['id']}, 姓名: {record['name']}, 建立時間: {record['created_at']}")
            
            return records
            
        except psycopg2.Error as e:
            print(f"❌ 查詢失敗: {e}")
            return []
    
    def add_name(self, name):
        """新增姓名記錄"""
        if not self.connection:
            print("❌ 尚未連接到資料庫")
            return False
            
        try:
            cursor = self.connection.cursor()
            cursor.execute(
                "INSERT INTO names (name) VALUES (%s) RETURNING id;",
                (name,)
            )
            new_id = cursor.fetchone()[0]
            cursor.close()
            
            print(f"✅ 成功新增姓名: '{name}' (ID: {new_id})")
            return new_id
            
        except psycopg2.Error as e:
            print(f"❌ 新增失敗: {e}")
            return False
    
    def search_names(self, keyword):
        """搜尋姓名"""
        if not self.connection:
            print("❌ 尚未連接到資料庫")
            return []
            
        try:
            cursor = self.connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            cursor.execute(
                "SELECT * FROM names WHERE name ILIKE %s ORDER BY created_at DESC;",
                (f'%{keyword}%',)
            )
            records = cursor.fetchall()
            cursor.close()
            
            print(f"🔍 搜尋 '{keyword}' 找到 {len(records)} 筆記錄:")
            for record in records:
                print(f"   ID: {record['id']}, 姓名: {record['name']}, 建立時間: {record['created_at']}")
            
            return records
            
        except psycopg2.Error as e:
            print(f"❌ 搜尋失敗: {e}")
            return []
    
    def get_statistics(self):
        """取得統計資訊"""
        if not self.connection:
            print("❌ 尚未連接到資料庫")
            return None
            
        try:
            cursor = self.connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            cursor.execute("SELECT * FROM name_statistics;")
            stats = cursor.fetchone()
            cursor.close()
            
            if stats:
                print("📊 資料庫統計:")
                print(f"   總記錄數: {stats['total_names']}")
                print(f"   最後更新: {stats['last_updated']}")
            
            return stats
            
        except psycopg2.Error as e:
            print(f"❌ 統計查詢失敗: {e}")
            return None
    
    def disconnect(self):
        """關閉連線"""
        if self.connection:
            self.connection.close()
            self.connection = None
            print("🔌 已關閉資料庫連線")


def main():
    """主程式"""
    print("=" * 60)
    print("🏢 Manager 端 - 姓名管理系統")
    print("連接到 Worker 端 PostgreSQL 資料庫")
    print("=" * 60)
    
    # 建立管理器實例
    manager = NameManager()
    
    # 連接到資料庫
    if not manager.connect():
        print("\n❌ 無法連接到 Worker 端資料庫，請檢查:")
        print("   1. Worker 端 PostgreSQL 服務是否運行")
        print("   2. 網路連線是否正常")
        print("   3. 防火牆設定是否正確")
        print("   4. PostgreSQL 設定檔是否允許遠端連線")
        sys.exit(1)
    
    try:
        # 顯示統計資訊
        print("\n" + "=" * 40)
        manager.get_statistics()
        
        # 顯示所有姓名
        print("\n" + "=" * 40)
        manager.get_all_names()
        
        # 互動式操作
        print("\n" + "=" * 40)
        print("🎮 互動式操作 (輸入 'exit' 結束):")
        
        while True:
            print("\n選項:")
            print("  1. 新增姓名 (add <姓名>)")
            print("  2. 搜尋姓名 (search <關鍵字>)")
            print("  3. 顯示所有姓名 (list)")
            print("  4. 顯示統計 (stats)")
            print("  5. 結束程式 (exit)")
            
            cmd = input("\n請輸入指令: ").strip()
            
            if cmd.lower() == 'exit':
                break
            elif cmd.lower() == 'list':
                manager.get_all_names()
            elif cmd.lower() == 'stats':
                manager.get_statistics()
            elif cmd.startswith('add '):
                name = cmd[4:].strip()
                if name:
                    manager.add_name(name)
                else:
                    print("❌ 請提供姓名")
            elif cmd.startswith('search '):
                keyword = cmd[7:].strip()
                if keyword:
                    manager.search_names(keyword)
                else:
                    print("❌ 請提供搜尋關鍵字")
            else:
                print("❌ 無效指令，請重試")
    
    except KeyboardInterrupt:
        print("\n\n⚠️  程式被使用者中斷")
    
    finally:
        manager.disconnect()
        print("\n👋 感謝使用 Manager 端姓名管理系統!")


if __name__ == "__main__":
    main()