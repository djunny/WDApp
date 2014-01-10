program v8;

uses
  sysutils,
  ceflib,
  Windows,
  Forms,
  main in 'main.pas' {MainForm},
  ceffilescheme in '..\filescheme\ceffilescheme.pas';

{$R *.res}

procedure RegisterSchemes(const registrar: ICefSchemeRegistrar);
begin
  registrar.AddCustomScheme('local', True, True, False);
end;

begin
   ReportMemoryLeaksOnShutdown := DebugHook<>0;
  CefOnRegisterCustomSchemes := RegisterSchemes;
  CefSingleProcess := true;
  if not CefLoadLibDefault then
    Exit;

  CefRegisterSchemeHandlerFactory('local', '', False, TFileScheme);

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

