(*
 *                       Delphi Chromium Embedded
 *
 * Usage allowed under the restrictions of the Lesser GNU General Public License
 * or alternatively the restrictions of the Mozilla Public License 1.1
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * Unit owner : Henri Gourvest <hgourvest@gmail.com>
 * Web site   : http://www.progdigy.com
 * Repository : http://code.google.com/p/delphichromiumembedded/
 * Group      : http://groups.google.com/group/delphichromiumembedded
 *
 * Embarcadero Technologies, Inc is not permitted to use or redistribute
 * this source code without explicit permission.
 *
 *)

unit ceffmx;

{$I cef.inc}

interface
uses
  SysUtils, System.UITypes, Classes,
{$ifdef MSWINDOWS}
  Messages, Windows,
{$endif}
  FMX.Types, FMX.Platform,
  System.Types, ceflib, cefgui;

type
  TCustomChromiumFMX = class(TControl, IChromiumEvents)
  private
    FHandler: ICefBase;
    FBrowser: ICefBrowser;
    FDefaultUrl: ustring;

    FOnBeforePopup: TOnBeforePopup;
    FOnAfterCreated: TOnAfterCreated;
    FOnBeforeClose: TOnBeforeClose;
    FOnClose: TOnClose;
    FOnRunModal: TOnRunModal;

    FOnLoadStart: TOnLoadStart;
    FOnLoadEnd: TOnLoadEnd;
    FOnLoadError: TOnLoadError;

    FOnAuthCredentials: TOnAuthCredentials;
    FOnGetDownloadHandler: TOnGetDownloadHandler;
    FOnBeforeBrowse: TOnBeforeBrowse;
    FOnBeforeResourceLoad: TOnBeforeResourceLoad;
    FOnProtocolExecution: TOnProtocolExecution;
    FOnResourceRedirect: TOnResourceRedirect;
    FOnResourceResponse: TOnResourceResponse;

    FOnAddressChange: TOnAddressChange;
    FOnContentsSizeChange: TOnContentsSizeChange;
    FOnConsoleMessage: TOnConsoleMessage;
    FOnNavStateChange: TOnNavStateChange;
    FOnStatusMessage: TOnStatusMessage;
    FOnTitleChange: TOnTitleChange;
    FOnTooltip: TOnTooltip;
    FOnFaviconUrlChange: TOnFaviconUrlChange;

    FOnTakeFocus: TOnTakeFocus;
    FOnSetFocus: TOnSetFocus;
    FOnFocusedNodeChanged: TOnFocusedNodeChanged;

    FOnKeyEvent: TOnKeyEvent;

    FOnBeforeMenu: TOnBeforeMenu;
    FOnGetMenuLabel: TOnGetMenuLabel;
    FOnMenuAction: TOnMenuAction;

    FOnBeforeScriptExtensionLoad: TOnBeforeScriptExtensionLoad;

    FOnPrintHeaderFooter: TOnPrintHeaderFooter;
    FOnPrintOptions: TOnPrintOptions;

    FOnFindResult: TOnFindResult;

    FOnJsAlert: TOnJsAlert;
    FOnJsConfirm: TOnJsConfirm;
    FOnJsPrompt: TOnJsPrompt;
    FOnJsBinding: TOnJsBinding;

    FOnContextCreated: TOnContextEvent;
    FOnContextReleased: TOnContextEvent;

    FOnDragStart: TOnDragEvent;
    FOnDragEnter: TOnDragEvent;

    FOnRequestGeolocationPermission: TOnRequestGeolocationPermission;
    FOnCancelGeolocationPermission: TOnCancelGeolocationPermission;

    FOnGetZoomLevel: TOnGetZoomLevel;
    FOnSetZoomLevel: TOnSetZoomLevel;

    FOptions: TChromiumOptions;
    FUserStyleSheetLocation: ustring;
    FDefaultEncoding: ustring;
    FFontOptions: TChromiumFontOptions;

    FBuffer: TBitmap;
    procedure GetSettings(var settings: TCefBrowserSettings);
    procedure CreateBrowser;
  protected
    class function ShiftStateToInt(Shift: TShiftState): Integer;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure DialogKey(var Key: Word; Shift: TShiftState); override;

    procedure Loaded; override;
    procedure Resize; override;

    function doOnBeforePopup(const parentBrowser: ICefBrowser;
      var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
      var url: ustring; var client: ICefBase): Boolean; virtual;
    procedure doOnAfterCreated(const browser: ICefBrowser); virtual;
    function doOnBeforeClose(const browser: ICefBrowser): Boolean; virtual;
    function doOnClose(const browser: ICefBrowser): Boolean; virtual;
    function doOnRunModal(const browser: ICefBrowser): Boolean; virtual;

    procedure doOnLoadStart(const browser: ICefBrowser; const frame: ICefFrame); virtual;
    function doOnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer): Boolean; virtual;
    function doOnLoadError(const browser: ICefBrowser;
      const frame: ICefFrame; errorCode: TCefHandlerErrorcode;
      const failedUrl: ustring; var errorText: ustring): Boolean; virtual;

    function doOnAuthCredentials(const browser: ICefBrowser; isProxy: Boolean; Port: Integer;
      const host, realm, scheme: ustring; var username, password: ustring): Boolean; virtual;
    function doOnGetDownloadHandler(const browser: ICefBrowser; const mimeType, fileName: ustring;
      contentLength: int64; var handler: ICefDownloadHandler): Boolean; virtual;
    function doOnBeforeBrowse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; navType: TCefHandlerNavtype;
      isRedirect: boolean): Boolean; virtual;
    function doOnBeforeResourceLoad(const browser: ICefBrowser;
      const request: ICefRequest; var redirectUrl: ustring;
      var resourceStream: ICefStreamReader; const response: ICefResponse;
      loadFlags: Integer): Boolean; virtual;
    function doOnProtocolExecution(const browser: ICefBrowser;
      const url: ustring; var AllowOsExecution: Boolean): Boolean; virtual;
    procedure doOnResourceRedirect(const browser: ICefBrowser;
      const oldurl: ustring; out newurl: ustring); virtual;
    procedure doOnResourceResponse(const browser: ICefBrowser;
      const url: ustring; const response: ICefResponse; var filter: ICefBase); virtual;

    procedure doOnAddressChange(const browser: ICefBrowser;
      const frame: ICefFrame; const url: ustring); virtual;
    procedure doOnContentsSizeChange(const browser: ICefBrowser;
      const frame: ICefFrame; width, height: Integer);
    function doOnConsoleMessage(const browser: ICefBrowser; const message,
      source: ustring; line: Integer): Boolean; virtual;
    function doOnNavStateChange(const browser: ICefBrowser; canGoBack,
      canGoForward: Boolean): Boolean; virtual;
    function doOnStatusMessage(const browser: ICefBrowser; const value: ustring;
      StatusType: TCefHandlerStatusType): Boolean; virtual;
    function doOnTitleChange(const browser: ICefBrowser;
      const title: ustring): Boolean; virtual;
    function doOnTooltip(const browser: ICefBrowser; var text: ustring): Boolean; virtual;
    procedure doOnFaviconUrlChange(const browser: ICefBrowser; list: TStrings); virtual;

    procedure doOnTakeFocus(const browser: ICefBrowser; next: Boolean); virtual;
    function doOnSetFocus(const browser: ICefBrowser; source: TCefHandlerFocusSource): Boolean; virtual;
    procedure doOnFocusedNodeChanged(const browser: ICefBrowser; const frame: ICefFrame; const node: ICefDomNode); virtual;

    function doOnKeyEvent(const browser: ICefBrowser; event: TCefHandlerKeyEventType;
      code, modifiers: Integer; isSystemKey, isAfterJavaScript: Boolean): Boolean; virtual;

    function doOnBeforeMenu(const browser: ICefBrowser;
      const menuInfo: PCefMenuInfo): Boolean; virtual;
    function doOnGetMenuLabel(const browser: ICefBrowser;
      menuId: TCefMenuId; var caption: ustring): Boolean; virtual;
    function doOnMenuAction(const browser: ICefBrowser;
      menuId: TCefMenuId): Boolean; virtual;

    function doOnBeforeScriptExtensionLoad(const browser: ICefBrowser;
      const frame: ICefFrame;const extensionName: ustring): Boolean;

    function doOnPrintHeaderFooter(const browser: ICefBrowser;
      const frame: ICefFrame; printInfo: PCefPrintInfo;
      const url, title: ustring; currentPage, maxPages: Integer;
      var topLeft, topCenter, topRight, bottomLeft, bottomCenter,
      bottomRight: ustring): Boolean; virtual;
    function doOnPrintOptions(const browser: ICefBrowser;
        printOptions: PCefPrintOptions): Boolean; virtual;

    function doOnJsAlert(const browser: ICefBrowser; const frame: ICefFrame;
      const message: ustring): Boolean; virtual;
    function doOnJsConfirm(const browser: ICefBrowser; const frame: ICefFrame;
      const message: ustring; var retval: Boolean): Boolean; virtual;
    function doOnJsPrompt(const browser: ICefBrowser; const frame: ICefFrame;
      const message, defaultValue: ustring; var retval: Boolean;
      var return: ustring): Boolean; virtual;
    function doOnJsBinding(const browser: ICefBrowser;
      const frame: ICefFrame; const obj: ICefv8Value): Boolean; virtual;
    function doOnFindResult(const browser: ICefBrowser; count: Integer;
      selectionRect: PCefRect; identifier, activeMatchOrdinal,
      finalUpdate: Boolean): Boolean; virtual;

    procedure doOnContextCreated(const browser: ICefBrowser; const frame: ICefFrame;
      const context: ICefv8Context); virtual;
    procedure doOnContextReleased(const browser: ICefBrowser; const frame: ICefFrame;
      const context: ICefv8Context); virtual;

    function doOnGetViewRect(const browser: ICefBrowser; rect: PCefRect): Boolean;
    function doOnGetScreenRect(const browser: ICefBrowser; rect: PCefRect): Boolean;
    function doOnGetScreenPoint(const browser: ICefBrowser; viewX, viewY: Integer;
      screenX, screenY: PInteger): Boolean;
    procedure doOnPopupShow(const browser: ICefBrowser; show: Boolean);
    procedure doOnPopupSize(const browser: ICefBrowser; const rect: PCefRect);
    procedure doOnPaint(const browser: ICefBrowser; kind: TCefPaintElementType;
        dirtyRectsCount: Cardinal; const dirtyRects: PCefRectArray; const buffer: Pointer);
    procedure doOnCursorChange(const browser: ICefBrowser; cursor: TCefCursorHandle);

    function doOnDragStart(const browser: ICefBrowser;
      const dragData: ICefDragData; mask: Integer): Boolean;
    function doOnDragEnter(const browser: ICefBrowser;
      const dragData: ICefDragData; mask: Integer): Boolean;

    procedure doOnRequestGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer; const callback: ICefGeolocationCallback);
    procedure doOnCancelGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer);

    function doOnGetZoomLevel(const browser: ICefBrowser; const url: ustring; out zoomLevel: Double): Boolean;
    function doOnSetZoomLevel(const browser: ICefBrowser; const url: ustring; zoomLevel: Double): Boolean;

    property DefaultUrl: ustring read FDefaultUrl write FDefaultUrl;

    property OnBeforePopup: TOnBeforePopup read FOnBeforePopup write FOnBeforePopup;
    property OnAfterCreated: TOnAfterCreated read FOnAfterCreated write FOnAfterCreated;
    property OnBeforeClose: TOnBeforeClose read FOnBeforeClose write FOnBeforeClose;
    property OnClose: TOnClose read FOnClose write FOnClose;
    property OnRunModal: TOnRunModal read FOnRunModal write FOnRunModal;

    property OnLoadStart: TOnLoadStart read FOnLoadStart write FOnLoadStart;
    property OnLoadEnd: TOnLoadEnd read FOnLoadEnd write FOnLoadEnd;
    property OnLoadError: TOnLoadError read FOnLoadError write FOnLoadError;

    property OnAuthCredentials: TOnAuthCredentials read FOnAuthCredentials write FOnAuthCredentials;
    property OnGetDownloadHandler: TOnGetDownloadHandler read FOnGetDownloadHandler write FOnGetDownloadHandler;
    property OnBeforeBrowse: TOnBeforeBrowse read FOnBeforeBrowse write FOnBeforeBrowse;
    property OnBeforeResourceLoad: TOnBeforeResourceLoad read FOnBeforeResourceLoad write FOnBeforeResourceLoad;
    property OnProtocolExecution: TOnProtocolExecution read FOnProtocolExecution write FOnProtocolExecution;
    property OnResourceRedirect: TOnResourceRedirect read FOnResourceRedirect write FOnResourceRedirect;
    property OnResourceResponse: TOnResourceResponse read FOnResourceResponse write FOnResourceResponse;

    property OnAddressChange: TOnAddressChange read FOnAddressChange write FOnAddressChange;
    property OnContentsSizeChange: TOnContentsSizeChange read FOnContentsSizeChange write FOnContentsSizeChange;
    property OnConsoleMessage: TOnConsoleMessage read FOnConsoleMessage write FOnConsoleMessage;
    property OnNavStateChange: TOnNavStateChange read FOnNavStateChange write FOnNavStateChange;
    property OnStatusMessage: TOnStatusMessage read FOnStatusMessage write FOnStatusMessage;
    property OnTitleChange: TOnTitleChange read FOnTitleChange write FOnTitleChange;
    property OnTooltip: TOnTooltip read FOnTooltip write FOnTooltip;
    property OnFaviconUrlChange: TOnFaviconUrlChange read FOnFaviconUrlChange write FOnFaviconUrlChange;

    property OnTakeFocus: TOnTakeFocus read FOnTakeFocus write FOnTakeFocus;
    property OnSetFocus: TOnSetFocus read FOnSetFocus write FOnSetFocus;
    property OnFocusedNodeChanged: TOnFocusedNodeChanged read FOnFocusedNodeChanged write FOnFocusedNodeChanged;

    property OnKeyEvent: TOnKeyEvent read FOnKeyEvent write FOnKeyEvent;

    property OnBeforeMenu: TOnBeforeMenu read FOnBeforeMenu write FOnBeforeMenu;
    property OnGetMenuLabel: TOnGetMenuLabel read FOnGetMenuLabel write FOnGetMenuLabel;
    property OnMenuAction: TOnMenuAction read FOnMenuAction write FOnMenuAction;

    property OnBeforeScriptExtensionLoad: TOnBeforeScriptExtensionLoad read FOnBeforeScriptExtensionLoad write FOnBeforeScriptExtensionLoad;

    property OnPrintHeaderFooter: TOnPrintHeaderFooter read FOnPrintHeaderFooter write FOnPrintHeaderFooter;
    property OnPrintOptions: TOnPrintOptions read FOnPrintOptions write FOnPrintOptions;

    property OnJsAlert: TOnJsAlert read FOnJsAlert write FOnJsAlert;
    property OnJsConfirm: TOnJsConfirm read FOnJsConfirm write FOnJsConfirm;
    property OnJsPrompt: TOnJsPrompt read FOnJsPrompt write FOnJsPrompt;
    property OnJsBinding: TOnJsBinding read FOnJsBinding write FOnJsBinding;
    property OnFindResult: TOnFindResult read FOnFindResult write FOnFindResult;

    property OnContextCreated: TOnContextEvent read FOnContextCreated write FOnContextCreated;
    property OnContextReleased: TOnContextEvent read FOnContextReleased write FOnContextReleased;

    property OnDragStart: TOnDragEvent read FOnDragStart write FOnDragStart;
    property OnDragEnter: TOnDragEvent read FOnDragEnter write FOnDragEnter;

    property OnRequestGeolocationPermission: TOnRequestGeolocationPermission read FOnRequestGeolocationPermission write FOnRequestGeolocationPermission;
    property OnCancelGeolocationPermission: TOnCancelGeolocationPermission read FOnCancelGeolocationPermission write FOnCancelGeolocationPermission;

    property OnGetZoomLevel: TOnGetZoomLevel read FOnGetZoomLevel write FOnGetZoomLevel;
    property OnSetZoomLevel: TOnSetZoomLevel read FOnSetZoomLevel write FOnSetZoomLevel;

    property Options: TChromiumOptions read FOptions write FOptions;
    property FontOptions: TChromiumFontOptions read FFontOptions;
    property DefaultEncoding: ustring read FDefaultEncoding write FDefaultEncoding;
    property UserStyleSheetLocation: ustring read FUserStyleSheetLocation write FUserStyleSheetLocation;
    property Browser: ICefBrowser read FBrowser;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Load(const url: ustring);
    procedure ReCreateBrowser(const url: string);
  end;

  TChromiumFMX = class(TCustomChromiumFMX)
  public
    property Browser;
  published
    property Align;
    property Anchors;
    property DefaultUrl;
    property TabOrder;
    property Visible;

    property OnBeforePopup;
    property OnAfterCreated;
    property OnBeforeClose;
    property OnClose;
    property OnRunModal;

    property OnLoadStart;
    property OnLoadEnd;
    property OnLoadError;

    property OnAuthCredentials;
    property OnGetDownloadHandler;
    property OnBeforeBrowse;
    property OnBeforeResourceLoad;
    property OnProtocolExecution;
    property OnResourceRedirect;
    property OnResourceResponse;

    property OnAddressChange;
    property OnContentsSizeChange;
    property OnConsoleMessage;
    property OnNavStateChange;
    property OnStatusMessage;
    property OnTitleChange;
    property OnTooltip;
    property OnFaviconUrlChange;

    property OnTakeFocus;
    property OnSetFocus;
    property OnFocusedNodeChanged;

    property OnKeyEvent;

    property OnBeforeMenu;
    property OnGetMenuLabel;
    property OnMenuAction;

    property OnPrintHeaderFooter;
    property OnPrintOptions;

    property OnJsAlert;
    property OnJsConfirm;
    property OnJsPrompt;
    property OnJsBinding;
    property OnFindResult;

    property OnDragStart;
    property OnDragEnter;

    property OnRequestGeolocationPermission;
    property OnCancelGeolocationPermission;

    property OnGetZoomLevel;
    property OnSetZoomLevel;

    property Options;
    property FontOptions;
    property DefaultEncoding;
    property UserStyleSheetLocation;
  end;

  TChromiumFMXOSR = class(TCustomChromiumOSR)
  public
    property Browser;
  published
    property DefaultUrl;

    property OnBeforePopup;
    property OnAfterCreated;
    property OnBeforeClose;
    property OnClose;
    property OnRunModal;

    property OnLoadStart;
    property OnLoadEnd;
    property OnLoadError;

    property OnAuthCredentials;
    property OnGetDownloadHandler;
    property OnBeforeBrowse;
    property OnBeforeResourceLoad;
    property OnProtocolExecution;
    property OnResourceRedirect;
    property OnResourceResponse;

    property OnAddressChange;
    property OnContentsSizeChange;
    property OnConsoleMessage;
    property OnNavStateChange;
    property OnStatusMessage;
    property OnTitleChange;
    property OnTooltip;
    property OnFaviconUrlChange;

    property OnTakeFocus;
    property OnSetFocus;
    property OnFocusedNodeChanged;

    property OnKeyEvent;

    property OnBeforeMenu;
    property OnGetMenuLabel;
    property OnMenuAction;

    property OnPrintHeaderFooter;
    property OnPrintOptions;

    property OnJsAlert;
    property OnJsConfirm;
    property OnJsPrompt;
    property OnJsBinding;
    property OnFindResult;

    property OnGetViewRect;
    property OnGetScreenRect;
    property OnGetScreenPoint;
    property OnPopupShow;
    property OnPopupSize;
    property OnPaint;
    property OnCursorChange;

    property OnDragStart;
    property OnDragEnter;

    property OnRequestGeolocationPermission;
    property OnCancelGeolocationPermission;

    property OnGetZoomLevel;
    property OnSetZoomLevel;

    property Options;
    property FontOptions;
    property DefaultEncoding;
    property UserStyleSheetLocation;
  end;

function CefGetBitmap(const browser: ICefBrowser; typ: TCefPaintElementType; Bitmap: TBitmap): Boolean;

implementation
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}

var
  CefInstances: Integer = 0;
  CefTimer: UINT = 0;
{$ENDIF}


function CefGetBitmap(const browser: ICefBrowser; typ: TCefPaintElementType; Bitmap: TBitmap): Boolean;
var
  w, h, i: Integer;
  p, s: Pointer;
begin
  browser.GetSize(typ, w, h);
  Bitmap.SetSize(w, h);
  GetMem(p, h * w * 4);
  try
    Result := browser.GetImage(typ, w, h, p);
    s := p;
    for i := 0 to h - 1 do
    begin
      Move(s^, Bitmap.ScanLine[i]^, w*4);
      Inc(Integer(s), w*4);
    end;
  finally
    FreeMem(p);
  end;
end;

type
  TFMXClientHandler = class(TCustomClientHandler)
  public
    constructor Create(const crm: IChromiumEvents); override;
    destructor Destroy; override;
  end;

{ TCustomChromiumFMX }

constructor TCustomChromiumFMX.Create(AOwner: TComponent);
begin
  inherited;

  if not (csDesigning in ComponentState) then
    FHandler := TFMXClientHandler.Create(Self) as ICefBase;

  FBuffer := nil;
  CanFocus := True;

  FOptions := TChromiumOptions.Create;
  FFontOptions := TChromiumFontOptions.Create;

  FUserStyleSheetLocation := '';
  FDefaultEncoding := '';
  FBrowser := nil;
end;

procedure TCustomChromiumFMX.CreateBrowser;
var
  info: TCefWindowInfo;
  settings: TCefBrowserSettings;
begin
  if not (csDesigning in ComponentState) then
  begin
    FillChar(info, SizeOf(info), 0);
{$ifdef MSWINDOWS}
    info.m_bWindowRenderingDisabled := True;
{$endif}
{$ifdef MACOSX}
    info.m_bHidden := 1;
{$endif}
    FillChar(settings, SizeOf(TCefBrowserSettings), 0);
    settings.size := SizeOf(TCefBrowserSettings);
    GetSettings(settings);
    FBrowser := CefBrowserCreateSync(@info, FHandler.Wrap, '', @settings);
  end;
end;

destructor TCustomChromiumFMX.Destroy;
begin
  if FBrowser <> nil then
    FBrowser.ParentWindowWillClose;
  if FHandler <> nil then
    (FHandler as ICefClientHandler).Disconnect;
  FHandler := nil;
  FBrowser := nil;
  FFontOptions.Free;
  FOptions.Free;
  if FBuffer <> nil then
    FBuffer.Free;
  inherited;
end;

procedure TCustomChromiumFMX.DialogKey(var Key: Word; Shift: TShiftState);
var
  keyInfo: TCefKeyInfo;
begin
  keyInfo.key := Key;
  keyInfo.sysChar := False;
  keyInfo.imeChar := False;
  if Browser <> nil then
    Browser.SendKeyEvent(KT_KEYDOWN, keyInfo, ShiftStateToInt(Shift));
end;

procedure TCustomChromiumFMX.doOnAddressChange(const browser: ICefBrowser;
  const frame: ICefFrame; const url: ustring);
begin
  if Assigned(FOnAddressChange) then
    FOnAddressChange(Self, browser, frame, url);
end;

procedure TCustomChromiumFMX.doOnAfterCreated(const browser: ICefBrowser);
begin
  if (browser <> nil) and not browser.IsPopup then
    browser.SendFocusEvent(True);
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  if (browser <> nil) and not browser.IsPopup then
    FBrowser := browser;
{$ENDIF}
  if Assigned(FOnAfterCreated) then
    FOnAfterCreated(Self, browser);
end;

function TCustomChromiumFMX.doOnAuthCredentials(const browser: ICefBrowser;
  isProxy: Boolean; Port: Integer; const host, realm, scheme: ustring; var username,
  password: ustring): Boolean;
begin
  Result := False;
  if Assigned(FOnAuthCredentials) then
    FOnAuthCredentials(Self, browser, isProxy, port, host, realm, scheme, username, password, Result);
end;

function TCustomChromiumFMX.doOnBeforeBrowse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  navType: TCefHandlerNavtype; isRedirect: boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforeBrowse) then
    FOnBeforeBrowse(Self, browser, frame, request, navType, isRedirect, Result);
end;

function TCustomChromiumFMX.doOnBeforeMenu(const browser: ICefBrowser;
  const menuInfo: PCefMenuInfo): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforeMenu) then
    FOnBeforeMenu(Self, browser, menuInfo, Result);
end;

function TCustomChromiumFMX.doOnBeforePopup(const parentBrowser: ICefBrowser;
  var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
  var url: ustring; var client: ICefBase): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforePopup) then
    FOnBeforePopup(Self, parentBrowser, popupFeatures, windowInfo, url, client, Result);
end;

function TCustomChromiumFMX.doOnBeforeResourceLoad(const browser: ICefBrowser;
  const request: ICefRequest; var redirectUrl: ustring;
  var resourceStream: ICefStreamReader; const response: ICefResponse;
  loadFlags: Integer): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforeResourceLoad) then
    FOnBeforeResourceLoad(Self, browser, request, redirectUrl, resourceStream,
      response, loadFlags, Result);
end;

function TCustomChromiumFMX.doOnBeforeScriptExtensionLoad(
  const browser: ICefBrowser; const frame: ICefFrame;
  const extensionName: ustring): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforeScriptExtensionLoad) then
    FOnBeforeScriptExtensionLoad(Self, browser, frame, extensionName, Result);
end;

function TCustomChromiumFMX.doOnBeforeClose(
  const browser: ICefBrowser): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforeClose) then
    FOnBeforeClose(Self, browser, Result);
end;

function TCustomChromiumFMX.doOnConsoleMessage(const browser: ICefBrowser; const message,
  source: ustring; line: Integer): Boolean;
begin
  Result := False;
  if Assigned(FOnConsoleMessage) then
    FOnConsoleMessage(Self, browser, message, source, line, Result);
end;

procedure TCustomChromiumFMX.doOnContentsSizeChange(const browser: ICefBrowser;
  const frame: ICefFrame; width, height: Integer);
begin
  if Assigned(FOnContentsSizeChange) then
    FOnContentsSizeChange(Self, browser, frame, width, height);
end;

procedure TCustomChromiumFMX.doOnContextCreated(const browser: ICefBrowser;
  const frame: ICefFrame; const context: ICefv8Context);
begin
  if Assigned(FOnContextCreated) then
    FOnContextCreated(Self, browser, frame, context);
end;

procedure TCustomChromiumFMX.doOnContextReleased(const browser: ICefBrowser;
  const frame: ICefFrame; const context: ICefv8Context);
begin
  if Assigned(FOnContextReleased) then
    FOnContextReleased(Self, browser, frame, context);
end;

function TCustomChromiumFMX.doOnGetDownloadHandler(const browser: ICefBrowser;
  const mimeType, fileName: ustring; contentLength: int64;
  var handler: ICefDownloadHandler): Boolean;
begin
  Result := False;
  if Assigned(FOnGetDownloadHandler) then
    FOnGetDownloadHandler(Self, browser, mimeType, fileName, contentLength, handler, Result);
end;

procedure TCustomChromiumFMX.doOnFaviconUrlChange(const browser: ICefBrowser;
  list: TStrings);
begin
  if Assigned(FOnFaviconUrlChange) then
    FOnFaviconUrlChange(Self, browser, list);
end;

function TCustomChromiumFMX.doOnFindResult(const browser: ICefBrowser;
  count: Integer; selectionRect: PCefRect; identifier, activeMatchOrdinal,
  finalUpdate: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnFindResult) then
    FOnFindResult(Self, browser, count, selectionRect, identifier,
      activeMatchOrdinal, finalUpdate, Result);
end;

procedure TCustomChromiumFMX.doOnFocusedNodeChanged(const browser: ICefBrowser;
  const frame: ICefFrame; const node: ICefDomNode);
begin
  if Assigned(FOnFocusedNodeChanged) then
    FOnFocusedNodeChanged(Self, browser, frame, node);
end;

function TCustomChromiumFMX.doOnGetMenuLabel(const browser: ICefBrowser;
  menuId: TCefMenuId; var caption: ustring): Boolean;
begin
  Result := False;
  if Assigned(FOnGetMenuLabel) then
    FOnGetMenuLabel(Self, browser, menuId, caption, Result);
end;

function TCustomChromiumFMX.doOnGetScreenPoint(const browser: ICefBrowser; viewX,
  viewY: Integer; screenX, screenY: PInteger): Boolean;
begin
  Result := False;
end;

function TCustomChromiumFMX.doOnGetScreenRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := False;
end;

function TCustomChromiumFMX.doOnGetViewRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := False;
end;

function TCustomChromiumFMX.doOnGetZoomLevel(const browser: ICefBrowser;
  const url: ustring; out zoomLevel: Double): Boolean;
begin
  Result := False;
  if Assigned(FOnGetZoomLevel) then
    FOnGetZoomLevel(Self, browser, url, zoomLevel, Result);
end;

function TCustomChromiumFMX.doOnJsAlert(const browser: ICefBrowser;
  const frame: ICefFrame; const message: ustring): Boolean;
begin
  Result := False;
  if Assigned(FOnJsAlert) then
    FOnJsAlert(Self, browser, frame, message, Result);
end;

function TCustomChromiumFMX.doOnJsBinding(const browser: ICefBrowser;
  const frame: ICefFrame; const obj: ICefv8Value): Boolean;
begin
  Result := False;
  if Assigned(FOnJsBinding) then
    FOnJsBinding(Self, browser, frame, obj, Result);
end;

function TCustomChromiumFMX.doOnJsConfirm(const browser: ICefBrowser;
  const frame: ICefFrame; const message: ustring;
  var retval: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnJsConfirm) then
    FOnJsConfirm(Self, browser, frame, message, retval, Result);
end;

function TCustomChromiumFMX.doOnJsPrompt(const browser: ICefBrowser;
  const frame: ICefFrame; const message, defaultValue: ustring;
  var retval: Boolean; var return: ustring): Boolean;
begin
  Result := False;
  if Assigned(FOnJsPrompt) then
    FOnJsPrompt(Self, browser, frame, message, defaultValue, retval, return, Result);
end;

function TCustomChromiumFMX.doOnKeyEvent(const browser: ICefBrowser;
  event: TCefHandlerKeyEventType; code, modifiers: Integer;
  isSystemKey, isAfterJavaScript: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnKeyEvent) then
    FOnKeyEvent(Self, browser, event, code, modifiers, isSystemKey, isAfterJavaScript, Result);
end;

function TCustomChromiumFMX.doOnLoadEnd(const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer): Boolean;
begin
  Result := False;
  if Assigned(FOnLoadEnd) then
    FOnLoadEnd(Self, browser, frame, httpStatusCode, Result);
end;

function TCustomChromiumFMX.doOnLoadError(const browser: ICefBrowser;
  const frame: ICefFrame; errorCode: TCefHandlerErrorcode;
  const failedUrl: ustring; var errorText: ustring): Boolean;
begin
  Result := False;
  if Assigned(FOnLoadError) then
    FOnLoadError(Self, browser, frame, errorCode, failedUrl, errorText, Result);
end;

procedure TCustomChromiumFMX.doOnLoadStart(const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  if Assigned(FOnLoadStart) then
    FOnLoadStart(Self, browser, frame);
end;

function TCustomChromiumFMX.doOnMenuAction(const browser: ICefBrowser;
  menuId: TCefMenuId): Boolean;
begin
  Result := False;
  if Assigned(FOnMenuAction) then
    FOnMenuAction(Self, browser, menuId, Result);
end;

function TCustomChromiumFMX.doOnNavStateChange(const browser: ICefBrowser;
  canGoBack, canGoForward: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnNavStateChange) then
    FOnNavStateChange(Self, browser, canGoBack, canGoForward, Result);
end;

procedure TCustomChromiumFMX.doOnCursorChange(const browser: ICefBrowser;
  cursor: TCefCursorHandle);
begin
{$ifdef MSWINDOWS}
  SetCursor(cursor);
{$endif}
end;

function TCustomChromiumFMX.doOnDragEnter(const browser: ICefBrowser;
  const dragData: ICefDragData; mask: Integer): Boolean;
begin
  Result := False;
  if Assigned(FOnDragEnter) then
    FOnDragEnter(Self, browser, dragData, mask, Result);
end;

function TCustomChromiumFMX.doOnDragStart(const browser: ICefBrowser;
  const dragData: ICefDragData; mask: Integer): Boolean;
begin
  Result := False;
  if Assigned(FOnDragStart) then
    FOnDragStart(Self, browser, dragData, mask, Result);
end;

procedure TCustomChromiumFMX.doOnPaint(const browser: ICefBrowser;
  kind: TCefPaintElementType; dirtyRectsCount: Cardinal;
  const dirtyRects: PCefRectArray; const buffer: Pointer);
var
  src, dst: PByte;
  offset, i, {j,} w, c: Integer;
  vw, vh: Integer;
begin
  FBrowser.GetSize(PET_VIEW, vw, vh);
  if FBuffer = nil then
    FBuffer := TBitmap.Create(vw, vh);
  with FBuffer do
    if (vw = Width) and (vh = Height) then
//    begin
//      Move(buffer^, StartLine^, vw * vh * 4);
//      InvalidateRect(ClipRect);
//    end;
    for c := 0 to dirtyRectsCount - 1 do
    begin
      w := Width * 4;
      offset := ((dirtyRects[c].y * Width) + dirtyRects[c].x) * 4;
      src := @PByte(buffer)[offset];
      dst := @PByte(StartLine)[offset];
      offset := dirtyRects[c].width * 4;
      for i := 0 to dirtyRects[c].height - 1 do
      begin
//        for j := 0 to offset div 4 do
//          PAlphaColorArray(dst)[j] := PAlphaColorArray(src)[j] or $FF000000;
        Move(src^, dst^, offset);
        Inc(dst, w);
        Inc(src, w);
      end;
      //InvalidateRect(ClipRect);
      InvalidateRect(RectF(dirtyRects[c].x, dirtyRects[c].y,
        dirtyRects[c].x + dirtyRects[c].width,  dirtyRects[c].y + dirtyRects[c].height));
    end;
end;

procedure TCustomChromiumFMX.doOnPopupShow(const browser: ICefBrowser;
  show: Boolean);
begin

end;

procedure TCustomChromiumFMX.doOnPopupSize(const browser: ICefBrowser;
  const rect: PCefRect);
begin

end;

function TCustomChromiumFMX.doOnPrintHeaderFooter(const browser: ICefBrowser;
  const frame: ICefFrame; printInfo: PCefPrintInfo; const url, title: ustring;
  currentPage, maxPages: Integer; var topLeft, topCenter, topRight, bottomLeft,
  bottomCenter, bottomRight: ustring): Boolean;
begin
  Result := False;
  if Assigned(FOnPrintHeaderFooter) then
    FOnPrintHeaderFooter(Self, browser, frame, printInfo, url, title,
      currentPage, maxPages, topLeft, topCenter, topRight, bottomLeft,
      bottomCenter, bottomRight, Result);
end;

function TCustomChromiumFMX.doOnPrintOptions(const browser: ICefBrowser;
  printOptions: PCefPrintOptions): Boolean;
begin
  Result := False;
  if Assigned(FOnPrintOptions) then
    FOnPrintOptions(Self, browser, printOptions, Result);
end;

function TCustomChromiumFMX.doOnProtocolExecution(const browser: ICefBrowser;
  const url: ustring; var AllowOsExecution: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnProtocolExecution) then
    FOnProtocolExecution(Self, browser, url, AllowOsExecution, Result);
end;

procedure TCustomChromiumFMX.doOnCancelGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer);
begin
  if Assigned(FOnCancelGeolocationPermission) then
    FOnCancelGeolocationPermission(Self, browser, requestingUrl, requestId);
end;

function TCustomChromiumFMX.doOnClose(const browser: ICefBrowser): Boolean;
begin
  Result := False;
  if Assigned(FOnClose) then
    FOnClose(Self, browser, Result);
end;

procedure TCustomChromiumFMX.doOnRequestGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer;
  const callback: ICefGeolocationCallback);
begin
  if Assigned(FOnRequestGeolocationPermission) then
    FOnRequestGeolocationPermission(Self, browser, requestingUrl, requestId, callback);
end;

procedure TCustomChromiumFMX.doOnResourceRedirect(const browser: ICefBrowser;
  const oldurl: ustring; out newurl: ustring);
begin
  if Assigned(FOnResourceRedirect) then
    FOnResourceRedirect(Self, browser, oldurl, newurl);
end;

procedure TCustomChromiumFMX.doOnResourceResponse(const browser: ICefBrowser;
  const url: ustring; const response: ICefResponse; var filter: ICefBase);
begin
  if Assigned(FOnResourceResponse) then
    FOnResourceResponse(Self, browser, url, response, filter);
end;

function TCustomChromiumFMX.doOnRunModal(const browser: ICefBrowser): Boolean;
begin
  Result := False;
  if Assigned(FOnRunModal) then
    FOnRunModal(Self, browser, Result);
end;

function TCustomChromiumFMX.doOnSetFocus(const browser: ICefBrowser;
  source: TCefHandlerFocusSource): Boolean;
begin
  Result := False;
  if Assigned(FOnSetFocus) then
    FOnSetFocus(Self, browser, source, Result);
end;

function TCustomChromiumFMX.doOnSetZoomLevel(const browser: ICefBrowser;
  const url: ustring; zoomLevel: Double): Boolean;
begin
  Result := False;
  if Assigned(FOnSetZoomLevel) then
    FOnSetZoomLevel(Self, browser, url, zoomLevel, Result);
end;

function TCustomChromiumFMX.doOnStatusMessage(const browser: ICefBrowser;
  const value: ustring; StatusType: TCefHandlerStatusType): Boolean;
begin
  Result := False;
  if Assigned(FOnStatusMessage) then
    FOnStatusMessage(Self, browser, value, StatusType, Result);
end;

procedure TCustomChromiumFMX.doOnTakeFocus(const browser: ICefBrowser;
  next: Boolean);
begin
  if Assigned(FOnTakeFocus) then
    FOnTakeFocus(Self, browser, next);
end;

function TCustomChromiumFMX.doOnTitleChange(const browser: ICefBrowser;
  const title: ustring): Boolean;
begin
  Result := False;
  if Assigned(FOnTitleChange) then
    FOnTitleChange(Self, browser, title, Result);
end;

function TCustomChromiumFMX.doOnTooltip(const browser: ICefBrowser;
  var text: ustring): Boolean;
begin
  Result := False;
  if Assigned(FOnTooltip) then
    FOnTooltip(Self, browser, text, Result);
end;

procedure TCustomChromiumFMX.GetSettings(var settings: TCefBrowserSettings);
begin
  Assert(settings.size >= SizeOf(settings));
  settings.standard_font_family := CefString(FFontOptions.StandardFontFamily);
  settings.fixed_font_family := CefString(FFontOptions.FixedFontFamily);
  settings.serif_font_family := CefString(FFontOptions.SerifFontFamily);
  settings.sans_serif_font_family := CefString(FFontOptions.SansSerifFontFamily);
  settings.cursive_font_family := CefString(FFontOptions.CursiveFontFamily);
  settings.fantasy_font_family := CefString(FFontOptions.FantasyFontFamily);
  settings.default_font_size := FFontOptions.DefaultFontSize;
  settings.default_fixed_font_size := FFontOptions.DefaultFixedFontSize;
  settings.minimum_font_size := FFontOptions.MinimumFontSize;
  settings.minimum_logical_font_size := FFontOptions.MinimumLogicalFontSize;
  settings.remote_fonts_disabled := FFontOptions.RemoteFontsDisabled;
  settings.default_encoding := CefString(DefaultEncoding);
  settings.user_style_sheet_location := CefString(UserStyleSheetLocation);

  settings.drag_drop_disabled := FOptions.DragDropDisabled;
  settings.load_drops_disabled := FOptions.LoadDropsDisabled;
  settings.history_disabled := FOptions.HistoryDisabled;
  settings.animation_frame_rate := FOptions.AnimationFrameRate;
  settings.encoding_detector_enabled := FOptions.EncodingDetectorEnabled;
  settings.javascript_disabled := FOptions.JavascriptDisabled;
  settings.javascript_open_windows_disallowed := FOptions.JavascriptOpenWindowsDisallowed;
  settings.javascript_close_windows_disallowed := FOptions.JavascriptCloseWindowsDisallowed;
  settings.javascript_access_clipboard_disallowed := FOptions.JavascriptAccessClipboardDisallowed;
  settings.dom_paste_disabled := FOptions.DomPasteDisabled;
  settings.caret_browsing_enabled := FOptions.CaretBrowsingEnabled;
  settings.java_disabled := FOptions.JavaDisabled;
  settings.plugins_disabled := FOptions.PluginsDisabled;
  settings.universal_access_from_file_urls_allowed := FOptions.UniversalAccessFromFileUrlsAllowed;
  settings.file_access_from_file_urls_allowed := FOptions.FileAccessFromFileUrlsAllowed;
  settings.web_security_disabled := FOptions.WebSecurityDisabled;
  settings.xss_auditor_enabled := FOptions.XssAuditorEnabled;
  settings.image_load_disabled := FOptions.ImageLoadDisabled;
  settings.shrink_standalone_images_to_fit := FOptions.ShrinkStandaloneImagesToFit;
  settings.site_specific_quirks_disabled := FOptions.SiteSpecificQuirksDisabled;
  settings.text_area_resize_disabled := FOptions.TextAreaResizeDisabled;
  settings.page_cache_disabled := FOptions.PageCacheDisabled;
  settings.tab_to_links_disabled := FOptions.TabToLinksDisabled;
  settings.hyperlink_auditing_disabled := FOptions.HyperlinkAuditingDisabled;
  settings.user_style_sheet_enabled := FOptions.UserStyleSheetEnabled;
  settings.author_and_user_styles_disabled := FOptions.AuthorAndUserStylesDisabled;
  settings.local_storage_disabled := FOptions.LocalStorageDisabled;
  settings.databases_disabled := FOptions.DatabasesDisabled;
  settings.application_cache_disabled := FOptions.ApplicationCacheDisabled;
  settings.webgl_disabled := FOptions.WebglDisabled;
  settings.accelerated_compositing_enabled := FOptions.AcceleratedCompositingEnabled;
  settings.accelerated_layers_disabled := FOptions.AcceleratedLayersDisabled;
  settings.accelerated_2d_canvas_disabled := FOptions.Accelerated2dCanvasDisabled;
  settings.developer_tools_disabled := FOptions.DeveloperToolsDisabled;
  settings.fullscreen_enabled := FOptions.FullscreenEnabled;
  settings.accelerated_painting_disabled := FOptions.AcceleratedPaintingDisabled;
  settings.accelerated_filters_disabled := FOptions.AcceleratedFiltersDisabled;
  settings.accelerated_plugins_disabled := FOptions.AcceleratedPluginsDisabled;
end;

procedure TCustomChromiumFMX.Load(const url: ustring);
var
  frm: ICefFrame;
begin
  if FBrowser <> nil then
  begin
    frm := FBrowser.MainFrame;
    if frm <> nil then
      frm.LoadUrl(url);
  end;
end;

procedure TCustomChromiumFMX.Loaded;
begin
  inherited;
  CreateBrowser;
  Resize;
  Load(FDefaultUrl);
end;

procedure TCustomChromiumFMX.Paint;
var
  r: TRectF;
  i: Integer;
begin
 if FBuffer <> nil then
 begin
   FBuffer.Canvas.BeginScene;
   for i := 0 to Scene.GetUpdateRectsCount - 1 do
   begin
     r := Scene.GetUpdateRect(i);
     r.TopLeft := AbsoluteToLocal(r.TopLeft);
     r.BottomRight := AbsoluteToLocal(r.BottomRight);
     if IntersectRectF(r, r, ClipRect) then
       Canvas.DrawBitmap(FBuffer, r, r, 1, False);
   end;
   FBuffer.Canvas.EndScene;
 end;
end;

procedure TCustomChromiumFMX.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
const
  BT: array[TMouseButton] of TCefMouseButtonType = (MBT_LEFT, MBT_RIGHT, MBT_MIDDLE);
begin
 inherited;
 if FBrowser <> nil then
 begin
   FBrowser.SendMouseClickEvent(Round(X), Round(Y), BT[Button], False, 1);
 end;
end;

procedure TCustomChromiumFMX.MouseMove(Shift: TShiftState; X, Y: Single);
begin
 inherited;
 if FBrowser <> nil then
   FBrowser.SendMouseMoveEvent(Round(X), Round(Y), False);
end;

procedure TCustomChromiumFMX.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
const
  BT: array[TMouseButton] of TCefMouseButtonType = (MBT_LEFT, MBT_RIGHT, MBT_MIDDLE);
begin
 inherited;
 if FBrowser <> nil then
   FBrowser.SendMouseClickEvent(Round(X), Round(Y), BT[Button], True, 1);
end;

procedure TCustomChromiumFMX.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  inherited;
  if FBrowser <> nil then
    with AbsoluteToLocal(Platform.GetMousePos) do
      if ssShift in Shift then
        FBrowser.SendMouseWheelEvent(Trunc(x), Trunc(y), 0, WheelDelta) else
        FBrowser.SendMouseWheelEvent(Trunc(x), Trunc(y), WheelDelta, 0);
end;

class function TCustomChromiumFMX.ShiftStateToInt(Shift: TShiftState): Integer;
begin
  Result := 0;
{$ifdef MSWINDOWS}
  if ssShift in Shift then
    Result := Result or VK_SHIFT;
  if ssCtrl in Shift then
    Result := Result or VK_CONTROL;
  if ssAlt in Shift then
    Result := Result or $20000000;
{$endif}
end;

procedure TCustomChromiumFMX.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  keyInfo: TCefKeyInfo;
begin
  if Browser <> nil then
    if KeyChar <> #0 then
    begin
      keyInfo.key := Ord(KeyChar);
      keyInfo.sysChar := False;
      keyInfo.imeChar := False;
      Browser.SendKeyEvent(KT_CHAR, keyInfo, ShiftStateToInt(Shift))
    end else
    begin
      keyInfo.key := key;
      keyInfo.sysChar := Key in [18, 121];
      keyInfo.imeChar := False;
      Browser.SendKeyEvent(KT_KEYDOWN, keyInfo, ShiftStateToInt(Shift));
    end;
end;

procedure TCustomChromiumFMX.KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  keyinfo: TCefKeyInfo;
begin
   if (FBrowser <> nil) and (key <> 0) then
   begin
     keyinfo.key := Key;
     keyinfo.sysChar := False;
     keyinfo.imeChar := False;
     FBrowser.SendKeyEvent(KT_KEYUP, keyinfo, ShiftStateToInt(Shift));
   end;
end;

procedure TCustomChromiumFMX.ReCreateBrowser(const url: string);
begin
  if (FBrowser <> nil) then
  begin
    FBrowser.ParentWindowWillClose;
    FBrowser := nil;
    CreateBrowser;
    Load(url);
  end;
end;

procedure TCustomChromiumFMX.Resize;
var
  brws: ICefBrowser;
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    brws := FBrowser;
    if (brws <> nil) then
    begin
      brws.SetSize(PET_VIEW, Trunc(Width), Trunc(Height));
      if FBuffer <> nil then
        FBuffer.Free;
      FBuffer := TBitmap.Create(Trunc(Width), Trunc(Height));
    end;
  end;
end;

{ TFMXClientHandler }

{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
var
  looping: Boolean = False;

procedure TimerProc(hwnd: HWND; uMsg: UINT; idEvent: Pointer; dwTime: DWORD); stdcall;
begin
  if looping then Exit;
  if CefInstances > 0 then
  begin
    looping := True;
    try
      CefDoMessageLoopWork;
    finally
      looping := False;
    end;
  end;
end;
{$ENDIF}

constructor TFMXClientHandler.Create(const crm: IChromiumEvents);
begin
  inherited;
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  if CefInstances = 0 then
    CefTimer := SetTimer(0, 0, 10, @TimerProc);
  InterlockedIncrement(CefInstances);
{$ENDIF}
end;

destructor TFMXClientHandler.Destroy;
begin
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  InterlockedDecrement(CefInstances);
  if CefInstances = 0 then
    KillTimer(0, CefTimer);
{$ENDIF}
  inherited;
end;

end.
