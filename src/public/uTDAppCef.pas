unit uTDAppCef;

interface

uses
  windows,
  Messages,
  controls,
  SysUtils,
  ExtCtrls,
  ceflib,
  Classes;

type
  // get message from cefvcl
  TCefPanel = class(TPanel)
  private
    FBrowser: ICefBrowser;
    procedure DoClick(Sender: Tobject);
  public
    property Browser: ICefBrowser read FBrowser;
    procedure Resize; override;
    procedure WndProc(var Message: TMessage); override;
    constructor Create(AOwner: TComponent; Browser: ICefBrowser);
  end;

  TOnExternalExecute = function(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring;context : ICefv8Context): Boolean of object;

  TOnProcessMessageReceived = function(const browser: ICefBrowser; sourceProcess: TCefProcessId;
      const message: ICefProcessMessage): Boolean of object;

  TBrowserGlobal = class(TObject)
  private
    FOnExternalExecute : TOnExternalExecute;
    FOnProcessMessageReceived : TOnProcessMessageReceived;
  public
    property OnProcessMessageReceived : TOnProcessMessageReceived read FOnProcessMessageReceived write FOnProcessMessageReceived;
    property OnExternalExecute : TOnExternalExecute read FOnExternalExecute write FOnExternalExecute;
  end;


  //cef process handler
  TCustomRenderProcessHandler = class(TCefRenderProcessHandlerOwn)
  protected
    procedure OnWebKitInitialized; override;
    function OnProcessMessageReceived(const browser: ICefBrowser; sourceProcess: TCefProcessId;
      const message: ICefProcessMessage): Boolean; override;

    procedure OnContextCreated(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context);override;


    procedure OnContextReleased(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context);override;
  end;

  //cef browser handler
  TBrowserProcessHandlerOwn = class(TCefBrowserProcessHandlerOwn)
  protected
    procedure OnContextInitialized; override;
    procedure OnBeforeChildProcessLaunch(const commandLine: ICefCommandLine); override;
    procedure OnRenderProcessThreadCreated(const extraInfo: ICefListValue);  override;
  end;


  //cef external handler
  TExternalHandler = class(TCefv8HandlerOwn)
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean; override;
  public
    context : ICefv8Context;
    constructor Create(); reintroduce;
  end;


//get browser message
function GetBrowserGlobal:TBrowserGlobal;
procedure CefAddExternalFunction(Functions : array of String);
procedure CefSendProcessMessage(Browser:ICefBrowser;arguments: TCefv8ValueArray;messageName:String);


implementation

uses uCommon, uConst;

var
  ExternalList  : TStringList;
  BrowserGlobal : TBrowserGlobal;

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

function getBrowserGlobal:TBrowserGlobal;
begin
  if BrowserGlobal = NIl then
  begin
    BrowserGlobal := TBrowserGlobal.Create;
  end;
  result := BrowserGlobal;
end;


procedure CefSendProcessMessage(Browser:ICefBrowser;arguments: TCefv8ValueArray;messageName:String);
var
  cefMessage : ICefProcessMessage;
  cefArgs    : ICefListValue;
  argIndex,argLen : integer;
begin
  cefMessage := TCefProcessMessageRef.New(messageName);
  argLen     := Length(arguments);
  if argLen > 0 then
  begin
    for argIndex := 0 to argLen-1 do
    begin
      if arguments[argIndex].IsString then
      begin
        cefMessage.ArgumentList.SetString(argIndex, arguments[argIndex].GetStringValue);
      end
      else if arguments[argIndex].IsInt then
      begin
        cefMessage.ArgumentList.SetInt(argIndex, arguments[argIndex].GetIntValue);
      end
      else if arguments[argIndex].IsBool then
      begin
        cefMessage.ArgumentList.SetBool(argIndex, arguments[argIndex].GetBoolValue);
      end
      else if(arguments[argIndex].IsDouble)
            OR(arguments[argIndex].IsDate) then
      begin
        cefMessage.ArgumentList.SetDouble(argIndex, arguments[argIndex].GetDoubleValue);
      end
      else if arguments[argIndex].IsObject then
      begin
        //@to do check type
      end;
    end;
  end;
  Browser.SendProcessMessage(PID_BROWSER, cefMessage);
end;


constructor TCefPanel.Create(AOwner: TComponent; Browser: ICefBrowser);
begin
  inherited Create(AOwner);
  FBrowser := Browser;
  self.OnClick := DoClick;
end;

procedure TCefPanel.DoClick(Sender: Tobject);
begin
  SendMessage(FBrowser.Host.WindowHandle, WM_SETFOCUS, 0, 0);
end;

procedure TCefPanel.Resize;
begin
  self.Invalidate;
  SendMessage(FBrowser.Host.windowHandle, CM_INVALIDATE, 0, 0);
end;

procedure TCefPanel.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_SETFOCUS:
      begin
        if (FBrowser <> nil) and (FBrowser.Host.WindowHandle <> 0) then
          PostMessage(FBrowser.Host.WindowHandle, WM_SETFOCUS, Message.WParam,
            0);
        inherited WndProc(Message);
      end;
    WM_ERASEBKGND:
      if (csDesigning in ComponentState) or (FBrowser = nil) or
        (FBrowser.host.WindowHandle <> 0) then
        inherited WndProc(Message);
    CM_WANTSPECIALKEY:
      if not (TWMKey(Message).CharCode in [VK_LEFT..VK_DOWN]) then
        Message.Result := 1
      else
        inherited WndProc(Message);
    WM_GETDLGCODE:
      Message.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
  else
    inherited WndProc(Message);
  end;
end;



constructor TExternalHandler.Create();
begin
  inherited create;
end;

function TExternalHandler.Execute(const name: ustring; const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring): Boolean;
begin
  if assigned(GetBrowserGlobal.OnExternalExecute) then
    Result := GetBrowserGlobal.OnExternalExecute(name, obj, arguments, retval, exception, context);
end;

procedure TCustomRenderProcessHandler.OnContextReleased(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context);
begin

end;

procedure TCustomRenderProcessHandler.OnContextCreated(const browser: ICefBrowser;
  const frame: ICefFrame; const context: ICefv8Context);
var
  Ext   : TExternalHandler;
  obj   : ICefV8Value;
  funcs : ICefv8Value;
  Func  : ICefv8Value;
  i     : integer;
  procedure addFunc(name:string;attr:TCefV8PropertyAttributes=[V8_PROPERTY_ATTRIBUTE_READONLY]);
  begin
    Func  := TCefv8ValueRef.NewFunction(name, Ext);
    funcs.SetValueByKey(name, Func, attr);
  end;
begin
  if(ExternalList <> Nil)
    AND(assigned(ExternalList)) then
  begin
    Ext := TExternalHandler.Create;
    Ext.context := context;
    obj := context.Global;
    funcs := TCefv8ValueRef.NewObject(nil);
    for i := 0 to ExternalList.Count -1 do
    begin
      addFunc(ExternalList[i]);
    end;
    obj.SetValueByKey(DAPP_EXTERNAL, funcs, [V8_PROPERTY_ATTRIBUTE_READONLY]);
  end;
end;

function TCustomRenderProcessHandler.OnProcessMessageReceived(
  const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage): Boolean;
begin
  if assigned(GetBrowserGlobal.OnProcessMessageReceived) then
    Result := GetBrowserGlobal.OnProcessMessageReceived(browser, sourceProcess, message);
end;

procedure TCustomRenderProcessHandler.OnWebKitInitialized;
begin

end;


procedure TBrowserProcessHandlerOwn.OnContextInitialized;
begin

end;

procedure TBrowserProcessHandlerOwn.OnBeforeChildProcessLaunch(const commandLine: ICefCommandLine);
begin
end;

procedure TBrowserProcessHandlerOwn.OnRenderProcessThreadCreated(const extraInfo: ICefListValue);
begin

end;

initialization
  CefRemoteDebuggingPort := DAPP_DEV_PORT;
  CefRenderProcessHandler := TCustomRenderProcessHandler.Create;
  CefBrowserProcessHandler := TBrowserProcessHandlerOwn.Create;
finalization
  if BrowserGlobal<>Nil then
    FreeAndNil(BrowserGlobal);
  if ExternalList <> Nil then
    FreeAndNil(ExternalList);
end.

