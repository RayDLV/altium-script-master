@echo off
title Script Manager - Avvio come Amministratore
echo Avvio Script Manager ...
echo.

:: Controlla se Python è installato
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRORE: Python non trovato nel PATH del sistema.
    echo Assicurati che Python sia installato e nel PATH.
    pause
    exit /b 1
)

set SCRIPT_PATH=%~dp0script_manager.py

:: Controlla se il file Python esiste
if not exist "%SCRIPT_PATH%" (
    echo ERRORE: File script_manager.py non trovato nella directory corrente.
    echo Directory corrente: %~dp0
    pause
    exit /b 1
)

:: Controlla se è già in modalità amministratore
echo Controllo permessi amministratore...
openfiles >nul 2>&1
if %errorlevel%==0 (
    echo Esecuzione come amministratore confermata.
    echo Avvio Script Manager...
    echo.
    python "%SCRIPT_PATH%"
    echo.
    echo Script terminato. Premi un tasto per chiudere...
    pause >nul
) else (
    echo Permessi amministratore richiesti. Rilancio come amministratore...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
) 