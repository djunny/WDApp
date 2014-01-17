unit fMain;

interface
{$I cef.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ceflib, cefvcl, Buttons, ActnList, Menus, ComCtrls,
  ExtCtrls, AppEvnts, XPMan;

const
  WM_BACKGROUND = WM_USER + $100;
type
  TMainForm = class(TForm)
    edAddress: TEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
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
    actShowDevTools: TAction;
    Showdevtools1: TMenuItem;
    actCloseDevTools: TAction;
    Closedeveloppertools1: TMenuItem;
    actZoomIn: TAction;
    actZoomOut: TAction;
    actZoomReset: TAction;
    Zoomin1: TMenuItem;
    Zoomout1: TMenuItem;
    Zoomreset1: TMenuItem;
    actExecuteJS: TAction;
    ExecuteJavaScript1: TMenuItem;
    Exit1: TMenuItem;
    actPrint: TAction;
    Print1: TMenuItem;
    actFileScheme: TAction;
    actFileScheme1: TMenuItem;
    actDom: TAction;
    VisitDOM1: TMenuItem;
    SaveDialog: TSaveDialog;
    Panel1: TPanel;
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
    procedure actShowDevToolsExecute(Sender: TObject);
    procedure actCloseDevToolsExecute(Sender: TObject);
    procedure actZoomInExecute(Sender: TObject);
    procedure actZoomOutExecute(Sender: TObject);
    procedure actZoomResetExecute(Sender: TObject);
    procedure actExecuteJSExecute(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actFileSchemeExecute(Sender: TObject);
    procedure actDomExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actPrevUpdate(Sender: TObject);
    procedure crmAddressChange(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
    procedure crmGetDownloadHandler(Sender: TObject;
      const browser: ICefBrowser; const mimeType, fileName: ustring;
      contentLength: Int64; var handler: ICefDownloadHandler;
      out Result: Boolean);
    procedure crmLoadEnd(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; httpStatusCode: Integer; out Result: Boolean);
    procedure crmLoadStart(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame);
    procedure crmStatusMessage(Sender: TObject;
      const browser: ICefBrowser; const value: ustring;
      StatusType: TCefHandlerStatusType; out Result: Boolean);
    procedure crmTitleChange(Sender: TObject;
      const browser: ICefBrowser; const title: ustring; out Result: Boolean);
    procedure crmKeyEvent(Sender: TObject; const browser: ICefBrowser; event: TCefHandlerKeyEventType;
                          code, modifiers: Integer;
                          isSystemKey, isAfterJavaScript: Boolean;
                          out Result: Boolean);
    procedure crmResourceResponse(Sender: TObject; const browser: ICefBrowser;
                          const url: ustring; const response: ICefResponse;
                          var filter: ICefBase);
    procedure crmBeforeBrowse(Sender: TObject; const browser: ICefBrowser;
                              const frame: ICefFrame;
                              const request: ICefRequest;
                              navType: TCefHandlerNavtype;
                              isRedirect: Boolean;
                              out Result: Boolean);
    procedure crmAfterCreated(Sender: TObject;const browser: ICefBrowser);
    procedure crmContentsSizeChange(Sender: TObject;
                              const browser: ICefBrowser;
                              const frame: ICefFrame; width,
                              height: Integer);
    procedure crmBeforePopup(Sender: TObject;
                              const parentBrowser: ICefBrowser;
                              var popupFeatures: TCefPopupFeatures;
                              var windowInfo: TCefWindowInfo;
                              var url: ustring; var client: ICefBase;
                              out Result: Boolean);
    procedure crmBeforeClose(Sender: TObject; const browser: ICefBrowser;
                             out Result: Boolean);
    procedure AppEventMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure AppEventShortCut(var Msg: TWMKey; var Handled: Boolean);
  private
    Chrome  : TChromium;
    FLoading: Boolean;
    procedure WMBackground(var msg:Tmessage); message WM_BACKGROUND;
    Procedure WMGetMinMaxInfo(Var msg: TWMGetMinMaxInfo);message WM_GETMINMAXINFO;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  end;

  TCefStreamDownloadHandler = class(TCefDownloadHandlerOwn)
  private
    FStream: TStream;
    FOwned: Boolean;
  protected
    function ReceivedData(data: Pointer; DataSize: Integer): Integer; override;
    procedure Complete; override;
  public
    constructor Create(stream: TStream; Owned: Boolean); reintroduce;
    destructor Destroy; override;
  end;


var
  MainForm: TMainForm;

implementation

uses
  uConst, uCommon, uScheme, uhashes, uWDAppCef;

{$R *.dfm}

type
  //external handler
  TWDAppExternal = class(TExternalHandler)
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean; override;
  public
    constructor Create(); override;
  end;

  //browser info
  TWDBrowserInfo = class
    Browser    : ICefBrowser;
    OldWndProc : Pointer;
  end;

var
{
  //register by extension code will be use
  ExternalFuncs : array[0..5] of string=(
    'windowMove:function()',
    'windowMax:function()',
    'windowMin:function()',
    'windowClose:function()',
    'windowColor:function(color)',
    'windowResize:function(width,height,realignCenter)'
  );
}

  ExternalFuncs : array[0..5] of string=(
    'windowMove',
    'windowMax',
    'windowMin',
    'windowClose',
    'windowColor',
    'windowResize'
  );
  ContentHandler : TCustomV8ContextHandler;
  //Browser List
  BrowserList : TObjectHash;


function BrowserWindowNewProc(hHwnd, Msg, wParam, lParam: LongWORD): LongInt; stdcall;
var
  id : String;
  browserInfo : TWDBrowserInfo;
  //nchittest
  function NCHITTEST():LongInt;
  const
    EDGEDETECT = 20;
  var
    deltaRect: TRect;
    BoundsRect: TRect;
    XPos,YPos : integer;
  begin
    GetWIndowRect(hHwnd, BoundsRect);
    XPos := Loword(lParam);
    YPos := HiWord(lParam);
    result := -1;
    with deltaRect do
    begin
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
        Result := HTRIGHT;
    end;
  end;
  //get min / max info
  function GETMAXINFO():LongInt;
  var
    maxInfo : PMinMaxInfo;
  begin
    maxInfo := PMinMaxInfo(lParam);
    with maxInfo^ do
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
    Result := 0;
  end;
begin
  id          := IntToStr(hHwnd);
  //@todo may be there is not safe for hash list
  if(Assigned(BrowserList))
    AND(BrowserList<>Nil) then
  begin
    browserInfo := TWDBrowserInfo(BrowserList[id]);

    case Msg of
      WM_NCHITTEST:
      begin
        result := NCHITTEST;
        exit;
      end;
      WM_GETMINMAXINFO:
      begin
        result := GETMAXINFO;
        exit;
      end;
    end;

    // call old wndproc
    if(Assigned(browserInfo))
      AND (browserInfo <> nil)then
    begin
      Result := CallWindowProc(browserInfo.OldWndProc, hHwnd, Msg, wParam, lParam);
    end;
  end;
end;

procedure TMainForm.actCloseDevToolsExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
     chrome.Browser.CloseDevTools;
end;

function getpath(const n: ICefDomNode): string;
begin
  Result := '<' + n.Name + '>';
  if (n.Parent <> nil) then
    Result := getpath(n.Parent) + Result;
end;

{$IFNDEF DELPHI12_UP}
procedure mouseeventcallback(const event: ICefDomEvent);
begin
  MainForm.caption := getpath(event.Target);
end;

procedure domvisitorcallback(const doc: ICefDomDocument);
begin
  doc.Body.AddEventListenerProc('mouseover', True, mouseeventcallback);
end;
{$ENDIF}

procedure TMainForm.actDomExecute(Sender: TObject);
begin
{$IFDEF DELPHI12_UP}
  chrome.Browser.MainFrame.VisitDomProc(
    procedure (const doc: ICefDomDocument) begin
      doc.Body.AddEventListenerProc('mouseover', True,
        procedure (const event: ICefDomEvent) begin
          caption := getpath(event.Target);
        end)
  end);
{$ELSE}
  chrome.Browser.MainFrame.VisitDomProc(domvisitorcallback);
{$ENDIF}
end;

procedure TMainForm.actExecuteJSExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    chrome.Browser.MainFrame.ExecuteJavaScript(
      'alert(''JavaScript execute works!'');', 'about:blank', 0);
end;

procedure TMainForm.actFileSchemeExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    chrome.Browser.MainFrame.LoadUrl('dcef://c/');
end;

procedure TMainForm.actGetSourceExecute(Sender: TObject);
var
  frame: ICefFrame;
  source: ustring;
begin
  if chrome.Browser = nil then Exit;
  frame := chrome.Browser.MainFrame;
  source := frame.Source;
  source := StringReplace(source, '<', '&lt;', [rfReplaceAll]);
  source := StringReplace(source, '>', '&gt;', [rfReplaceAll]);
  source := '<html><body>Source:<pre>' + source + '</pre></body></html>';
  frame.LoadString(source, 'http://tests/getsource');
end;

procedure TMainForm.actGetTextExecute(Sender: TObject);
var
  frame: ICefFrame;
  source: ustring;
begin
  if chrome.Browser = nil then Exit;
  frame := chrome.Browser.MainFrame;
  source := frame.Text;
  source := StringReplace(source, '<', '&lt;', [rfReplaceAll]);
  source := StringReplace(source, '>', '&gt;', [rfReplaceAll]);
  source := '<html><body>Text:<pre>' + source + '</pre></body></html>';
  frame.LoadString(source, 'http://tests/gettext');
end;

procedure TMainForm.actGoToExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    chrome.Browser.MainFrame.LoadUrl(edAddress.Text);
end;

procedure TMainForm.actHomeExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    chrome.Browser.MainFrame.LoadUrl(chrome.DefaultUrl);
end;

procedure TMainForm.actHomeUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := chrome.Browser <> nil;
end;

procedure TMainForm.actNextExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    chrome.Browser.GoForward;
end;

procedure TMainForm.actNextUpdate(Sender: TObject);
begin
  if chrome.Browser <> nil then
    actNext.Enabled := chrome.Browser.CanGoForward else
    actNext.Enabled := False;
end;

procedure TMainForm.actPrevExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    chrome.Browser.GoBack;
end;

procedure TMainForm.actPrevUpdate(Sender: TObject);
begin
  if chrome.Browser <> nil then
    actPrev.Enabled := chrome.Browser.CanGoBack else
    actPrev.Enabled := False;
end;

procedure TMainForm.actPrintExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    chrome.Browser.MainFrame.Print;
end;

procedure TMainForm.actReloadExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    if FLoading then
      chrome.Browser.StopLoad else
      chrome.Browser.Reload;
end;

procedure TMainForm.actReloadUpdate(Sender: TObject);
begin
  if FLoading then
    TAction(sender).Caption := 'X' else
    TAction(sender).Caption := 'R';
  TAction(Sender).Enabled := chrome.Browser <> nil;
end;

procedure TMainForm.actShowDevToolsExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    chrome.Browser.ShowDevTools;
end;

procedure TMainForm.actZoomInExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    chrome.Browser.ZoomLevel := chrome.Browser.ZoomLevel + 0.5;
end;

procedure TMainForm.actZoomOutExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    chrome.Browser.ZoomLevel := chrome.Browser.ZoomLevel - 0.5;
end;

procedure TMainForm.actZoomResetExecute(Sender: TObject);
begin
  if chrome.Browser <> nil then
    chrome.Browser.ZoomLevel := 0;
end;

procedure TMainForm.AppEventMessage(var Msg: tagMSG; var Handled: Boolean);
var
  i  : integer;
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
          Chrome.Browser.ZoomLevel := Chrome.Browser.ZoomLevel+(i/10);
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
    WM_SYSCOMMAND:
    begin
      OutputDebugString(PChar('syscommand'));
    end;
  end;
end;

procedure TMainForm.AppEventShortCut(var Msg: TWMKey; var Handled: Boolean);
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
      end;
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

procedure TMainForm.crmBeforePopup(Sender: TObject;
  const parentBrowser: ICefBrowser; var popupFeatures: TCefPopupFeatures;
  var windowInfo: TCefWindowInfo; var url: ustring; var client: ICefBase;
  out Result: Boolean);
begin
//
end;

procedure TMainForm.crmBeforeClose(Sender: TObject;
  const browser: ICefBrowser; out Result: Boolean);
begin
//
end;

procedure TMainForm.crmContentsSizeChange(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; width, height: Integer);
begin
//

  SendMessage(browser.GetWindowHandle, WM_SIZE, 0, 0);
end;

procedure TMainForm.crmAfterCreated(Sender: TObject;
  const browser: ICefBrowser);
var
  rootWND     : HWND;
  ParentRect  : TRect;
  windowStyle : integer;
  idStr       : String;
  BrowserInfo : TWDBrowserInfo;
begin
  if(Chrome.Browser<>Nil)then
  begin
    rootWND     := GetBrowserWindow(browser);

    //set no caption window
    windowStyle := GetWindowLong(rootWND, GWL_STYLE);
    //@todo how to check developer tools
    if Pos('', browser.MainFrame.Url) =0 then
    begin
      {
      windowStyle := windowStyle and not WS_CAPTION;
      windowStyle := windowStyle and not WS_SYSMENU;
      windowStyle := windowStyle and not WS_THICKFRAME;
      windowStyle := windowStyle and not WS_MINIMIZE;
      windowStyle := windowStyle and not WS_MAXIMIZEBOX;
      windowStyle := windowStyle and not WS_DLGFRAME;
      windowStyle := windowStyle and not WS_BORDER;
      }
    end;
    SetWindowLong(rootWND, GWL_STYLE, windowStyle);

    //set transparent
    windowStyle := GetWindowLong(rootWND, GWL_EXSTYLE);
    SetWindowLong(rootWND, GWL_EXSTYLE, windowStyle or WS_EX_TRANSPARENT);

    //set topmost and redraw frame
    SetWindowPos(rootWND, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE
                                                 or SWP_NOZORDER or SWP_FRAMECHANGED
                                                 or SWP_DRAWFRAME);

    // add browser in HashMap
    BrowserInfo            := TWDBrowserInfo.Create;
    // get old Wndproc
    BrowserInfo.OldWndProc := Pointer(GetWindowLong(rootWND, GWL_WNDPROC));
    // get ICefBrowser interface
    BrowserInfo.Browser    := browser;
    // rootWND is key of BrowserList
    idStr                  := IntToStr(RootWND);
    BrowserList[idstr]     := BrowserInfo;
    //replace wndproc
    SetWindowLong(rootWND, GWL_WNDPROC, Integer(@BrowserWindowNewProc));
  end;
end;

procedure TMainForm.crmBeforeBrowse(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; navType: TCefHandlerNavtype; isRedirect: Boolean;
  out Result: Boolean);
begin
//
end;

procedure TMainForm.crmAddressChange(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
begin
  if (browser.GetWindowHandle = chrome.BrowserHandle) and ((frame = nil) or (frame.IsMain)) then
    edAddress.Text := url;
end;


procedure TMainForm.crmGetDownloadHandler(Sender: TObject;
  const browser: ICefBrowser; const mimeType, fileName: ustring;
  contentLength: Int64; var handler: ICefDownloadHandler; out Result: Boolean);
begin
  SaveDialog.FileName := fileName;
  if SaveDialog.Execute then
    handler := TCefStreamDownloadHandler.Create(
      TFileStream.Create(SaveDialog.FileName, fmCreate), true);
  Result := True;
end;

procedure TMainForm.crmLoadEnd(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer;
  out Result: Boolean);
begin
  if (browser <> nil) and (browser.GetWindowHandle = chrome.BrowserHandle) and ((frame = nil) or (frame.IsMain)) then
    FLoading := False;
end;

procedure TMainForm.crmLoadStart(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame);
begin
  if (browser <> nil) and (browser.GetWindowHandle = chrome.BrowserHandle) and ((frame = nil) or (frame.IsMain)) then
    FLoading := True;
end;

procedure TMainForm.crmStatusMessage(Sender: TObject;
  const browser: ICefBrowser; const value: ustring;
  StatusType: TCefHandlerStatusType; out Result: Boolean);
begin
  if StatusType in [STATUSTYPE_MOUSEOVER_URL, STATUSTYPE_KEYBOARD_FOCUS_URL] then
    StatusBar.SimpleText := value
end;

procedure TMainForm.crmTitleChange(Sender: TObject;
  const browser: ICefBrowser; const title: ustring; out Result: Boolean);
begin
  if browser.GetWindowHandle = chrome.BrowserHandle then
    Caption := title;
end;


procedure TMainForm.crmKeyEvent(Sender: TObject; const browser: ICefBrowser; event: TCefHandlerKeyEventType;
          code, modifiers: Integer; isSystemKey, isAfterJavaScript: Boolean; out Result: Boolean);
var
  KCtrl,kMenu,kSHift : Integer;
begin
  KCtrl  := GetKeyState(VK_CONTROL) and $8000;
  kMenu  := GetKeyState(VK_MENU)    and $8000;
  kSHift := GetKeyState(VK_SHIFT)   and $8000;
  if event = KEYEVENT_RAWKEYDOWN then
  begin
    if isAfterJavaScript then
    begin
        //f5
      if((code = VK_F5)
           OR
           //ctrl+r
           ((LowerCase(Chr(code))='r')and(KCtrl<>0))
         )then
      begin
        browser.Reload;
        result := true;
      end
      else if code = VK_F12 then
      begin
        browser.ShowDevTools;
      end;
    end;

  end;
end;

procedure TMainForm.crmResourceResponse(Sender: TObject; const browser: ICefBrowser;
                          const url: ustring; const response: ICefResponse;
                          var filter: ICefBase);
begin
  if pos('text/html', response.GetHeader('Content-Type'))>0 then
  begin
    filter := TCustomFilter.Create;
  end;
end;

procedure TMainForm.edAddressKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if chrome.Browser <> nil then
    begin
      chrome.Browser.MainFrame.LoadUrl(edAddress.Text);
      Abort;
    end;
  end;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;


procedure TMainForm.WMBackground(var msg:Tmessage);
begin
  self.Color := msg.WParam;
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
  //drawRound(handle);
end;

procedure TMainForm.WMNCHitTest(var Message: TWMNCHitTest);
const
  EDGEDETECT = 10;//adjust to suit yourself
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


procedure TMainForm.FormCreate(Sender: TObject);
begin
  FLoading               := False;
  //set app can cross domain
  CefAddCrossOriginWhitelistEntry(getAppPath('app'), 'http', '', true);
  CefAddCrossOriginWhitelistEntry(getAppPath('app'), 'https', '', true);
  CefAddCrossOriginWhitelistEntry(getAppPath('app'), WDAPP_PROTOCOL, '', true);

  //create chrome
  Chrome                      := TChromium.Create(Self);
  Chrome.Parent               := Self;
  chrome.Align                := alClient;
  chrome.OnAddressChange      := crmAddressChange;
  Chrome.OnLoadEnd            := crmLoadEnd;
  Chrome.OnLoadStart          := crmLoadStart;
  Chrome.OnStatusMessage      := crmStatusMessage;
  Chrome.OnTitleChange        := crmTitleChange;
  Chrome.OnContextCreated     := ContentHandler.OnContextCreated;
  Chrome.OnKeyEvent           := crmKeyEvent;
  chrome.OnResourceResponse   := crmResourceResponse;
  chrome.OnBeforeBrowse       := crmBeforeBrowse;
  Chrome.OnAfterCreated       := crmAfterCreated;
  Chrome.OnBeforePopup        := crmBeforePopup;
  Chrome.OnContentsSizeChange := crmContentsSizeChange;
  Chrome.OnBeforeClose        := crmBeforeClose;
  chrome.Load(getAppPath('app'));
end;


{ TTDAppExternal }

//------------------------------------------------------------------------------
// TTDAppExternal :
// external handler has V8Context property
//------------------------------------------------------------------------------
constructor TWDAppExternal.Create();
begin
  inherited;
end;


//------------------------------------------------------------------------------
// TTDAppExternal.execute
// when js:window.external.xxx();
// P.S, but only it can do no visual method
//      Sync MainThread must use CefSendProcessMessage() method
//------------------------------------------------------------------------------
function TWDAppExternal.Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean;
var
  messageName   : string;
  browserHandle : THandle;
  argsLength    : integer;
  //resize window
  procedure DoWindowResize;
  var
    posX, posY : integer;
    windowStyle: integer;
  begin
    windowStyle := 0;
    posX := 0;
    posY := 0;
    if(argsLength > 2)
        and(arguments[2].GetBoolValue)then
    begin
      posX := Round((Screen.WorkAreaWidth - arguments[0].GetIntValue)/2);
      posY := Round((Screen.WorkAreaHeight - arguments[1].GetIntValue)/2);
    end
    else begin
      WindowStyle := WindowStyle or SWP_NOMOVE;
    end;
    if(argsLength>1)then
    begin
      SetWindowPos(browserHandle, 0, posX, posY,
                arguments[0].GetIntValue, arguments[1].GetIntValue,
                windowStyle);
    end;
  end;
begin
  result        := false;
  //get message name
  messageName   := name;
  browserHandle := GetBrowserWindow(context.Browser);
  argsLength    := Length(arguments);
  case StrToCase(messageName, ExternalFuncs) of
    0://move
    begin
      ReleaseCapture;
      SendMessage(browserHandle, WM_SYSCOMMAND, SC_MOVE + HTCAPTION,0);
      Result := true;
    end;
    1://max
    begin
      //@todo why SendMessage make app crash
      if IsZoomed(browserHandle) then
      begin
        PostMessage(browserHandle, WM_SYSCOMMAND, SC_RESTORE, 0);
      end
      else begin
        PostMessage(browserHandle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
      end;
      //draw Round
      //drawRound(browserHandle);
      Result := true;
    end;
    2://min
    begin
      PostMessage(browserHandle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
      //draw Round
      //drawRound(browserHandle);
      Result := true;
    end;
    3://close
    begin
      PostMessage(browserHandle, WM_SYSCOMMAND, SC_CLOSE, 0);
      Result := true;
    end;
    4://color
    begin
      if argsLength > 1 then
      begin
        PostMessage(browserHandle, WM_BACKGROUND, HtmlToColor(arguments[0].GetStringValue), 0);
        result := true;
      end
      else begin
        result := false;
      end;
    end;
    5://resize(width, height, centerwindow)
    begin
      DoWindowResize;
      //draw Round
      //drawRound(browserHandle);
      result := true;
    end
    else begin
    end;
  end;
end;

{ TCefStreamDownloadHandler }

procedure TCefStreamDownloadHandler.Complete;
begin
  MainForm.StatusBar.SimpleText := 'Download complete';
end;

constructor TCefStreamDownloadHandler.Create(stream: TStream; Owned: Boolean);
begin
  inherited Create;
  FStream := stream;
  FOwned := Owned;
end;

destructor TCefStreamDownloadHandler.Destroy;
begin
  if FOwned then
    FStream.Free;
  inherited;
end;

function TCefStreamDownloadHandler.ReceivedData(data: Pointer;
  DataSize: Integer): Integer;
begin
  Result := FStream.Write(data^, DataSize);
  MainForm.StatusBar.SimpleText := 'Downloading ... ' + IntToStr(FStream.Position div 1000) + ' Kb';
end;

(*
//or you can build extension code in CefRegisterExtension
function buildExtensionCode:string;
var
  i,p : integer;
begin
  result := Format('var %0:s; if (!%0:s){ %0:s = {', [WDAPP_EXTERNAL]);
  for i := 0 to Length(ExternalFuncs)-1 do
  begin
    p := Pos(':', externalFuncs[i]);
    if p>0 then
    begin
      Result := Result + ExternalFuncs[i];
      Delete(ExternalFuncs[i], p, MaxInt);
      Result := Result + Format('{native function %0:s();'#13#10'return %0:s();},', [ExternalFuncs[i]])
    end;
  end;
  Result := Result + '}};'
end;

*)

initialization
  // create browserList
  BrowserList              := TObjectHash.Create;
  ContentHandler := TCustomV8ContextHandler.Create;
  // register by extension code
  // CefRegisterExtension('v8/'+WDAPP_EXTERNAL, buildExtensionCode, TWDAppExternal.Create);
  //register by contextCreated
  ExternalClass := TWDAppExternal;
  CefAddExternalFunction(ExternalFuncs);

finalization
  FreeAndNil(ContentHandler);
  FreeAndNil(BrowserList);
end.
