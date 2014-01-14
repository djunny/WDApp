program WDApp;

uses
  ceflib,
  Forms,
  fMain,
  uScheme,
  uConst;

{$R *.res}

procedure RegisterSchemes(const registrar: ICefSchemeRegistrar);
begin
  registrar.AddCustomScheme(WDAPP_PROTOCOL, True, True, False);
end;

begin
  ReportMemoryLeaksOnShutdown := DebugHook<>0;
  CefSingleProcess := DebugHook<>0;
  //CefSingleProcess := false;
  //CefLogFile := WDAPP_DATAPATH + 'log.dat';
  //CefLogSeverity := LOGSEVERITY_DEFAULT;
  CefCache   := WDAPP_DATAPATH + 'cache/';
  CefPersistSessionCookies := true;

  CefOnRegisterCustomSchemes := RegisterSchemes;
  if not CefLoadLibDefault then
    Exit;

  CefRegisterSchemeHandlerFactory(WDAPP_PROTOCOL, '', False, TTDAppScheme);

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

