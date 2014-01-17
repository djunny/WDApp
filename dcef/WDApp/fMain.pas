unit fMain;

interface
{$I cef.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ceflib, cefvcl, Buttons, ActnList, Menus, ComCtrls,
  ExtCtrls;

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
  private
    Chrome  : TChromium;
    FLoading: Boolean;
    procedure WMBackground(var msg:Tmessage); message WM_BACKGROUND;
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
  uConst, uCommon, uScheme, uWDAppCef;

{$R *.dfm}

type
  TWDAppExternal = class(TExternalHandler)
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean; override;
  public
    constructor Create(); override;
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


procedure TMainForm.FormCreate(Sender: TObject);
begin
  FLoading               := False;
  //set app can cross domain
  CefAddCrossOriginWhitelistEntry(getAppPath('app'), 'http', '', true);
  CefAddCrossOriginWhitelistEntry(getAppPath('app'), 'https', '', true);
  CefAddCrossOriginWhitelistEntry(getAppPath('app'), WDAPP_PROTOCOL, '', true);

  //create chrome
  Chrome                 := TChromium.Create(Self);
  Chrome.Parent          := Self;
  chrome.Align           := alClient;
  chrome.OnAddressChange := crmAddressChange;
  Chrome.OnLoadEnd       := crmLoadEnd;
  Chrome.OnLoadStart     := crmLoadStart;
  Chrome.OnStatusMessage := crmStatusMessage;
  Chrome.OnTitleChange   := crmTitleChange;
  Chrome.OnContextCreated:= ContentHandler.OnContextCreated;
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
{$J+}
const LastMaxTime : Integer = -1;
{$J-}
var
  messageName   : string;
  pt            : TPoint;
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
      //check time click too fast maybe get restore
      if GetTickCount - LastMaxTime - 1000 > 0 then
      begin
        //@todo why SendMessage make app crash
        if IsZoomed(browserHandle) then
        begin
          PostMessage(browserHandle, WM_SYSCOMMAND, SC_RESTORE, 0);
        end
        else begin
          PostMessage(browserHandle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
        end;
        LastMaxTime := getTickCount;
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
  ContentHandler := TCustomV8ContextHandler.Create;

  // register by extension code
  // CefRegisterExtension('v8/'+WDAPP_EXTERNAL, buildExtensionCode, TWDAppExternal.Create);
  //register by contextCreated
  ExternalClass := TWDAppExternal;
  CefAddExternalFunction(ExternalFuncs);

finalization
  FreeAndNil(ContentHandler);
end.
