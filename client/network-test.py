# -*- coding: utf-8 -*-
"""
Manager端 網路連線測試腳本
測試到 Worker 端的連線狀態
"""

import socket
import sys

def test_tcp_connection(host, port):
    """測試 TCP 連線"""
    print(f"Testing TCP connection to {host}:{port}")
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        result = sock.connect_ex((host, port))
        sock.close()
        
        if result == 0:
            print("SUCCESS: TCP connection established")
            return True
        else:
            print(f"FAILED: TCP connection failed (error code: {result})")
            return False
    except Exception as e:
        print(f"ERROR: {e}")
        return False

def main():
    print("=" * 50)
    print("Manager端 Network Connectivity Test")
    print("Target: Worker PostgreSQL Database")
    print("=" * 50)
    
    # Worker端設定
    worker_host = '192.168.0.34'
    worker_port = 5432
    
    print(f"Host: {worker_host}")
    print(f"Port: {worker_port}")
    print("-" * 30)
    
    # 執行測試
    if test_tcp_connection(worker_host, worker_port):
        print("\n[PASS] Network connectivity test passed!")
        print("Next steps:")
        print("1. Install PostgreSQL client: pip install psycopg2-binary")
        print("2. Use the provided manager-client.py script")
        
        print("\nConnection Details:")
        print(f"  Host: {worker_host}")
        print(f"  Port: {worker_port}")
        print("  Database: worker_names")
        print("  Username: worker")
        print("  Password: worker_password")
        
    else:
        print("\n[FAIL] Network connectivity test failed!")
        print("Troubleshooting steps:")
        print("1. Check if Worker PostgreSQL is running")
        print("2. Verify network connectivity between Manager and Worker")
        print("3. Check firewall settings on Worker machine")
        print("4. Verify Docker Swarm service status")
    
    print("\n" + "=" * 50)

if __name__ == "__main__":
    main()