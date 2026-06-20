@echo off
echo =======================================================
echo    Instalando dependencias del Proyecto TAG OK
echo =======================================================
echo.

REM Moverse al directorio donde esta guardado este archivo (Producto)
cd /d "%~dp0"

echo [1/2] Instalando dependencias de la app principal (tag_ok)...
cd tag_ok
call flutter pub get
cd ..
echo.

echo [2/2] Instalando dependencias del panel de administrador (admin)...
cd admin
call flutter pub get
cd ..
echo.

echo =======================================================
echo    Instalacion completada con exito!
echo =======================================================
echo IMPORTANTE: Ya no necesitas configurar .env para tag_ok,
echo pero verifica si 'admin' necesita configuraciones.
echo.
pause
