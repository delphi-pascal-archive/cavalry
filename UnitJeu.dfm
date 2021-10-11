object FormJeu: TFormJeu
  Left = 228
  Top = 130
  AlphaBlendValue = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Cavalry'
  ClientHeight = 578
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnKeyDown = IntercepterClavier
  OnShow = ShowForm
  PixelsPerInch = 120
  TextHeight = 16
  object pnlJeu: TPanel
    Left = 6
    Top = 6
    Width = 492
    Height = 492
    BevelOuter = bvLowered
    TabOrder = 5
    OnDragDrop = DeplacerPion
    OnDragOver = AutoriserDeplacementPion
    object imgPlateau: TImage
      Left = 0
      Top = 0
      Width = 492
      Height = 492
      Enabled = False
      Transparent = True
    end
    object imgPion1: TImage
      Left = 0
      Top = 0
      Width = 123
      Height = 123
      Cursor = crHandPoint
      DragCursor = crSizeAll
      DragMode = dmAutomatic
      Transparent = True
    end
    object imgPion2: TImage
      Left = 0
      Top = 246
      Width = 123
      Height = 123
      Cursor = crHandPoint
      DragCursor = crSizeAll
      DragMode = dmAutomatic
      Transparent = True
    end
    object imgPion3: TImage
      Left = 369
      Top = 123
      Width = 123
      Height = 123
      Cursor = crHandPoint
      DragCursor = crSizeAll
      DragMode = dmAutomatic
      Transparent = True
    end
    object imgPion4: TImage
      Left = 123
      Top = 246
      Width = 123
      Height = 123
      Cursor = crHandPoint
      DragCursor = crSizeAll
      DragMode = dmAutomatic
      Transparent = True
    end
  end
  object mmoTexte: TMemo
    Left = 74
    Top = 505
    Width = 357
    Height = 67
    TabStop = False
    Color = cl3DLight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlight
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 4
    OnKeyDown = IntercepterClavier
  end
  object btnAnnuler: TButton
    Left = 6
    Top = 505
    Width = 62
    Height = 30
    Caption = 'Clear'
    TabOrder = 0
    TabStop = False
    OnClick = AnnulerDeplacement
    OnKeyDown = IntercepterClavier
  end
  object btnInitialiser: TButton
    Left = 6
    Top = 542
    Width = 62
    Height = 30
    Caption = 'Back'
    TabOrder = 1
    TabStop = False
    OnClick = Reinitialiser
    OnKeyDown = IntercepterClavier
  end
  object btnResoudre: TButton
    Left = 437
    Top = 505
    Width = 61
    Height = 30
    Caption = 'Solution'
    TabOrder = 2
    TabStop = False
    OnClick = Resoudre
    OnKeyDown = IntercepterClavier
  end
  object btnAide: TButton
    Left = 437
    Top = 542
    Width = 61
    Height = 30
    Caption = 'About'
    TabOrder = 3
    TabStop = False
    OnClick = AfficherAide
    OnKeyDown = IntercepterClavier
  end
end
