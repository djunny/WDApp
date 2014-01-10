unit main;

interface
{$I cef.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ceflib, cefvcl, Buttons, ActnList, Menus, ComCtrls,
  ExtCtrls, XPMan, Registry, ShellApi, SyncObjs, mzTabs, AppEvnts;

type
  TMainForm = class(TForm)
    crm: TChromium;
    StatusBar: TStatusBar;
    ActionList: TActionList;
    actPrev: TAction;
    actNext: TAction;
    actHome: TAction;
    actReload: TAction;
    actGoTo: TAction;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    est1: TMenuItem;
    mGetsource: TMenuItem;
    mGetText: TMenuItem;
    actGetSource: TAction;
    actGetText: TAction;
    actZoomIn: TAction;
    actZoomOut: TAction;
    actZoomReset: TAction;
    Zoomin1: TMenuItem;
    Zoomout1: TMenuItem;
    Zoomreset1: TMenuItem;
    actExecuteJS: TAction;
    ExecuteJavaScript1: TMenuItem;
    Exit1: TMenuItem;
    Print1: TMenuItem;
    actFileScheme1: TMenuItem;
    actDom: TAction;
    VisitDOM1: TMenuItem;
    SaveDialog: TSaveDialog;
    actDevTool: TAction;
    DevelopperTools1: TMenuItem;
    debug: TChromium;
    Splitter1: TSplitter;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    edAddress: TEdit;
    SpeedButton5: TSpeedButton;
    actDoc: TAction;
    Help1: TMenuItem;
    Documentation1: TMenuItem;
    actGroup: TAction;
    Googlegroup1: TMenuItem;
    actFileScheme: TAction;
    actChromeDevTool: TAction;
    DebuginChrome1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    procedure edAddressKeyPress(Sender: TObject; var Key: Char);
    procedure actPrevExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actHomeExecute(Sender: TObject);
    procedure actReloadExecute(Sender: TObject);
    procedure actReloadUpdate(Sender: TObject);
    procedure actGoToExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actHomeUpdate(Sender: TObject);
    procedure actGetSourceExecute(Sender: TObject);
    procedure actGetTextExecute(Sender: TObject);
    procedure actZoomInExecute(Sender: TObject);
    procedure actZoomOutExecute(Sender: TObject);
    procedure actZoomResetExecute(Sender: TObject);
    procedure actExecuteJSExecute(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure actFileSchemeExecute(Sender: TObject);
    procedure actDomExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actPrevUpdate(Sender: TObject);
    procedure crmAddressChange(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; const url: ustring);
    procedure crmLoadEnd(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; httpStatusCode: Integer);
    procedure crmLoadStart(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame);
    procedure crmStatusMessage(Sender: TObject; const browser: ICefBrowser;
      const value: ustring);
    procedure crmTitleChange(Sender: TObject; const browser: ICefBrowser;
      const title: ustring);
    procedure actDevToolExecute(Sender: TObject);
    procedure actDocExecute(Sender: TObject);
    procedure actGroupExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure crmBeforeDownload(Sender: TObject; const browser: ICefBrowser;
      const downloadItem: ICefDownloadItem; const suggestedName: ustring;
      const callback: ICefBeforeDownloadCallback);
    procedure crmDownloadUpdated(Sender: TObject; const browser: ICefBrowser;
      const downloadItem: ICefDownloadItem;
      const callback: ICefDownloadItemCallback);
    procedure crmProcessMessageReceived(Sender: TObject;
      const browser: ICefBrowser; sourceProcess: TCefProcessId;
      const message: ICefProcessMessage; out Result: Boolean);
    procedure actChromeDevToolExecute(Sender: TObject);
    procedure crmBeforeResourceLoad(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; const request: ICefRequest; out Result: Boolean);
    procedure crmBeforePopup(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
      var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
      var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean; out Result: Boolean);
    procedure StatusBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ApplicationEvents1ShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
  private
    { D閏larations priv閑s }
    FLoading: Boolean;
    FDevToolLoaded: Boolean;
    function IsMain(const b: ICefBrowser; const f: ICefFrame = nil): Boolean;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  end;

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

  TBrowserProcessHandlerOwn = class(TCefBrowserProcessHandlerOwn)
  protected
    procedure OnContextInitialized; override;
    procedure OnBeforeChildProcessLaunch(const commandLine: ICefCommandLine); override;
    procedure OnRenderProcessThreadCreated(const extraInfo: ICefListValue);  override;
  end;


  TExternalHandler = class(TCefv8HandlerOwn)
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean; override;
  public
    context : ICefv8Context; 
    constructor Create(); reintroduce;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses ufrmShadowFrame;

var
  shadow : TFormShadow;

procedure TMainForm.actChromeDevToolExecute(Sender: TObject);
var
  reg: TRegistry;
  path, url: string;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.OpenKeyReadOnly('\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe') then
      path := ExtractFilePath(reg.ReadString('')) else
      Exit;
  finally
    reg.Free;
  end;

  if DirectoryExists(path) then
  begin
    url := crm.Browser.Host.GetDevToolsUrl(True);
    ShellExecute(0, 'open', 'chrome.exe', PChar(url), PChar(Path), 0);
  end;
end;

procedure TMainForm.actDevToolExecute(Sender: TObject);
begin
  actDevTool.Checked := not actDevTool.Checked;
  debug.Visible := actDevTool.Checked;
  Splitter1.Visible := actDevTool.Checked;
  if actDevTool.Checked then
  begin
    if not FDevToolLoaded then
    begin
      debug.Load(crm.Browser.Host.GetDevToolsUrl(True));
      FDevToolLoaded := True;
    end;
  end;
end;

procedure TMainForm.actDocExecute(Sender: TObject);
begin
  crm.Load('http://magpcss.org/ceforum/apidocs3');
end;

procedure TMainForm.actDomExecute(Sender: TObject);
begin
  crm.browser.SendProcessMessage(PID_RENDERER, TCefProcessMessageRef.New('visitdom'));
end;

procedure TMainForm.actExecuteJSExecute(Sender: TObject);
begin
  if crm.Browser <> nil then
    crm.Browser.MainFrame.ExecuteJavaScript(
      'alert(''JavaScript execute works!'');', 'about:blank', 0);
end;

procedure TMainForm.actFileSchemeExecute(Sender: TObject);
begin
  if crm.Browser <> nil then
    crm.Browser.MainFrame.LoadUrl('local://c/');
end;

procedure CallbackGetSource(const src: ustring);
var
  source: ustring;
begin
  source := src;
  source := StringReplace(source, '<', '&lt;', [rfReplaceAll]);
  source := StringReplace(source, '>', '&gt;', [rfReplaceAll]);
  source := '<html><body>Source:<pre>' + source + '</pre></body></html>';
  MainForm.crm.Browser.MainFrame.LoadString(source, '');
end;

procedure TMainForm.actGetSourceExecute(Sender: TObject);
begin
  crm.Browser.MainFrame.GetSourceProc(CallbackGetSource);
end;

procedure CallbackGetText(const txt: ustring);
var
  source: ustring;
begin
  source := txt;
  source := StringReplace(source, '<', '&lt;', [rfReplaceAll]);
  source := StringReplace(source, '>', '&gt;', [rfReplaceAll]);
  source := '<html><body>Text:<pre>' + source + '</pre></body></html>';
  MainForm.crm.Browser.MainFrame.LoadString(source, '');
end;

procedure TMainForm.actGetTextExecute(Sender: TObject);
begin
  crm.Browser.MainFrame.GetTextProc(CallbackGetText);
end;

procedure TMainForm.actGoToExecute(Sender: TObject);
begin
  if crm.Browser <> nil then
    crm.Browser.MainFrame.LoadUrl(edAddress.Text);
end;

procedure TMainForm.actGroupExecute(Sender: TObject);
begin
  crm.Load('https://groups.google.com/forum/?fromgroups#!forum/delphichromiumembedded');
end;

procedure TMainForm.actHomeExecute(Sender: TObject);
begin
  if crm.Browser <> nil then
    crm.Browser.MainFrame.LoadUrl(crm.DefaultUrl);
end;

procedure TMainForm.actHomeUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := crm.Browser <> nil;
end;

procedure TMainForm.actNextExecute(Sender: TObject);
begin
  if crm.Browser <> nil then
    crm.Browser.GoForward;
end;

procedure TMainForm.actNextUpdate(Sender: TObject);
begin
  if crm.Browser <> nil then
    actNext.Enabled := crm.Browser.CanGoForward else
    actNext.Enabled := False;
end;

procedure TMainForm.actPrevExecute(Sender: TObject);
begin
  if crm.Browser <> nil then
    crm.Browser.GoBack;
end;

procedure TMainForm.actPrevUpdate(Sender: TObject);
begin
  if crm.Browser <> nil then
    actPrev.Enabled := crm.Browser.CanGoBack else
    actPrev.Enabled := False;
end;

procedure TMainForm.actReloadExecute(Sender: TObject);
begin
  if crm.Browser <> nil then
    if FLoading then
      crm.Browser.StopLoad else
      crm.Browser.Reload;
end;

procedure TMainForm.actReloadUpdate(Sender: TObject);
begin
  if FLoading then
    TAction(sender).Caption := 'X' else
    TAction(sender).Caption := 'R';
  TAction(Sender).Enabled := crm.Browser <> nil;
end;

function TMainForm.IsMain(const b: ICefBrowser; const f: ICefFrame): Boolean;
begin
  Result := (b <> nil) and (b.Identifier = crm.BrowserId) and ((f = nil) or (f.IsMain));
end;

procedure TMainForm.StatusBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  SendMessage(Self.handle, WM_SYSCOMMAND, SC_MOVE + HTCAPTION,0);
end;

procedure TMainForm.actZoomInExecute(Sender: TObject);
begin
  if crm.Browser <> nil then
    crm.Browser.Host.ZoomLevel := crm.Browser.Host.ZoomLevel + 0.5;
end;

procedure TMainForm.actZoomOutExecute(Sender: TObject);
begin
  if crm.Browser <> nil then
    crm.Browser.Host.ZoomLevel := crm.Browser.Host.ZoomLevel - 0.5;
end;

procedure TMainForm.actZoomResetExecute(Sender: TObject);
begin
  if crm.Browser <> nil then
    crm.Browser.Host.ZoomLevel := 0;
end;

procedure TMainForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  i : integer;
begin
  case Msg.message of
    WM_MOUSEWHEEL:
    begin
      if ((GetKeyState(VK_CONTROL) and $8000)<> 0)then
      begin
        i := msg.wParam;
        Handled := true;
        if i > 120 then
        begin
          i := 5;
        end
        else begin
          i := -5;
        end;
        crm.Browser.Host.ZoomLevel := crm.Browser.Host.ZoomLevel +  (i/10);
      end;
    end;
  end;
end;

procedure TMainForm.ApplicationEvents1ShortCut(var Msg: TWMKey;
  var Handled: Boolean);
var
  KeyExists,i        : Integer;
  KCtrl,kMenu,kSHift : Integer;
begin
  KCtrl  := GetKeyState(VK_CONTROL) and $8000;
  kMenu  := GetKeyState(VK_MENU)    and $8000;
  kSHift := GetKeyState(VK_SHIFT)   and $8000;
  //组合的在前
  if(KCtrl<>0)AND(kSHift<>0)then//ctrl+shift
  begin
    if lowercase(chr(msg.charCode)) = 'd' then
    begin
      if Panel1.Visible then
      begin
        self.Menu := Nil;
        StatusBar.Visible := false;
        Panel1.Visible := false;
        self.BorderStyle := bsNone;
      end
      else begin
        self.Menu := MainMenu;
        StatusBar.Visible := true;
        Panel1.Visible := true;
        self.BorderStyle := bsSizeable;
      end;
        actDevToolExecute(Nil);
    end;
  end
  else if(KCtrl<>0)AND(kMenu<>0)then//ctrl+alt
  begin

  end
  else if(kSHift<>0)then
  begin

  end
  else if(KCtrl<>0)then
  begin

  end
  else if (kMenu<>0) then
  begin

  end
  else if (0-KCtrl-KMenu-Kshift=0) then
  begin

  end;
end;

procedure TMainForm.crmAddressChange(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
begin
  if IsMain(browser, frame) then
    edAddress.Text := url;
end;

procedure TMainForm.crmBeforeDownload(Sender: TObject;
  const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
  const suggestedName: ustring; const callback: ICefBeforeDownloadCallback);
begin
  callback.Cont(ExtractFilePath(ParamStr(0)) + suggestedName, True);
end;

procedure TMainForm.crmBeforePopup(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
  var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
  var client: ICefClient; var settings: TCefBrowserSettings;
  var noJavascriptAccess: Boolean; out Result: Boolean);
begin
  // prevent popup
  //windowInfo.parent_window := panel2.Handle;

  crm.Load(targetUrl);
  Result := True;
end;

procedure TMainForm.crmBeforeResourceLoad(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; out Result: Boolean);
var
  u: TUrlParts;
begin
  // redirect home to google
  if CefParseUrl(request.Url, u) then
    if (u.host = 'home') then
    begin
      u.host := 'www.google.com';
      request.Url := CefCreateUrl(u);
    end;
end;

procedure TMainForm.crmDownloadUpdated(Sender: TObject;
  const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
  const callback: ICefDownloadItemCallback);
begin
  if downloadItem.IsInProgress then
    StatusBar.SimpleText := IntToStr(downloadItem.PercentComplete) + '%' else
    StatusBar.SimpleText := '';
end;

procedure TMainForm.crmLoadEnd(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin
  if IsMain(browser, frame) then
    FLoading := False;
  //crm.browser.SendProcessMessage(PID_RENDERER, TCefProcessMessageRef.New('moveWindow'));
end;

procedure TMainForm.crmLoadStart(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  if IsMain(browser, frame) then
  begin
    FLoading := True;
  end;
end;

procedure TMainForm.crmProcessMessageReceived(Sender: TObject;
  const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage; out Result: Boolean);
begin
  if (message.Name = 'mouseover') then
  begin
    StatusBar.SimpleText := message.ArgumentList.GetString(0);
    Result := True;
  end
  else if (message.Name = 'movewindow') then
  begin
    ReleaseCapture;
    SendMessage(MainForm.handle, WM_SYSCOMMAND, SC_MOVE + HTCAPTION,0);
    Result := true;
  end
  else
    Result := False;
end;

procedure TMainForm.crmStatusMessage(Sender: TObject;
  const browser: ICefBrowser; const value: ustring);
begin
  StatusBar.SimpleText := value
end;

procedure TMainForm.crmTitleChange(Sender: TObject; const browser: ICefBrowser;
  const title: ustring);
begin
  if IsMain(browser) then
    Caption := title;
end;

procedure TMainForm.edAddressKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if crm.Browser <> nil then
    begin
      crm.Browser.MainFrame.LoadUrl(edAddress.Text);
      Abort;
    end;
  end;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // avoid AV when closing application
  if CefSingleProcess then
  begin
    crm.Load('about:blank');
    debug.Load('about:blank');
    while debug.Browser.IsLoading or crm.Browser.IsLoading  do
      Application.ProcessMessages;
  end;
  CanClose := True;
end;

procedure TMainForm.WMNCHitTest(var Message: TWMNCHitTest);
var
  pt: TPoint;
begin
  pt := ScreenToClient(SmallPointToPoint(Message.Pos));
  if PtInRect(BoundsRect, pt) then
    Message.Result := HTCAPTION
  else
    Inherited;
end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  FLoading := False;
  FDevToolLoaded := False;
  crm.Load('mz://app/');
  CefAddCrossOriginWhitelistEntry('mz://app', 'http', '', true);
  shadow := TFormShadow.Create(Application);
  shadow.ParentForm := Self;
  shadow.ShadowColor := clgray;
  shadow.ShadowOffset := 3;
  shadow.Active := True;

end;

{ TCustomRenderProcessHandler }


function getpath(const n: ICefDomNode): string;
begin
  Result := '<' + n.Name + '>';
  if (n.Parent <> nil) then
    Result := getpath(n.Parent) + Result;
end;

constructor TExternalHandler.Create();
begin
  inherited create;
end;

function TExternalHandler.Execute(const name: ustring; const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring): Boolean;
var
  args : TCefv8ValueArray;
begin
  Result := false;
  if name = 'call' then
  begin
    if arguments[0].IsFunction then
    begin
      SetLength(args, 1);
      args[0] := context.Global;  
      retval  := arguments[0].ExecuteFunction(obj, args);
      Exit(true);
    end;
    Exit(true);
    Exit(true);
  end
  else if name = 'windowMove' then
  begin
    context.Browser.SendProcessMessage(PID_BROWSER, TCefProcessMessageRef.New('movewindow'));
    {
    ReleaseCapture;
    SendMessage(MainForm.handle, WM_SYSCOMMAND, SC_MOVE + HTCAPTION,0);
    Result := true;
    }
  end;
end;

procedure TCustomRenderProcessHandler.OnContextReleased(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context);
begin
  
end;

procedure TCustomRenderProcessHandler.OnContextCreated(const browser: ICefBrowser;
  const frame: ICefFrame; const context: ICefv8Context);
var 
  Ext: TExternalHandler;
  obj : ICefV8Value;
  funcs : ICefv8Value;
  Func : ICefv8Value;
begin
  Ext := TExternalHandler.Create;
  Ext.context := context;
  obj := context.Global;
  funcs := TCefv8ValueRef.NewObject(nil);

  Func  := TCefv8ValueRef.NewFunction('call', Ext);
  funcs.SetValueByKey('call', Func,
                [V8_PROPERTY_ATTRIBUTE_READONLY]);
  Func  := TCefv8ValueRef.NewFunction('call2', Ext);
  funcs.SetValueByKey('call2', Func,
                [V8_PROPERTY_ATTRIBUTE_READONLY]);

  Func  := TCefv8ValueRef.NewFunction('windowMove', Ext);
  funcs.SetValueByKey('windowMove', Func,
                [V8_PROPERTY_ATTRIBUTE_READONLY]);
  obj.SetValueByKey('app', funcs, [V8_PROPERTY_ATTRIBUTE_READONLY]);  
end;

function TCustomRenderProcessHandler.OnProcessMessageReceived(
  const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage): Boolean;
begin
  if (message.Name = 'visitdom') then
    begin
      browser.MainFrame.VisitDomProc(
        procedure(const doc: ICefDomDocument) begin
          doc.Body.AddEventListenerProc('mouseover', True,
            procedure (const event: ICefDomEvent)
            var
              msg: ICefProcessMessage;
            begin
              msg := TCefProcessMessageRef.New('mouseover');
              msg.ArgumentList.SetString(0, getpath(event.Target));
              browser.SendProcessMessage(PID_BROWSER, msg);
            end)
        end);
        Result := True;
    end
  else if message.Name = 'moveWindow' then
  begin
    browser.MainFrame.VisitDomProc(procedure(const doc: ICefDomDocument) begin
            doc.Body.AddEventListenerProc('mousedown', True,
              procedure (const event: ICefDomEvent)
              var
                msg: ICefProcessMessage;
              begin
                msg := TCefProcessMessageRef.New('movewindow');
                browser.SendProcessMessage(PID_BROWSER, msg);
              end)
          end);
  end
  else
    Result := False;
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
  CefRemoteDebuggingPort := 9000;
  CefRenderProcessHandler := TCustomRenderProcessHandler.Create;
  CefBrowserProcessHandler := TBrowserProcessHandlerOwn.Create;
end.
