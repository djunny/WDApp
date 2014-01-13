unit fMain;

interface
{$I cef.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ceflib, cefvcl, Buttons, ActnList, Menus, ComCtrls,
  ExtCtrls, XPMan, Registry, ShellApi, SyncObjs, AppEvnts, uTDAppCef;

const
  WM_BACKGROUND = WM_USER + $100;

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
    actExecuteJS: TAction;
    ExecuteJavaScript1: TMenuItem;
    Exit1: TMenuItem;
    Print1: TMenuItem;
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
    AppEvent: TApplicationEvents;
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
    procedure actExecuteJSExecute(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
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
    procedure actChromeDevToolExecute(Sender: TObject);
    procedure crmBeforePopup(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
      var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
      var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean; out Result: Boolean);
    procedure AppEventShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure AppEventMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure crmPreKeyEvent(Sender: TObject; const browser: ICefBrowser;
      const event: PCefKeyEvent; osEvent: PMsg; out isKeyboardShortcut,
      Result: Boolean);
    procedure crmAfterCreated(Sender: TObject; const browser: ICefBrowser);
    procedure crmProcessMessageReceived(Sender: TObject;
      const browser: ICefBrowser; sourceProcess: TCefProcessId;
      const message: ICefProcessMessage; out Result: Boolean);
    procedure crmRenderProcessTerminated(Sender: TObject;
      const browser: ICefBrowser; status: TCefTerminationStatus);
  private
    FLoading: Boolean;
    FDevToolLoaded: Boolean;
    function IsMain(const b: ICefBrowser; const f: ICefFrame = nil): Boolean;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;

    procedure CreateParams(var Params: TCreateParams); override;
    Procedure WMGetMinMaxInfo(Var msg: TWMGetMinMaxInfo);message WM_GETMINMAXINFO;

    procedure WMBackground(var msg:Tmessage); message WM_BACKGROUND;

  end;

  TTDAppExternal = class(TExternalHandler)
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean; override;
  public
    constructor Create(); override;
  end;

  TTDAppProcessHandler = class(TCustomRenderProcessHandler)
  protected

    function OnProcessMessageReceived(const browser: ICefBrowser; sourceProcess: TCefProcessId;
      const message: ICefProcessMessage): Boolean; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses uConst, uCommon;

var
  ExternalFuncs : array[0..4] of string=(
    'windowMove',
    'windowMax',
    'windowMin',
    'windowClose',
    'windowColor'
  );


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

procedure TMainForm.AppEventMessage(var Msg: tagMSG;
  var Handled: Boolean);
var
  i  : integer;
  pt,selfPt : TPoint;
begin
  case Msg.message of
    //ctrl + mousewheel : scroll to zoom
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

        if(CefCurrentlyOn(TID_UI)) then
        begin
          crm.Browser.Host.ZoomLevel := crm.Browser.Host.ZoomLevel+(i/10);
        end
        else begin
        end;
      end;
    end;
    //
    WM_ERASEBKGND:
    begin
      if Not(csDesigning in ComponentState) then Handled := true;
    end;
    WM_MOUSEMOVE:
    begin
    end;
  end;
end;

procedure TMainForm.AppEventShortCut(var Msg: TWMKey;
  var Handled: Boolean);
var
  KeyExists,i        : Integer;
  KCtrl,kMenu,kSHift : Integer;
begin
  KCtrl  := GetKeyState(VK_CONTROL) and $8000;
  kMenu  := GetKeyState(VK_MENU)    and $8000;
  kSHift := GetKeyState(VK_SHIFT)   and $8000;
  if(KCtrl<>0)AND(kSHift<>0)then//ctrl+shift
  begin
    //ctrl + shift + d : toggle debug mode
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
        Splitter1.Top := debug.Top-10;
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
  if IsMain(browser, frame) then edAddress.Text := url;
end;

procedure TMainForm.crmAfterCreated(Sender: TObject;
  const browser: ICefBrowser);
var
  rootWND : HWND;
  r : TRect;
  windowStyle : integer;
  newPanel : TCefPanel;
begin
  if(crm.Browser<>Nil)AND(browser.Identifier<>crm.Browser.Identifier)then
  begin
    rootWND     := GetBrowserWindow(browser);//browser.Host.WindowHandle;
    windowStyle := GetWindowLong(rootWND, GWL_STYLE);
    windowStyle := windowStyle and not WS_CAPTION;
    windowStyle := windowStyle and not WS_SYSMENU;
    windowStyle := windowStyle and not WS_THICKFRAME;
    windowStyle := windowStyle and not WS_MINIMIZE;
    windowStyle := windowStyle and not WS_MAXIMIZEBOX;
    windowStyle := windowStyle and not WS_DLGFRAME;
    windowStyle := windowStyle and not WS_BORDER;

    SetWindowLong(rootWND, GWL_STYLE, windowStyle);
    windowStyle := GetWindowLong(rootWND, GWL_EXSTYLE);
    SetWindowLong(rootWND, GWL_EXSTYLE, windowStyle or WS_EX_TRANSPARENT);
    SetWindowPos(rootWND, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE
                                                 or SWP_NOZORDER or SWP_FRAMECHANGED
                                                 or SWP_DRAWFRAME);
    //Windows.
    //Windows.SetWindowPos(rootWND, 0, 0, 0, 0, 0, 0);

    {
    //set width and height
    newPanel          := TCefPanel.create(Self, Browser);
    newPanel.parent   := self;
    newPanel.align    := alleft;
    newPanel.Width    := 150;
    Windows.SetParent(rootWND, newPanel.Handle);
    GetWindowRect(newPanel.Handle, r);
    Windows.SetWindowPos(rootWND, 0, 0, 0, newPanel.Width, r.Bottom-r.Top, 0);
    }
  end;
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
  //you can use this as a single app
  {
    crm.Load(targetUrl);
    Result := True;
  }
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
end;

procedure TMainForm.crmLoadStart(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  if IsMain(browser, frame) then
  begin
    FLoading := True;
  end;
end;

procedure TMainForm.crmPreKeyEvent(Sender: TObject; const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: PMsg; out isKeyboardShortcut,
  Result: Boolean);
begin
  if event^.kind = KEYEVENT_RAWKEYDOWN then
  begin
    if event.windows_key_code = VK_F5 then
    begin
      browser.Reload;
      result := true;
    end;
  end;
end;


procedure TMainForm.crmRenderProcessTerminated(Sender: TObject;
  const browser: ICefBrowser; status: TCefTerminationStatus);
begin
  case status of
    TS_ABNORMAL_TERMINATION:
    begin

    end;
    TS_PROCESS_WAS_KILLED:
    begin

    end;
    TS_PROCESS_CRASHED:
    begin

    end;
  end;
end;

procedure TMainForm.crmStatusMessage(Sender: TObject;
  const browser: ICefBrowser; const value: ustring);
begin
  StatusBar.SimpleText := value;
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
  //close
  if CefSingleProcess then
  begin
    crm.Load('about:blank');
    debug.Load('about:blank');
    while debug.Browser.IsLoading or crm.Browser.IsLoading  do
      Application.ProcessMessages;
  end
  else begin
    crm.Browser.Host.CloseBrowser(false);
  end;
  CanClose := True;
end;

procedure TMainForm.WMNCHitTest(var Message: TWMNCHitTest);
const
  EDGEDETECT = 10;  //adjust to suit yourself
var
  deltaRect: TRect;
begin
  inherited;
  if BorderStyle = bsNone then
    with Message, deltaRect do begin
      Left := XPos - BoundsRect.Left;
      Right := BoundsRect.Right - XPos;
      Top := YPos - BoundsRect.Top;
      Bottom := BoundsRect.Bottom - YPos;
      if (Top<EDGEDETECT)and(Left<EDGEDETECT) then
        Result := HTTOPLEFT
      else if (Top<EDGEDETECT)and(Right<EDGEDETECT) then
        Result := HTTOPRIGHT
      else if (Bottom<EDGEDETECT)and(Left<EDGEDETECT) then
        Result := HTBOTTOMLEFT
      else if (Bottom<EDGEDETECT)and(Right<EDGEDETECT) then
        Result := HTBOTTOMRIGHT
      else if (Top<EDGEDETECT) then
        Result := HTTOP
      else if (Left<EDGEDETECT) then
        Result := HTLEFT
      else if (Bottom<EDGEDETECT) then
        Result := HTBOTTOM
      else if (Right<EDGEDETECT) then
        Result := HTRIGHT
    end;
end;

procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
end;


Procedure TMainForm.WMGetMinMaxInfo(Var msg: TWMGetMinMaxInfo);
begin
  with msg.MinMaxInfo^ do
  begin
    ptMaxSize.X      := Screen.WorkAreaWidth;        {Width when maximized}
    ptMaxSize.Y      := Screen.WorkAreaHeight;       {Height when maximized}
    ptMaxPosition.X  := 0;                           {Left position when maximized}
    ptMaxPosition.Y  := 0;                           {Top position when maximized}
    ptMinTrackSize.X := 0;                           {Minimum width}
    ptMinTrackSize.Y := 0;                           {Minimum height}
    ptMaxTrackSize.X := Screen.WorkAreaWidth;        {Maximum width}
    ptMaxTrackSize.Y := Screen.WorkAreaHeight;       {Maximum height}
  end;
  msg.Result := 0;                                   {Tell windows you have changed minmaxinfo}
  inherited;
end;



procedure TMainForm.WMBackground(var msg:Tmessage);
begin
  self.Color := msg.WParam;
end;


procedure TMainForm.FormCreate(Sender: TObject);
var
  f : TForm;
begin
  FLoading := False;
  FDevToolLoaded := False;

  //bind external call event
  //load default app
  crm.Load(getAppPath('app'));
  //set app can cross domain
  CefAddCrossOriginWhitelistEntry(getAppPath('app'), 'http', '', true);
end;

procedure TMainForm.crmProcessMessageReceived(Sender: TObject;
  const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage; out Result: Boolean);
begin
  Result := CefRenderProcessHandler.OnProcessMessageReceived(browser, sourceProcess, message);
end;


//------------------------------------------------------------------------------
// TTDAppExternal :
// external handler has V8Context property
//------------------------------------------------------------------------------
constructor TTDAppExternal.Create();
begin
  inherited;
end;


//------------------------------------------------------------------------------
// TTDAppExternal.execute
// when js:window.external.xxx();
// P.S, but only it can do no visual method
//      Sync MainThread must use CefSendProcessMessage() method
//------------------------------------------------------------------------------
function TTDAppExternal.Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean;
{$J+}
const lastMoveTime : Integer = -1;
{$J-}
var
  messageName : string;
  args : TCefv8ValueArray;
begin
  {
  //call back example
  if name = 'call' then
  begin
    SetLength(args, 1);
    args[0] := context.Global;
    retval  := arguments[0].ExecuteFunction(obj, args);
    Exit(true);
  end;
  }
  //get message name
  messageName := name;


  //check dblclick time: toggle max and restore window
  if compareText(name, ExternalFuncs[0])=0 then
  begin
    if lastMoveTime>=getTickCount-300 then
    begin
      messageName := ExternalFuncs[1];
    end
    else begin
      lastMoveTime := getTickCount;
    end;
  end;

  CefSendProcessMessage(PID_RENDERER, context.Browser, arguments, messageName);

end;


//------------------------------------------------------------------------------
// TTDAppProcessHandler.OnProcessMessageReceived:
// when CefSendProcessMessage send a message , this callback whill active
//------------------------------------------------------------------------------
function TTDAppProcessHandler.OnProcessMessageReceived(const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage): Boolean;
{$J+}
const LastMaxTime : Integer = -1;
{$J-}
var
  pt : TPoint;
begin
  Result := false;
  case StrToCase(message.Name, ExternalFuncs) of
    0://move
    begin
      ReleaseCapture;
      SendMessage(GetBrowserWindow(browser), WM_SYSCOMMAND, SC_MOVE + HTCAPTION,0);
      Result := true;
    end;
    1://max
    begin
      //check time click too fast maybe get restore
      if GetTickCount - LastMaxTime - 1000 > 0 then
      begin
        //@todo why SendMessage make app crash
        if IsZoomed(GetBrowserWindow(browser)) then
        begin
          PostMessage(GetBrowserWindow(browser), WM_SYSCOMMAND, SC_RESTORE, 0);
        end
        else begin
          PostMessage(GetBrowserWindow(browser), WM_SYSCOMMAND, SC_MAXIMIZE, 0);
        end;
        LastMaxTime := getTickCount;
      end;
      Result := true;
    end;
    2://min
    begin
      PostMessage(GetBrowserWindow(browser), WM_SYSCOMMAND, SC_MINIMIZE, 0);
      Result := true;
    end;
    3://close
    begin
      PostMessage(GetBrowserWindow(browser), WM_SYSCOMMAND, SC_CLOSE, 0);
      Result := true;
    end;
    4://color
    begin
      PostMessage(GetBrowserWindow(browser), WM_BACKGROUND, message.ArgumentList.GetInt(0), 0);
      result := true;
    end
    else begin
    end;
  end;
  if Not Result then
    Result := inherited OnProcessMessageReceived(browser,sourceProcess,message);
end;


initialization
  // register External Handler Class
  ExternalClass          := TTDAppExternal;
  // devtool port
  CefRemoteDebuggingPort := TDAPP_DEV_PORT;
  // add External functions
  CefAddExternalFunction(ExternalFuncs);
  // init Process Handler
  CefRenderProcessHandler := TTDAppProcessHandler.Create;
  // init Browser Handler
  CefBrowserProcessHandler := TBrowserProcessHandlerOwn.Create;
end.
