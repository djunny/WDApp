object MainForm: TMainForm
  Left = 276
  Top = 194
  AlphaBlend = True
  BorderStyle = bsNone
  Caption = 'Chromium Embedded'
  ClientHeight = 464
  ClientWidth = 699
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
  Position = poScreenCenter
  Visible = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 240
    Width = 698
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    Visible = False
    ExplicitTop = 429
    ExplicitWidth = 864
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 444
    Width = 698
    Height = 19
    Panels = <>
    SimplePanel = True
    Visible = False
  end
  object debug: TChromium
    Left = 0
    Top = 243
    Width = 698
    Height = 201
    Align = alBottom
    DefaultUrl = 'about:blank'
    TabOrder = 1
    Visible = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 698
    Height = 25
    Align = alTop
    Padding.Right = 1
    Padding.Bottom = 1
    TabOrder = 2
    Visible = False
    DesignSize = (
      698
      25)
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
    end
    object SpeedButton4: TSpeedButton
      Left = 72
      Top = 0
      Width = 23
      Height = 22
      Action = actReload
    end
    object SpeedButton5: TSpeedButton
      Left = 674
      Top = 0
      Width = 23
      Height = 22
      Action = actGoTo
      Anchors = [akTop, akRight]
      ExplicitLeft = 841
    end
    object edAddress: TEdit
      Left = 95
      Top = 0
      Width = 577
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'http://www.google.com'
      OnKeyPress = edAddressKeyPress
    end
  end
  object crm: TChromium
    Left = 0
    Top = 25
    Width = 698
    Height = 215
    Align = alClient
    DefaultUrl = 'about:blank'
    TabOrder = 3
    OnProcessMessageReceived = crmProcessMessageReceived
    OnLoadStart = crmLoadStart
    OnLoadEnd = crmLoadEnd
    OnRenderProcessTerminated = crmRenderProcessTerminated
    OnBeforeContextMenu = crmBeforeContextMenu
    OnPreKeyEvent = crmPreKeyEvent
    OnAddressChange = crmAddressChange
    OnTitleChange = crmTitleChange
    OnStatusMessage = crmStatusMessage
    OnBeforeDownload = crmBeforeDownload
    OnDownloadUpdated = crmDownloadUpdated
    OnBeforePopup = crmBeforePopup
    OnAfterCreated = crmAfterCreated
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
      Caption = 'H'
      OnExecute = actHomeExecute
      OnUpdate = actHomeUpdate
    end
    object actReload: TAction
      Caption = 'R'
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
    object actZoomIn: TAction
      Caption = 'Zoom in'
    end
    object actZoomOut: TAction
      Caption = 'Zoom out'
    end
    object actZoomReset: TAction
      Caption = 'Zoom reset'
    end
    object actExecuteJS: TAction
      Caption = 'Execute JavaScript'
      OnExecute = actExecuteJSExecute
    end
    object actDom: TAction
      Caption = 'Hook DOM'
      OnExecute = actDomExecute
    end
    object actDevTool: TAction
      Caption = 'Show DevTools'
      ShortCut = 123
      OnExecute = actDevToolExecute
    end
    object actDoc: TAction
      Caption = 'Documentation'
      OnExecute = actDocExecute
    end
    object actGroup: TAction
      Caption = 'Google group'
      OnExecute = actGroupExecute
    end
    object actFileScheme: TAction
      Caption = 'File Scheme'
    end
    object actChromeDevTool: TAction
      Caption = 'Debug in Chrome'
      OnExecute = actChromeDevToolExecute
    end
  end
  object MainMenu: TMainMenu
    Left = 624
    Top = 56
    object File1: TMenuItem
      Caption = '&File'
      object Print1: TMenuItem
        Caption = 'Print'
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
      object VisitDOM1: TMenuItem
        Action = actDom
      end
      object DevelopperTools1: TMenuItem
        Action = actDevTool
      end
      object DebuginChrome1: TMenuItem
        Action = actChromeDevTool
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object Documentation1: TMenuItem
        Action = actDoc
      end
      object Googlegroup1: TMenuItem
        Action = actGroup
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
