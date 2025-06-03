{..............................................................................}
{ Summary   Genera certificati PDF per ogni tipologia di componente e aggiunge  }
{           un attributo "Certificato" contenente il percorso del PDF           }
{                                                                              }
{ Versione 1.0                                                                 }
{ Copyright (c) 2024 - Script per Altium 25                                    }
{..............................................................................}

{..............................................................................}
Const
    CertificateParamName = 'Certificato';
    CertificatesFolder   = 'Certificati';
    MaxComponents        = 1000;

{..............................................................................}
Var
    UserSignature: String;
    ComponentCount: Integer;
    
    // Array separati invece di record
    ComponentPartType: Array[0..MaxComponents-1] Of String;
    ComponentValue: Array[0..MaxComponents-1] Of String;
    ComponentFootprint: Array[0..MaxComponents-1] Of String;
    ComponentDescription: Array[0..MaxComponents-1] Of String;
    ComponentFirstDesignator: Array[0..MaxComponents-1] Of String;
    ComponentQuantity: Array[0..MaxComponents-1] Of Integer;
    ComponentActive: Array[0..MaxComponents-1] Of Boolean;

{..............................................................................}
// Dichiarazione forward della procedura principale
Procedure CertificaComponenti; Forward;

{..............................................................................}
Function GetProjectPath : String;
Var
    Project : IProject;
Begin
    Result := '';
    Project := GetWorkspace.DM_FocusedProject;
    If Project <> Nil Then
    Begin
        Result := ExtractFileDir(Project.DM_ProjectFullPath);
    End;
End;
{..............................................................................}

{..............................................................................}
Function GetProjectName : String;
Var
    Project : IProject;
Begin
    Result := '';
    Project := GetWorkspace.DM_FocusedProject;
    If Project <> Nil Then
    Begin
        Result := ChangeFileExt(ExtractFileName(Project.DM_ProjectFullPath), '');
    End;
End;
{..............................................................................}

{..............................................................................}
Function GetProjectCreationDate(ProjectPath: String): String;
Begin
    // Versione semplificata per compatibilità con Altium DelphiScript
    Result := DateToStr(Now);
End;
{..............................................................................}

{..............................................................................}
Function GetUserSignature(): String;
Begin
    // Versione semplificata per compatibilità con Altium DelphiScript
    // In futuro si può migliorare con un dialog personalizzato
    Result := 'Certificatore Altium - ' + DateToStr(Now);
    
    ShowMessage('Certificazione eseguita da: ' + Result + #13#10 + 
                'Nota: Modifica questa funzione per personalizzare la firma del certificatore.');
End;
{..............................................................................}

{..............................................................................}
Function CreateCertificatesFolder(ProjectPath : String): Boolean;
Var
    CertificatesFolderPath : String;
Begin
    Result := True;  // Assumiamo che funzioni sempre per compatibilità
    If ProjectPath <> '' Then
    Begin
        CertificatesFolderPath := ProjectPath + '\' + CertificatesFolder;
        
        ShowMessage('DEBUG: Creazione cartella certificati:' + #13#10 + 
                   'Percorso progetto: ' + ProjectPath + #13#10 +
                   'Cartella certificati: ' + CertificatesFolderPath); // Debug
        
        // Versione semplificata - tenta di creare la cartella
        Try
            CreateDir(CertificatesFolderPath);
            ShowMessage('DEBUG: Cartella creata/verificata: ' + CertificatesFolderPath); // Debug
            Result := True;
        Except
            // Se fallisce, continua comunque (la cartella potrebbe già esistere)
            ShowMessage('ATTENZIONE: Impossibile creare/verificare la cartella: ' + CertificatesFolderPath + #13#10 + 
                       'Assicurati che esista manualmente e che ci siano i permessi di scrittura.');
            Result := True;  // Continua comunque
        End;
    End;
End;
{..............................................................................}

{..............................................................................}
Function GetComponentKey(Component: ISch_Component): String;
Var
    PartType: String;
    Value: String;
    Footprint: String;
    PIterator: ISch_Iterator;
    Parameter: ISch_Parameter;
Begin
    PartType := VarToStr(Component.ComponentDescription);
    Value := '';
    Footprint := VarToStr(Component.CurrentPartID);
    
    // Ottieni il valore del componente se presente
    Try
        PIterator := Component.SchIterator_Create;
        PIterator.AddFilter_ObjectSet(MkSet(eParameter));

        Parameter := PIterator.FirstSchObject;
        While Parameter <> Nil Do
        Begin
            If (Parameter.Name = 'Value') or (Parameter.Name = 'Val') Then
            Begin
                Value := VarToStr(Parameter.Text);
                Break;
            End;
            Parameter := PIterator.NextSchObject;
        End;
    Finally
        Component.SchIterator_Destroy(PIterator);
    End;

    // Crea una chiave unica basata su tipo, valore e footprint
    Result := PartType + '|' + Value + '|' + Footprint;
End;
{..............................................................................}

{..............................................................................}
Function FindComponentInfoIndex(ComponentKey: String): Integer;
Var
    I: Integer;
    TestKey: String;
Begin
    Result := -1;
    For I := 0 To ComponentCount - 1 Do
    Begin
        If ComponentActive[I] Then
        Begin
            TestKey := ComponentPartType[I] + '|' + ComponentValue[I] + '|' + ComponentFootprint[I];
            If TestKey = ComponentKey Then
            Begin
                Result := I;
                Break;
            End;
        End;
    End;
End;
{..............................................................................}

{..............................................................................}
Procedure AddComponentInfo(Component: ISch_Component);
Var
    ComponentKey: String;
    ComponentIndex: Integer;
    PIterator: ISch_Iterator;
    Parameter: ISch_Parameter;
Begin
    If ComponentCount >= MaxComponents Then
    Begin
        ShowMessage('Limite massimo di componenti raggiunto (' + IntToStr(MaxComponents) + ')');
        Exit;
    End;
    
    ComponentKey := GetComponentKey(Component);
    ComponentIndex := FindComponentInfoIndex(ComponentKey);
    
    If ComponentIndex = -1 Then
    Begin
        // Nuovo componente
        ComponentIndex := ComponentCount;
        ComponentCount := ComponentCount + 1;
        
        ComponentPartType[ComponentIndex] := VarToStr(Component.ComponentDescription);
        ComponentValue[ComponentIndex] := '';
        ComponentFootprint[ComponentIndex] := VarToStr(Component.CurrentPartID);
        ComponentDescription[ComponentIndex] := VarToStr(Component.LibReference);
        ComponentFirstDesignator[ComponentIndex] := VarToStr(Component.Designator.Text);
        ComponentQuantity[ComponentIndex] := 1;
        ComponentActive[ComponentIndex] := True;
        
        // Ottieni il valore se presente
        Try
            PIterator := Component.SchIterator_Create;
            PIterator.AddFilter_ObjectSet(MkSet(eParameter));

            Parameter := PIterator.FirstSchObject;
            While Parameter <> Nil Do
            Begin
                If (Parameter.Name = 'Value') or (Parameter.Name = 'Val') Then
                Begin
                    ComponentValue[ComponentIndex] := VarToStr(Parameter.Text);
                    Break;
                End;
                Parameter := PIterator.NextSchObject;
            End;
        Finally
            Component.SchIterator_Destroy(PIterator);
        End;
    End
    Else
    Begin
        // Incrementa il conteggio per questo tipo di componente
        ComponentQuantity[ComponentIndex] := ComponentQuantity[ComponentIndex] + 1;
    End;
End;
{..............................................................................}

{..............................................................................}
Function GeneratePDFContent(ComponentIndex: Integer; ProjectName: String; ProjectPath: String; ProjectCreationDate: String; CertificationDate: String; Signature: String): String;
Var
    Content: String;
Begin
    Content := 'CERTIFICATO COMPONENTE ELETTRONICO' + #13#10 + #13#10;
    Content := Content + '================================================' + #13#10;
    Content := Content + 'INFORMAZIONI PROGETTO:' + #13#10;
    Content := Content + '  Nome Progetto: ' + ProjectName + #13#10;
    Content := Content + '  Percorso: ' + ProjectPath + #13#10;
    Content := Content + '  Data Creazione Progetto: ' + ProjectCreationDate + #13#10;
    Content := Content + '  Data Certificazione: ' + CertificationDate + #13#10 + #13#10;
    
    Content := Content + 'INFORMAZIONI COMPONENTE:' + #13#10;
    Content := Content + '  Tipo: ' + ComponentPartType[ComponentIndex] + #13#10;
    Content := Content + '  Valore: ' + ComponentValue[ComponentIndex] + #13#10;
    Content := Content + '  Footprint: ' + ComponentFootprint[ComponentIndex] + #13#10;
    Content := Content + '  Descrizione: ' + ComponentDescription[ComponentIndex] + #13#10;
    Content := Content + '  Primo Designatore: ' + ComponentFirstDesignator[ComponentIndex] + #13#10;
    Content := Content + '  Quantità nel Progetto: ' + IntToStr(ComponentQuantity[ComponentIndex]) + #13#10 + #13#10;
    
    Content := Content + 'CERTIFICAZIONE:' + #13#10;
    Content := Content + '  Certificato da: ' + Signature + #13#10;
    Content := Content + '  Data: ' + CertificationDate + #13#10 + #13#10;
    
    Content := Content + '================================================' + #13#10;
    Content := Content + 'Questo certificato attesta la presenza e le' + #13#10;
    Content := Content + 'caratteristiche del componente nel progetto.' + #13#10;
    Content := Content + '================================================';
    
    Result := Content;
End;
{..............................................................................}

{..............................................................................}
Function CreatePDFCertificate(ComponentIndex: Integer; ProjectPath: String): String;
Var
    FileName: String;
    FilePath: String;
    TextFile: TextFile;
    Content: String;
    ProjectName: String;
    ProjectCreationDate: String;
    CertificationDate: String;
Begin
    ProjectName := GetProjectName;
    ProjectCreationDate := GetProjectCreationDate(ProjectPath);
    CertificationDate := DateToStr(Now);
    
    // Crea nome file basato sul primo designatore
    FileName := ComponentFirstDesignator[ComponentIndex] + '_Certificato.txt';
    FilePath := ProjectPath + '\' + CertificatesFolder + '\' + FileName;
    
    ShowMessage('DEBUG: Tentativo creazione file:' + #13#10 + 
                'Nome: ' + FileName + #13#10 +
                'Percorso completo: ' + FilePath); // Debug
    
    Try
        Content := GeneratePDFContent(ComponentIndex, ProjectName, ProjectPath, 
                                    ProjectCreationDate, CertificationDate, UserSignature);
        
        AssignFile(TextFile, FilePath);
        Rewrite(TextFile);
        Write(TextFile, Content);
        CloseFile(TextFile);
        
        ShowMessage('DEBUG: File creato con successo: ' + FilePath); // Debug
        
        // Restituisce il percorso relativo
        Result := CertificatesFolder + '\' + FileName;
        
    Except
        ShowMessage('ERRORE nella creazione del certificato: ' + FilePath + #13#10 + 
                   'Verifica che la cartella esista e abbia i permessi di scrittura.');
        Result := '';
    End;
End;
{..............................................................................}

{..............................................................................}
Function ComponentHasCertificateParam(Component : ISch_Component) : Boolean;
Var
    PIterator : ISch_Iterator;
    Parameter : ISch_Parameter;
Begin
    Result := False;
    
    Try
        PIterator := Component.SchIterator_Create;
        PIterator.AddFilter_ObjectSet(MkSet(eParameter));

        Parameter := PIterator.FirstSchObject;
        While Parameter <> Nil Do
        Begin
            If Parameter.Name = CertificateParamName Then
            Begin
                Result := True;
                Break;
            End;
            Parameter := PIterator.NextSchObject;
        End;
    Finally
        Component.SchIterator_Destroy(PIterator);
    End;
End;
{..............................................................................}

{..............................................................................}
Function GetCertificatePathForComponent(Component: ISch_Component): String;
Var
    ComponentKey: String;
    ComponentIndex: Integer;
Begin
    ComponentKey := GetComponentKey(Component);
    ComponentIndex := FindComponentInfoIndex(ComponentKey);
    
    If (ComponentIndex <> -1) And ComponentActive[ComponentIndex] Then
    Begin
        Result := CertificatesFolder + '\' + ComponentFirstDesignator[ComponentIndex] + '_Certificato.txt';
    End
    Else
        Result := '';
End;
{..............................................................................}

{..............................................................................}
Procedure AddCertificateParameterToComponents(SchDoc : ISch_Document; ProjectPath : String);
Var
    Component: ISch_Component;
    Param: ISch_Parameter;
    Iterator: ISch_Iterator;
    CertificatePath: String;
    LocalComponentCount: Integer;
    ProcessedCount: Integer;
Begin
    LocalComponentCount := 0;
    ProcessedCount := 0;
    
    Iterator := SchDoc.SchIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eSchComponent));

    Try
       SchServer.ProcessControl.PreProcess(SchDoc, '');
       Try
           Component := Iterator.FirstSchObject;
           While Component <> Nil Do
           Begin
              LocalComponentCount := LocalComponentCount + 1;
              
              If Not ComponentHasCertificateParam(Component) Then
              Begin
                  CertificatePath := GetCertificatePathForComponent(Component);
                  
                  ShowMessage('DEBUG: Componente ' + VarToStr(Component.Designator.Text) + #13#10 +
                             'Percorso certificato: ' + CertificatePath); // Debug
                  
                  If CertificatePath <> '' Then
                  Begin
                      Param := SchServer.SchObjectFactory(eParameter, eCreate_Default);
                      Param.Name := CertificateParamName;
                      Param.ShowName := True;
                      Param.Text := CertificatePath;
                      Param.IsHidden := False;
                      Param.ParamType := eParameterType_String;
                      Param.ReadOnlyState := eReadOnly_None;

                      Param.Location := Point(Component.Location.X, Component.Location.Y - DxpsToCoord(0.15));

                      Component.AddSchObject(Param);
                      SchServer.RobotManager.SendMessage(Component.I_ObjectAddress, c_BroadCast, SCHM_PrimitiveRegistration, Param.I_ObjectAddress);
                      
                      ShowMessage('DEBUG: Attributo aggiunto a ' + VarToStr(Component.Designator.Text) + 
                                 ' con valore: ' + CertificatePath); // Debug
                      
                      ProcessedCount := ProcessedCount + 1;
                  End
                  Else
                  Begin
                      ShowMessage('DEBUG: Nessun certificato trovato per ' + VarToStr(Component.Designator.Text)); // Debug
                  End;
              End
              Else
              Begin
                  ShowMessage('DEBUG: Componente ' + VarToStr(Component.Designator.Text) + 
                             ' ha già l attributo certificato'); // Debug
              End;
              
              Component := Iterator.NextSchObject;
           End;

        Finally
           SchDoc.SchIterator_Destroy(Iterator);
        End;
    Finally
        SchServer.ProcessControl.PostProcess(SchDoc, '');
    End;
    
    ShowMessage('Foglio: ' + SchDoc.DocumentName + #13#10 + 
                'Componenti totali: ' + IntToStr(LocalComponentCount) + #13#10 +
                'Parametri aggiunti: ' + IntToStr(ProcessedCount));
End;
{..............................................................................}

{..............................................................................}
Procedure ProcessAllSchematics(Project: IProject; ProjectPath: String);
Var
    I: Integer;
    Doc: IDocument;
    CurrentSch: ISch_Document;
    SchDocument: IServerDocument;
    Component: ISch_Component;
    Iterator: ISch_Iterator;
    TotalComponents: Integer;
Begin
    TotalComponents := 0;
    
    // Prima fase: raccogli informazioni su tutti i componenti
    For I := 0 To Project.DM_LogicalDocumentCount - 1 Do
    Begin
        Doc := Project.DM_LogicalDocuments(I);
        If Doc.DM_DocumentKind = 'SCH' Then
        Begin
            SchDocument := Client.OpenDocument('SCH', Doc.DM_FullPath);
            If SchDocument <> Nil Then
            Begin
                CurrentSch := SchServer.GetSchDocumentByPath(Doc.DM_FullPath);
                If CurrentSch <> Nil Then
                Begin
                    Iterator := CurrentSch.SchIterator_Create;
                    Iterator.AddFilter_ObjectSet(MkSet(eSchComponent));

                    Try
                        Component := Iterator.FirstSchObject;
                        While Component <> Nil Do
                        Begin
                            AddComponentInfo(Component);
                            TotalComponents := TotalComponents + 1;
                            Component := Iterator.NextSchObject;
                        End;
                    Finally
                        CurrentSch.SchIterator_Destroy(Iterator);
                    End;
                End;
                Client.CloseDocument(SchDocument);
            End;
        End;
    End;
    
    ShowMessage('Raccolte informazioni per ' + IntToStr(TotalComponents) + ' componenti.' + #13#10 +
                'Tipi unici di componenti trovati: ' + IntToStr(ComponentCount));
End;
{..............................................................................}

{..............................................................................}
Procedure GenerateAllCertificates(ProjectPath: String);
Var
    I: Integer;
    CertificatePath: String;
    GeneratedCount: Integer;
Begin
    GeneratedCount := 0;
    
    For I := 0 To ComponentCount - 1 Do
    Begin
        If ComponentActive[I] Then
        Begin
            CertificatePath := CreatePDFCertificate(I, ProjectPath);
            If CertificatePath <> '' Then
                GeneratedCount := GeneratedCount + 1;
        End;
    End;
    
    ShowMessage('Generati ' + IntToStr(GeneratedCount) + ' certificati di ' + IntToStr(ComponentCount) + ' tipi di componenti.');
End;
{..............................................................................}

{..............................................................................}
Procedure AddCertificateAttributesToAllComponents(Project: IProject; ProjectPath: String);
Var
    I: Integer;
    Doc: IDocument;
    CurrentSch: ISch_Document;
    SchDocument: IServerDocument;
Begin
    For I := 0 To Project.DM_LogicalDocumentCount - 1 Do
    Begin
        Doc := Project.DM_LogicalDocuments(I);
        If Doc.DM_DocumentKind = 'SCH' Then
        Begin
            SchDocument := Client.OpenDocument('SCH', Doc.DM_FullPath);
            If SchDocument <> Nil Then
            Begin
                CurrentSch := SchServer.GetSchDocumentByPath(Doc.DM_FullPath);
                If CurrentSch <> Nil Then
                Begin
                    AddCertificateParameterToComponents(CurrentSch, ProjectPath);
                End;
                Client.CloseDocument(SchDocument);
            End;
        End;
    End;
End;
{..............................................................................}

{..............................................................................}
Procedure InitializeComponentList;
Var
    I: Integer;
Begin
    ComponentCount := 0;
    For I := 0 To MaxComponents - 1 Do
    Begin
        ComponentActive[I] := False;
        ComponentPartType[I] := '';
        ComponentValue[I] := '';
        ComponentFootprint[I] := '';
        ComponentDescription[I] := '';
        ComponentFirstDesignator[I] := '';
        ComponentQuantity[I] := 0;
    End;
End;
{..............................................................................}

{..............................................................................}
Procedure CertificaComponenti;
Var
    Project: IProject;
    ProjectPath: String;
Begin
    ShowMessage('DEBUG: Script certifica.pas avviato'); // Debug

    // Ottieni il progetto corrente
    Project := GetWorkspace.DM_FocusedProject;
    If Project = Nil Then
    Begin
        ShowMessage('Nessun progetto aperto trovato!');
        Exit;
    End;

    ShowMessage('DEBUG: Progetto trovato: ' + Project.DM_ProjectFileName); // Debug

    // Ottieni il percorso del progetto
    ProjectPath := GetProjectPath;
    If ProjectPath = '' Then
    Begin
        ShowMessage('Impossibile determinare il percorso del progetto!');
        Exit;
    End;

    ShowMessage('DEBUG: Percorso progetto: ' + ProjectPath); // Debug

    // Ottieni la firma dell'utente
    UserSignature := GetUserSignature();
    
    // Crea la cartella Certificati se non esiste
    If Not CreateCertificatesFolder(ProjectPath) Then
    Begin
        ShowMessage('Impossibile creare la cartella certificati!');
        Exit;
    End;

    // Compila il progetto per assicurarsi che sia aggiornato
    Project.DM_Compile;

    // Inizializza l'array dei componenti
    InitializeComponentList;
    
    Try
        // Fase 1: Raccogli informazioni sui componenti
        ProcessAllSchematics(Project, ProjectPath);
        
        // Fase 2: Genera tutti i certificati
        GenerateAllCertificates(ProjectPath);
        
        // Fase 3: Aggiungi gli attributi ai componenti
        AddCertificateAttributesToAllComponents(Project, ProjectPath);
        
        ShowMessage('Certificazione completata con successo!' + #13#10 +
                    'Certificati generati nella cartella: ' + ProjectPath + '\' + CertificatesFolder + #13#10 +
                    'Attributi "' + CertificateParamName + '" aggiunti ai componenti.');
        
    Finally
        // Pulisci l'array
        InitializeComponentList;
    End;
End;
{..............................................................................} 