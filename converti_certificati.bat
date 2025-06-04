@echo off
title Convertitore Certificati TXT -> PDF
echo Avvio Convertitore Certificati...
echo.

:: Controlla se Python è installato
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRORE: Python non trovato nel PATH del sistema.
    echo Assicurati che Python sia installato e nel PATH.
    pause
    exit /b 1
)

set SCRIPT_PATH=%~dp0converti_certificati_pdf.py

:: Controlla se il file Python esiste
if not exist "%SCRIPT_PATH%" (
    echo ERRORE: File converti_certificati_pdf.py non trovato nella directory corrente.
    echo Directory corrente: %~dp0
    pause
    exit /b 1
)

:: Esegui lo script Python
echo Avvio conversione certificati...
echo.
python "%SCRIPT_PATH%"

echo.
echo Script terminato.
pause 