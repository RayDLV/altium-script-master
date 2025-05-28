# Scripts per Listare Componenti in Altium Designer

Questa cartella contiene tre script DelphiScript per listare tutti i componenti utilizzati nel progetto corrente in Altium Designer.

## Script Disponibili

### 1. ComponentsLister.pas
**Script principale** - Lista tutti i componenti del progetto leggendo direttamente dai documenti schematici.

**Funzionalità:**
- Legge tutti i documenti schematici del progetto corrente
- Estrae informazioni base per ogni componente:
  - Designator (R1, C2, U1, ecc.)
  - LibRef (riferimento libreria)
  - Comment (valore/commento)
  - Footprint (package PCB)
  - Description (descrizione)
- Mostra risultati nel pannello messaggi di Altium
- Conta il totale dei componenti trovati

### 2. ComponentsLister_ActiveBOM.pas
**Script per ActiveBOM** - Cerca documenti ActiveBOM nel progetto e fornisce informazioni su come accedere ai dati BOM.

**Funzionalità:**
- Rileva se esiste un documento ActiveBOM nel progetto
- Fornisce istruzioni per creare un ActiveBOM se non presente
- Spiega come utilizzare le API BOM avanzate per accesso programmatico
- Include fallback alla lettura da documenti schematici

### 3. ComponentsLister_Advanced.pas
**Script avanzato** - Versione estesa con tutti gli attributi possibili e statistiche dettagliate.

**Funzionalità:**
- Estrae tutti i parametri personalizzati dei componenti
- Mostra attributi estesi:
  - Part Number, Manufacturer, Value
  - Voltage, Power, Tolerance, Package
  - Tutti i parametri personalizzati
- Statistiche dettagliate:
  - Conteggio componenti per documento
  - Lista tipi di componenti unici
  - Totale componenti nel progetto
- Formattazione dettagliata per analisi approfondita

## Come Utilizzare gli Script

### Prerequisiti
1. Avere un progetto Altium Designer aperto
2. Il progetto deve contenere almeno un documento schematico con componenti

### Esecuzione
1. **Metodo 1 - Dal menu File:**
   - File → Run Script
   - Navigare alla cartella Scripts
   - Selezionare lo script desiderato (.pas)
   - Cliccare OK

2. **Metodo 2 - Da un progetto script:**
   - Creare un nuovo Script Project (File → New → Project → Script Project)
   - Aggiungere i file script al progetto
   - Eseguire dal pannello script

### Output
Tutti gli script mostrano i risultati in due modi:
1. **Finestra di messaggio**: Riassunto rapido con conteggio componenti
2. **Pannello messaggi Altium**: Lista completa dettagliata

## Scopo degli Script

Questi script sono stati creati per:
- **Analisi BOM**: Ottenere una lista completa di tutti i componenti utilizzati
- **Verifica progetto**: Controllare che tutti i componenti abbiano le informazioni necessarie
- **Preparazione per script futuri**: Fornire una base per script più complessi che operano sui componenti
- **Debug e analisi**: Identificare problemi nei dati dei componenti

## Personalizzazione

Gli script possono essere facilmente modificati per:
- Filtrare tipi specifici di componenti
- Esportare dati in formati diversi (CSV, Excel, ecc.)
- Aggiungere validazioni specifiche
- Integrare con sistemi di gestione componenti esterni

## Note Tecniche

- **API utilizzate**: Workspace Manager, Schematic Server
- **Linguaggio**: DelphiScript (Pascal-like)
- **Compatibilità**: Altium Designer (versioni recenti)
- **Dipendenze**: Nessuna libreria esterna richiesta

## Prossimi Sviluppi

Questi script formano la base per funzionalità più avanzate come:
- Generazione BOM personalizzate
- Validazione componenti automatica
- Sincronizzazione con database parti aziendali
- Report di costo e disponibilità componenti

## Troubleshooting

**Errore "Nessun progetto attivo":**
- Assicurarsi che un progetto sia aperto in Altium
- Il progetto deve essere il focus corrente

**Nessun componente trovato:**
- Verificare che il progetto contenga documenti schematici
- I documenti devono contenere componenti piazzati

**Errori di accesso API:**
- Riavviare Altium Designer
- Verificare che la versione di Altium supporti le API utilizzate 