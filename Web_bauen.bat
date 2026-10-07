@echo off
rem Baut die Web-Testversion (nur Cache-Wiesen + Firewall-Vulkan) nach build\web und packt sie als ZIP fuer itch.io
cd /d "%~dp0game"
if exist "..\build\web" rmdir /s /q "..\build\web"
mkdir "..\build\web"
"C:\Users\zereb\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --export-release "Web" "..\build\web\index.html"
copy /Y tools\LIZENZEN.txt "..\build\web\LIZENZEN.txt"
powershell -NoProfile -Command "Compress-Archive -Force -Path ..\build\web\* -DestinationPath ..\build\Glitchlings_Web.zip"
echo Fertig: build\Glitchlings_Web.zip (auf itch.io als HTML-Spiel hochladen)
echo Lokal testen: node tools\webserver.js, dann http://localhost:8124 im Browser oeffnen
if "%1"=="" pause
