unit uWDAppCef;

interface

uses
  windows,
  Messages,
  controls,
  SysUtils,
  ceflib,
  Classes;

type
  //cef process handler
  TCustomV8ContextHandler = class(Tobject)
  public
    procedure OnContextCreated(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;const context: ICefv8Context);

    procedure OnContextReleased(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context);
  end;

  //cef external handler
  TExternalHandler = class(TCefv8HandlerOwn)
  public
    context : ICefv8Context;
    constructor Create(); override;
  end;
  TExternalClass = class of TExternalHandler;

var
   ExternalClass : TExternalClass;

//get browser message
procedure CefAddExternalFunction(Functions : array of String);
function GetBrowserWindow(Browser:ICefBrowser):HWND;

implementation

uses uCommon,
     uConst,
     dialogs;

var
  ExternalList  : TStringList;


function GetBrowserWindow(Browser:ICefBrowser):HWND;
begin
  result := GetAncestor(Browser.GetWindowHandle, GA_ROOT);//;
end;


procedure CefAddExternalFunction(Functions : array of String);
var
  Func : String;
begin
  if ExternalList=Nil then
    ExternalList := TStringList.Create;
  for Func In Functions do
  begin
    ExternalList.Add(Func);
  end;
end;

constructor TExternalHandler.Create();
begin
  inherited create;
end;

procedure TCustomV8ContextHandler.OnContextReleased(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context);
begin

end;

procedure TCustomV8ContextHandler.OnContextCreated(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    const context: ICefv8Context);
var
  Ext   : TExternalHandler;
  obj   : ICefV8Value;
  funcs : ICefv8Value;
  Func  : ICefv8Value;
  i     : integer;
  procedure addFunc(name:string;attr:TCefV8PropertyAttributes=V8_PROPERTY_ATTRIBUTE_READONLY);
  begin
    Func  := TCefv8ValueRef.CreateFunction(name, Ext);
    funcs.SetValueByKey(name, Func, attr);
  end;
begin
  if(ExternalList <> Nil)
    AND(assigned(ExternalList)) then
  begin
    Ext   := ExternalClass.Create;
    Ext.context := context;
    obj   := context.Global;
    funcs := TCefv8ValueRef.CreateObject(nil);
    for i := 0 to ExternalList.Count -1 do
    begin
      addFunc(ExternalList[i]);
    end;
    obj.SetValueByKey(WDAPP_EXTERNAL, funcs, V8_PROPERTY_ATTRIBUTE_READONLY);
  end;
end;


initialization

finalization
  if ExternalList <> Nil then
    FreeAndNil(ExternalList);
end.

