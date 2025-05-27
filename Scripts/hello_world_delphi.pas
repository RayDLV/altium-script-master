procedure HelloWorld;
begin
    ShowMessage('Hello World da DelphiScript!');
    
    // Aggiungi anche un messaggio nel panel dei messaggi di Altium
    AddStringParameter('Text', 'Hello World - Script eseguito con successo!');
    RunProcess('WorkspaceManager:Print');
end; 