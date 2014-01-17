object MainForm: TMainForm
  Left = 276
  Top = 194
  BorderStyle = bsNone
  Caption = 'Chromium Embedded'
  ClientHeight = 497
  ClientWidth = 746
  Color = clBtnFace
  TransparentColor = True
  TransparentColorValue = clFuchsia
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Padding.Right = 1
  Padding.Bottom = 1
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 477
    Width = 745
    Height = 19
    Panels = <>
    SimplePanel = True
    Visible = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 745
    Height = 22
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 1
    Visible = False
    DesignSize = (
      745
      22)
    object SpeedButton1: TSpeedButton
      Left = 0
      Top = 0
      Width = 23
      Height = 22
      Action = actPrev
    end
    object SpeedButton2: TSpeedButton
      Left = 24
      Top = 0
      Width = 23
      Height = 22
      Action = actNext
    end
    object SpeedButton3: TSpeedButton
      Left = 48
      Top = 0
      Width = 23
      Height = 22
      Action = actHome
      Caption = 'H'
    end
    object SpeedButton4: TSpeedButton
      Left = 72
      Top = 0
      Width = 23
      Height = 22
      Action = actReload
      Caption = 'R'
    end
    object SpeedButton5: TSpeedButton
      Left = 722
      Top = 0
      Width = 23
      Height = 22
      Action = actGoTo
      Anchors = [akTop, akRight]
      ExplicitLeft = 707
    end
    object edAddress: TEdit
      Left = 95
      Top = 0
      Width = 625
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'http://www.google.com'
      OnKeyPress = edAddressKeyPress
    end
  end
  object ActionList: TActionList
    Left = 624
    Top = 112
    object actPrev: TAction
      Caption = '<-'
      Enabled = False
      OnExecute = actPrevExecute
      OnUpdate = actPrevUpdate
    end
    object actNext: TAction
      Caption = '->'
      Enabled = False
      OnExecute = actNextExecute
      OnUpdate = actNextUpdate
    end
    object actHome: TAction
      Caption = 'actHome'
      OnExecute = actHomeExecute
      OnUpdate = actHomeUpdate
    end
    object actReload: TAction
      Caption = 'actReload'
      OnExecute = actReloadExecute
      OnUpdate = actReloadUpdate
    end
    object actGoTo: TAction
      Caption = '>'
      OnExecute = actGoToExecute
    end
    object actGetSource: TAction
      Caption = 'Get source'
      OnExecute = actGetSourceExecute
    end
    object actGetText: TAction
      Caption = 'Get text'
      OnExecute = actGetTextExecute
    end
    object actShowDevTools: TAction
      Caption = 'Show developper tools'
      OnExecute = actShowDevToolsExecute
    end
    object actCloseDevTools: TAction
      Caption = 'Close developper tools'
      OnExecute = actCloseDevToolsExecute
    end
    object actZoomIn: TAction
      Caption = 'Zoom in'
      OnExecute = actZoomInExecute
    end
    object actZoomOut: TAction
      Caption = 'Zoom out'
      OnExecute = actZoomOutExecute
    end
    object actZoomReset: TAction
      Caption = 'Zoom reset'
      OnExecute = actZoomResetExecute
    end
    object actExecuteJS: TAction
      Caption = 'Execute JavaScript'
      OnExecute = actExecuteJSExecute
    end
    object actPrint: TAction
      Caption = 'Print'
      OnExecute = actPrintExecute
    end
    object actFileScheme: TAction
      Caption = 'File scheme'
      OnExecute = actFileSchemeExecute
    end
    object actDom: TAction
      Caption = 'Hook DOM'
      OnExecute = actDomExecute
    end
  end
  object MainMenu: TMainMenu
    Left = 624
    Top = 56
    object File1: TMenuItem
      Caption = '&File'
      object Print1: TMenuItem
        Action = actPrint
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        ShortCut = 16465
        OnClick = Exit1Click
      end
    end
    object est1: TMenuItem
      Caption = '&Test'
      object mGetsource: TMenuItem
        Action = actGetSource
      end
      object mGetText: TMenuItem
        Action = actGetText
      end
      object ExecuteJavaScript1: TMenuItem
        Action = actExecuteJS
      end
      object Zoomin1: TMenuItem
        Action = actZoomIn
      end
      object Zoomout1: TMenuItem
        Action = actZoomOut
      end
      object Zoomreset1: TMenuItem
        Action = actZoomReset
      end
      object Showdevtools1: TMenuItem
        Action = actShowDevTools
      end
      object Closedeveloppertools1: TMenuItem
        Action = actCloseDevTools
      end
      object actFileScheme1: TMenuItem
        Action = actFileScheme
      end
      object VisitDOM1: TMenuItem
        Action = actDom
      end
    end
  end
  object SaveDialog: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 624
    Top = 176
  end
  object AppEvent: TApplicationEvents
    OnMessage = AppEventMessage
    OnShortCut = AppEventShortCut
    Left = 624
    Top = 248
  end
end
