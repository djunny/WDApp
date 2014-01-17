program WDApp;

uses
  Forms,
  fMain,
  uScheme,
  ceflib,
  uConst;

{$R *.res}


procedure CefOnRegisterCustomSchemes(const registrar: ICefSchemeRegistrar);
begin
  registrar.AddCustomScheme(WDAPP_PROTOCOL, True, False, False);
end;


begin
  ReportMemoryLeaksOnShutdown := DebugHook<>0;
  CefCache := WDAPP_DATAPATH+ 'cache/';
  CefRegisterCustomSchemes := CefOnRegisterCustomSchemes;
  CefRegisterSchemeHandlerFactory(WDAPP_PROTOCOL, '', True, TWDAppScheme);
  //auto detect proxy
  CefAutoDetectProxySettings := true;

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
