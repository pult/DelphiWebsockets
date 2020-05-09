unit uClientWebSocketDemo;

interface

{$DEFINE DelphiWebsockets}

{$DEFINE SuperObject}      // json-интерфейc "ISuperObject"
{-DEFINE JsonDataObjects}  // json-класс "TJsonObject"

uses
  Types, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Vcl.StdCtrls, Vcl.ExtCtrls

  {$IFDEF DelphiWebsockets} // https://github.com/andremussche/DelphiWebsockets
  ,amdws.IdHTTPWebsocketClient, amdws.IdIOHandlerWebsocket
  {$ENDIF DelphiWebsockets}

  {$IFDEF JsonDataObjects}
  ,JsonDataObjects  // json-класс "TJsonObject"
  {$ENDIF JsonDataObjects}
  {$IFDEF SuperObject}
  ,superobject      // json-интерфейc "ISuperObject"
  {$ENDIF SuperObject}
  ;

const
  CWS_URL  = 'ws://localhost:3000/echo';
  //CWS_URL  = 'ws://10.124.2.181:3000/echo'; // Тест доступа к серверу на другом ПК!

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    BSendRead: TButton;
    Memo1: TMemo;
    BClear: TButton;
    BSReadOnly: TButton;
    BClose: TButton;
    ESendData: TComboBox;
    Label1: TLabel;
    EServer: TComboBox;
    Label2: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure BSendReadClick(Sender: TObject);
    procedure BClearClick(Sender: TObject);
    procedure BCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    procedure log(const S: string);

  private
    {$IFDEF DelphiWebsockets}
    ws: TClientWebSocket;
    {$ENDIF DelphiWebsockets}
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.IOUtils, System.DateUtils;

procedure TForm1.FormCreate(Sender: TObject);
begin
  log('WebSockets:Create:');
  {$IFDEF DelphiWebsockets}

  //
  // Создаём клиентский WebSocket
  //
  begin
    G_DEBUG_WS := True; // Optional: Включаем отладочные сообщения для TClientWebSocket

    ws := TClientWebSocket.Create(Self);

    // Настраиваем задержки.
    // По документации 30-60 секунд в зависимости от операции.
    // Для отладки поставил малые.
    ws.ConnectTimeout := 2*1000;
    ws.WriteTimeout := 2*1000;
    ws.ReadTimeout := 7*1000;

    //ws.IOHandler.UseSingleWriteThread := True;          // optional!
    // or:
    TIdIOHandlerWebsocket.UseSingleWriteThread := True; // optional!
  end;
  {$ENDIF DelphiWebsockets}
  log('WebSockets:Create.');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  {$IFDEF DelphiWebsockets}
  FreeAndNil(ws);
  {$ENDIF DelphiWebsockets}
end;

procedure TForm1.BClearClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TForm1.log(const S: string);
// Логируем работу

  function DoSetScrollBarPos(AControl: TWinControl; Kind: TScrollBarKind;
    Position: Integer; bRedraw: Boolean = True): Boolean;
  const
    cSBCode: array[Boolean] of Integer = (WS_HSCROLL, WS_VSCROLL);
  var
    vSBCode: Integer;
  begin
    Result := (AControl <> nil) and (AControl.HandleAllocated);
    if not Result then
      Exit;
    vSBCode := cSBCode[Kind <> sbHorizontal];
    Result := (GetWindowLong(AControl.Handle, GWL_STYLE) and vSBCode) <> 0;
    if Result then
      SetScrollPos(AControl.Handle, vSBCode, Position, bRedraw);
  end;

begin
  //OutputDebugString(PChar('wsc:> '+S));
  Memo1.Lines.Add(S);
  DoSetScrollBarPos(Memo1, sbVertical, Memo1.Lines.Count, True);
end;

procedure TForm1.BCloseClick(Sender: TObject);
begin
  log('------------------------------------------------------------------------------------------------------------');
  {$IFDEF DelphiWebsockets}
  log('ws: Close:');
  begin
    ws.Disconnect;
  end;
  log('ws: Close.');
  {$ENDIF DelphiWebsockets}
end;

procedure TForm1.BSendReadClick(Sender: TObject);
var
  S: string;
  ws_received: string; // получаемые данные
  OK, ASended: Boolean;
  {$IFDEF JsonDataObjects}
  json, jo: TJsonObject; // json parser #1
  {$ENDIF JsonDataObjects}
  {$IFDEF SuperObject}
  so, sov: ISuperObject; // json parser #2
  {$ENDIF SuperObject}
begin
  log('------------------------------------------------------------------------------------------------------------');

  {$IFDEF JsonDataObjects}
  json := nil;
  {$ENDIF JsonDataObjects}
  ASended := False;
  try
    Screen.Cursor := crHourGlass;

    {$IFDEF DelphiWebsockets}

    if ws.SocketIOConnectBusy then
    begin
      log('ws: Busy!');
      Exit;
    end;

    //
    // connect:
    //
    if (not ws.Connected) then
    begin
      S := CWS_URL;
      S := EServer.Text;
      log('ws: Open: "'+S+'"');
      ws_received := '';
      OK := ws.TryOpen(S);
      if not OK then ws_received := 'ERROR: ' + ws.LastError;
      log('ws: Open. OK: '+BoolToStr(OK, true) + '; note: "'+ws_received+'"');
      if not OK then
        Exit;
    end;
    //}

    OK := False;
    ws_received := '';

    if Sender <> BSReadOnly then // если не кнопка "только читать (WS Read)"
    begin
      //
      // Отсылаем данные (команду):
      //

      S := Trim(ESendData.Text);

      if (Length(S) >= 2) and (Copy(S,1,2) = '//') then
      begin
        S := TrimLeft(Copy(S,3,Length(S)));
        if S <> '' then
          log('ws: skip commented command: "'+S+'"');
        Exit;
      end;

      //
      // ping:
      //
      if (S = '@ws.ping') then
      begin
        log('ws: Ping:');
        ws.Ping;
        log('ws: Ping.');
      end;
      //}

      //
      // send data (command):
      //
      if (S <> '@ws.ping') then
      begin
//(*
        //
        //# send sample #1 : json-команда пишется вручную (в строку)
        //
        //S := '{"method":"PingDevice","step":0}';
        //S := '{"method":"GetTerminalInfo","step":0}';
        log('ws: Send: data: "'+S+'":');
        OK := ws.TrySendData(S);
        ASended := OK;
        if not OK then ws_received := 'ERROR: ' + ws.LastError;
        log('ws: Send. OK: '+BoolToStr(OK, true) + '; note: "'+ws_received+'"');
        //#1 *)

(*
        //
        //# send sample #2 : json-команда создаётся с помощью json-класса "TJsonObject"
        //
        {$IFDEF JsonDataObjects}
        if not ASended then
        begin
          if json = nil then json := TJsonObject.Create;
          json.Clear;
          json.S['method'] := 'PingDevice';
          json.S['method'] := 'GetTerminalInfo';
          json.I['step'] := 0;
          S := json.ToJSON();
          log('ws: Send: data: "'+S+'":');
          OK := ws.TrySendData(S);
          ASended := OK;
          if not OK then ws_received := 'ERROR: ' + ws.LastError;
          log('ws: Send. OK: '+BoolToStr(OK, true) + '; note: "'+ws_received+'"');
          //-exit;
        end;
        {$ENDIF JsonDataObjects}
        //#2 *)

(*
        //
        //# send sample #2 : json-команда создаётся с помощью json-интерфейса "ISuperObject"
        //
       {$IFDEF SuperObject}
        if not ASended then
        begin
          so := SuperObject.so('{}');
          so.S['method'] := 'PingDevice';
          so.S['method'] := 'GetTerminalInfo';
          so.I['step'] := 0;
          S := so.AsString;
          log('ws: Send: data: "'+S+'":');
          OK := ws.TrySendData(S);
          ASended := OK;
          if not OK then ws_received := 'ERROR: ' + ws.LastError;
          log('ws: Send. OK: '+BoolToStr(OK, true) + '; note: "'+ws_received+'"');
          //-exit;
        end;
        {$ENDIF SuperObject}
        //#3 *)

      end // if (S <> '@ws.ping') then
      else
      begin
        OK := True;
      end;
    end
    else
    begin
      if (S <> '@ws.ping') then
      begin
        ASended := True; // Режим только приём/чтение
        OK := True;
      end;
    end;

    if ASended then
    begin
      log('ws: Receive:');
      //
      // Читаем/Получаем данные от сервера в течении ws.ReadTimeout милисекунд
      //

      OK := False;
      ws_received := '';

      if ws.SocketIOConnectBusy then
      begin
        log('ws: Busy!-#0');
      end;

      OK := ws.TryReceiveData(ws_received); // читаем в стоку
      if not OK then ws_received := 'ERROR: ' + ws.LastError;

      if OK then
      begin
        // Примеры оветов :
        (*

         для метода PingDevice:

           {"method":"PingDevice","step":0,"params":{"code":"00"},"error":false}
           {"method":"ServiceMessage","step":0,"params":{"msgType":"DeviceBusy"},"error":false}"    -   пример ответа когда устройство занято

         для метода GetTerminalInfo:

          "{"method":"GetTerminalInfo","step":0,"params":{"code":"00","version":"TE7E126 S1K20RJG00CT21629361"},"error":false}"

         На будущее - возможно так:
          {"method":"GetTerminalInfo","step":0,"params":{"code":"00","version":"TE7E126 S1K20RJG00CT21629361"},"error": {"message": "Ошибка связи с терминалом!","code": 404}}

         другое из доки:
           {"method":"Purchase","step":0,"params":{"amount":"0.60","approvalCode":"999999","captureReference":"","cardExpiryDate":"0000","cardHolderName":"99999999","date":"0112","discount":"0.00","hstFld63Sf89":"","invoiceNumber":"999999","issuerName":"ALEX","merchant":"TSTTTTTT","pan":"************9999","posConditionCode":"00","posEntryMode":"022","processingCode":"000000","receipt":"000054","responseCode":"0000","rrn":"9999999999999","terminalId":"TSTSALE2","time":"0941","track1":"","track2":""},"error":false}

        *)

        // demo/test: на будущее: пример разбора структурного "error": { ... }"
        //ws_received := '{"method":"GetTerminalInfo","step":0,"params":{"code":"00","version":"TE7E126 S1K20RJG00CT21629361"},"error": {"message": "Ошибка связи с терминалом!","code": 404}}';
        // demo/test: мусор
        //ws_received := ']}Мусор';

        log('  json: Parse: "'+ws_received+'"');

        //
        // Парсим json-ответ:
        //

(*
        //#1
        //
        //# parse sample #1 : парсим json с помощью json-класса "TJsonObject"
        //
       {$IFDEF JsonDataObjects}
        //--if json = nil then json := TJsonObject.Create;
        //-- try json.FromJSON(ws_received); except raise; end;// AV: В XE3 бывают AV-шки!
        // or :
        FreeAndNil(json);
        try
          json := TJsonObject.Parse(ws_received) as TJsonObject;
        except
          on e: Exception do
          begin
            ws_received := Format('ERROR: (E: %s): %s', [e.ClassName,e.Message]);
            log('  json:    '+ws_received);
          end;
        end;

        if json <> nil then
        begin
          S := json.S['method'];
          log('  json:   method: "'+S+'"');

          if S <> '' then
          begin
            if json.Contains('params') then
            begin
              jo := json.O['params'];
              if jo.Contains('code') then
                log('  json:   params.code: "'+jo.S['code']+'"');
              if json.S['method'] = 'GetTerminalInfo' then
              begin
                if jo.Contains('version') then
                  log('  json:   params.version: "'+jo.S['version']+'"');
              end;
            end;
          end;

          if json.Contains('error') then
          begin
            case json.Types['error'] of // jdtNone, jdtString, jdtInt, jdtLong, jdtULong, jdtFloat, jdtDateTime, jdtUtcDateTime, jdtBool, jdtArray, jdtObject
              jdtObject:
                begin
                  jo := json.O['error'];
                  if jo.Contains('code') then
                    log('  json:   error.code: "'+jo.S['code']+'"');
                  if jo.Contains('message') then
                    log('  json:   error.message: "'+jo.S['message']+'"');
                end;
              jdtArray:
                begin
                  log('  json:   error: "[!ARRAY!]"');
                end;
              else
                begin
                  S := json.S['error'];
                  log('  json:   error: "'+S+'"');
                end;
            end;
          end;
        end;
       {$ENDIF JsonDataObjects}
        // #1 *)

//(*
        //#2
        //
        //# parse sample #2 : парсим json с помощью json-интерфейса "ISuperObject"
        //
        {$IFDEF SuperObject}

        so := SuperObject.so(ws_received);
        if so <> nil then
        begin
          S := so.S['method'];
          log('  json:   method: "'+S+'"');

          S := so.S['params.code'];
          log('  json:   params.code: "'+S+'"');

          if so.S['method'] = 'GetTerminalInfo' then
          begin
            S := so.S['params.version'];
            log('  json:   params.version: "'+S+'"');
          end;

          sov := so.O['error'];
          if (sov <> nil) then
          begin
            case sov.DataType of
              stObject:
                begin
                  S := sov.S['code'];
                  log('  json:   error.code: "'+S+'"');
                  S := sov.S['message'];
                  log('  json:   error.message: "'+S+'"');
                end;
              stNull,
              stBoolean,
              stDouble,
              stCurrency,
              stInt,
              stString:
                begin
                  S := so.S['error'];
                  log('  json:   error: "'+S+'"');
                end;
              else
                begin
                  S := 'unsupported type';
                end;
            end;
          end;

        end;
        {$ENDIF SuperObject}
        // #2 *)

        log('  json: Parse.');

      end;

      log('ws: Receive. OK: '+BoolToStr(OK, true) + '; data: "'+ws_received+'"');
    end;

    if (not OK) then
    begin // optional:
      //
      // Если данные не получены, сможем принудительно закрыть соединение (чтобы повторно читать с нового листа). (Не обязательно!)
      //
      {$IFDEF DelphiWebsockets}
(*
      //--if TIdWebsocketWriteThread.Instance.Suspended then
      begin

        log('ws: Close: when received timeout or other!');
        ws.Disconnect;
        log('ws: Close.');
      end;
      //*)
      {$ENDIF DelphiWebsockets}
    end;

    Exit;
    {$ENDIF DelphiWebsockets}

  finally
    Screen.Cursor := crDefault;

    {$IFDEF JsonDataObjects}
    FreeAndNil(json);
    {$ENDIF JsonDataObjects}
  end;

//*)
end; // of: procedure TForm1.BSendReadClick

end.
