@echo off
echo =======================================================
echo    Instalando dependencias del Proyecto TAG OK
echo =======================================================
echo.

echo [1/2] Instalando dependencias de la app principal (tag_ok)...
cd Producto\tag_ok
call flutter pub get
cd ..\..
echo.

echo [2/2] Instalando dependencias del panel de administrador (admin)...
cd Producto\admin
call flutter pub get
cd ..\..
echo.

echo =======================================================
echo    Instalacion completada con exito!
echo =======================================================
echo IMPORTANTE: No olvides crear tus archivos .env en:
echo 1. Producto\tag_ok\.env
echo 2. Producto\admin\.env
echo.
pause
