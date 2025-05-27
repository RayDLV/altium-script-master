{..............................................................................}
{ Script: ComponentsLister.pas                                                    }
{ Autore: Script generato per elencare i componenti di un progetto Altium        }
{ Data: Creato con Altium Designer                                               }
{ Descrizione: Estrae tutti i componenti dai documenti schematici del progetto   }
{..............................................................................}

// Procedura principale che elenca i componenti
procedure ComponentsLister;
var
    Project : IProject;
    Document : IDocument;
    SchDoc : ISch_Document;
    ComponentsList : TStringList;
    Component : ISch_Component;
    SchIterator : ISch_Iterator;
    i, j : Integer;
    TxtDocument : IServerDocument;
    FilePath : String;
begin
    // Inizializza la lista di componenti
    ComponentsList := TStringList.Create;
    try
        // Ottieni il progetto corrente
        Project := GetWorkspace.DM_FocusedProject;
        if Project = nil then
        begin
            ShowMessage('Nessun progetto aperto!');
            Exit;
        end;

        // Compila il progetto per assicurarsi che tutti i dati siano aggiornati
        Project.DM_Compile;

        // Aggiungi header alla lista
        ComponentsList.Add('=================================================================');
        ComponentsList.Add('=== LISTA COMPONENTI DEL PROGETTO: ' + Project.DM_ProjectFileName + ' ===');
        ComponentsList.Add('=================================================================');
        ComponentsList.Add('');

        // Itera attraverso tutti i documenti logici del progetto
        for i := 0 to Project.DM_LogicalDocumentCount - 1 do
        begin
            Document := Project.DM_LogicalDocuments(i);
            
            // Controlla se è un documento schematico
            if Document.DM_DocumentKind = 'SCH' then
            begin
                // Accedi al documento schematico direttamente
                SchDoc := Document;
                if SchDoc <> nil then
                begin
                    ComponentsList.Add('--- Documento: ' + Document.DM_FileName + ' ---');
                    ComponentsList.Add('');

                    // Crea iteratore per i componenti
                    SchIterator := SchDoc.SchIterator_Create;
                    SchIterator.AddFilter_ObjectSet(MkSet(eSchComponent));
                    
                    // Itera attraverso tutti i componenti nel documento
                    Component := SchIterator.FirstSchObject;
                    while Component <> nil do
                    begin
                        // Aggiungi informazioni del componente
                        if Component.Designator <> nil then
                            ComponentsList.Add('Designator: ' + Component.Designator.Text)
                        else
                            ComponentsList.Add('Designator: (vuoto)');
                            
                        ComponentsList.Add('  Tipo: ' + Component.LibReference);
                        
                        if Component.SchematicLibrary <> '' then
                            ComponentsList.Add('  Libreria: ' + Component.SchematicLibrary)
                        else
                            ComponentsList.Add('  Libreria: (non specificata)');
                            
                        if Component.Comment <> nil then
                            ComponentsList.Add('  Descrizione: ' + Component.Comment.Text)
                        else
                            ComponentsList.Add('  Descrizione: (vuota)');
                        ComponentsList.Add('');
                        
                        Component := SchIterator.NextSchObject;
                    end;
                    
                    SchDoc.SchIterator_Destroy(SchIterator);
                    ComponentsList.Add('');
                end;
            end;
        end;

        // Aggiungi footer
        ComponentsList.Add('=================================================================');
        ComponentsList.Add('Fine elenco componenti');
        ComponentsList.Add('=================================================================');

        // Salva il risultato in un file di testo
        FilePath := ExtractFilePath(Project.DM_ProjectFullPath) + 'ComponentsList.txt';
        ComponentsList.SaveToFile(FilePath);

        // Mostra risultati in una finestra di messaggio
        ShowMessage('Elenco componenti generato con successo!' + #13#10 + 'File salvato in: ' + FilePath);

    finally
        ComponentsList.Free;
    end;
end;

// Procedura di ingresso per l'esecuzione dello script
procedure Main;
begin
    ComponentsLister;
end;

// Nota: Rimuovo l'inizializzazione automatica per permettere chiamate esterne
// begin
//     Main;
// end. 