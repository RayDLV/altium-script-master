procedure ComponentsLister;
var
    Project         : IProject;
    Document        : IDocument;
    SchDoc          : ISch_Document;
    SchServer       : ISch_ServerInterface;
    SchIterator     : ISch_Iterator;
    Component       : ISch_Component;
    ComponentCount  : Integer;
    ComponentsList  : TStringList;
    i, j            : Integer;
    ComponentInfo   : String;
    Designator      : String;
    Comment         : String;
    LibRef          : String;
    Footprint       : String;
    Description     : String;
    Parameter       : ISch_Parameter;
    FilePath        : String;
begin
    // Inizializza contatore e lista
    ComponentCount := 0;
    ComponentsList := TStringList.Create;
    
    try
        // Ottieni il progetto corrente
        Project := GetWorkspace.DM_FocusedProject;
        if Project = nil then
        begin
            ShowMessage('Nessun progetto attivo trovato!');
            Exit;
        end;
        
        // Ottieni il server schematico
        SchServer := SchServer;
        if SchServer = nil then
        begin
            ShowMessage('Impossibile accedere al server schematico!');
            Exit;
        end;
        
        ComponentsList.Add('=== LISTA COMPONENTI DEL PROGETTO: ' + Project.DM_ProjectFileName + ' ===');
        ComponentsList.Add('');
        ComponentsList.Add('Formato: Designator | LibRef | Comment | Footprint | Description');
        ComponentsList.Add('-----------------------------------------------------------------------');
        ComponentsList.Add('');
        
        // Itera attraverso tutti i documenti del progetto
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
                    
                    // Crea iteratore per i componenti
                    SchIterator := SchDoc.SchIterator_Create;
                    SchIterator.AddFilter_ObjectSet(MkSet(eSchComponent));
                    
                    // Itera attraverso tutti i componenti nel documento
                    Component := SchIterator.FirstSchObject;
                    while Component <> nil do
                    begin
                        // Estrai informazioni del componente
                        Designator := Component.Designator.Text;
                        Comment := Component.Comment.Text;
                        LibRef := Component.LibReference;
                        Footprint := Component.Footprint.Text;
                        Description := Component.ComponentDescription;
                        
                        // Se la descrizione è vuota, prova a ottenerla dai parametri
                        if Description = '' then
                        begin
                            // Cerca il parametro Description usando un iteratore
                            j := 0;
                            while j < Component.ParameterCount do
                            begin
                                Parameter := Component.Parameter[j];
                                if Parameter <> nil then
                                begin
                                    if Parameter.Name = 'Description' then
                                    begin
                                        Description := Parameter.Text;
                                        Break;
                                    end;
                                end;
                                Inc(j);
                            end;
                        end;
                        
                        // Costruisci stringa informazioni componente
                        ComponentInfo := Designator + ' | ' + LibRef + ' | ' + Comment + ' | ' + Footprint + ' | ' + Description;
                        ComponentsList.Add(ComponentInfo);
                        
                        Inc(ComponentCount);
                        Component := SchIterator.NextSchObject;
                    end;
                    
                    SchDoc.SchIterator_Destroy(SchIterator);
                    ComponentsList.Add('');
                end;
            end;
        end;
        
        ComponentsList.Add('-----------------------------------------------------------------------');
        ComponentsList.Add('TOTALE COMPONENTI TROVATI: ' + IntToStr(ComponentCount));
        ComponentsList.Add('');
        ComponentsList.Add('=== FINE LISTA ===');
        
        // Salva il risultato in un file di testo
        FilePath := ExtractFilePath(Project.DM_ProjectFullPath) + 'ComponentsList_Simple.txt';
        ComponentsList.SaveToFile(FilePath);
        
        // Mostra risultati in una finestra di messaggio
        ShowMessage('Componenti Listati con Successo!' + #13#10 + 
                   'Totale componenti trovati: ' + IntToStr(ComponentCount) + #13#10#13#10 +
                   'File salvato in: ' + FilePath);
        
    finally
        ComponentsList.Free;
    end;
end; 