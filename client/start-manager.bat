@echo off
title Manager端 - Worker數據庫連線工具

echo ==========================================
echo  Manager端 - Worker數據庫連線工具
echo ==========================================
echo.

:menu
echo 請選擇操作:
echo 1. 執行網路連線測試
echo 2. 安裝 PostgreSQL 驅動程式
echo 3. 啟動 Manager 客戶端
echo 4. 檢查防火牆狀態
echo 5. 配置防火牆 (需要管理員權限)
echo 6. 顯示說明文件
echo 0. 退出
echo.
set /p choice=輸入選項 (0-6): 

if "%choice%"=="1" goto network_test
if "%choice%"=="2" goto install_driver
if "%choice%"=="3" goto start_client
if "%choice%"=="4" goto check_firewall
if "%choice%"=="5" goto setup_firewall
if "%choice%"=="6" goto show_readme
if "%choice%"=="0" goto exit
goto menu

:network_test
echo.
echo 執行網路連線測試...
python network-test.py
pause
goto menu

:install_driver
echo.
echo 安裝 PostgreSQL 驅動程式...
pip install psycopg2-binary
pause
goto menu

:start_client
echo.
echo 啟動 Manager 客戶端...
python manager-client.py
pause
goto menu

:check_firewall
echo.
echo 檢查防火牆狀態...
powershell -ExecutionPolicy Bypass -File "check-firewall.ps1"
pause
goto menu

:setup_firewall
echo.
echo 配置防火牆 (需要管理員權限)...
echo 請以管理員身份執行此選項
powershell -ExecutionPolicy Bypass -File "setup-firewall-admin.ps1"
pause
goto menu

:show_readme
echo.
type README-Manager.md
pause
goto menu

:exit
echo.
echo 感謝使用 Manager端 連線工具!
exit