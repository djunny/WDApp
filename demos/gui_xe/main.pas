unit main;

interface
{$I cef.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ceflib, cefvcl, Buttons, ActnList, Menus, ComCtrls,
  ExtCtrls, XPMan, Registry, ShellApi, SyncObjs, AppEvnts;

type

  TCefPanel = class(TPanel)
  private
    FBrowser : ICefBrowser;
    procedure DoClick(Sender:Tobject);
  public
    property Browser:ICefBrowser read FBrowser;
    procedure Resize; override;
    procedure WndProc(var Message: TMessage); override;
    constructor Create(AOwner: TComponent;Browser:ICefBrowser);
  end;

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
    leftPanel: TPanel;
    Button1: TButton;
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
    procedure crmPreKeyEvent(Sender: TObject; const browser: ICefBrowser;
      const event: PCefKeyEvent; osEvent: PMsg; out isKeyboardShortcut,
      Result: Boolean);
    procedure crmClose(Sender: TObject; const browser: ICefBrowser;
      out Result: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure crmAfterCreated(Sender: TObject; const browser: ICefBrowser);
{    procedure ChromiumOSR1GetRootScreenRect(Sender: TObject;
      const browser: ICefBrowser; rect: PCefRect; out Result: Boolean);
    procedure ChromiumOSR1GetViewRect(Sender: TObject;
      const browser: ICefBrowser; rect: PCefRect; out Result: Boolean);
    procedure ChromiumOSR1GetScreenPoint(Sender: TObject;
      const browser: ICefBrowser; viewX, viewY: Integer; screenX,
      screenY: PInteger; out Result: Boolean);
    procedure ChromiumOSR1Paint(Sender: TObject; const browser: ICefBrowser;
      kind: TCefPaintElementType; dirtyRectsCount: Cardinal;
      const dirtyRects: PCefRectArray; const buffer: Pointer; width,
      height: Integer);
}
  private
{
    hDC_    : HDC;
    hRC_    : HGLRC;
    //renderer_: ClientOSRenderer;
    }
    FLoading: Boolean;
    FDevToolLoaded: Boolean;
    //procedure OpenGL;
    function IsMain(const b: ICefBrowser; const f: ICefFrame = nil): Boolean;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;

    procedure CreateParams(var Params: TCreateParams); override;
    //procedure WndProc(var Message: TMessage);override;
    procedure DoResize();
    procedure DoMax(Browser:ICefBrowser);
    Procedure WMGetMinMaxInfo(Var msg: TWMGetMinMaxInfo);message WM_GETMINMAXINFO;
    procedure Toggle(Handle:TCefWindowHandle; cmd:Cardinal);

    procedure Minimize(Handle:TCefWindowHandle);
    procedure Maximize(Handle:TCefWindowHandle);
    procedure Restore(Handle:TCefWindowHandle);

    function GetBrowserWindow(Browser:ICefBrowser):HWND;
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

uses ufrmShadowFrame, uCommon;

var
  shadow : TFormShadow;


constructor TCefPanel.Create(AOwner: TComponent; Browser : ICefBrowser);
begin
  inherited Create(AOwner);
  FBrowser := Browser;
  self.OnClick := DoClick;
end;


procedure TCefPanel.DoClick(Sender:Tobject);
begin
  SendMessage(FBrowser.Host.WindowHandle , WM_SETFOCUS, 0, 0);
end;

procedure TCefPanel.Resize;
begin

end;

procedure TCefPanel.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_SETFOCUS:
      begin
        if (FBrowser <> nil) and (FBrowser.Host.WindowHandle <> 0) then
          PostMessage(FBrowser.Host.WindowHandle, WM_SETFOCUS, Message.WParam, 0);
        inherited WndProc(Message);
      end;
    WM_ERASEBKGND:
      if (csDesigning in ComponentState) or (FBrowser = nil) or (FBrowser.host.WindowHandle <>0) then
        inherited WndProc(Message);
    CM_WANTSPECIALKEY:
      if not (TWMKey(Message).CharCode in [VK_LEFT .. VK_DOWN]) then
        Message.Result := 1 else
        inherited WndProc(Message);
    WM_GETDLGCODE:
      Message.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
  else
    inherited WndProc(Message);
  end;
end;

procedure DrawRounded(Control: TWinControl;ReDraw:boolean=true;AddControl:boolean=true;RoundNum:integer=8);
var
  R   : TRect;
  Rgn : HRGN;
  i   : integer;
	Pen: HPen;
	OldPen: HPen;
	OldBrush: HBrush;
  ts : TStringStream;
begin
 // exit;
  //RoundNum := 50;
   with Control do
   begin
     R   := ClientRect;
     rgn := CreateRoundRectRgn(R.Left, R.Top, R.Right, R.Bottom, RoundNum, RoundNum) ;
     Perform(EM_GETRECT, 0, lParam(@r)) ;
     InflateRect(r, -3, -3) ;
     Perform(EM_SETRECTNP, 0, lParam(@r)) ;
     SetWindowRgn(Handle, rgn, True) ;
     if ReDraw then Invalidate;

     {
     if(AddControl)then
     begin
       for i := 0 to Length(RoundedControls)-1 do
       begin
         if RoundedControls[i]=Control then exit;
       end;
       SetLength(RoundedControls, length(RoundedControls)+1);
       control.Tag := RoundNum;
       RoundedControls[length(RoundedControls)-1] := control;
     end;
     }
   end;
end;


procedure TMainForm.DoResize();
//var i : integer;
begin
  //圆角
  {
  for i := 0 to Length(RoundedControls)-1 do
    if (RoundedControls[i]<>Nil) then
      DrawRounded(RoundedControls[i], false, false, RoundedControls[i].Tag);
  }

  //captionPanel.width := width - 80;
end;

procedure TMainForm.DoMax(Browser:ICefBrowser);
{$J+}
Const
  Rect: TRect = (Left:0; Top:0; Right:0; Bottom:0);
  FullScreen: Boolean = False;
{$J-}
var
  BrowserWnd : THandle;
begin
  BrowserWnd := GetBrowserWindow(Browser);
  FullScreen := not FullScreen;
  If FullScreen Then Begin
    Rect := BoundsRect;
    Maximize(BrowserWnd);
    {
    SetWindowPos(BrowserWnd, 0, Left - ClientOrigin.X,
      Top - ClientOrigin.Y,
      screen.WorkAreaWidth + padding.left+padding.right,
      screen.workAreaHeight + padding.top + padding.bottom,
        SWP_NOZORDER + SWP_NOACTIVATE)
    }
    (*
    SetBounds(
      Left - ClientOrigin.X,
      Top - ClientOrigin.Y,
      screen.WorkAreaWidth + padding.left+padding.right{GetDeviceCaps( Canvas.handle, HORZRES ) + (Width - ClientWidth)},
      screen.workAreaHeight + padding.top + padding.bottom{GetDeviceCaps( Canvas.handle, VERTRES ) + (Height - ClientHeight )});
    *)
  End
  Else begin
    //BoundsRect := Rect;
    Restore(BrowserWnd);
    {
    SetWindowPos(BrowserWnd, 0, Rect.Left,
      Rect.Top,
      Rect.Right - Rect.left,
      Rect.Top - Rect.bottom,
      0);
    InvalidateRect(BrowserWnd, Rect, True);
    }
    //Perform(WM_WINDOWPOSCHANGED, 0, 0);
    {
    SetWindowPos(WindowHandle, 0, Rect.Left,
      Rect.Top,
      Rect.Right - Rect.left,
      Rect.Top - Rect.bottom,
      SWP_NOZORDER + SWP_NOACTIVATE)
      }
  end;
end;


procedure TMainForm.Toggle(Handle:TCefWindowHandle; cmd:Cardinal);
var
  rootWND : HWND;
  placement : PWindowPlacement;
begin
  rootWND := GetAncestor(handle, GA_ROOT);
  GetWindowPlacement(rootWND, placement);
  if placement.showCmd = cmd then
    ShowWindow(rootWND, SW_RESTORE)
  else
    ShowWindow(rootWND, cmd);
end;

procedure TMainForm.Minimize(Handle:TCefWindowHandle);
begin
  TOGGLE(handle, SW_MINIMIZE);
end;
procedure TMainForm.Maximize(Handle:TCefWindowHandle);
begin
  TOGGLE(handle, SW_MAXIMIZE);
end;
procedure TMainForm.Restore(Handle:TCefWindowHandle);
begin
  TOGGLE(GetAncestor(handle, GA_ROOT), SW_RESTORE);
end;

function TMainForm.GetBrowserWindow(Browser:ICefBrowser):HWND;
begin
  result := GetAncestor(Browser.Host.WindowHandle, GA_ROOT);//;
end;


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

    WM_ERASEBKGND:
      if (csDesigning in ComponentState) then
        Handled := true;
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
        leftPanel.Visible := false;
      end
      else begin
        self.Menu := MainMenu;
        StatusBar.Visible := true;
        Panel1.Visible := true;
        self.BorderStyle := bsSizeable;
        Splitter1.Top := debug.Top-10;
        leftPanel.Visible := true;
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
procedure TMainForm.Button1Click(Sender: TObject);
var
  f : TForm;
begin
  DoMax(crm.Browser);

  f := TForm.Create(self);
  f.ParentWindow := leftPanel.Handle;
  with f do
  begin
    Show;

    windows.SetParent(leftPanel.Handle, f.Handle);
  end;
end;

{
procedure TMainForm.ChromiumOSR1GetRootScreenRect(Sender: TObject;
  const browser: ICefBrowser; rect: PCefRect; out Result: Boolean);
var
  r : TRect;
begin
  GetWindowRect(Panel2.Handle, r);
  rect.x:=r.Left;
  rect.y:=r.Top;
  rect.width:=r.Right-r.Left;
  rect.height:=r.Top-r.Bottom;
  result := true;
end;

procedure TMainForm.ChromiumOSR1GetScreenPoint(Sender: TObject;
  const browser: ICefBrowser; viewX, viewY: Integer; screenX, screenY: PInteger;
  out Result: Boolean);
var
  pt : TPoint;
begin
  pt.X := viewX;
  pt.Y := viewY;

  Panel2.ClientToScreen(pt);
  screenX^ := pt.X;
  screenY^ := pt.Y;
  result  := true;
end;

procedure TMainForm.ChromiumOSR1GetViewRect(Sender: TObject;
  const browser: ICefBrowser; rect: PCefRect; out Result: Boolean);
var
  clientRect : TRect;
begin
  GetWindowRect(Panel2.Handle, clientRect);
  rect.x := 0;
  rect.y := 0;
  rect.width := clientRect.Right;
  rect.height := clientRect.bottom;
  Result := true;
end;

procedure TMainForm.OpenGL;
var
  format : integer;
  pfd    : PPIXELFORMATDESCRIPTOR;
begin
  ASSERT(CefCurrentlyOn(TID_UI));
  // Get the device context.
  hDC_ := GetDC(Panel2.Handle);
  // Set the pixel format for the DC.
  ZeroMemory(pfd, sizeof(pfd));
  pfd.nSize     := sizeof(pfd);
  pfd.nVersion  := 1;
  pfd.dwFlags   := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  pfd.iPixelType:= PFD_TYPE_RGBA;
  pfd.cColorBits:= 24;
  pfd.cDepthBits:= 16;
  pfd.iLayerType:= PFD_MAIN_PLANE;
  format := ChoosePixelFormat(hDC_, pfd);
  SetPixelFormat(hDC_, format, pfd);

  // Create and enable the render context.
  hRC_ := wglCreateContext(hDC_);
  wglMakeCurrent(hDC_, hRC_);
end;

procedure TMainForm.ChromiumOSR1Paint(Sender: TObject;
  const browser: ICefBrowser; kind: TCefPaintElementType;
  dirtyRectsCount: Cardinal; const dirtyRects: PCefRectArray;
  const buffer: Pointer; width, height: Integer);
var
  res : TCefRect;
  clientRect : TRect;
begin
  GetWindowRect(Panel2.Handle, clientRect);
  self.OpenGL();

  wglMakeCurrent(hDC_, hRC_);
  //renderer_.OnPaint(browser, type, dirtyRects, buffer, width, height);
  if (kind = PET_VIEW )then
  begin
    res.x := 0;
    res.y := 0;
    res.width := clientRect.Right-clientRect.Left;
    res.height := clientRect.Top - clientRect.Bottom;
    //painting_popup_ = true;

    browser.Host.Invalidate(@res, PET_POPUP);
    //browser->GetHost()->Invalidate(client_popup_rect, PET_POPUP);
    //painting_popup_ = false;
  end;
  //renderer_.Render();
  SwapBuffers(hDC_);
end;
}
procedure TMainForm.crmAddressChange(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
begin
  if IsMain(browser, frame) then
    edAddress.Text := url;
end;

procedure TMainForm.crmAfterCreated(Sender: TObject;
  const browser: ICefBrowser);
var
  rootWND : HWND;
  r : trect;
  windowStyle : integer;
  placement : PWindowPlacement;
  F : TForm;
  p : TCefPanel;
begin
  if(crm.Browser<>Nil)AND(browser.Identifier<>crm.Browser.Identifier)then
  begin
    rootWND := browser.Host.WindowHandle;//GetAncestor(, GA_ROOT);
    {
    f := TForm.Create(self);

    Windows.SetParent(rootWND, f.Handle);
    f.Show;
    }
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


    {
    p := PChar(GetWindowLong(rootWND, GWL_ID));
    Button1.Caption := string(p);
     }
    p := TCefPanel.create(Self, Browser);
    p.parent := self;
    p.align := alleft;
    p.Width:= 150;
    Windows.SetParent(rootWND, p.Handle);
    GetWindowRect(p.Handle, r);
    Windows.SetWindowPos(rootWND, 0, 0, 0, p.Width, r.Bottom-r.Top, 0);
    //SetWindowPos(rootWND, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_FRAMECHANGED);


    //SetWindowLong(, GWL_HWNDPARENT, rootWND);
    //SetWindowPos(rootWND, 0, 0,0,0,0, SWP_FRAMECHANGED or SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER | SWP_NOOWNERZORDER);
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
  // prevent popup
  //windowInfo.parent_window := panel2.Handle;
  windowInfo.parent_window := ParentWindow;
  windowInfo.transparent_painting := true;
  windowInfo.window := leftPanel.Handle;
  windowInfo.window_rendering_disabled := false;
  if browser.IsPopup then
  begin

  end
  else begin
    //crm.Load(targetUrl);
    //Result := True;
  end;
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

procedure TMainForm.crmClose(Sender: TObject; const browser: ICefBrowser;
  out Result: Boolean);
begin
//
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
  crm.browser.SendProcessMessage(PID_RENDERER, TCefProcessMessageRef.New('visitdom'));
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

procedure TMainForm.crmProcessMessageReceived(Sender: TObject;
  const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage; out Result: Boolean);
{$J+}
const LastMaxTime : Integer = -1;
{$J-}
var
  pt : TPoint;
begin
  if (message.Name = 'mouseover') then
  begin
    //ClientToScreen(Pt);
    SendMessage(GetBrowserWindow(browser), WM_NCHITTEST, 0, MAKELONG(Mouse.CursorPos.X, Mouse.CursorPos.Y));
    //StatusBar.SimpleText := message.ArgumentList.GetString(0);
    Result := True;
  end
  else begin
    if message.Name = 'windowColor' then
    begin
      Self.Color := message.ArgumentList.GetInt(0);
    end
    else
    case StrToCase(message.Name, ['windowMove',
                                  'windowMax',
                                  'windowMin',
                                  'windowClose']) of
      0:
      begin
        ReleaseCapture;
        SendMessage(GetBrowserWindow(browser), WM_SYSCOMMAND, SC_MOVE + HTCAPTION,0);
        Result := true;
      end;
      1:
      begin
        if GetTickCount - LastMaxTime - 1000 > 0 then
        begin
          //Maximize(browser.Host.WindowHandle);
          DoMax(browser);
          LastMaxTime := getTickCount;
        end;
        Result := true;
      end;
      2:
      begin
        //WindowState := wsMinimized;
        //Minimize(browser.Host.WindowHandle);

        PostMessage(GetBrowserWindow(browser), WM_SYSCOMMAND, SC_MINIMIZE, 0);
        Result := true;
      end;
      3:
      begin

        //Maximize(browser.Host.WindowHandle);
        PostMessage(GetBrowserWindow(browser), WM_SYSCOMMAND, SC_CLOSE, 0);
        Result := true;
      end
      else begin
        Result := false;
      end;
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
const
  EDGEDETECT = 10;  //adjust to suit yourself
var
  deltaRect: TRect;  //not really used as a rect, just a convenient structure
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
    end;  //with Message, deltaRect; if BorderStyle = bsNone
end;

procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
end;


Procedure TMainForm.WMGetMinMaxInfo(Var msg: TWMGetMinMaxInfo);
begin
  inherited;
  With msg.MinMaxInfo^.ptMaxTrackSize Do Begin
    X := GetDeviceCaps( Canvas.handle, HORZRES ) + (Width - ClientWidth);
    Y := GetDeviceCaps( Canvas.handle, VERTRES ) + (Height - ClientHeight);
  End;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  f : TForm;
begin
  FLoading := False;
  FDevToolLoaded := False;
  crm.Load('mz://app/');
  CefAddCrossOriginWhitelistEntry('mz://app', 'http', '', true);
{$IFDEF WINDOWS}
{
  shadow := TFormShadow.Create(Application);
  shadow.ParentForm := Self;
  shadow.ShadowColor := clgray;
  shadow.ShadowOffset := 3;
  shadow.Active := True;
}
{$ENDIF}
  DoMax(crm.Browser);

end;

procedure TMainForm.FormShow(Sender: TObject);
begin

  //DrawRounded(self, true, false, 8);
  //DrawRounded(crm, true, false, 8);
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
{$J+}
const lastMoveTime : Integer = -1;
{$J-}
var
  messageName : string;
  args : TCefv8ValueArray;
  procedure sendProcessMessage(messageName:String);
  var
    cefMessage : ICefProcessMessage;
    cefArgs    : ICefListValue;
    argIndex,argLen : integer;
  begin
    cefMessage := TCefProcessMessageRef.New(messageName);

    argLen     := Length(arguments);
    if argLen > 0 then
    begin
      //cefArgs  := TCefListValueRef.New();
      for argIndex := 0 to argLen-1 do
      begin
        if arguments[argIndex].IsString then
        begin
          cefMessage.ArgumentList.SetString(argIndex, arguments[argIndex].GetStringValue);
        end
        else if arguments[argIndex].IsInt then
        begin
          cefMessage.ArgumentList.SetInt(argIndex, arguments[argIndex].GetIntValue);
        end;
      end;
    end;
    context.Browser.SendProcessMessage(PID_BROWSER, cefMessage);
  end;
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
  else if StrToCase(name,['windowMove',
                          'windowMax',
                          'windowMin',
                          'windowClose',
                          'windowColor'])>-1 then
  begin
    messageName := name;
    //
    if compareText(name, 'windowMove')=0 then
    begin
      //OutputDebugString(PChar(inttostr(getTickCount-5)));
      if lastMoveTime>=getTickCount-300 then
      begin
        messageName := 'windowMax';
      end
      else begin
        lastMoveTime := getTickCount;
      end;
    end;
    sendProcessMessage(messageName);
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
  procedure addFunc(name:string;attr:TCefV8PropertyAttributes=[V8_PROPERTY_ATTRIBUTE_READONLY]);
  begin
    Func  := TCefv8ValueRef.NewFunction(name, Ext);
    funcs.SetValueByKey(name, Func, attr);
  end;
begin
  Ext := TExternalHandler.Create;
  Ext.context := context;
  obj := context.Global;
  funcs := TCefv8ValueRef.NewObject(nil);

  addFunc('windowMove');
  addFunc('windowMax');
  addFunc('windowMin');
  addFunc('windowClose');
  addFunc('windowColor');
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
  //ShowMessage(commandLine.GetProgram);
end;

procedure TBrowserProcessHandlerOwn.OnRenderProcessThreadCreated(const extraInfo: ICefListValue);
begin

end;
initialization
  CefRemoteDebuggingPort := 9080;
  CefRenderProcessHandler := TCustomRenderProcessHandler.Create;
  CefBrowserProcessHandler := TBrowserProcessHandlerOwn.Create;
end.
