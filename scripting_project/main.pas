
Const
  ProjectFilePath = 'None';
  DataFolder = '\\192.168.10.89\Multimedia\Altium Scripting/scripting_project/data/';

Procedure SCRIPTING_SYSTEM_MAIN;
Var
  Document: IDocument;
Begin
  log_str('Starting script');
  If AnsiCompareStr(ProjectFilePath, 'None') then
  Begin
    log_str('Opening project: ' + ProjectFilePath);
    Document := Client.OpenDocument('PcbProject', ProjectFilePath);
    Client.ShowDocument(Document);
  End;
  certificacomponenti();
  DeleteFile(DataFolder + 'running')
End;