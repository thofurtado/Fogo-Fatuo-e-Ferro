@echo off
title Fogo-Fatuo & Ferro
cd /d "%~dp0"

set "GODOT_EXE="

if exist "%LOCALAPPDATA%\Programs\Godot\Godot_v4.3-stable_win64.exe" (
    set "GODOT_EXE=%LOCALAPPDATA%\Programs\Godot\Godot_v4.3-stable_win64.exe"
) else (
    where godot >nul 2>&1 && for /f "delims=" %%i in ('where godot') do set "GODOT_EXE=%%i"
)

if "%GODOT_EXE%"=="" (
    echo [ERRO] Godot 4.3 nao foi encontrado no caminho padrao.
    echo Abra o Godot 4 e selecione esta pasta de projeto.
    pause
    exit /b 1
)

if not exist ".godot\imported" (
    echo [Fogo-Fatuo ^& Ferro] Primeira execucao detectada. Importando texturas e arte...
    "%GODOT_EXE%" --headless --editor --quit --path .
)

start "" "%GODOT_EXE%" --path .
exit
