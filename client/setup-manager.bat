@echo off
echo ===============================================
echo Manager 端環境設定
echo ===============================================

echo.
echo 安裝 PostgreSQL 連線套件...
pip install psycopg2-binary

echo.
echo 測試連線...
python manager-client.py

echo.
echo 設定完成！
pause