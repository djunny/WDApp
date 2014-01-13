program TDApp;

uses
  ceflib,
  Forms,
  fMain in 'fMain.pas' {MainForm},
  uScheme,
  uConst;

{$R *.res}

procedure RegisterSchemes(const registrar: ICefSchemeRegistrar);
begin
  registrar.AddCustomScheme(TDAPP_PROTOCOL, True, True, False);
end;

begin
  ReportMemoryLeaksOnShutdown := DebugHook<>0;
  CefOnRegisterCustomSchemes := RegisterSchemes;
  CefSingleProcess := DebugHook<>0;
  //CefSingleProcess := false;
  if not CefLoadLibDefault then
    Exit;

  CefRegisterSchemeHandlerFactory(TDAPP_PROTOCOL, '', False, TTDAppScheme);

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

