@echo off
echo Cleaning files ...
echo.
del *.~* /s/q >nul 2>&1
del *.local /s/q >nul 2>&1
del *.identcache /s/q >nul 2>&1
del *.dcu /s/q >nul 2>&1
del *.exe /s/q >nul 2>&1

echo Removing build folders ...
echo.
for /d /r . %%d in (__history Debug Release) do @if exist "%%d" echo "%%d" && rd /s/q "%%d"
echo Done!