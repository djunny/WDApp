program v8;

uses
  sysutils,
  ceflib,
  Windows,
  Forms,
  main in 'main.pas' {MainForm},
  mzscheme;

{$R *.res}

procedure RegisterSchemes(const registrar: ICefSchemeRegistrar);
begin
  registrar.AddCustomScheme('mz', True, True, False);
end;

begin
  ReportMemoryLeaksOnShutdown := DebugHook<>0;
  CefOnRegisterCustomSchemes := RegisterSchemes;
  CefSingleProcess := true;//DebugHook<>0;
  if not CefLoadLibDefault then
    Exit;

  CefRegisterSchemeHandlerFactory('mz', '', False, TMzScheme);

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

