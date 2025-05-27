{$INCLUDE ComponentsLister.pas}

Const
  ProjectFilePath = 'None';
  DataFolder = 'C:\Users\ricca\Desktop\Altium Scripting/scripting_project/data/';

// Procedura per il logging (semplice implementazione)
procedure log_str(msg: String);
begin
  // Puoi implementare il logging come preferisci
  // Per ora usiamo un semplice messaggio
  // ShowMessage('LOG: ' + msg);
end;

Procedure SCRIPTING_SYSTEM_MAIN;
Var
  Document: IDocument;
Begin
  log_str('Starting script');
  If AnsiCompareStr(ProjectFilePath, 'None') <> 0 then // Corretta la condizione
  Begin
    log_str('Opening project: ' + ProjectFilePath);
    Document := Client.OpenDocument('PcbProject', ProjectFilePath);
    Client.ShowDocument(Document);
  End;
  ComponentsLister(); // Nota: nome corretto con C maiuscola
  DeleteFile(DataFolder + 'running')
End;

// Procedura principale
procedure Main;
begin
    SCRIPTING_SYSTEM_MAIN;
end;

// Inizializzazione automatica dello script
begin
    Main;
end. 