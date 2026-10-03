@echo off
title Editor Godot - Fogo-Fatuo e Ferro
cd /d "%~dp0"

set "GODOT="
if exist "%USERPROFILE%\Documents\GODOT\Godot_v4.7.2-stable_win64.exe" set "GODOT=%USERPROFILE%\Documents\GODOT\Godot_v4.7.2-stable_win64.exe"
if exist "%LOCALAPPDATA%\Programs\Godot\Godot_v4.3-stable_win64.exe" set "GODOT=%LOCALAPPDATA%\Programs\Godot\Godot_v4.3-stable_win64.exe"
if "%GODOT%"=="" (
    where godot >nul 2>&1 && for /f "delims=" %%i in ('where godot') do set "GODOT=%%i"
)

if not "%GODOT%"=="" (
    start "" "%GODOT%" -e --path .
) else (
    echo [ERRO] Executavel do Godot 4 nao encontrado.
    pause
)