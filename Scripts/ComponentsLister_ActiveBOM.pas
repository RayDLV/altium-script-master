procedure ComponentsLister_ActiveBOM;
var
    Project         : IProject;
    Document        : IDocument;
    ActiveBOMDoc    : IDocument;
    ComponentCount  : Integer;
    ComponentsList  : TStringList;
    i               : Integer;
    ComponentInfo   : String;
    BOMFound        : Boolean;
begin
    // Inizializza contatore e lista
    ComponentCount := 0;
    ComponentsList := TStringList.Create;
    BOMFound := False;
    
    try
        // Ottieni il progetto corrente
        Project := GetWorkspace.DM_FocusedProject;
        if Project = nil then
        begin
            ShowMessage('Nessun progetto attivo trovato!');
            Exit;
        end;
        
        ComponentsList.Add('=== LISTA COMPONENTI DEL PROGETTO (via ActiveBOM): ' + Project.DM_ProjectFileName + ' ===');
        ComponentsList.Add('');
        
        // Cerca un documento ActiveBOM nel progetto
        for i := 0 to Project.DM_LogicalDocumentCount - 1 do
        begin
            Document := Project.DM_LogicalDocuments(i);
            
            // Controlla se è un documento ActiveBOM
            if Document.DM_DocumentKind = 'BOMTAB' then
            begin
                ActiveBOMDoc := Document;
                BOMFound := True;
                ComponentsList.Add('Documento ActiveBOM trovato: ' + Document.DM_FileName);
                ComponentsList.Add('Percorso: ' + Document.DM_FullPath);
                ComponentsList.Add('');
                Break;
            end;
        end;
        
        if not BOMFound then
        begin
            ComponentsList.Add('NOTA: Nessun documento ActiveBOM trovato nel progetto.');
            ComponentsList.Add('Per utilizzare ActiveBOM, crea un nuovo documento ActiveBOM dal menu:');
            ComponentsList.Add('Project -> Add New to Project -> ActiveBOM');
            ComponentsList.Add('');
            ComponentsList.Add('Alternativa: Utilizzare lo script ComponentsLister.pas che legge');
            ComponentsList.Add('direttamente dai documenti schematici.');
        end
        else
        begin
            ComponentsList.Add('Per accedere ai dati della BOM programmaticamente,');
            ComponentsList.Add('è necessario utilizzare l''API BOM più avanzata di Altium.');
            ComponentsList.Add('');
            ComponentsList.Add('Questo richiede l''utilizzo di:');
            ComponentsList.Add('- IBomManager / IActiveBomManager');
            ComponentsList.Add('- IBomManagerFactory');
            ComponentsList.Add('- EDP.Utils.GetBomManagerFactory()');
            ComponentsList.Add('');
            ComponentsList.Add('Vedi documentazione: BOM Engine Interfaces per Altium SDK');
        end;
        
        ComponentsList.Add('');
        ComponentsList.Add('=== ALTERNATIVA: LETTURA COMPONENTI DA SCHEMATICI ===');
        ComponentsList.Add('');
        
        // Esegui lettura diretta dai documenti schematici come fallback
        ComponentCount := 0;
        for i := 0 to Project.DM_LogicalDocumentCount - 1 do
        begin
            Document := Project.DM_LogicalDocuments(i);
            
            if Document.DM_DocumentKind = 'SCH' then
            begin
                ComponentsList.Add('Documento schematico: ' + Document.DM_FileName);
                Inc(ComponentCount);
            end;
        end;
        
        ComponentsList.Add('');
        ComponentsList.Add('Documenti schematici trovati: ' + IntToStr(ComponentCount));
        ComponentsList.Add('');
        ComponentsList.Add('Per una lista dettagliata dei componenti, eseguire ComponentsLister.pas');
        ComponentsList.Add('');
        ComponentsList.Add('=== FINE LISTA ===');
        
        // Mostra risultati
        if BOMFound then
            ShowMessage('Documento ActiveBOM trovato!' + #13#10 + 
                       'Per accesso completo ai dati BOM è necessario' + #13#10 +
                       'utilizzare l''API BOM più avanzata.' + #13#10#13#10 +
                       'Dettagli disponibili tramite altri metodi di output.')
        else
            ShowMessage('Nessun documento ActiveBOM trovato!' + #13#10 +
                       'Usa ComponentsLister.pas per lettura diretta' + #13#10 +
                       'dai documenti schematici.' + #13#10#13#10 +
                       'Dettagli disponibili tramite altri metodi di output.');
        
    finally
        ComponentsList.Free;
    end;
end; 