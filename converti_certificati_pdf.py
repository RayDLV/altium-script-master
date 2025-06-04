#!/usr/bin/env python3
"""
Script per convertire i certificati di testo generati da certifica.pas
in un unico documento PDF unificato.

Ogni certificato diventa una pagina del PDF finale.
"""

import os
import sys
from pathlib import Path
from datetime import datetime

def install_required_packages():
    """Installa i pacchetti necessari se non sono presenti."""
    required_packages = ['reportlab']
    
    for package in required_packages:
        try:
            __import__(package)
            print(f"{package} già installato")
        except ImportError:
            print(f"Installazione di {package}...")
            try:
                import subprocess
                result = subprocess.run([sys.executable, "-m", "pip", "install", package], 
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    print(f"{package} installato")
                else:
                    print(f"Errore nell'installazione di {package}: {result.stderr}")
                    return False
            except Exception as e:
                print(f"Errore durante l'installazione di {package}: {e}")
                return False
    return True

def find_certificates_folder():
    """Trova la cartella Certificati nel progetto."""
    # Cerca nella directory corrente
    current_dir = Path.cwd()
    certificates_folder = current_dir / "Certificati"
    
    if certificates_folder.exists():
        return certificates_folder
    
    # Cerca nelle sottocartelle (caso in cui lo script sia eseguito da una sottocartella)
    for root, dirs, files in os.walk(current_dir):
        if "Certificati" in dirs:
            return Path(root) / "Certificati"
    
    return None

def get_manual_certificates_folder():
    """Permette all'utente di inserire manualmente il percorso della cartella certificati."""
    print("\nInserimento manuale del percorso:")
    print("Inserisci il percorso completo della cartella 'Certificati'")
    print("Esempi:")
    print("  C:\\Users\\tuonome\\Desktop\\MioProgetto\\Certificati")
    print("  C:\\Progetti\\AltiumProject\\Certificati")
    print()
    
    while True:
        try:
            user_path = input("Percorso cartella Certificati: ").strip()
            
            # Rimuovi virgolette se presenti (da copia-incolla Windows)
            user_path = user_path.strip('"\'')
            
            if not user_path:
                print("Percorso vuoto. Inserisci un percorso valido.")
                continue
            
            certificates_folder = Path(user_path)
            
            # Verifica se il percorso esiste
            if not certificates_folder.exists():
                print(f"Errore: Il percorso '{certificates_folder}' non esiste.")
                retry = input("Vuoi riprovare? (s/n): ").lower().strip()
                if retry != 's':
                    return None
                continue
            
            # Verifica se è una cartella
            if not certificates_folder.is_dir():
                print(f"Errore: '{certificates_folder}' non è una cartella.")
                retry = input("Vuoi riprovare? (s/n): ").lower().strip()
                if retry != 's':
                    return None
                continue
            
            # Verifica se contiene file .txt
            txt_files = list(certificates_folder.glob("*.txt"))
            if not txt_files:
                print(f"Attenzione: La cartella '{certificates_folder}' non contiene file .txt")
                confirm = input("Vuoi continuare comunque? (s/n): ").lower().strip()
                if confirm != 's':
                    retry = input("Vuoi inserire un altro percorso? (s/n): ").lower().strip()
                    if retry != 's':
                        return None
                    continue
            
            print(f"Cartella trovata: {certificates_folder}")
            return certificates_folder
            
        except KeyboardInterrupt:
            print("\nOperazione annullata dall'utente.")
            return None
        except Exception as e:
            print(f"Errore: {e}")
            retry = input("Vuoi riprovare? (s/n): ").lower().strip()
            if retry != 's':
                return None

def diagnose_files(certificates_folder):
    """Esegue una diagnostica completa sui file nella cartella certificati."""
    print("\n" + "="*60)
    print("DIAGNOSTICA FILE CERTIFICATI")
    print("="*60)
    
    if not certificates_folder or not certificates_folder.exists():
        print("Errore: Cartella non valida")
        return []
    
    # Trova tutti i file nella cartella
    all_files = list(certificates_folder.iterdir())
    txt_files = [f for f in all_files if f.suffix.lower() == '.txt']
    
    print(f"Cartella analizzata: {certificates_folder}")
    print(f"File totali nella cartella: {len(all_files)}")
    print(f"File .txt trovati: {len(txt_files)}")
    print()
    
    if not txt_files:
        print("ATTENZIONE: Nessun file .txt trovato!")
        return []
    
    problematic_files = []
    valid_files = []
    files_with_warnings = []
    
    for i, file_path in enumerate(txt_files, 1):
        print(f"[{i}/{len(txt_files)}] Analisi: {file_path.name}")
        file_issues = analyze_single_file(file_path)
        encoding_info = get_file_encoding_info(file_path)
        
        if file_issues:
            problematic_files.append((file_path, file_issues))
            print(f"  ERRORE - Problemi rilevati: {len(file_issues)}")
            for issue in file_issues:
                print(f"     - {issue}")
        else:
            valid_files.append(file_path)
            if encoding_info and encoding_info != 'utf-8':
                files_with_warnings.append((file_path, f"Encoding: {encoding_info}"))
                print(f"  OK - File valido (encoding: {encoding_info})")
            else:
                print(f"  OK - File valido")
        print()
    
    # Riepilogo
    print("="*60)
    print("RIEPILOGO DIAGNOSTICA")
    print("="*60)
    print(f"File validi: {len(valid_files)}")
    print(f"File problematici (esclusi): {len(problematic_files)}")
    
    if files_with_warnings:
        print(f"File con encoding non-UTF8 (inclusi): {len(files_with_warnings)}")
        for file_path, warning in files_with_warnings:
            print(f"  {file_path.name}: {warning}")
        print()
    
    if problematic_files:
        print("File con problemi (esclusi dalla conversione):")
        for file_path, issues in problematic_files:
            print(f"  {file_path.name}: {', '.join(issues)}")
    
    print()
    return valid_files

def get_file_encoding_info(file_path):
    """Restituisce l'encoding rilevato per un file."""
    encodings_to_try = ['utf-8', 'utf-8-sig', 'latin1', 'cp1252', 'ascii']
    
    for encoding in encodings_to_try:
        try:
            with open(file_path, 'r', encoding=encoding) as f:
                f.read()
                return encoding
        except UnicodeDecodeError:
            continue
        except Exception:
            continue
    
    return None

def analyze_single_file(file_path):
    """Analizza un singolo file e restituisce una lista di problemi."""
    issues = []
    
    try:
        # 1. Controllo dimensione file
        file_size = file_path.stat().st_size
        if file_size == 0:
            issues.append("File vuoto (0 bytes)")
            return issues
        elif file_size > 10 * 1024 * 1024:  # 10MB
            issues.append(f"File molto grande ({file_size/1024/1024:.1f}MB)")
        
        # 2. Controllo caratteri nel nome file
        filename = file_path.name
        problematic_chars = ['<', '>', ':', '"', '|', '?', '*']
        if any(char in filename for char in problematic_chars):
            issues.append("Nome file contiene caratteri problematici")
        
        # 3. Tentativo di lettura con diversi encoding
        content = None
        encoding_used = None
        
        encodings_to_try = ['utf-8', 'utf-8-sig', 'latin1', 'cp1252', 'ascii']
        
        for encoding in encodings_to_try:
            try:
                with open(file_path, 'r', encoding=encoding) as f:
                    content = f.read()
                    encoding_used = encoding
                    break
            except UnicodeDecodeError:
                continue
            except Exception as e:
                issues.append(f"Errore lettura con {encoding}: {str(e)}")
        
        if content is None:
            issues.append("Impossibile leggere il file con nessun encoding")
            return issues
        
        # 4. Analisi contenuto
        if not content.strip():
            issues.append("File vuoto o solo spazi bianchi")
        
        # 5. Controllo caratteri non stampabili
        non_printable = sum(1 for c in content if ord(c) < 32 and c not in '\r\n\t')
        if non_printable > 0:
            issues.append(f"Contiene {non_printable} caratteri non stampabili")
        
        # 6. Controllo lunghezza righe eccessive
        lines = content.split('\n')
        long_lines = [i for i, line in enumerate(lines, 1) if len(line) > 1000]
        if long_lines:
            issues.append(f"Righe molto lunghe: {len(long_lines)} righe > 1000 caratteri")
        
        # 7. Controllo encoding effettivo usato (solo come avviso, non come errore bloccante)
        # Rimosso perché il sistema può gestire encoding multipli
        
        # 8. Verifica struttura certificato (controllo di base)
        if "CERTIFICATO COMPONENTE" not in content:
            issues.append("Non sembra un certificato valido (manca header)")
        
    except Exception as e:
        issues.append(f"Errore generale nell'analisi: {str(e)}")
    
    return issues

def get_certificate_files(certificates_folder):
    """Ottiene tutti i file .txt dalla cartella certificati."""
    if not certificates_folder or not certificates_folder.exists():
        return []
    
    txt_files = list(certificates_folder.glob("*.txt"))
    # Ordina alfabeticamente per avere un ordine consistente
    txt_files.sort(key=lambda x: x.name.lower())
    
    return txt_files

def read_certificate_content(file_path):
    """Legge il contenuto di un file certificato con gestione migliorata degli encoding."""
    encodings_to_try = ['utf-8', 'utf-8-sig', 'latin1', 'cp1252']
    
    for encoding in encodings_to_try:
        try:
            with open(file_path, 'r', encoding=encoding) as file:
                content = file.read()
                # Rimuovi caratteri non stampabili eccetto \r\n\t
                content = ''.join(c for c in content if ord(c) >= 32 or c in '\r\n\t')
                return content
        except UnicodeDecodeError:
            continue
        except Exception as e:
            print(f"Errore nella lettura di {file_path} con encoding {encoding}: {e}")
            continue
    
    # Se tutti gli encoding falliscono
    print(f"Errore: Impossibile leggere {file_path} con nessun encoding")
    return f"Errore nella lettura del file: {file_path.name}"

def create_unified_pdf(certificate_files, output_path):
    """Crea un PDF unificato con tutti i certificati."""
    try:
        from reportlab.lib.pagesizes import A4
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import inch
        from reportlab.lib import colors
        
        # Crea il documento PDF
        doc = SimpleDocTemplate(str(output_path), pagesize=A4)
        story = []
        styles = getSampleStyleSheet()
        
        # Stile personalizzato per il titolo
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=16,
            spaceAfter=30,
            textColor=colors.darkblue,
            alignment=1  # Centro
        )
        
        # Stile per il contenuto
        content_style = ParagraphStyle(
            'CustomContent',
            parent=styles['Normal'],
            fontSize=10,
            fontName='Courier',  # Font monospace per mantenere formattazione
            spaceAfter=12,
            leftIndent=20,
            rightIndent=20
        )
        
        print(f"Creazione PDF con {len(certificate_files)} certificati...")
        
        successful_conversions = 0
        failed_conversions = 0
        
        for i, cert_file in enumerate(certificate_files):
            print(f"  Processando: {cert_file.name} ({i+1}/{len(certificate_files)})")
            
            try:
                # Leggi il contenuto del certificato
                content = read_certificate_content(cert_file)
                
                if content.startswith("Errore nella lettura"):
                    print(f"    SALTATO - Errore di lettura")
                    failed_conversions += 1
                    continue
                
                # Titolo della pagina
                title = f"Certificato: {cert_file.stem.replace('_Certificato', '')}"
                story.append(Paragraph(title, title_style))
                story.append(Spacer(1, 0.2*inch))
                
                # Contenuto del certificato
                # Dividi il contenuto in righe e crea paragrafi
                lines = content.split('\n')
                for line in lines:
                    if line.strip():  # Salta righe vuote
                        # Escape caratteri speciali per ReportLab
                        escaped_line = line.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
                        # Tronca righe troppo lunghe
                        if len(escaped_line) > 200:
                            escaped_line = escaped_line[:200] + "..."
                        story.append(Paragraph(escaped_line, content_style))
                    else:
                        story.append(Spacer(1, 0.1*inch))
                
                # Aggiungi interruzione di pagina se non è l'ultimo certificato
                if i < len(certificate_files) - 1:
                    story.append(PageBreak())
                
                successful_conversions += 1
                print(f"    OK - Convertito con successo")
                
            except Exception as e:
                print(f"    ERRORE - Conversione fallita: {e}")
                failed_conversions += 1
                continue
        
        if successful_conversions == 0:
            print("Errore: Nessun certificato è stato convertito con successo!")
            return False
        
        # Genera il PDF
        doc.build(story)
        
        print(f"\nRiepilogo conversione:")
        print(f"  Successi: {successful_conversions}")
        print(f"  Errori: {failed_conversions}")
        
        return True
        
    except Exception as e:
        print(f"Errore nella creazione del PDF: {e}")
        return False

def main():
    print("CONVERTITORE CERTIFICATI TXT a PDF")
    print()
    
    # Installa pacchetti necessari
    print("Controllo dipendenze...")
    if not install_required_packages():
        print("Impossibile installare le dipendenze necessarie.")
        input("Premi INVIO per uscire...")
        return
    
    print()
    
    # Trova la cartella certificati
    print("Ricerca cartella Certificati...")
    certificates_folder = find_certificates_folder()
    
    if not certificates_folder:
        print("Cartella 'Certificati' non trovata automaticamente.")
        print("Vuoi inserire manualmente il percorso della cartella?")
        choice = input("Inserire percorso manualmente? (s/n): ").lower().strip()
        
        if choice == 's':
            certificates_folder = get_manual_certificates_folder()
            if not certificates_folder:
                print("Operazione annullata.")
                input("Premi INVIO per uscire...")
                return
        else:
            print("Operazione annullata.")
            print("Assicurati di aver eseguito prima lo script certifica.pas di Altium.")
            input("Premi INVIO per uscire...")
            return
    else:
        print(f"Cartella trovata automaticamente: {certificates_folder}")
    
    # Diagnostica dei file
    print("\nEseguendo diagnostica dei file...")
    choice = input("Vuoi eseguire la diagnostica completa? (s/n): ").lower().strip()
    
    if choice == 's':
        valid_files = diagnose_files(certificates_folder)
        if not valid_files:
            print("Nessun file valido trovato dopo la diagnostica!")
            input("Premi INVIO per uscire...")
            return
        certificate_files = valid_files
    else:
        # Trova i file certificato normalmente
        certificate_files = get_certificate_files(certificates_folder)
    
    if not certificate_files:
        print("Nessun file .txt trovato nella cartella Certificati!")
        print(f"Cartella controllata: {certificates_folder}")
        input("Premi INVIO per uscire...")
        return
    
    print(f"\nTrovati {len(certificate_files)} certificati da convertire:")
    for cert_file in certificate_files:
        print(f"  - {cert_file.name}")
    
    print()
    
    # Crea il nome del file PDF
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    project_name = certificates_folder.parent.name
    output_filename = f"Certificati_{project_name}_{timestamp}.pdf"
    output_path = certificates_folder / output_filename
    
    print(f"Creazione PDF: {output_filename}")
    print(f"Percorso output: {output_path}")
    
    # Crea il PDF unificato
    if create_unified_pdf(certificate_files, output_path):
        print(f"PDF creato con successo!")
        print(f"  Percorso: {output_path}")
        print(f"  Pagine: {len(certificate_files)}")
        
        # Chiedi se aprire il PDF
        try:
            response = input("\nVuoi aprire il PDF? (s/n): ").lower().strip()
            if response == 's':
                os.startfile(str(output_path))  # Windows
        except:
            pass
    else:
        print("Errore nella creazione del PDF!")
    
    print()
    input("Premi INVIO per uscire...")

if __name__ == "__main__":
    main() 