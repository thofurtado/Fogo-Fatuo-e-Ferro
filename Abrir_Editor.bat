@echo off
title Editor Godot - Fogo-Fatuo e Ferro
cd /d "%~dp0"
set GODOT="%LOCALAPPDATA%\Programs\Godot\Godot_v4.3-stable_win64.exe"

if exist %GODOT% (
    start "" %GODOT% -e --path .
) else (
    echo [ERRO] Executavel do Godot 4 nao encontrado em: %GODOT%
    pause
)