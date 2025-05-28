procedure ComponentsLister_Advanced;
var
    Project         : IProject;
    Document        : IDocument;
    SchDoc          : ISch_Document;
    SchServer       : ISch_ServerInterface;
    SchIterator     : ISch_Iterator;
    Component       : ISch_Component;
    Parameter       : ISch_Parameter;
    ComponentCount  : Integer;
    ComponentsList  : TStringList;
    i, j            : Integer;
    ComponentInfo   : String;
    Designator      : String;
    Comment         : String;
    LibRef          : String;
    Footprint       : String;
    Description     : String;
    PartNumber      : String;
    Manufacturer    : String;
    Value           : String;
    Voltage         : String;
    Power           : String;
    Tolerance       : String;
    Package         : String;
    ParameterList   : String;
    UniqueComponents: TStringList;
    TotalComponents : Integer;
    UniqueCount     : Integer;
    FilePath        : String;
begin
    // Inizializza contatori e liste
    ComponentCount := 0;
    TotalComponents := 0;
    UniqueCount := 0;
    ComponentsList := TStringList.Create;
    UniqueComponents := TStringList.Create;
    
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
        
        ComponentsList.Add('=== LISTA AVANZATA COMPONENTI DEL PROGETTO: ' + Project.DM_ProjectFileName + ' ===');
        ComponentsList.Add('Data/Ora: ' + DateTimeToStr(Now));
        ComponentsList.Add('');
        ComponentsList.Add('Attributi estratti: Designator, LibRef, Comment, Footprint, Description,');
        ComponentsList.Add('                   PartNumber, Manufacturer, Value, Voltage, Power, Tolerance, Package');
        ComponentsList.Add('                   + tutti i parametri personalizzati');
        ComponentsList.Add('');
        ComponentsList.Add('=============================================================================');
        ComponentsList.Add('');
        
        // Itera attraverso tutti i documenti del progetto
        for i := 0 to Project.DM_LogicalDocumentCount - 1 do
        begin
            Document := Project.DM_LogicalDocuments(i);
            
            // Controlla se è un documento schematico
            if Document.DM_DocumentKind = 'SCH' then
            begin
                SchDoc := SchServer.GetSchDocumentByPath(Document.DM_FullPath);
                if SchDoc <> nil then
                begin
                    ComponentsList.Add('### DOCUMENTO: ' + Document.DM_FileName + ' ###');
                    ComponentsList.Add('Percorso: ' + Document.DM_FullPath);
                    ComponentsList.Add('');
                    
                    // Crea iteratore per i componenti
                    SchIterator := SchDoc.SchIterator_Create;
                    SchIterator.AddFilter_ObjectSet(MkSet(eSchComponent));
                    
                    // Itera attraverso tutti i componenti nel documento
                    Component := SchIterator.FirstSchObject;
                    while Component <> nil do
                    begin
                        // Inizializza variabili
                        Designator := '';
                        Comment := '';
                        LibRef := '';
                        Footprint := '';
                        Description := '';
                        PartNumber := '';
                        Manufacturer := '';
                        Value := '';
                        Voltage := '';
                        Power := '';
                        Tolerance := '';
                        Package := '';
                        ParameterList := '';
                        
                        // Estrai informazioni base del componente
                        if Component.Designator <> nil then
                            Designator := Component.Designator.Text;
                        if Component.Comment <> nil then
                            Comment := Component.Comment.Text;
                        LibRef := Component.LibReference;
                        if Component.Footprint <> nil then
                            Footprint := Component.Footprint.Text;
                        Description := Component.ComponentDescription;
                        
                        // Estrai tutti i parametri del componente
                        if Component.ParameterCount > 0 then
                        begin
                            for j := 0 to Component.ParameterCount - 1 do
                            begin
                                Parameter := Component.Parameters[j];
                                if Parameter <> nil then
                                begin
                                    // Parametri comuni
                                    if Parameter.Name = 'Description' then
                                        Description := Parameter.Text
                                    else if Parameter.Name = 'Part Number' then
                                        PartNumber := Parameter.Text
                                    else if Parameter.Name = 'PartNumber' then
                                        PartNumber := Parameter.Text
                                    else if Parameter.Name = 'Manufacturer' then
                                        Manufacturer := Parameter.Text
                                    else if Parameter.Name = 'Value' then
                                        Value := Parameter.Text
                                    else if Parameter.Name = 'Voltage' then
                                        Voltage := Parameter.Text
                                    else if Parameter.Name = 'Power' then
                                        Power := Parameter.Text
                                    else if Parameter.Name = 'Tolerance' then
                                        Tolerance := Parameter.Text
                                    else if Parameter.Name = 'Package' then
                                        Package := Parameter.Text;
                                    
                                    // Aggiungi tutti i parametri alla lista
                                    if ParameterList <> '' then
                                        ParameterList := ParameterList + '; ';
                                    ParameterList := ParameterList + Parameter.Name + '=' + Parameter.Text;
                                end;
                            end;
                        end;
                        
                        // Costruisci stringa informazioni componente dettagliate
                        ComponentsList.Add('--- COMPONENTE #' + IntToStr(ComponentCount + 1) + ' ---');
                        ComponentsList.Add('Designator:    ' + Designator);
                        ComponentsList.Add('LibRef:        ' + LibRef);
                        ComponentsList.Add('Comment:       ' + Comment);
                        ComponentsList.Add('Footprint:     ' + Footprint);
                        ComponentsList.Add('Description:   ' + Description);
                        ComponentsList.Add('Part Number:   ' + PartNumber);
                        ComponentsList.Add('Manufacturer:  ' + Manufacturer);
                        ComponentsList.Add('Value:         ' + Value);
                        ComponentsList.Add('Voltage:       ' + Voltage);
                        ComponentsList.Add('Power:         ' + Power);
                        ComponentsList.Add('Tolerance:     ' + Tolerance);
                        ComponentsList.Add('Package:       ' + Package);
                        ComponentsList.Add('Tutti i Parametri: ' + ParameterList);
                        ComponentsList.Add('');
                        
                        // Conta componenti unici per LibRef
                        if UniqueComponents.IndexOf(LibRef) = -1 then
                        begin
                            UniqueComponents.Add(LibRef);
                            Inc(UniqueCount);
                        end;
                        
                        Inc(ComponentCount);
                        Inc(TotalComponents);
                        Component := SchIterator.NextSchObject;
                    end;
                    
                    SchDoc.SchIterator_Destroy(SchIterator);
                    ComponentsList.Add('Componenti in questo documento: ' + IntToStr(ComponentCount));
                    ComponentsList.Add('');
                    ComponentCount := 0; // Reset per il prossimo documento
                end;
            end;
        end;
        
        ComponentsList.Add('=============================================================================');
        ComponentsList.Add('');
        ComponentsList.Add('### RIASSUNTO STATISTICHE ###');
        ComponentsList.Add('TOTALE COMPONENTI NEL PROGETTO: ' + IntToStr(TotalComponents));
        ComponentsList.Add('TIPI DI COMPONENTI UNICI (LibRef): ' + IntToStr(UniqueCount));
        ComponentsList.Add('');
        ComponentsList.Add('### TIPI DI COMPONENTI UNICI ###');
        for i := 0 to UniqueComponents.Count - 1 do
        begin
            ComponentsList.Add('- ' + UniqueComponents[i]);
        end;
        ComponentsList.Add('');
        ComponentsList.Add('=== FINE LISTA AVANZATA ===');
        ComponentsList.Add('Script eseguito da: ComponentsLister_Advanced.pas');
        ComponentsList.Add('Data: ' + DateTimeToStr(Now));
        
        // Salva il risultato in un file di testo
        FilePath := ExtractFilePath(Project.DM_ProjectFullPath) + 'ComponentsList_Advanced.txt';
        ComponentsList.SaveToFile(FilePath);
        
        // Mostra risultati in una finestra di messaggio
        ShowMessage('Lista Avanzata Componenti Completata!' + #13#10 + 
                   'Totale componenti: ' + IntToStr(TotalComponents) + #13#10 +
                   'Tipi unici: ' + IntToStr(UniqueCount) + #13#10#13#10 +
                   'File salvato in: ' + FilePath);
        
    finally
        ComponentsList.Free;
        UniqueComponents.Free;
    end;
end; 