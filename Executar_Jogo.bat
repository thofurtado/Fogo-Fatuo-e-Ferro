@echo off
title Fogo-Fatuo e Ferro - Teste
cd /d "%~dp0"
set GODOT="%LOCALAPPDATA%\Programs\Godot\Godot_v4.3-stable_win64.exe"

if exist %GODOT% (
    start "" %GODOT% --path .
) else (
    echo [ERRO] Executavel do Godot 4 nao encontrado em: %GODOT%
    pause
)