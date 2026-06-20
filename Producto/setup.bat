@echo off
setlocal enabledelayedexpansion

echo =======================================================
echo    Configuracion y Ejecucion del Proyecto TAG OK
echo =======================================================
echo.

rem Ir al directorio donde se encuentra este script
cd /d "%~dp0"

echo [1/2] Instalar/Actualizar dependencias del proyecto...
echo.
echo Instalando dependencias de la app principal (tag_ok)...
cd tag_ok
call flutter pub get
cd ..

echo.
echo Instalando dependencias del panel de administrador (admin)...
cd admin
call flutter pub get
cd ..

echo.
echo =======================================================
echo    Instalacion y configuracion completadas con exito!
echo =======================================================
echo (Nota: Las claves de Firebase y Gemini se cargan en 
echo  memoria automaticamente. ¡No necesitas archivos .env!)
echo.

rem 2. Menu de ejecucion
:menu
echo Selecciona la aplicacion que deseas ejecutar:
echo 1) App Principal (tag_ok) - Ejecutar en Windows Desktop
echo 2) App Principal (tag_ok) - Ejecutar en Chrome (Web)
echo 3) Panel Administrador (admin) - Ejecutar en Windows Desktop
echo 4) Panel Administrador (admin) - Ejecutar en Chrome (Web)
echo 5) Salir
echo.
set /p opcion="Introduce el numero de tu opcion (1-5): "

if "%opcion%"=="1" (
    echo Ejecutando App Principal (tag_ok) en Windows...
    cd tag_ok
    flutter run -d windows
    cd ..
    goto menu
)
if "%opcion%"=="2" (
    echo Ejecutando App Principal (tag_ok) en Chrome...
    cd tag_ok
    flutter run -d chrome
    cd ..
    goto menu
)
if "%opcion%"=="3" (
    echo Ejecutando Panel Administrador (admin) en Windows...
    cd admin
    flutter run -d windows
    cd ..
    goto menu
)
if "%opcion%"=="4" (
    echo Ejecutando Panel Administrador (admin) en Chrome...
    cd admin
    flutter run -d chrome
    cd ..
    goto menu
)
if "%opcion%"=="5" (
    echo Saliendo del script. ¡Adios!
    pause
    exit /b 0
)

echo Opcion no valida, por favor intenta de nuevo.
echo.
goto menu

