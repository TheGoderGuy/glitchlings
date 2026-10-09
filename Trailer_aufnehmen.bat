@echo off
rem Nimmt den Trailer auf (09.10.2026): build\trailer\Glitchlings_Trailer_DE.avi und _EN.avi, 1920x1080, 60 Bilder/s.
rem Godot nimmt in der Projektauflösung auf. override.cfg hebt sie nur für die Aufnahme auf 1920x1080 (das Spiel selbst
rem läuft im Trailer weiter in 640x360 und wird pixelgenau dreifach vergrößert) und wird danach sofort wieder gelöscht.
cd /d "%~dp0game"
if not exist "..\build\trailer" mkdir "..\build\trailer"
set GODOT="C:\Users\zereb\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
(echo [display]& echo window/size/viewport_width=1920& echo window/size/viewport_height=1080) > override.cfg
%GODOT% --path . --write-movie "..\build\trailer\Glitchlings_Trailer_DE.avi" --fixed-fps 60 --resolution 1920x1080 -- --play=trailer --lang=de
%GODOT% --path . --write-movie "..\build\trailer\Glitchlings_Trailer_EN.avi" --fixed-fps 60 --resolution 1920x1080 -- --play=trailer --lang=en
del override.cfg
echo Fertig: build\trailer
if "%1"=="" pause
