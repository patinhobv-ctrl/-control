@echo off
chcp 65001 >nul 2>nul
title Stock Control - Servidor Local
echo ============================================
echo   STOCK CONTROL - Servidor Local
echo   Control de Envios entre Sucursales
echo ============================================
echo.

:: Verificar PHP
where php >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] PHP no encontrado en el PATH.
    echo.
    echo Descarga PHP desde: https://windows.php.net/download/
    echo O instala con: winget install PHP.PHP.8.2
    echo Luego reinicia esta terminal.
    pause
    exit /b 1
)

:: Verificar Composer
where composer >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Composer no encontrado.
    echo Instala con: winget install Composer.Composer
    pause
    exit /b 1
)

echo [1/6] Instalando dependencias de PHP...
call composer install --no-interaction --prefer-dist

if not exist .env (
    echo [2/6] Creando archivo .env...
    copy .env.example .env >nul
)

echo [3/6] Generando clave de aplicacion...
call php artisan key:generate

echo [4/6] Creando base de datos...
where mysql >nul 2>nul
if %errorlevel% equ 0 (
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS stock_control CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>nul
    if %errorlevel% equ 0 (
        echo       Base de datos stock_control lista.
    ) else (
        echo [AVISO] No se pudo crear la BD. Crela manualmente: CREATE DATABASE stock_control;
    )
) else (
    echo [AVISO] MySQL no encontrado en PATH. Crea la BD manualmente.
)

echo [5/6] Ejecutando migraciones y seeders...
call php artisan migrate --force
call php artisan db:seed --force

echo [6/6] Limpiando caché...
call php artisan config:clear
call php artisan cache:clear
call php artisan route:clear
call php artisan view:clear

echo.
echo ============================================
echo   SERVIDOR LISTO
echo ============================================
echo.
echo   URL:        http://localhost:8000
echo   API:        http://localhost:8000/api
echo   Login:      admin@empresa.com
echo   Password:   password
echo.
echo   Sucursales: 15 configuradas
echo   Productos:  45+ con stock inicial
echo   Roles:      Super Admin, Gerente, Admin, Operador, Auditor
echo.
echo ============================================
echo   PRESIONA CTRL+C PARA DETENER
echo ============================================
echo.

call php artisan serve --host=0.0.0.0 --port=8000

pause