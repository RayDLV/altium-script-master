#!/usr/bin/env python3
"""
Script che utilizza PyAltiumRun per eseguire script DelphiScript in Altium Designer
"""

import sys
import os
import time
import subprocess
from pathlib import Path

def wait_for_input():
    """Aspetta input dall'utente prima di chiudere."""
    try:
        input("Premi INVIO per continuare...")
    except:
        pass

def install_pyaltiumrun():
    """Installa PyAltiumRun se non è presente."""
    print("Tentativo di installazione di PyAltiumRun...")
    try:
        import subprocess
        result = subprocess.run([sys.executable, "-m", "pip", "install", "PyAltiumRun"], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print("PyAltiumRun installato.")
            return True
        else:
            print(f"Errore nell'installazione: {result.stderr}")
            return False
    except Exception as e:
        print(f"Errore durante l'installazione: {e}")
        return False

def find_altium_processes():
    """Trova tutti i processi Altium in esecuzione."""
    altium_processes = []
    try:
        import psutil
        print("  Cercando processi Altium...")
        for proc in psutil.process_iter(['pid', 'name', 'exe']):
            try:
                proc_name = proc.info['name']
                if proc_name:
                    proc_name_lower = proc_name.lower()
                    # Cerca vari nomi possibili per Altium Designer
                    altium_keywords = ['altium', 'dxp', 'x2', 'designer']
                    if any(keyword in proc_name_lower for keyword in altium_keywords):
                        altium_processes.append({
                            'pid': proc.info['pid'],
                            'name': proc_name,
                            'exe': proc.info['exe']
                        })
                        print(f"    Trovato: {proc_name} (PID: {proc.info['pid']})")
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                continue
        return altium_processes
    except ImportError:
        print("  Modulo psutil non disponibile - impossibile cercare processi")
        return []
    except Exception as e:
        print(f"  Errore nella ricerca processi: {e}")
        return []

def check_altium_running():
    """Verifica se Altium Designer è in esecuzione."""
    processes = find_altium_processes()
    return len(processes) > 0

def find_altium_installation():
    """Trova l'installazione di Altium Designer 25."""
    print("  Cercando installazione di Altium Designer 25...")
    
    # Percorsi comuni per Altium Designer 25
    possible_paths = [
        r"C:\Program Files\Altium\AD25\DXP.exe",
        r"C:\Program Files\Altium\AD25\X2.exe", 
        r"C:\Program Files (x86)\Altium\AD25\DXP.exe",
        r"C:\Program Files (x86)\Altium\AD25\X2.exe",
        r"C:\Program Files\Altium\AltiumDesigner25\DXP.exe",
        r"C:\Program Files\Altium\AltiumDesigner25\X2.exe",
        r"C:\Program Files (x86)\Altium\AltiumDesigner25\DXP.exe",
        r"C:\Program Files (x86)\Altium\AltiumDesigner25\X2.exe",
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            print(f"    Trovato: {path}")
            return path
    
    print("    Nessuna installazione standard trovata")
    
    # Cerca in altre possibili directory
    print("  Cercando in altre directory...")
    search_dirs = [r"C:\Program Files\Altium", r"C:\Program Files (x86)\Altium"]
    
    for search_dir in search_dirs:
        if os.path.exists(search_dir):
            print(f"    Cercando in: {search_dir}")
            try:
                for root, dirs, files in os.walk(search_dir):
                    for file in files:
                        if file.lower() in ['dxp.exe', 'x2.exe']:
                            full_path = os.path.join(root, file)
                            print(f"    Trovato: {full_path}")
                            return full_path
            except Exception as e:
                print(f"    Errore nella ricerca: {e}")
    
    return None

def launch_altium():
    """Avvia Altium Designer."""
    print("Tentativo di avvio di Altium Designer...")
    
    altium_path = find_altium_installation()
    if not altium_path:
        print("Impossibile trovare l'installazione di Altium Designer.")
        return False
    
    try:
        print(f"  Avviando: {altium_path}")
        # Avvia Altium in background
        subprocess.Popen([altium_path], shell=True)
        
        print("  Attendendo l'avvio di Altium Designer...")
        # Aspetta fino a 60 secondi che Altium si avvii
        for i in range(60):
            time.sleep(1)
            if check_altium_running():
                print(f"  Altium Designer avviato con successo! (dopo {i+1} secondi)")
                # Aspetta altri 5 secondi per essere sicuri che sia completamente caricato
                print("  Aspettando il caricamento completo...")
                time.sleep(5)
                return True
            if i % 10 == 9:  # Stampa un messaggio ogni 10 secondi
                print(f"  Ancora in attesa... ({i+1}/60 secondi)")
        
        print("  Timeout: Altium potrebbe non essersi avviato completamente.")
        return False
        
    except Exception as e:
        print(f"  Errore nell'avvio di Altium: {e}")
        return False

def find_scripts_directory():
    """Trova la directory Scripts all'interno del progetto."""
    script_dir = Path(__file__).parent.absolute()
    scripts_dir = script_dir / "Scripts"
    
    return scripts_dir if scripts_dir.exists() else None

def list_available_scripts():
    """Elenca tutti gli script DelphiScript disponibili nella cartella Scripts."""
    scripts_dir = find_scripts_directory()
    
    if not scripts_dir:
        return []
    
    # Cerca file con estensioni DelphiScript comuni
    script_extensions = ['*.pas', '*.dfm', '*.dpr']
    scripts = []
    
    for extension in script_extensions:
        scripts.extend(scripts_dir.glob(extension))
    
    # Ordina alfabeticamente
    scripts.sort(key=lambda x: x.name.lower())
    
    return scripts

def display_script_menu(scripts):
    """Visualizza il menu degli script disponibili."""
    print("\n" + "="*60)
    print("SELETTORE SCRIPT ALTIUM DESIGNER")
    print("="*60)
    
    if not scripts:
        print("Nessuno script trovato nella cartella Scripts.")
        return None
    
    print(f"Script disponibili ({len(scripts)} trovati):")
    print("-" * 40)
    
    for i, script in enumerate(scripts):
        print(f"  {i:2}. {script.name}")
    
    print("-" * 40)
    print("  q. Esci dal programma")
    print()
    
    return scripts

def get_user_selection(max_index):
    """Ottiene la selezione dell'utente."""
    while True:
        try:
            user_input = input(f"Seleziona uno script (0-{max_index}) o 'q' per uscire: ").strip().lower()
            
            if user_input == 'q':
                return None
            
            selection = int(user_input)
            if 0 <= selection <= max_index:
                return selection
            else:
                print(f"Errore: inserisci un numero tra 0 e {max_index}.")
                
        except ValueError:
            print("Errore: inserisci un numero valido o 'q' per uscire.")
        except KeyboardInterrupt:
            print("\nOperazione annullata dall'utente.")
            return None

def extract_function_name(script_path):
    """Estrae il nome della funzione principale dal file script."""
    try:
        with open(script_path, 'r', encoding='utf-8') as file:
            content = file.read().lower()
            
            # Cerca pattern comuni per funzioni DelphiScript
            import re
            
            # Cerca "procedure NomeFunzione" o "function NomeFunzione"
            patterns = [
                r'procedure\s+(\w+)',
                r'function\s+(\w+)',
            ]
            
            for pattern in patterns:
                matches = re.findall(pattern, content)
                if matches:
                    # Prendi la prima funzione trovata (di solito è quella principale)
                    return matches[0]
            
            # Se non trova niente, usa il nome del file senza estensione
            return script_path.stem
            
    except Exception as e:
        print(f"  Avviso: impossibile leggere il file script ({e}). Uso il nome del file.")
        return script_path.stem

def execute_selected_script(script_path):
    """Esegue lo script DelphiScript selezionato."""
    print(f"\nEsecuzione dello script: {script_path.name}")
    print("-" * 50)
    
    try:
        # Importa PyAltiumRun
        from PyAltiumRun.AltiumRun import AltiumRun
        
        # Crea il runner
        print("  Inizializzazione del runner PyAltiumRun...")
        runner = AltiumRun(use_internal_logger=True)
        
        # Pulisci i log precedenti
        runner.clear_log_file()
        print("  Log precedenti puliti.")
        
        # Aggiungi lo script
        script_path_abs = str(script_path.absolute())
        runner.add_script(script_path_abs)
        print(f"  Script aggiunto: {script_path.name}")
        
        # Determina il nome della funzione
        function_name = extract_function_name(script_path)
        runner.set_function(function_name)
        print(f"  Funzione impostata: {function_name}")
        
        # Esegui lo script
        print("  Invio comandi ad Altium Designer...")
        runner.run()
        
        print("  Script eseguito con successo!")
        
    except Exception as e:
        print(f"  Errore durante l'esecuzione dello script: {e}")
        return False
    
    return True

def main():
    print("PyAltiumRun - Gestore Script Altium Designer")
    print("Versione 1.0\n")
    
    # Verifica se PyAltiumRun è installato
    try:
        from PyAltiumRun.AltiumRun import AltiumRun
        print("PyAltiumRun trovato e importato correttamente.")
    except ImportError:
        print("PyAltiumRun non trovato.")
        print("Tentativo di installazione automatica...")
        if install_pyaltiumrun():
            try:
                from PyAltiumRun.AltiumRun import AltiumRun
                print("PyAltiumRun installato e importato correttamente.")
            except ImportError:
                print("Impossibile importare PyAltiumRun anche dopo l'installazione.")
                wait_for_input()
                return
        else:
            print("Installazione fallita. Installa manualmente con: pip install PyAltiumRun")
            wait_for_input()
            return
    
    # Verifica se Altium è in esecuzione
    print("\nControllo se Altium Designer è in esecuzione...")
    if not check_altium_running():
        print("Nessun processo Altium Designer trovato.")
        response = input("Vuoi che provi ad avviare Altium Designer automaticamente? (s/n): ").lower()
        if response == 's':
            if not launch_altium():
                print("Impossibile avviare Altium Designer.")
                print("Prova ad avviarlo manualmente e rilanciare questo script.")
                wait_for_input()
                return
        else:
            print("Avvia Altium Designer manualmente e rilancia questo script.")
            wait_for_input()
            return
    else:
        print("Altium Designer è in esecuzione.")
    
    # Verifica la directory Scripts
    scripts_dir = find_scripts_directory()
    if not scripts_dir:
        print(f"\nErrore: cartella 'Scripts' non trovata.")
        print(f"Crea una cartella chiamata 'Scripts' nella directory del progetto:")
        print(f"  {Path(__file__).parent.absolute()}")
        wait_for_input()
        return
    
    print(f"Cartella Scripts trovata: {scripts_dir}")
    
    # Loop principale dell'interfaccia
    while True:
        # Elenca gli script disponibili
        scripts = list_available_scripts()
        scripts = display_script_menu(scripts)
        
        if not scripts:
            wait_for_input()
            break
        
        # Ottieni la selezione dell'utente
        selection = get_user_selection(len(scripts) - 1)
        
        if selection is None:
            print("Uscita dal programma.")
            break
        
        # Esegui lo script selezionato
        selected_script = scripts[selection]
        success = execute_selected_script(selected_script)
        
        # Chiedi se continuare
        print("\n" + "="*60)
        if success:
            continue_choice = input("Vuoi eseguire un altro script? (s/n): ").lower()
        else:
            continue_choice = input("Vuoi provare con un altro script? (s/n): ").lower()
        
        if continue_choice != 's':
            print("Uscita dal programma.")
            break

if __name__ == "__main__":
    main() 