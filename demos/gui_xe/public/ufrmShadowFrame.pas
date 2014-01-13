unit ufrmShadowFrame;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics, Forms;

const
  EXTSHADOWSIZE = 16;

type
  TFormShadow = class(TWinControl)
  private
    FForm: TForm;
    FActive: Boolean;
    FShadowOffset: Integer;
    FShadowColor: TColor;

    FSavedWndProc: TWndMethod;
    FFormTransColor: TColor;

    FFormRgn: HRGN;
    FBlendBmp: TBitmap;
    FBlendFunc: TBlendFunction;
    FNeedRebuildBlend: Boolean;

    procedure SetActive(const Value: Boolean);
    procedure SetParentForm(const Value: TForm);
    procedure SetShadowOffset(const Value: Integer);
    procedure SetShadowColor(const Value: TColor);

    procedure ThisNCHitTest(var Message: TMessage); message WM_NCHITTEST;
    procedure ThisEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
    procedure FrmWindowPosChanged(var Message: TWMWindowPosChanged);
    procedure FrmWindowPosChanging(var Message: TWMWindowPosChanging);
  protected
    procedure CreateParams(var Params: TCreateParams); override;

    procedure HookedWndProc(var Message: TMessage); virtual;

    procedure ReadFormSurface;
    procedure GaussianBlur(Bmp: TBitmap; Amount: Integer);
    procedure RebuildBlend;
    procedure UpdateShadow;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ResetShadow;
    procedure AdjustBlendMasks(CalledFromInternal: Boolean = False);

    property Active: Boolean read FActive write SetActive;
    property ParentForm: TForm read FForm write SetParentForm;
    property ShadowOffset: Integer read FShadowOffset write SetShadowOffset;
    property ShadowColor: TColor read FShadowColor write SetShadowColor;

  end;

implementation

uses
  Dialogs;
{ TFormShadow }

constructor TFormShadow.Create(AOwner: TComponent);
begin
  inherited;
  FShadowOffset := 4;

  FNeedRebuildBlend := True;
  FBlendBmp := TBitmap.Create;
  FBlendBmp.PixelFormat := pf32Bit;
  FShadowColor := clBlack;

  FBlendFunc.BlendOp := AC_SRC_OVER;
  FBlendFunc.AlphaFormat := AC_SRC_ALPHA;

end;

destructor TFormShadow.Destroy;
begin
  SetParentForm(nil);
  FBlendBmp.Free;
  inherited;
end;

procedure TFormShadow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    WndParent := Application.Handle;
    WindowClass.style := CS_DBLCLKS or CS_OWNDC;
    Style := WS_POPUP or WS_SIZEBOX;
    ExStyle := WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE or WS_EX_LAYERED;
  end;
end;

procedure TFormShadow.SetParentForm(const Value: TForm);
begin
  if FForm <> Value then
  begin
    if Assigned(FForm) and Assigned(FSavedWndProc) then
    begin
      FForm.WindowProc := FSavedWndProc;
      FSavedWndProc := nil;
    end;
    FForm := Value;
    if Assigned(FForm) then
    begin
      FSavedWndProc := FForm.WindowProc;
      FForm.WindowProc := HookedWndProc;
      FFormTransColor := FForm.TransparentColorValue;
    end;
    FNeedRebuildBlend := True;
    UpdateShadow;
  end;
end;

procedure TFormShadow.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    UpdateShadow;
  end;
end;

procedure TFormShadow.SetShadowColor(const Value: TColor);
begin
  if FShadowColor <> Value then
  begin
    FShadowColor := Value;
    AdjustBlendMasks(False);
  end;
end;

procedure TFormShadow.SetShadowOffset(const Value: Integer);
begin
  if FShadowOffset <> Value then
  begin
    FShadowOffset := Value;
    UpdateShadow;
  end;
end;

procedure TFormShadow.HookedWndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_WINDOWPOSCHANGING:
      FrmWindowPosChanging(TWMWindowPosChanging(Message));
    WM_WINDOWPOSCHANGED:
      FrmWindowPosChanged(TWMWindowPosChanged(Message));
  else
    FSavedWndProc(Message);
  end;
end;

procedure TFormShadow.FrmWindowPosChanging(
  var Message: TWMWindowPosChanging);
begin
  FSavedWndProc(TMessage(Message));
  with Message.WindowPos^ do
  begin
    if (FForm.WindowState <> wsNormal) or (flags and SWP_HIDEWINDOW <> 0) then
      SetWindowPos(Handle, FForm.Handle, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);

  end;
end;

procedure TFormShadow.FrmWindowPosChanged(
  var Message: TWMWindowPosChanged);
const
  ShowingFlags: array [Boolean] of Cardinal = (
      SWP_NOZORDER or SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW,
      SWP_NOZORDER or SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
var
  l, t: Integer;
begin
  FSavedWndProc(TMessage(Message));
  with Message.WindowPos^ do
  begin
    if flags and SWP_NOMOVE = 0 then
    begin
      l := x; t := y;
    end
    else begin
      l := FForm.Left;
      t := FForm.Top;
    end;
    if FForm.WindowState <> wsMaximized then
      RebuildBlend;
    SetWindowPos(Handle, FForm.Handle,
        l - EXTSHADOWSIZE + FShadowOffset,
        t - EXTSHADOWSIZE + FShadowOffset,
        FBlendBmp.Width,
        FBlendBmp.Height,
        SWP_NOACTIVATE);
    SetWindowPos(Handle, 0, 0, 0, 0, 0, ShowingFlags[FActive and (FForm.WindowState = wsNormal)]);
  end;
end;

procedure TFormShadow.ThisEraseBkgnd(var Message: TMessage);
begin
  Message.Result := 1;
  inherited;
end;

procedure TFormShadow.ThisNCHitTest(var Message: TMessage);
begin
  Message.Result := HTTRANSPARENT;
end;

procedure TFormShadow.ResetShadow;
begin
  FNeedRebuildBlend := True;
  UpdateShadow;
end;

procedure TFormShadow.UpdateShadow;
begin
  if Assigned(FForm) and FForm.HandleAllocated then
    SetWindowPos(FForm.Handle, 0, 0, 0, 0, 0,
                    SWP_FRAMECHANGED or SWP_NOZORDER or SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE);
end;

procedure TFormShadow.RebuildBlend;
var
  BlackBr: HBRUSH;
  WhiteBr: HBRUSH;
  Rct: TRect;
  pwi: TWindowInfo;
begin
  if not FActive or not Assigned(FForm) or not FForm.HandleAllocated then Exit;
  if (FBlendBmp.Width <> FForm.Width + EXTSHADOWSIZE * 2)
      or (FBlendBmp.Height <> FForm.Height + EXTSHADOWSIZE * 2) then
  begin
    FNeedRebuildBlend := True;
    FBlendBmp.Width := FForm.Width + EXTSHADOWSIZE * 2;
    FBlendBmp.Height := FForm.Height + EXTSHADOWSIZE * 2;
  end
  else if FForm.TransparentColor and (FForm.TransparentColorValue <> FFormTransColor) then
  begin
    FNeedRebuildBlend := True;
  end;
  if FNeedRebuildBlend then
  begin
    FNeedRebuildBlend := False;
    BlackBr := CreateSolidBrush(0);
    WhiteBr := CreateSolidBrush($FFFFFF);

    FillRect(FBlendBmp.Canvas.Handle, Rect(0, 0, FBlendBmp.Width, FBlendBmp.Height), BlackBr);

    if FFormRgn = 0 then
      FFormRgn := CreateRectRgn(0, 0, 1, 1);
    if GetWindowRgn(FForm.Handle, FFormRgn) <> COMPLEXREGION then
    begin
      DeleteObject(FFormRgn);
      FFormRgn := 0;
    end;
    if (FFormRgn <> 0) then
    begin
      OffsetRgn(FFormRgn, EXTSHADOWSIZE, EXTSHADOWSIZE);
      SelectClipRgn(FBlendBmp.Canvas.Handle, FFormRgn);
      GetRgnBox(FFormRgn, Rct);
    end
    else begin
      GetWindowRect(FForm.Handle, Rct);
      OffsetRect(Rct, -Rct.Left, -Rct.Top);
      if FForm.BorderStyle <> bsNone then
      begin
        GetWindowInfo(FForm.Handle, pwi);
        InflateRect(Rct, pwi.cxWindowBorders div 3, pwi.cyWindowBorders div 3);
      end;
      OffsetRect(Rct, EXTSHADOWSIZE, EXTSHADOWSIZE);
    end;
    FillRect(FBlendBmp.Canvas.Handle, Rct, WhiteBr);

    ReadFormSurface;

    SelectClipRgn(FBlendBmp.Canvas.Handle, 0);
    DeleteObject(BlackBr);
    DeleteObject(WhiteBr);

    GaussianBlur(FBlendBmp, 3);

    AdjustBlendMasks(True);

  end;

end;

type
  TColor32 = record b, g, r, a: Byte; end;
  PColor32 = ^TColor32;

var
  BlendColorMap: array [0..255, 0..255] of Byte;

procedure TFormShadow.AdjustBlendMasks(CalledFromInternal: Boolean);
var
  x, y, Index: Integer;
  srcClr: TColor32;
  dstClr: PColor32;
  pt: TPoint;
  sz: TSize;
begin
  if FForm.AlphaBlend then
    FBlendFunc.SourceConstantAlpha := FForm.AlphaBlendValue
  else
    FBlendFunc.SourceConstantAlpha := 255;

  srcClr := TColor32(ColorToRGB(FShadowColor));
  for y := 0 to FBlendBmp.Height - 1 do
  begin
    dstClr := PColor32(FBlendBmp.ScanLine[y]);
    for x := 0 to FBlendBmp.Width - 1 do
    begin
      if CalledFromInternal then
        dstClr.a := dstClr.b;
      dstClr.b := BlendColorMap[srcClr.r, dstClr.a];
      dstClr.g := BlendColorMap[srcClr.g, dstClr.a];
      dstClr.r := BlendColorMap[srcClr.b, dstClr.a];
      Inc(dstClr);
    end;
  end;

  pt.X := 0;
  pt.Y := 0;
  sz.cx := FBlendBmp.Width;
  sz.cy := FBlendBmp.Height;
  HandleNeeded;
  UpdateLayeredWindow(Handle, 0, nil, @sz,
                              FBlendBmp.Canvas.Handle, @pt, 0, @FBlendFunc, ULW_ALPHA);
end;

procedure TFormShadow.GaussianBlur(Bmp: TBitmap; Amount: Integer);
var
  i: Integer;

  function TrimRow(n: Integer): Integer;
  begin
    if n < 0 then Result := 0 else if n >= Bmp.Height then Result := Bmp.Height - 1
    else Result := n;
  end;

  function TrimCol(n: Integer): Integer;
  begin
    if n < 0 then Result := 0 else if n >= Bmp.Width then Result := Bmp.Width - 1
    else Result := n;
  end;

  procedure SplitBlur(Amount: Integer);
  var
    x, y: Integer;
    tl, tr, bl, br: PColor32;
    line, line1, line2: PIntegerArray;
  begin
    for y := 0 to Bmp.Height - 1 do
    begin
      line := PIntegerArray(Bmp.ScanLine[y]);
      line1 := PIntegerArray(Bmp.ScanLine[TrimRow(y-Amount)]);
      line2 := PIntegerArray(Bmp.ScanLine[TrimRow(y+Amount)]);
      for x := 0 to Bmp.Width - 1 do
      begin
        tl := PColor32(@line1[TrimCol(x-Amount)]);
        tr := PColor32(@line1[TrimCol(x+Amount)]);
        bl := PColor32(@line2[TrimCol(x-Amount)]);
        br := PColor32(@line2[TrimCol(x+Amount)]);
        with PColor32(@line[x])^ do
        begin
          r := (tl.r + tr.r + bl.r + br.r) shr 2;
          g := (tl.g + tr.g + bl.g + br.g) shr 2;
          b := (tl.b + tr.b + bl.b + br.b) shr 2;
        end;
      end;

    end;
  end;

begin
  for i := 1 to Amount do
    SplitBlur(i);
end;

procedure TFormShadow.ReadFormSurface;
var
  tmpBmp: TBitmap;
  pt: TPoint;
  DC: HDC;
  Index: Integer;
begin
  pt := FForm.ClientToScreen(Point(0,0));
  if FForm.TransparentColor then
  begin
    FFormTransColor := FForm.TransparentColorValue;
    tmpBmp := TBitmap.Create;
    tmpBmp.Width := FForm.ClientWidth;
    tmpBmp.Height := FForm.ClientHeight;
    FForm.PaintTo(tmpBmp.Canvas, 0, 0);
    tmpBmp.Mask(FFormTransColor);
    SetBkColor(FBlendBmp.Canvas.Handle, 0);
    SetTextColor(FBlendBmp.Canvas.Handle, $FFFFFF);
    BitBlt(FBlendBmp.Canvas.Handle, pt.X + EXTSHADOWSIZE - FForm.Left,
              pt.Y + EXTSHADOWSIZE - FForm.Top, tmpBmp.Width, tmpBmp.Height,
              tmpBmp.Canvas.Handle, 0, 0, SRCCOPY);
    tmpBmp.Free;
  end;
end;

var
  Index1, Index2: Integer;

initialization
  for Index1 := 0 to 255 do
    for Index2 := 0 to 255 do
      BlendColorMap[Index1, Index2] := Index1 * Index2 div 255;

end.
