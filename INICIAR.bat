@echo off
chcp 65001 >nul 2>nul
title StockControl - Iniciando...
echo ============================================
echo   STOCK CONTROL - Iniciando Servidor
echo ============================================
echo.

set PROJECT_DIR=%~dp0
cd /d "%PROJECT_DIR%"

set PHP_PATH=C:\Users\User\AppData\Local\Microsoft\WinGet\Packages\PHP.PHP.8.2_Microsoft.Winget.Source_8wekyb3d8bbwe
set PATH=%PHP_PATH%;%PATH%

:: Verificar si ya hay servidor corriendo en puerto 8000
netstat -ano | findstr :8000 >nul
if %errorlevel% equ 0 (
    echo [INFO] Servidor ya corriendo en puerto 8000
) else (
    echo [1/3] Iniciando servidor PHP...
    start /B "" "%PHP_PATH%\php.exe" artisan serve --host=0.0.0.0 --port=8000
    
    echo [2/3] Esperando a que el servidor responda...
    :wait
    timeout /t 2 /nobreak >nul
    curl -s -o nul -w "%%{http_code}" http://localhost:8000/up 2>nul | findstr "200" >nul
    if %errorlevel% neq 0 goto wait
    echo [OK] Servidor listo
)

echo [3/3] Abriendo dashboard en el navegador...
start "" "http://localhost:8000/dashboard.html"

echo.
echo ============================================
echo   STOCKCONTROL LISTO
echo ============================================
echo.
echo   Dashboard:  http://localhost:8000/dashboard.html
echo   API:        http://localhost:8000/api
echo   Login:      admin@empresa.com / password
echo.
echo   Cierra esta ventana para detener el servidor
echo ============================================
echo.

:: Mantener ventana abierta
pause