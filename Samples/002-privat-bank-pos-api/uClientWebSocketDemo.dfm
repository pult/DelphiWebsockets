object Form1: TForm1
  Left = 0
  Top = 0
  ActiveControl = EServer
  Caption = 'Form1'
  ClientHeight = 505
  ClientWidth = 868
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    868
    505)
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 868
    Height = 109
    Align = alTop
    TabOrder = 0
    DesignSize = (
      868
      109)
    object Label1: TLabel
      Left = 32
      Top = 79
      Width = 54
      Height = 13
      Caption = 'Send Data:'
    end
    object Label2: TLabel
      Left = 32
      Top = 11
      Width = 39
      Height = 13
      Caption = 'Server :'
    end
    object BSendRead: TButton
      Left = 16
      Top = 39
      Width = 93
      Height = 25
      Caption = 'WS Send/Read'
      TabOrder = 1
      OnClick = BSendReadClick
    end
    object BClear: TButton
      Left = 353
      Top = 39
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 4
      OnClick = BClearClick
    end
    object BSReadOnly: TButton
      Left = 140
      Top = 39
      Width = 75
      Height = 25
      Caption = 'WS Read'
      TabOrder = 2
      OnClick = BSendReadClick
    end
    object BClose: TButton
      Left = 247
      Top = 39
      Width = 75
      Height = 25
      Caption = 'WS Close'
      TabOrder = 3
      OnClick = BCloseClick
    end
    object ESendData: TComboBox
      Left = 120
      Top = 76
      Width = 740
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      DropDownCount = 27
      ItemIndex = 2
      TabOrder = 5
      Items.Strings = (
        ''
        '{"method":"PingDevice","step":0}'
        '{"method":"GetTerminalInfo","step":0}'
        #1052#1091#1089#1086#1088#1080#1064#1082#1072
        '{"method":"xUnknownMethod","step":0}'
        '@ws.ping'
        '//'
        '// '#1047#1072#1087#1088#1086#1089' '#1085#1072' '#1086#1087#1083#1072#1090#1091
        
          '// {"method":"Purchase","step":0,"params":{"amount":"0.60","disc' +
          'ount":"","merchantId":"0"}}'
        '//'
        '// '#1054#1087#1077#1088#1072#1094#1080#1103' '#171#1042#1086#1079#1074#1088#1072#1090#187
        
          '// {"method":"Refund","step":0,"params":{"amount":"0.30","discou' +
          'nt":"","merchantId":"0","rrn":"014721258513"}}'
        '//'
        
          '// '#1054#1087#1077#1088#1072#1094#1080#1103' '#171#1054#1090#1084#1077#1085#1072#187' '#1090#1088#1072#1085#1079#1072#1082#1094#1080#1080' '#1074' '#1088#1072#1084#1082#1072#1093' '#1090#1077#1082#1091#1097#1077#1075#1086' '#1087#1072#1082#1077#1090#1072' '#1090#1088#1072#1085#1079#1072#1082 +
          #1094#1080#1081' ('#1086#1087#1077#1088#1072#1094#1080#1086#1085#1085#1086#1075#1086' '#1076#1085#1103'). '
        '// {"method":"Withdrawal","step":0,"params":{"check":"131220"}}'
        '//'
        '// '#1087#1086#1083#1091#1095#1077#1085#1080#1103' '#1089#1090#1072#1090#1080#1089#1090#1080#1082#1080' '#1086#1090' '#1090#1077#1088#1084#1080#1085#1072#1083#1072' '#1089' '#1086#1078#1080#1076#1072#1085#1080#1077#1084' '#1074#1074#1074#1086#1076#1072' '#1082#1072#1088#1090#1099
        '{"method":"Infocall", "step":0}'
        '//'
        '// '#1087#1086#1083#1091#1095#1077#1085#1080#1103' '#1089#1090#1072#1090#1080#1089#1090#1080#1082#1080' '#1086#1090' '#1090#1077#1088#1084#1080#1085#1072#1083#1072' '#1073#1077#1079' '#1074#1074#1074#1086#1076#1072' '#1082#1072#1088#1090#1099
        '{"method":"InfocallWithoutCard","step":0}'
        '//'
        '// '#1054#1087#1077#1088#1072#1094#1080#1103' '#171#1055#1088#1086#1074#1077#1088#1082#1072' '#1089#1074#1103#1079#1080#187
        '{"method":"CheckConnection","step": 0}'
        '//'
        '// '#1054#1087#1077#1088#1072#1094#1080#1103' '#171#1063#1090#1077#1085#1080#1077' '#1073#1072#1085#1082#1086#1074#1089#1082#1086#1081' '#1082#1072#1088#1090#1099#187
        '{"method": "ReadCardBank","step": 0}'
        '//'
        '// '#1054#1087#1077#1088#1072#1094#1080#1103' '#171#1063#1090#1077#1085#1080#1077' '#1076#1080#1089#1082#1086#1085#1090#1085#1086#1081' '#1082#1072#1088#1090#1099#187
        '{"method": "ReadCardDiscount","step": 0}'
        '//'
        '// '#1054#1087#1077#1088#1072#1094#1080#1103' '#171#1042#1077#1088#1089#1080#1103' '#1055#1054#187
        '{"method": "GetTerminalInfo","step": 0}'
        '//'
        '// '#1054#1087#1077#1088#1072#1094#1080#1103' '#171#1041#1072#1083#1072#1085#1089#187
        '{"method":"GetBalance","step":0}'
        '//'
        '// 3.13.'#9#1054#1087#1077#1088#1072#1094#1080#1103' '#171#1057#1077#1088#1074#1080#1089' '#1074#1086#1079#1074#1088#1072#1090#187
        
          '{"method":"ServiceRefund","step":0,"params":{"amount":"0.30","me' +
          'rchantId":"5","rrn":"014721258513"}}'
        '//'
        
          '// # INTERUPT '#1090#1088#1077#1073#1086#1074#1072#1085#1080#1077' '#1087#1088#1077#1088#1099#1074#1072#1085#1080#1103' '#1080#1085#1080#1094#1080#1080#1088#1086#1074#1072#1085#1085#1086#1081' '#1086#1087#1077#1088#1072#1094#1080#1080' '#1076#1083#1103' ' +
          'Balance, Purchase, Refund, ServiceRefund, ServicePbP'
        
          '{"method":"ServiceMessage","step":0,"params":{"msgType":"interru' +
          'pt"}}'
        '//'
        
          '// '#1079#1072#1087#1088#1086#1089' '#1082#1083#1080#1077#1085#1090#1086#1084' '#1091' '#1089#1077#1088#1074#1077#1088#1072' terminal software version + termina' +
          'l profile ID + POS S/N + the list of acquirers'
        
          '{"method":"ServiceMessage", "step":0, "params":{ "msgType":"getM' +
          'erchantList"}'
        '//'
        
          '// '#1079#1072#1087#1088#1086#1089' '#1082#1083#1080#1077#1085#1090#1086#1084' '#1091' '#1089#1077#1088#1074#1077#1088#1072' terminal software version + termina' +
          'l profile ID + POS S/N + the list of merchants'
        
          '{"method":"ServiceMessage", "step":0, "params":{ "msgType":" get' +
          'MasktList"}'
        '//'
        
          '// debug '#8211' '#1080#1089#1087#1086#1083#1100#1079#1091#1077#1090#1089#1103' '#1076#1083#1103' '#1086#1090#1082#1083#1102#1095#1077#1085#1080#1103'/'#1074#1082#1083#1102#1095#1077#1085#1080#1103' '#1092#1091#1085#1082#1094#1080#1080' '#1085#1077#1087#1086#1089#1088#1077 +
          #1076#1089#1090#1074#1077#1085#1085#1086#1075#1086' '#1089#1085#1103#1090#1080#1103' '#1083#1086#1075#1086#1074' '#1087#1086#1088#1090#1086#1074' COM, USB, ETH'
        
          '{"method":"ServiceMessage", "step":0, "params":{ "msgType":"debu' +
          'g"}'
        '')
    end
    object EServer: TComboBox
      Left = 120
      Top = 8
      Width = 308
      Height = 21
      ItemIndex = 0
      TabOrder = 0
      Items.Strings = (
        'ws://localhost:3000/echo'
        'ws://wskiecco0582.mc.gcf:3000/echo'
        'ws://10.124.2.181:3000/echo')
    end
  end
  object Memo1: TMemo
    Left = 8
    Top = 115
    Width = 852
    Height = 382
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 1
    WantReturns = False
  end
end
