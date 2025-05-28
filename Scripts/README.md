# Script per Elencare Componenti in Altium Designer

Questa cartella contiene tre script DelphiScript per elencare i componenti nei progetti di Altium Designer.

## Script Disponibili

### 1. ComponentsLister.pas
**Script base per elencare tutti i componenti**

- Elenca tutti i componenti presenti nei documenti schematici del progetto attivo
- Mostra: Designator, LibRef, Comment, Footprint, Description
- Cerca automaticamente la descrizione nei parametri del componente se non presente
- Output nel pannello messaggi di Altium

**Utilizzo:**
1. Apri un progetto in Altium Designer
2. Vai su DXP → Run Script
3. Seleziona `ComponentsLister.pas`
4. Clicca OK

### 2. ComponentsLister_ActiveBOM.pas
**Script per verificare la presenza di documenti ActiveBOM**

- Cerca documenti ActiveBOM nel progetto
- Fornisce informazioni su come accedere ai dati BOM programmaticamente
- Include fallback per lettura diretta dai documenti schematici
- Utile per progetti che utilizzano ActiveBOM

**Utilizzo:**
1. Apri un progetto in Altium Designer
2. Vai su DXP → Run Script
3. Seleziona `ComponentsLister_ActiveBOM.pas`
4. Clicca OK

### 3. ComponentsLister_Advanced.pas
**Script avanzato con statistiche dettagliate**

- Elenca tutti i componenti con informazioni estese
- Estrae tutti i parametri personalizzati
- Fornisce statistiche: totale componenti, tipi unici
- Mostra parametri comuni: PartNumber, Manufacturer, Value, Voltage, Power, Tolerance, Package
- Output dettagliato nel pannello messaggi

**Utilizzo:**
1. Apri un progetto in Altium Designer
2. Vai su DXP → Run Script
3. Seleziona `ComponentsLister_Advanced.pas`
4. Clicca OK

## Installazione

1. Copia tutti i file `.pas` nella cartella degli script di Altium
2. In Altium Designer, vai su DXP → Run Script
3. Naviga alla cartella e seleziona lo script desiderato

## Note Tecniche

- Gli script sono compatibili con DelphiScript di Altium Designer
- Utilizzano l'API SchServer per accedere ai documenti schematici
- Non richiedono librerie esterne
- Testati con Altium Designer (versioni recenti)

## Limitazioni DelphiScript

- DelphiScript è un linguaggio tipeless (senza tipi)
- Non supporta la sintassi `for var` (utilizzare dichiarazioni separate)
- Le variabili devono essere dichiarate nella sezione `var`
- Non è possibile definire record o classi personalizzate

## Output

Tutti gli script mostrano i risultati in due modi:
1. **Finestra di messaggio**: Riassunto rapido
2. **Pannello messaggi di Altium**: Lista completa dettagliata

Per visualizzare il pannello messaggi:
- Vai su View → Workspace Panels → System → Messages
- Oppure premi Ctrl+Alt+M

## Risoluzione Problemi

**Errore "Nessun progetto attivo":**
- Assicurati di avere un progetto aperto in Altium
- Il progetto deve contenere almeno un documento schematico

**Errore "Server schematico non disponibile":**
- Riavvia Altium Designer
- Verifica che i documenti schematici siano validi

**Script non trovato:**
- Verifica che i file `.pas` siano nella cartella corretta
- Controlla che l'estensione sia `.pas` e non `.txt`

## Personalizzazione

Gli script possono essere modificati per:
- Aggiungere nuovi parametri da estrarre
- Modificare il formato di output
- Filtrare componenti specifici
- Esportare in file esterni (CSV, TXT)

Per modifiche avanzate, consultare la documentazione dell'API di Altium Designer. 