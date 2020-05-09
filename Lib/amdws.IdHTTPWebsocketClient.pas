unit amdws.IdHTTPWebsocketClient;
// AndreMussche: DelphiWebsockets
// fork from: https://github.com/andremussche/DelphiWebsockets

interface
{$I amdws.wsdefines.inc}

uses
  Types, SysUtils, Classes, Generics.Collections, SyncObjs
  // indy:
  ,IdGlobal, IdIOHandler, IdSocketHandle, IdIOHandlerSocket, IdWinsock2
  ,IdHTTP, {XE3 etc:}IdHashSHA
  // andremussche:
  ,amdws.IdIOHandlerWebsocket, amdws.IdSocketIOHandling
;

type
  TWebsocketMsgBin = procedure(const aData: TStream) of object;

  TWebsocketMsgText = procedure(const aData: string) of object;

  TIdHTTPWebsocketClient = class;

  TSocketIOMsg = procedure(const AClient: TIdHTTPWebsocketClient; const aText: string; aMsgNr: Integer) of object;

  TIdSocketIOHandling_Ext = class(TIdSocketIOHandling)
  end;

  TIdHTTPWebsocketClient = class(TIdHTTP)
  private
    FWSResourceName: string;
    FHash: TIdHashSHA1;
    FOnData: TWebsocketMsgBin;
    FOnTextData: TWebsocketMsgText;
    FNoAsyncRead: Boolean;
    FWriteTimeout: Integer;
    {+}
    FProtocol: string;
    FLastError: string;
    {+.}
    function GetIOHandlerWS: TIdIOHandlerWebsocket;
    procedure SetIOHandlerWS(const Value: TIdIOHandlerWebsocket);
    procedure SetOnData(const Value: TWebsocketMsgBin);
    procedure SetOnTextData(const Value: TWebsocketMsgText);
    procedure SetWriteTimeout(const Value: Integer);
    {+}
    procedure SetProtocol(const Value: string);
    {+.}
  protected
    FSocketIOCompatible: Boolean;
    FSocketIOHandshakeResponse: string;
    FSocketIO: TIdSocketIOHandling_Ext;
    FSocketIOContext: ISocketIOContext;
    FSocketIOConnectBusy: Boolean;

    //FHeartBeat: TTimer;
    //procedure HeartBeatTimer(Sender: TObject);
    function GetSocketIO: TIdSocketIOHandling;
  protected
    procedure InternalUpgradeToWebsocket(aRaiseException: Boolean; out aFailedReason: string); virtual;
    function MakeImplicitClientHandler: TIdIOHandler; override;
  public
    procedure AsyncDispatchEvent(const aEvent: TStream); overload; virtual;
    procedure AsyncDispatchEvent(const aEvent: string); overload; virtual;
    procedure ResetChannel;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    function TryUpgradeToWebsocket: Boolean;
    procedure UpgradeToWebsocket;
    function TryLock: Boolean;
    procedure Lock;
    procedure UnLock;
    procedure Connect; override;
    procedure ConnectAsync; virtual;
    function TryConnect: Boolean;
    procedure Disconnect(ANotifyPeer: Boolean); override;
    function CheckConnection: Boolean;
    procedure Ping; {+}virtual;{+.}
    {+}
    function ReadAndProcessData: Boolean;
    {+.}
    property IOHandler: TIdIOHandlerWebsocket read GetIOHandlerWS write SetIOHandlerWS;

    //websockets
    property OnBinData: TWebsocketMsgBin read FOnData write SetOnData;
    property OnTextData: TWebsocketMsgText read FOnTextData write SetOnTextData;
    property NoAsyncRead: Boolean read FNoAsyncRead write FNoAsyncRead;

    //https://github.com/LearnBoost/socket.io-spec
    property SocketIOCompatible: Boolean read FSocketIOCompatible write FSocketIOCompatible;
    property SocketIO: TIdSocketIOHandling read GetSocketIO;

    {+}
    property SocketIOConnectBusy: Boolean read FSocketIOConnectBusy;
    property LastError: string read FLastError;
    {+.}
  published
    property Host;
    property Port;
    property WSResourceName: string read FWSResourceName write FWSResourceName;
    property WriteTimeout: Integer read FWriteTimeout write SetWriteTimeout default 2000;
    {+}
    property Protocol: string read FProtocol write SetProtocol; // 'ws' or 'http' or 'https'. Default: 'http' when (not SocketIOCompatible) else 'https'
    {+.}
  end;

  {+}
  TClientWebSocket = class(TIdHTTPWebsocketClient)
  private
    FReceivedDataStr: string;
    FReceivedDataStm: TStream;

    procedure Received_OnTextData(const aData: string);
    procedure Received_OnBinData(const aData: TStream);

  protected
    function DoOpen(ARaise: Boolean; const AURL: string): Boolean;
    function DoReceiveData(ARaise: Boolean; var aData: string): Boolean; overload;
    function DoReceiveData(ARaise: Boolean; aData: TStream): Boolean; overload;
    function DoSendData(ARaise: Boolean; const AData: string; AEncoding: IIdTextEncoding = nil): Boolean; overload;
    function DoSendData(ARaise: Boolean; AData: TStream; ADataType: TWSDataType = wdtBinary): Boolean; overload;

  public
    procedure AfterConstruction; override;
    destructor Destroy; override;

    procedure Open(const AURL: string);
    function TryOpen(const AURL: string): Boolean;

    procedure Ping; override;

    procedure ReceiveData(var aData: string); overload;
    procedure ReceiveData(aData: TStream); overload;

    function TryReceiveData(var aData: string): Boolean; overload;
    function TryReceiveData(aData: TStream): Boolean; overload;

    procedure SendData(const AData: string; AEncoding: IIdTextEncoding = nil); overload;
    procedure SendData(AData: TStream; ADataType: TWSDataType = wdtBinary); overload;

    function TrySendData(const AData: string; AEncoding: IIdTextEncoding = nil): Boolean; overload;
    function TrySendData(AData: TStream; ADataType: TWSDataType = wdtBinary): Boolean; overload;

  published
    property WriteTimeout default 30 * 1000;
    property ReadTimeout default 30 * 1000;
    property ConnectTimeout default 7 * 1000;
  end;
  {+.}

//  on error
  (*
  TIdHTTPSocketIOClient_old = class(TIdHTTPWebsocketClient)
  private
    FOnConnected: TNotifyEvent;
    FOnDisConnected: TNotifyEvent;
    FOnSocketIOMsg: TSocketIOMsg;
    FOnSocketIOEvent: TSocketIOMsg;
    FOnSocketIOJson: TSocketIOMsg;
  protected
    FHeartBeat: TTimer;
    procedure HeartBeatTimer(Sender: TObject);

    procedure InternalUpgradeToWebsocket(aRaiseException: Boolean; out aFailedReason: string);override;
  public
    procedure AsyncDispatchEvent(const aEvent: string); override;
  public
    procedure  AfterConstruction; override;
    destructor Destroy; override;

    procedure AutoConnect;

    property  SocketIOHandshakeResponse: string read FSocketIOHandshakeResponse;
    property  OnConnected: TNotifyEvent read FOnConnected write FOnConnected;
    property  OnDisConnected: TNotifyEvent read FOnDisConnected write FOnDisConnected;

//    procedure ProcessSocketIORequest(const strmRequest: TStream);
    property  OnSocketIOMsg  : TSocketIOMsg read FOnSocketIOMsg write FOnSocketIOMsg;
    property  OnSocketIOJson : TSocketIOMsg read FOnSocketIOJson write FOnSocketIOJson;
    property  OnSocketIOEvent: TSocketIOMsg read FOnSocketIOEvent write FOnSocketIOEvent;
  end;
  *)

  TWSThreadList = class(TThreadList)
  public
    function Count: Integer;
  end;

  TIdWebsocketMultiReadThread = class(TThread)
  private
    class var
      FInstance: TIdWebsocketMultiReadThread;
  protected
    FReadTimeout: Integer;
    FTempHandle: THandle;
    FPendingBreak: Boolean;
    Freadset, Fexceptionset: TFDSet;
    Finterval: TTimeVal;
    procedure InitSpecialEventSocket;
    procedure ResetSpecialEventSocket;
    procedure BreakSelectWait;
  protected
    FChannels: TThreadList;
    FReconnectlist: TWSThreadList;
    FReconnectThread: TIdWebsocketQueueThread;
    procedure ReadFromAllChannels;
    procedure PingAllChannels;
    procedure Execute; override;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    procedure Terminate;
    procedure AddClient(aChannel: TIdHTTPWebsocketClient);
    procedure RemoveClient(aChannel: TIdHTTPWebsocketClient);
    property ReadTimeout: Integer read FReadTimeout write FReadTimeout default 5000;
    class function Instance: TIdWebsocketMultiReadThread;
    class procedure RemoveInstance(aForced: boolean = false);
  end;

  //async process data
  TIdWebsocketDispatchThread = class(TIdWebsocketQueueThread)
  private
    class var
      FInstance: TIdWebsocketDispatchThread;
  public
    class function Instance: TIdWebsocketDispatchThread;
    class procedure RemoveInstance(aForced: boolean = false);
  end;

{+}
procedure ParseURI(const AURI: string; var VProtocol, VHost, VPath, VDocument, VPort, VBookmark : string);
{+.}

implementation

uses
  Windows, StrUtils, Math, DateUtils
  // indy:
  ,IdCoderMIME, IdException, IdStackConsts, IdStack, IdStackBSDBase, IdURI
;

var
  GUnitFinalized: Boolean = false;

{+}
procedure ParseURI(const AURI: string; var VProtocol, VHost, VPath, VDocument, VPort, VBookmark : string);
var
  URI: {IdURI.pas}TIdURI;
begin
  URI := TIdURI.Create(AURI);
  try
    VProtocol := Trim(URI.Protocol);
    VHost := Trim(URI.Host);
    VPath := URI.Path;
    VDocument := URI.Document;
    VPort := Trim(URI.Port);
    VBookmark := URI.Bookmark;
  finally
    URI.Free;
  end;
  //if VPort = '' then
  //begin
  //  if SameText(VProtocol, 'HTTPS') then
  //    VPort := '443'; // IdPORT_SSL
  //end;
end;
{+.}

{+}
type
  TIdIOHandlerAccess = class({IdIOHandler.pas}TIdIOHandler);
  TIdSocketHandleAccess = class({IdSocketHandle.pas}TIdSocketHandle);
{+.}

//type
//  TAnonymousThread = class(TThread)
//  protected
//    FThreadProc: TThreadProcedure;
//    procedure Execute; override;
//  public
//    constructor Create(AThreadProc: TThreadProcedure);
//  end;

//procedure CreateAnonymousThread(AThreadProc: TThreadProcedure);
//begin
//  TAnonymousThread.Create(AThreadProc);
//end;

{ TAnonymousThread }

//constructor TAnonymousThread.Create(AThreadProc: TThreadProcedure);
//begin
//  FThreadProc := AThreadProc;
//  FreeOnTerminate := True;
//  inherited Create(False {direct start});
//end;
//
//procedure TAnonymousThread.Execute;
//begin
//  if Assigned(FThreadProc) then
//  try
//    FThreadProc();
//  except
//  end;
//end;

{ TIdHTTPWebsocketClient }

procedure TIdHTTPWebsocketClient.AfterConstruction;
begin
  inherited;
  FHash := TIdHashSHA1.Create;

  IOHandler := TIdIOHandlerWebsocket.Create(nil);
  IOHandler.UseNagle := False;
  ManagedIOHandler := True;

  FSocketIO := TIdSocketIOHandling_Ext.Create;
//  FHeartBeat := TTimer.Create(nil);
//  FHeartBeat.Enabled := False;
//  FHeartBeat.OnTimer := HeartBeatTimer;

  FWriteTimeout := 2 * 1000;
  ConnectTimeout := 2000;
end;

procedure TIdHTTPWebsocketClient.AsyncDispatchEvent(const aEvent: TStream);
var
  strmevent: TMemoryStream;
begin
  if not Assigned(OnBinData) then
    Exit;

  strmevent := TMemoryStream.Create;
  try
    strmevent.CopyFrom(aEvent, aEvent.Size);

    {+}
    if NoAsyncRead then
    begin
      if Assigned(OnBinData) then
        OnBinData(strmevent);
      FreeAndNil(strmevent);
      Exit;
    end;
    {+.}

    //events during dispatch? channel is busy so offload event dispatching to different thread!
    TIdWebsocketDispatchThread.Instance.QueueEvent(
      procedure
      begin
        if Assigned(OnBinData) then
          OnBinData(strmevent);
        FreeAndNil(strmevent);
      end);
  finally
    strmevent.Free;
  end;
end;

procedure TIdHTTPWebsocketClient.AsyncDispatchEvent(const aEvent: string);
begin
  if G_DEBUG_WS then
  begin
    dbg_ws('AsyncDispatchEvent: ' + aEvent);
  end;

  //if not Assigned(OnTextData) then Exit;

  {+}
  if NoAsyncRead then
  begin
    if FSocketIOCompatible then
      FSocketIO.ProcessSocketIORequest(FSocketIOContext as TSocketIOContext, aEvent)
    else if Assigned(OnTextData) then
      OnTextData(aEvent);
    Exit;
  end;
  {+.}

  //events during dispatch? channel is busy so offload event dispatching to different thread!
  TIdWebsocketDispatchThread.Instance.QueueEvent(
    procedure
    begin
      if FSocketIOCompatible then
        FSocketIO.ProcessSocketIORequest(FSocketIOContext as TSocketIOContext, aEvent)
      else if Assigned(OnTextData) then
        OnTextData(aEvent);
    end);
end;

function TIdHTTPWebsocketClient.CheckConnection: Boolean;
begin
  Result := False;
  try
    if (IOHandler <> nil) and not IOHandler.ClosedGracefully and IOHandler.Connected then
    begin
      IOHandler.CheckForDisconnect(True{error}, True{ignore buffer, check real connection});
      Result := True;  //ok if we reach here
    end;
  except
    on E: Exception do
    begin
      //clear inputbuffer, otherwise it stays connected :(
//      if (IOHandler <> nil) then
//        IOHandler.Clear;
      Disconnect(False);
      if Assigned(OnDisConnected) then
        OnDisConnected(Self);
    end;
  end;
end;

procedure TIdHTTPWebsocketClient.Connect;
begin
  Lock;
  try
    if Connected then
    begin
      TryUpgradeToWebsocket;
      Exit;
    end;

    //FHeartBeat.Enabled := True;
    if SocketIOCompatible and not FSocketIOConnectBusy then
    begin
      //FSocketIOConnectBusy := True;
      //try
      TryUpgradeToWebsocket;     //socket.io connects using HTTP, so no seperate .Connect needed (only gives Connection closed gracefully exceptions because of new http command)
      //finally
      //  FSocketIOConnectBusy := False;
      //end;
    end
    else
    begin
      //clear inputbuffer, otherwise it can't connect :(
      if (IOHandler <> nil) then
        IOHandler.Clear;
      inherited Connect;
    end;
  finally
    UnLock;
  end;
end;

procedure TIdHTTPWebsocketClient.ConnectAsync;
begin
  TIdWebsocketMultiReadThread.Instance.AddClient(Self);
end;

destructor TIdHTTPWebsocketClient.Destroy;
//var tmr: TObject;
begin
//  tmr := FHeartBeat;
//  FHeartBeat := nil;
//  TThread.Queue(nil,    //otherwise free in other thread than created
//    procedure
//    begin
      //FHeartBeat.Free;
//      FreeAndNil(tmr);
//    end);

  {+}
  // quick close:
  //if (IOHandler <> nil) and (IOHandler.Binding <> nil) then
  //  TIdSocketHandleAccess(IOHandler.Binding).Disconnect;
  if (IOHandler <> nil) then
    IOHandler.IsWebsocket := False;
  // quick close.
  {+.}

  TIdWebsocketMultiReadThread.Instance.RemoveClient(Self);
  FreeAndNil(FSocketIO);
  FreeAndNil(FHash);
  inherited;
end;

procedure TIdHTTPWebsocketClient.DisConnect(ANotifyPeer: Boolean);
begin
  if not SocketIOCompatible and ((IOHandler <> nil) and not IOHandler.IsWebsocket) then
    TIdWebsocketMultiReadThread.Instance.RemoveClient(Self);

  if ANotifyPeer and SocketIOCompatible then
    FSocketIO.WriteDisConnect(FSocketIOContext as TSocketIOContext)
  else
    FSocketIO.FreeConnection(FSocketIOContext as TSocketIOContext);

//  IInterface(FSocketIOContext)._Release;
  FSocketIOContext := nil;

  Lock;
  try
    if IOHandler <> nil then
    begin
      IOHandler.Lock;
      try
        IOHandler.IsWebsocket := False;

        inherited DisConnect(ANotifyPeer);
        //clear buffer, other still "connected"
        IOHandler.Clear;

        //FreeAndNil(IOHandler);
        //IOHandler := TIdIOHandlerWebsocket.Create(nil);
      finally
        IOHandler.Unlock;
      end;
    end;
  finally
    UnLock;
  end;
end;

function TIdHTTPWebsocketClient.GetIOHandlerWS: TIdIOHandlerWebsocket;
begin
//  if inherited IOHandler is TIdIOHandlerWebsocket then
  Result := inherited IOHandler as TIdIOHandlerWebsocket
//  else
//    Assert(False);
end;

function TIdHTTPWebsocketClient.GetSocketIO: TIdSocketIOHandling;
begin
  Result := FSocketIO;
end;

(*
procedure TIdHTTPWebsocketClient.HeartBeatTimer(Sender: TObject);
begin
  FHeartBeat.Enabled := False;
  FSocketIO.Lock;
  try
    try
      if (IOHandler <> nil) and
         not IOHandler.ClosedGracefully and
         IOHandler.Connected and
         (FSocketIOContext <> nil) then
      begin
        FSocketIO.WritePing(FSocketIOContext as TSocketIOContext);  //heartbeat socket.io message
      end
      //retry re-connect
      else
      try
        //clear inputbuffer, otherwise it can't connect :(
        if (IOHandler <> nil) then
          IOHandler.Clear;

        Self.ConnectTimeout := 100;  //100ms otherwise GUI hangs too much -> todo: do it in background thread!
        if not Connected then
          Self.Connect;
        TryUpgradeToWebsocket;
      except
        //skip, just retried
      end;
    except on E:Exception do
      begin
        //clear inputbuffer, otherwise it stays connected :(
        if (IOHandler <> nil) then
          IOHandler.Clear;
        Disconnect(False);

        if Assigned(OnDisConnected) then
          OnDisConnected(Self);
        try
          raise EIdException.Create('Connection lost from ' +
                                    Format('ws://%s:%d/%s', [Host, Port, WSResourceName]) +
                                    ' - Error: ' + e.Message);
        except
          //eat, no error popup!
        end;
      end;
    end;
  finally
    FSocketIO.UnLock;
    FHeartBeat.Enabled := True;  //always enable: in case of disconnect it will re-connect
  end;
end;
*)

function TIdHTTPWebsocketClient.TryConnect: Boolean;
begin
  Lock;
  try
    try
      if Connected then
        Exit(True);

      Connect;
      Result := Connected;
      //if Result then
      //  Result := TryUpgradeToWebsocket     already done in connect
    except
      Result := False;
    end
  finally
    UnLock;
  end;
end;

function TIdHTTPWebsocketClient.TryLock: Boolean;
begin
  Result := System.TMonitor.TryEnter(Self);
end;

function TIdHTTPWebsocketClient.TryUpgradeToWebsocket: Boolean;
var
  sError: string;
begin
  try
    FSocketIOConnectBusy := True;
    Lock;
    try
      if (IOHandler <> nil) and IOHandler.IsWebsocket then
        Exit(True);

      InternalUpgradeToWebsocket(False{no raise}, sError);
      Result := (sError = '');
    finally
      FSocketIOConnectBusy := False;
      UnLock;
    end;
  except
    Result := False;
  end;
end;

procedure TIdHTTPWebsocketClient.UnLock;
begin
  System.TMonitor.Exit(Self);
end;

procedure TIdHTTPWebsocketClient.UpgradeToWebsocket;
var
  sError: string;
begin
  Lock;
  try
    if IOHandler = nil then
      Connect
    else if not IOHandler.IsWebsocket then
      InternalUpgradeToWebsocket(True{raise}, sError);
  finally
    UnLock;
  end;
end;

procedure TIdHTTPWebsocketClient.InternalUpgradeToWebsocket(aRaiseException: Boolean; out aFailedReason: string);
var
  sURL: string;
  strmResponse: TMemoryStream;
  i: Integer;
  sKey, sResponseKey: string;
  sSocketioextended: string;
  bLocked: boolean;
begin
  Assert((IOHandler = nil) or not IOHandler.IsWebsocket);
  //remove from thread during connection handling
  TIdWebsocketMultiReadThread.Instance.RemoveClient(Self);

  bLocked := False;
  strmResponse := nil;
  Self.Lock;
  try
    strmResponse := TMemoryStream.Create;
    //reset pending data
    if IOHandler <> nil then
    begin
      IOHandler.Lock;
      bLocked := True;
      if IOHandler.IsWebsocket then
        Exit;
      IOHandler.Clear;
    end;

    //special socket.io handling, see https://github.com/LearnBoost/socket.io-spec
    if SocketIOCompatible then
    begin
      Request.Clear;
      Request.Connection := 'keep-alive';
      {+}
      //-{$IFDEF WEBSOCKETSSL}
      //-sURL := Format('https://%s:%d/socket.io/1/', [Host, Port]);
      //-{$ELSE}
      //-sURL := Format('http://%s:%d/socket.io/1/', [Host, Port]);
      //-{$ENDIF}
      sURL := FProtocol;
      if sURL = '' then
      begin
        {$IFDEF WEBSOCKETSSL}
        sURL := 'https';
        {$ELSE}
        sURL := 'http';
        {$ENDIF}
      end;
      sURL := Format('%s://%s:%d/socket.io/1/', [sURL, Host, Port]);
      {+.}
      strmResponse.Clear;

      ReadTimeout := 5 * 1000;
      //get initial handshake
      Post(sURL, strmResponse, strmResponse);
      if ResponseCode = 200 {OK} then
      begin
        //if not Connected then  //reconnect
        //  Self.Connect;
        strmResponse.Position := 0;
        //The body of the response should contain the session id (sid) given to the client,
        //followed by the heartbeat timeout, the connection closing timeout, and the list of supported transports separated by :
        //4d4f185e96a7b:15:10:websocket,xhr-polling
        with TStreamReader.Create(strmResponse) do
        try
          FSocketIOHandshakeResponse := ReadToEnd;
        finally
          Free;
        end;
        sKey := Copy(FSocketIOHandshakeResponse, 1, Pos(':', FSocketIOHandshakeResponse) - 1);
        sSocketioextended := 'socket.io/1/websocket/' + sKey;
        WSResourceName := sSocketioextended;
      end
      else
      begin
        aFailedReason := Format('Initial socket.io handshake failed: "%d: %s"', [ResponseCode, ResponseText]);
        if aRaiseException then
          raise EIdWebSocketHandleError.Create(aFailedReason);
      end;
    end;

    Request.Clear;
    Request.CustomHeaders.Clear;
    strmResponse.Clear;
    //http://www.websocket.org/aboutwebsocket.html
    (* GET ws://echo.websocket.org/?encoding=text HTTP/1.1
     Origin: http://websocket.org
     Cookie: __utma=99as
     Connection: Upgrade
     Host: echo.websocket.org
     Sec-WebSocket-Key: uRovscZjNol/umbTt5uKmw==
     Upgrade: websocket
     Sec-WebSocket-Version: 13 *)

    //Connection: Upgrade
    Request.Connection := 'Upgrade';
    //Upgrade: websocket
    Request.CustomHeaders.Add('Upgrade:websocket');

    //Sec-WebSocket-Key
    sKey := '';
    for i := 1 to 16 do
      sKey := sKey + Char(Random(127 - 32) + 32);
    //base64 encoded
    sKey := TIdEncoderMIME.EncodeString(sKey);
    Request.CustomHeaders.AddValue('Sec-WebSocket-Key', sKey);
    //Sec-WebSocket-Version: 13
    Request.CustomHeaders.AddValue('Sec-WebSocket-Version', '13');
    Request.CustomHeaders.AddValue('Sec-WebSocket-Extensions', '');

    Request.CacheControl := 'no-cache';
    Request.Pragma := 'no-cache';
    Request.Host := Format('Host:%s:%d', [Host, Port]);
    Request.CustomHeaders.AddValue('Origin', Format('http://%s:%d', [Host, Port]));
    {+}
    // ws://host:port/<resourcename>
    // about resourcename, see: http://dev.w3.org/html5/websockets/ "Parsing WebSocket URLs"
    //-sURL := Format('ws://%s:%d/%s', [Host, Port, WSResourceName]);
    //-sURL := Format('http://%s:%d/%s', [Host, Port, WSResourceName]);
    sURL := FProtocol;
    if sURL = '' then
      sURL := 'http';
    sURL := Format('%s://%s:%d/%s', [sURL, Host, Port, WSResourceName]);
    {+.}

    ReadTimeout := Max(5 * 1000, ReadTimeout);

    { voorbeeld:
    GET http://localhost:9222/devtools/page/642D7227-148E-47C2-B97A-E00850E3AFA3 HTTP/1.1
    Upgrade: websocket
    Connection: Upgrade
    Host: localhost:9222
    Origin: http://localhost:9222
    Pragma: no-cache
    Cache-Control: no-cache
    Sec-WebSocket-Key: HIqoAdZkxnWWH9dnVPyW7w==
    Sec-WebSocket-Version: 13
    Sec-WebSocket-Extensions: x-webkit-deflate-frame
    User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.116 Safari/537.36
    Cookie: __utma=1.2040118404.1366961318.1366961318.1366961318.1; __utmc=1; __utmz=1.1366961318.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); deviceorder=0123456789101112; MultiTouchEnabled=false; device=3; network_type=0
    }
    if SocketIOCompatible then
    begin
      //1st, try to do socketio specific connection
      Response.Clear;
      Response.ResponseCode := 0;
      Request.URL := sURL;
      Request.Method := Id_HTTPMethodGet;
      Request.Source := nil;
      Response.ContentStream := strmResponse;
      PrepareRequest(Request);

      //connect and upgrade
      ConnectToHost(Request, Response);

      //check upgrade succesfull
      CheckForGracefulDisconnect(True);
      CheckConnected;
      Assert(Self.Connected);

      if Response.ResponseCode = 0 then
        Response.ResponseText := Response.ResponseText
      else if Response.ResponseCode <> 200{ok} then
      begin
        aFailedReason := Format('Error while upgrading: "%d: %s"', [ResponseCode, ResponseText]);
        if aRaiseException then
          raise EIdWebSocketHandleError.Create(aFailedReason)
        else
          Exit;
      end;

      //2nd, get websocket response
      Response.Clear;
      if IOHandler.CheckForDataOnSource(ReadTimeout) then
      begin
        Self.FHTTPProto.RetrieveHeaders(MaxHeaderLines);
        //Response.RawHeaders.Text := IOHandler.InputBufferAsString();
        Response.ResponseText := Response.RawHeaders.Text;
      end;
    end
    else
    begin
      Get(sURL, strmResponse, [101]);
    end;

    //http://www.websocket.org/aboutwebsocket.html
    (* HTTP/1.1 101 WebSocket Protocol Handshake
       Date: Fri, 10 Feb 2012 17:38:18 GMT
       Connection: Upgrade
       Server: Kaazing Gateway
       Upgrade: WebSocket
       Access-Control-Allow-Origin: http://websocket.org
       Access-Control-Allow-Credentials: true
       Sec-WebSocket-Accept: rLHCkw/SKsO9GAH/ZSFhBATDKrU=
       Access-Control-Allow-Headers: content-type *)

    //'HTTP/1.1 101 Switching Protocols'
    if Response.ResponseCode <> 101 then
    begin
      aFailedReason := Format('Error while upgrading: "%d: %s"', [Response.ResponseCode, Response.ResponseText]);
      if aRaiseException then
        raise EIdWebSocketHandleError.Create(aFailedReason)
      else
        Exit;
    end;
    //connection: upgrade
    if not SameText(Response.Connection, 'upgrade') then
    begin
      aFailedReason := Format('Connection not upgraded: "%s"', [Response.Connection]);
      if aRaiseException then
        raise EIdWebSocketHandleError.Create(aFailedReason)
      else
        Exit;
    end;
    //upgrade: websocket
    if not SameText(Response.RawHeaders.Values['upgrade'], 'websocket') then
    begin
      aFailedReason := Format('Not upgraded to websocket: "%s"', [Response.RawHeaders.Values['upgrade']]);
      if aRaiseException then
        raise EIdWebSocketHandleError.Create(aFailedReason)
      else
        Exit;
    end;
    //check handshake key
    sResponseKey := Trim(sKey) +                                         //... "minus any leading and trailing whitespace"
      '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';              //special GUID
    sResponseKey := TIdEncoderMIME.EncodeBytes(                          //Base64
      FHash.HashString(sResponseKey));               //SHA1
    if not SameText(Response.RawHeaders.Values['sec-websocket-accept'], sResponseKey) then
    begin
      aFailedReason := 'Invalid key handshake';
      if aRaiseException then
        raise EIdWebSocketHandleError.Create(aFailedReason)
      else
        Exit;
    end;

    //upgrade succesful
    IOHandler.IsWebsocket := True;
    aFailedReason := '';
    Assert(Connected);

    if SocketIOCompatible then
    begin
      FSocketIOContext := TSocketIOContext.Create(Self);
      (FSocketIOContext as TSocketIOContext).ConnectSend := True;  //connect already send via url? GET /socket.io/1/websocket/9elrbEFqiimV29QAM6T-
      FSocketIO.WriteConnect(FSocketIOContext as TSocketIOContext);
    end;

    //always read the data! (e.g. RO use override of AsyncDispatchEvent to process data)
    //if Assigned(OnBinData) or Assigned(OnTextData) then
  finally
    Request.Clear;
    Request.CustomHeaders.Clear;
    strmResponse.Free;

    if bLocked and (IOHandler <> nil) then
      IOHandler.Unlock;
    Unlock;

    //add to thread for auto retry/reconnect
    if not Self.NoAsyncRead then
      TIdWebsocketMultiReadThread.Instance.AddClient(Self);
  end;

  //default 2s write timeout
  //http://msdn.microsoft.com/en-us/library/windows/desktop/ms740532(v=vs.85).aspx
  if Connected then
    Self.IOHandler.Binding.SetSockOpt(SOL_SOCKET, SO_SNDTIMEO, Self.WriteTimeout);
end;

procedure TIdHTTPWebsocketClient.Lock;
begin
  System.TMonitor.Enter(Self);
end;

function TIdHTTPWebsocketClient.MakeImplicitClientHandler: TIdIOHandler;
begin
  Result := TIdIOHandlerWebsocket.Create(nil);
end;

procedure TIdHTTPWebsocketClient.Ping;
var
  ws: TIdIOHandlerWebsocket;
begin
  if TryLock then
  try
    ws := IOHandler as TIdIOHandlerWebsocket;
    ws.LastPingTime := Now;

    //socket.io?
    if SocketIOCompatible and ws.IsWebsocket then
    begin
      FSocketIO.Lock;
      try
        if (FSocketIOContext <> nil) then
          FSocketIO.WritePing(FSocketIOContext as TSocketIOContext);  //heartbeat socket.io message
      finally
        FSocketIO.UnLock;
      end
    end
    //only websocket?
    else if not SocketIOCompatible and ws.IsWebsocket then
    begin
      if ws.TryLock then
      try
        ws.WriteData(nil, wdcPing);
      finally
        ws.Unlock;
      end;
    end;
  finally
    Unlock;
  end;
end;

{+}
function TIdHTTPWebsocketClient.ReadAndProcessData: Boolean;
{+.}
var
  strmEvent: TMemoryStream;
  swstext: utf8string;
  wscode: TWSDataCode;
  {+}
  AHasData: Boolean;
  {+.}
begin
  {+}
  Result := False;
  {+.}
  strmEvent := nil;
  IOHandler.Lock;
  try
    //try to process all events
    {+}
    AHasData := IOHandler.HasData or (IOHandler.Connected and IOHandler.Readable(0));

    if (not IOHandler.HasData) and IOHandler.Connected then
    begin
//      sleep(2*1000); //!!!
      sleep(10);
      AHasData := IOHandler.HasData or (IOHandler.Connected and IOHandler.Readable(0));
    end;

    if not AHasData then
    begin
      if IOHandler.Connected and not IOHandler.Readable(0) then
        FLastError := 'not Readable'
      else if not IOHandler.HasData then
        FLastError := 'not HasData'
      else
        FLastError := 'not Connected';
      Exit;
    end;

    strmEvent := TMemoryStream.Create;
    while AHasData do //has some data
    begin
      //first is the data type TWSDataType(text or bin), but is ignore/not needed

      //{$IFDEF UNICODE}
      ////--{$IF not declared(TIdIOHandler.ReadLongWord)}
      //wscode := TWSDataCode(IOHandler.ReadUInt32);
      //{$ELSE}
      //wscode := TWSDataCode(IOHandler.ReadLongWord);
      //{$ENDIF}

      {$WARN SYMBOL_DEPRECATED OFF}  // W1000
      wscode := TWSDataCode(IOHandler.ReadLongWord);
      {$WARN SYMBOL_DEPRECATED ON}  // W1000

      if not (wscode in [wdcText, wdcBinary, wdcPing, wdcPong]) then
      begin
        // empty
        //Sleep(0);
      end
      else
      begin
        //next the size + data = stream
        IOHandler.ReadStream(strmEvent);
        if (not Result) and (strmEvent.Size > 0) then
          Result := True;

        //ignore ping/pong messages
        if (wscode in [wdcPing, wdcPong]) then
        begin
          if not Result then
            Result := True;
        end
        else
        begin
          //fire event
          //offload event dispatching to different thread! otherwise deadlocks possible? (do to synchronize)
          strmEvent.Position := 0;
          if wscode = wdcBinary then
          begin
            AsyncDispatchEvent(strmEvent);
          end
          else if wscode = wdcText then
          begin
            SetLength(swstext, strmEvent.Size);
            strmEvent.Read(swstext[1], strmEvent.Size);
            if swstext <> '' then
            begin
              AsyncDispatchEvent(string(swstext));
            end;
          end;
        end;
      end;

      strmEvent.Clear;
      AHasData := IOHandler.HasData or (IOHandler.Connected and IOHandler.Readable(0));
    end; // while OK

    if (not Result) then
    begin
      if IOHandler.Connected and not IOHandler.Readable(0) then
        FLastError := 'not Readable'
      else if not IOHandler.HasData then
        FLastError := 'not HasData'
      else
        FLastError := 'not Connected';
      Exit;
    end;

    {+.}
  finally
    IOHandler.Unlock;
    strmEvent.Free;
  end;
end;

procedure TIdHTTPWebsocketClient.ResetChannel;
//var
//  ws: TIdIOHandlerWebsocket;
begin
//  TIdWebsocketMultiReadThread.Instance.RemoveClient(Self); keep for reconnect

  if IOHandler <> nil then
  begin
    IOHandler.InputBuffer.Clear;
    IOHandler.BusyUpgrading := False;
    IOHandler.IsWebsocket := False;
    //close/disconnect internal socket
    //ws := IndyClient.IOHandler as TIdIOHandlerWebsocket;
    //ws.Close;  done in disconnect below
  end;
  Disconnect(False);
end;

procedure TIdHTTPWebsocketClient.SetIOHandlerWS(const Value: TIdIOHandlerWebsocket);
begin
  SetIOHandler(Value);
end;

procedure TIdHTTPWebsocketClient.SetOnData(const Value: TWebsocketMsgBin);
begin
//  if not Assigned(Value) and not Assigned(FOnTextData) then
//    TIdWebsocketMultiReadThread.Instance.RemoveClient(Self);

  FOnData := Value;

//  if Assigned(Value) and
//     (Self.IOHandler as TIdIOHandlerWebsocket).IsWebsocket
//  then
//    TIdWebsocketMultiReadThread.Instance.AddClient(Self);
end;

procedure TIdHTTPWebsocketClient.SetOnTextData(const Value: TWebsocketMsgText);
begin
//  if not Assigned(Value) and not Assigned(FOnData) then
//    TIdWebsocketMultiReadThread.Instance.RemoveClient(Self);

  FOnTextData := Value;

//  if Assigned(Value) and
//     (Self.IOHandler as TIdIOHandlerWebsocket).IsWebsocket
//  then
//    TIdWebsocketMultiReadThread.Instance.AddClient(Self);
end;

procedure TIdHTTPWebsocketClient.SetProtocol(const Value: string);
begin
  FProtocol := Trim(Value);
end;

procedure TIdHTTPWebsocketClient.SetWriteTimeout(const Value: Integer);
begin
  FWriteTimeout := Value;
  if Connected then
    Self.IOHandler.Binding.SetSockOpt(SOL_SOCKET, SO_SNDTIMEO, Self.WriteTimeout);
end;

{ TIdHTTPSocketIOClient }

(*
procedure TIdHTTPSocketIOClient_old.AfterConstruction;
begin
  inherited;
  SocketIOCompatible := True;

  FHeartBeat := TTimer.Create(nil);
  FHeartBeat.Enabled := False;
  FHeartBeat.OnTimer := HeartBeatTimer;
end;

procedure TIdHTTPSocketIOClient_old.AsyncDispatchEvent(const aEvent: string);
begin
  //https://github.com/LearnBoost/socket.io-spec
  if StartsStr('1:', aEvent) then  //connect
    Exit;
  if aEvent = '2::' then  //ping, heartbeat
    Exit;
  inherited AsyncDispatchEvent(aEvent);
end;

procedure TIdHTTPSocketIOClient_old.AutoConnect;
begin
  //for now: timer in mainthread?
  TThread.Queue(nil,
    procedure
    begin
      FHeartBeat.Interval := 5 * 1000;
      FHeartBeat.Enabled  := True;
    end);
end;

destructor TIdHTTPSocketIOClient_old.Destroy;
var tmr: TObject;
begin
  tmr := FHeartBeat;
  TThread.Queue(nil,    //otherwise free in other thread than created
    procedure
    begin
      //FHeartBeat.Free;
      tmr.Free;
    end);
  inherited;
end;

procedure TIdHTTPSocketIOClient_old.HeartBeatTimer(Sender: TObject);
begin
  FHeartBeat.Enabled := False;
  try
    try
      if (IOHandler <> nil) and
         not IOHandler.ClosedGracefully and
         IOHandler.Connected then
      begin
        IOHandler.Write('2:::');  //heartbeat socket.io message
      end
      //retry connect
      else
      try
        //clear inputbuffer, otherwise it can't connect :(
        if (IOHandler <> nil) and
           not IOHandler.InputBufferIsEmpty
        then
          IOHandler.DiscardAll;

        Self.Connect;
        TryUpgradeToWebsocket;
      except
        //skip, just retried
      end;
    except
      //clear inputbuffer, otherwise it stays connected :(
      if (IOHandler <> nil) and
         not IOHandler.InputBufferIsEmpty
      then
        IOHandler.DiscardAll;

      if Assigned(OnDisConnected) then
        OnDisConnected(Self);
      try
        raise EIdException.Create('Connection lost from ' + Format('ws://%s:%d/%s', [Host, Port, WSResourceName]));
      except
        //eat, no error popup!
      end;
    end;
  finally
    FHeartBeat.Enabled := True;  //always enable: in case of disconnect it will re-connect
  end;
end;

procedure TIdHTTPSocketIOClient_old.InternalUpgradeToWebsocket(
  aRaiseException: Boolean; out aFailedReason: string);
var
  stimeout: string;
begin
  inherited InternalUpgradeToWebsocket(aRaiseException, aFailedReason);

  if (aFailedReason = '') and
     (IOHandler as TIdIOHandlerWebsocket).IsWebsocket then
  begin
    stimeout := Copy(SocketIOHandshakeResponse, Pos(':', SocketIOHandshakeResponse)+1, Length(SocketIOHandshakeResponse));
    stimeout := Copy(stimeout, 1, Pos(':', stimeout)-1);
    if stimeout <> '' then
    begin
      //if (FHeartBeat.Interval > 0) then
        //for now: timer in mainthread?
        TThread.Queue(nil,
          procedure
          begin
            FHeartBeat.Interval := StrToIntDef(stimeout, 15) * 1000;
            if FHeartBeat.Interval >= 15000 then
              //FHeartBeat.Interval := FHeartBeat.Interval - 5000
              FHeartBeat.Interval := 5000
            else if FHeartBeat.Interval >= 5000 then
              FHeartBeat.Interval := FHeartBeat.Interval - 2000;

            FHeartBeat.Enabled := (FHeartBeat.Interval > 0);
          end);
    end;

    if Assigned(OnConnected) then
      OnConnected(Self);
  end;
end;

)
procedure TIdHTTPSocketIOClient_old.ProcessSocketIORequest(
  const strmRequest: TStream);

  function __ReadToEnd: string;
  var
    utf8: TBytes;
    ilength: Integer;
  begin
    Result := '';
    ilength := strmRequest.Size - strmRequest.Position;
    SetLength(utf8, ilength);
    strmRequest.Read(utf8[0], ilength);
    Result := TEncoding.UTF8.GetString(utf8);
  end;

  function __GetSocketIOPart(const aData: string; aIndex: Integer): string;
  var ipos: Integer;
    i: Integer;
  begin
    //'5::/chat:{"name":"hi!"}'
    //0 = 5
    //1 =
    //2 = /chat
    //3 = {"name":"hi!"}
    ipos := 0;
    for i := 0 to aIndex-1 do
      ipos := PosEx(':', aData, ipos+1);
    if ipos >= 0 then
    begin
      Result := Copy(aData, ipos+1, Length(aData));
      if aIndex < 3 then                      // /chat:{"name":"hi!"}'
      begin
        ipos   := PosEx(':', Result, 1);      // :{"name":"hi!"}'
        if ipos > 0 then
          Result := Copy(Result, 1, ipos-1);  // /chat
      end;
    end;
  end;

var
  str, smsg, schannel, sdata: string;
  imsg: Integer;
//  bCallback: Boolean;
begin
  str := __ReadToEnd;
  if str = '' then Exit;

  //5:1+:/chat:test
  smsg      := __GetSocketIOPart(str, 1);
  imsg      := 0;
//  bCallback := False;
  if smsg <> '' then                                       // 1+
  begin
    imsg    := StrToIntDef(ReplaceStr(smsg,'+',''), 0);    // 1
//    bCallback := (Pos('+', smsg) > 1);  //trailing +, e.g.    1+
  end;
  schannel  := __GetSocketIOPart(str, 2);                  // /chat
  sdata     := __GetSocketIOPart(str, 3);                  // test

  //(0) Disconnect
  if StartsStr('0:', str) then
  begin
    schannel := __GetSocketIOPart(str, 2);
    if schannel <> '' then
      //todo: close channel
    else
      Self.Disconnect;
  end
  //(1) Connect
  //'1::' [path] [query]
  else if StartsStr('1:', str) then
  begin
    //todo: add channel/room to authorized channel/room list
    Self.IOHandler.Write(str);  //write same connect back, e.g. 1::/chat
  end
  //(2) Heartbeat
  else if StartsStr('2:', str) then
  begin
    Self.IOHandler.Write(str);  //write same connect back, e.g. 2::
  end
  //(3) Message (https://github.com/LearnBoost/socket.io-spec#3-message)
  //'3:' [message id ('+')] ':' [message endpoint] ':' [data]
  //3::/chat:hi
  else if StartsStr('3:', str) then
  begin
    if Assigned(OnSocketIOMsg) then
      OnSocketIOMsg(Self, sdata, imsg);
  end
  //(4) JSON Message
  //'4:' [message id ('+')] ':' [message endpoint] ':' [json]
  //4:1::{"a":"b"}
  else if StartsStr('4:', str) then
  begin
    if Assigned(OnSocketIOJson) then
      OnSocketIOJson(Self, sdata, imsg);
  end
  //(5) Event
  //'5:' [message id ('+')] ':' [message endpoint] ':' [json encoded event]
  //5::/chat:{"name":"my other event","args":[{"my":"data"}]}
  //5:1+:/chat:{"name":"GetLocations","args":[""]}
  else if StartsStr('5:', str) then
  begin
    if Assigned(OnSocketIOEvent) then
      OnSocketIOEvent(Self, sdata, imsg);
  end
  //(6) ACK
  //6::/news:1+["callback"]
  //6:::1+["Response"]
  //(7) Error
  //(8) Noop
  else if StartsStr('8:', str) then
  begin
    //nothing
  end
  else
    raise Exception.CreateFmt('Unsupported data: "%s"', [str]);
end;
*)

{ TIdWebsocketMultiReadThread }

procedure TIdWebsocketMultiReadThread.AddClient(aChannel: TIdHTTPWebsocketClient);
var
  l: TList;
begin
  //Assert( (aChannel.IOHandler as TIdIOHandlerWebsocket).IsWebsocket, 'Channel is not a websocket');
  if Self = nil then
    Exit;
  if Self.Terminated then
    Exit;

  l := FChannels.LockList;
  try
    //already exists?
    if l.IndexOf(aChannel) >= 0 then
      Exit;

    Assert(l.Count < 64, 'Max 64 connections can be handled by one read thread!');  //due to restrictions of the "select" API
    l.Add(aChannel);

    //trigger the "select" wait
    BreakSelectWait;
  finally
    FChannels.UnlockList;
  end;
end;

procedure TIdWebsocketMultiReadThread.AfterConstruction;
begin
  inherited;

  ReadTimeout := 5000;

  FChannels := TThreadList.Create;
  FillChar(Freadset, SizeOf(Freadset), 0);
  FillChar(Fexceptionset, SizeOf(Fexceptionset), 0);

  InitSpecialEventSocket;
end;

procedure TIdWebsocketMultiReadThread.BreakSelectWait;
var
  //iResult: Integer;
  LAddr: TSockAddrIn6;
begin
  if FTempHandle = 0 then
    Exit;

  FillChar(LAddr, SizeOf(LAddr), 0);
  //Id_IPv4
  with PSOCKADDR(@LAddr)^ do
  begin
    sin_family := Id_PF_INET4;
    //dummy address and port
    (GStack as TIdStackBSDBase).TranslateStringToTInAddr('0.0.0.0', sin_addr, Id_IPv4);
    sin_port := htons(1);
  end;

  FPendingBreak := True;

  //connect to non-existing address to stop "select" from waiting
  //Note: this is some kind of "hack" because there is no nice way to stop it
  //The only(?) other possibility is to make a "socket pair" and send a byte to it,
  //but this requires a dynamic server socket (which can trigger a firewall
  //exception/question popup in WindowsXP+)
  //iResult :=
  IdWinsock2.connect(FTempHandle, PSOCKADDR(@LAddr), SIZE_TSOCKADDRIN);
  //non blocking socket, so will always result in "would block"!
//  if (iResult <> Id_SOCKET_ERROR) or
//     ( (GStack <> nil) and (GStack.WSGetLastError <> WSAEWOULDBLOCK) )
//  then
//    GStack.CheckForSocketError(iResult);
end;

destructor TIdWebsocketMultiReadThread.Destroy;
begin
  if FReconnectThread <> nil then
  begin
    try
      FReconnectThread.Terminate;
      FReconnectThread.WaitFor;
    except
    end;
    try
      FreeAndNil(FReconnectThread);
    except
      FReconnectThread := nil;
    end;
  end;

  FreeAndNil(FReconnectlist);

  if FTempHandle <> 0 then
  begin
    try
      IdWinsock2.closesocket(FTempHandle);
    except
    end;
    FTempHandle := 0;
  end;

  FreeAndNil(FChannels);
  inherited;
end;

procedure TIdWebsocketMultiReadThread.Execute;
begin
  {$ifndef NOSETTHREADNAME}
  Self.NameThreadForDebugging(AnsiString(Self.ClassName));
  {$endif}

  while not Terminated do
  begin
    try
      while not Terminated do
      begin
        ReadFromAllChannels;
        PingAllChannels;
      end;
    except
      //continue
    end;
  end;
end;

procedure TIdWebsocketMultiReadThread.InitSpecialEventSocket;
var
  param: Cardinal;
  iResult: Integer;
begin
  if GStack = nil then
    Exit; //finalized?

  //alloc socket
  FTempHandle := GStack.NewSocketHandle(Id_SOCK_STREAM, Id_IPPROTO_IP, Id_IPv4, False);
  Assert(FTempHandle <> Id_INVALID_SOCKET);
  //non block mode
  param := 1; // enable NON blocking mode
  iResult := ioctlsocket(FTempHandle, FIONBIO, param);
  GStack.CheckForSocketError(iResult);
end;

class function TIdWebsocketMultiReadThread.Instance: TIdWebsocketMultiReadThread;
begin
  if (FInstance = nil) then
  begin
    if GUnitFinalized then
      Exit(nil);

    FInstance := TIdWebsocketMultiReadThread.Create(True);
    FInstance.Start;
  end;
  Result := FInstance;
end;

procedure TIdWebsocketMultiReadThread.PingAllChannels;
var
  l: TList;
  chn: TIdHTTPWebsocketClient;
  ws: TIdIOHandlerWebsocket;
  i: Integer;
begin
  if Terminated then
    Exit;

  l := FChannels.LockList;
  try
    for i := 0 to l.Count - 1 do
    begin
      chn := TIdHTTPWebsocketClient(l.Items[i]);
      if chn.NoAsyncRead then
        Continue;

      ws := chn.IOHandler as TIdIOHandlerWebsocket;
      //valid?
      if (chn.IOHandler <> nil) and (chn.IOHandler.IsWebsocket) and (chn.Socket <> nil) and (chn.Socket.Binding <> nil)
        and (chn.Socket.Binding.Handle > 0) and (chn.Socket.Binding.Handle <> INVALID_SOCKET) then
      begin
        //more than 10s nothing done? then send ping
        if SecondsBetween(Now, ws.LastPingTime) > 10 then
          if chn.CheckConnection then
          try
            chn.Ping;
          except
            //retry connect the next time?
          end;
      end
      else if not chn.Connected then
      begin
        if (ws <> nil) and (SecondsBetween(Now, ws.LastActivityTime) < 5) then
          Continue;

        if FReconnectlist = nil then
          FReconnectlist := TWSThreadList.Create;
        //if chn.TryLock then
        FReconnectlist.Add(chn);
      end;
    end;
  finally
    FChannels.UnlockList;
  end;

  if Terminated then
    Exit;

  //reconnect needed? (in background)
  if FReconnectlist <> nil then
    if FReconnectlist.Count > 0 then
    begin
      if FReconnectThread = nil then
        FReconnectThread := TIdWebsocketQueueThread.Create(False{direct start});
      FReconnectThread.QueueEvent(
        procedure
        var
          l: TList;
          chn: TIdHTTPWebsocketClient;
        begin
          while FReconnectlist.Count > 0 do
          begin
            chn := nil;
            try
            //get first one
              l := FReconnectlist.LockList;
              try
                if l.Count <= 0 then
                  Exit;

                chn := TObject(l.Items[0]) as TIdHTTPWebsocketClient;
                if not chn.TryLock then
                begin
                  l.Delete(0);
                  chn := nil;
                  Continue;
                end;
              finally
                FReconnectlist.UnlockList;
              end;

            //try reconnect
              ws := chn.IOHandler as TIdIOHandlerWebsocket;
              if ((ws = nil) or (SecondsBetween(Now, ws.LastActivityTime) >= 5)) then
              begin
                try
                  if not chn.Connected then
                  begin
                    if ws <> nil then
                      ws.LastActivityTime := Now;
                  //chn.ConnectTimeout  := 1000;
                    if (chn.Host <> '') and (chn.Port > 0) then
                      chn.TryUpgradeToWebsocket;
                  end;
                except
                //just try
                end;
              end;

            //remove from todo list
              l := FReconnectlist.LockList;
              try
                if l.Count > 0 then
                  l.Delete(0);
              finally
                FReconnectlist.UnlockList;
              end;
            finally
              if chn <> nil then
                chn.Unlock;
            end;
          end;
        end);
    end;
end;

procedure TIdWebsocketMultiReadThread.ReadFromAllChannels;
var
  l: TList;
  chn: TIdHTTPWebsocketClient;
  iCount, i: Integer;
  iResult: NativeInt;
  ws: TIdIOHandlerWebsocket;
begin
  l := FChannels.LockList;
  try
    iCount := 0;
    iResult := 0;
    Freadset.fd_count := iCount;

    for i := 0 to l.Count - 1 do
    begin
      chn := TIdHTTPWebsocketClient(l.Items[i]);
      if chn.NoAsyncRead then
        Continue;

      //valid?
      if //not chn.Busy and    also take busy channels (will be ignored later), otherwise we have to break/reset for each RO function execution
        (chn.IOHandler <> nil) and (chn.IOHandler.IsWebsocket) and (chn.Socket <> nil) and (chn.Socket.Binding <> nil)
        and (chn.Socket.Binding.Handle > 0) and (chn.Socket.Binding.Handle <> INVALID_SOCKET) then
      begin
        if chn.IOHandler.HasData then
        begin
          Inc(iResult);
          Break;
        end;

        Freadset.fd_count := iCount + 1;
        Freadset.fd_array[iCount] := chn.Socket.Binding.Handle;
        Inc(iCount);
      end;
    end;

    if FPendingBreak then
      ResetSpecialEventSocket;
  finally
    FChannels.UnlockList;
  end;

  //special helper socket to be able to stop "select" from waiting
  Fexceptionset.fd_count := 1;
  Fexceptionset.fd_array[0] := FTempHandle;

  //wait 15s till some data
  Finterval.tv_sec := Self.ReadTimeout div 1000; //5s
  Finterval.tv_usec := Self.ReadTimeout mod 1000;

  //nothing to wait for? then sleep some time to prevent 100% CPU
  if iResult = 0 then
  begin
    if iCount = 0 then
    begin
      iResult := IdWinsock2.select(0, nil, nil, @Fexceptionset, @Finterval);
      if iResult = SOCKET_ERROR then
        iResult := 1;  //ignore errors
    end
    //wait till a socket has some data (or a signal via exceptionset is fired)
    else
      iResult := IdWinsock2.select(0, @Freadset, nil, @Fexceptionset, @Finterval);
    if iResult = SOCKET_ERROR then
      //raise EIdWinsockStubError.Build(WSAGetLastError, '', []);
      //ignore error during wait: socket disconnected etc
      Exit;
  end;

  if Terminated then
    Exit;

  //some data?
  if (iResult > 0) then
  begin
    //make sure the thread is created outside a lock
    TIdWebsocketDispatchThread.Instance;

    l := FChannels.LockList;
    if l = nil then
      Exit;
    try
      //check for data for all channels
      for i := 0 to l.Count - 1 do
      begin
        if l = nil then
          Exit;
        chn := TIdHTTPWebsocketClient(l.Items[i]);
        if chn.NoAsyncRead then
          Continue;

        if chn.TryLock then
        try
          ws := chn.IOHandler as TIdIOHandlerWebsocket;
          if (ws = nil) then
            Continue;

          if ws.TryLock then     //IOHandler.Readable cannot be done during pending action!
          try
            try
              chn.ReadAndProcessData;
            except
              on e: Exception do
              begin
                l := nil;
                FChannels.UnlockList;
                chn.ResetChannel;
                //raise;
              end;
            end;
          finally
            ws.Unlock;
          end;
        finally
          chn.Unlock;
        end;
      end;

      if FPendingBreak then
        ResetSpecialEventSocket;
    finally
      if l <> nil then
        FChannels.UnlockList;
      //strmEvent.Free;
    end;
  end;
end;

procedure TIdWebsocketMultiReadThread.RemoveClient(aChannel: TIdHTTPWebsocketClient);
begin
  if Self = nil then
    Exit;
  if Self.Terminated then
    Exit;

  aChannel.Lock;
  try
    FChannels.Remove(aChannel);
    if FReconnectlist <> nil then
      FReconnectlist.Remove(aChannel);
  finally
    aChannel.UnLock;
  end;
  BreakSelectWait;
end;

class procedure TIdWebsocketMultiReadThread.RemoveInstance(aForced: boolean);
var
  o: TIdWebsocketMultiReadThread;
begin
  if FInstance <> nil then
  begin
    FInstance.Terminate;
    o := FInstance;
    FInstance := nil;

    if aForced then
    begin
      WaitForSingleObject(o.Handle, 2 * 1000);
      TerminateThread(o.Handle, MaxInt);
    end
    else
      o.WaitFor;
    FreeAndNil(o);
  end;
end;

procedure TIdWebsocketMultiReadThread.ResetSpecialEventSocket;
begin
  Assert(FPendingBreak);
  FPendingBreak := False;

  IdWinsock2.closesocket(FTempHandle);
  FTempHandle := 0;
  InitSpecialEventSocket;
end;

procedure TIdWebsocketMultiReadThread.Terminate;
begin
  inherited Terminate;
  if FReconnectThread <> nil then
    FReconnectThread.Terminate;

  FChannels.LockList;
  try
    //fire a signal, so the "select" wait will quit and thread can stop
    BreakSelectWait;
  finally
    FChannels.UnlockList;
  end;
end;

{ TIdWebsocketDispatchThread }

class function TIdWebsocketDispatchThread.Instance: TIdWebsocketDispatchThread;
begin
  if FInstance = nil then
  begin
    if GUnitFinalized then
      Exit(nil);

    GlobalNameSpace.BeginWrite;
    try
      if FInstance = nil then
      begin
        FInstance := Self.Create(True);
        FInstance.Start;
      end;
    finally
      GlobalNameSpace.EndWrite;
    end;
  end;
  Result := FInstance;
end;

class procedure TIdWebsocketDispatchThread.RemoveInstance;
var
  o: TIdWebsocketDispatchThread;
begin
  if FInstance <> nil then
  begin
    FInstance.Terminate;
    o := FInstance;
    FInstance := nil;

    if aForced then
    begin
      WaitForSingleObject(o.Handle, 2 * 1000);
      TerminateThread(o.Handle, MaxInt);
    end;
    o.WaitFor;
    FreeAndNil(o);
  end;
end;

{ TWSThreadList }

function TWSThreadList.Count: Integer;
var
  l: TList;
begin
  l := LockList;
  try
    Result := l.Count;
  finally
    UnlockList;
  end;
end;

{+}
{ TClientWebSocket }

procedure TClientWebSocket.AfterConstruction;
begin
  inherited;

  NoAsyncRead := True; // !!! - ≈сли перемыкать NoAsyncRead, то поток читатель может считвать данные паралельно.
  // ≈сли нужно перемыкать, то нужно разрывать соединение при смене "NoAsyncRead".

  FWriteTimeout := 30 * 1000;
  ReadTimeout := 30 * 1000;
  ConnectTimeout := 7 * 1000;
end;

destructor TClientWebSocket.Destroy;
begin
{ // quick close:
  //if (IOHandler <> nil) and (IOHandler.Binding <> nil) then
  //  TIdSocketHandleAccess(IOHandler.Binding).Disconnect;
  if (IOHandler <> nil) then
    IOHandler.IsWebsocket := False;
  // quick close.}
  inherited;
end;

function TClientWebSocket.DoOpen(ARaise: Boolean; const AURL: string): Boolean;
var
  sProtocol, sHost, sPath, sDocument, sPort, sBookmark: string;
begin
  FLastError := '';
  Result := False;
  try
    Self.Disconnect();

    ParseURI(AURL, sProtocol, sHost, sPath, sDocument, sPort, sBookmark);
    if sProtocol <> '' then
      Protocol := sProtocol;
    Host := sHost;
    if sPort <> '' then
      Port := StrToIntDef(sPort, Port);
    if (sPath <> '') and (sPath <> '/') then
      sDocument := Copy(sPath, Low(sPath)+1, Length(sPath)-1 ) + sDocument;

    WSResourceName := sDocument;

    Connect();

    if not IOHandler.IsWebsocket then
      UpgradeToWebsocket; //!!!

    if not IOHandler.IsWebsocket then
    begin
      FLastError := 'Failed UpgradeToWebsocket';
      if G_DEBUG_WS then
      begin
        dbg_ws(Format('Open ERROR: (TID:%d): %s', [GetCurrentThreadID, FLastError]));
      end;

      Exit;
    end;

    Result := True;
  except
    on e: Exception do
    begin
      FLastError := e.Message;
      if G_DEBUG_WS then
      begin
        dbg_ws(Format('Open ERROR: (E: %s; TID:%d): %s', [e.ClassName, GetCurrentThreadID, FLastError]));
      end;
      Disconnect();
      if ARaise then
        raise;
    end;
  end;
end;

function TClientWebSocket.DoReceiveData(ARaise: Boolean; aData: TStream): Boolean;
var
  _NoAsyncRead: Boolean;
  _OnBinData: TWebsocketMsgBin;
  _OnTextData: TWebsocketMsgText;
  //
  AHasData: Boolean;
  ws: TIdIOHandlerWebsocket;
  AStartWait: TDateTime;
  ATimeout: Cardinal;
begin
  //FLastError := '';
  Result := False;
  if aData = nil then
  begin
    FLastError := 'bad parameter "aData"  (nil)';
    Exit;
  end;
  ws := IOHandler as TIdIOHandlerWebsocket;

  _NoAsyncRead := NoAsyncRead;
  _OnBinData := OnBinData;
  _OnTextData := OnTextData;
  try
    try
      aData.Size := 0;

      NoAsyncRead := True; //!!!
      OnTextData := nil;
      OnBinData := Received_OnBinData;
      FReceivedDataStm := aData;

      AHasData := ws.HasData or (ws.Connected and ws.Readable(0));
      if not AHasData then
      begin // wait data ...
        AStartWait := Now();

        if ReadTimeout > 0 then
          ATimeout := ReadTimeout
        else
          ATimeout := 0;
        if ATimeout < 2000 then
          ATimeout := 2000;
        while (not AHasData) and (MilliSecondOfTheMinute(Now()-AStartWait) < ATimeout)  do
        begin
          AHasData := (not ws.Closing) and
            (TIdIOHandlerAccess(ws).ReadFromSource(False{no disconnect error}, 1 * 100, False) > 0);

          if not AHasData then
            AHasData := ws.HasData or (ws.Connected and ws.Readable(0));
        end;
        if not AHasData then
        begin
          FLastError := 'not read data bin by timeout';
          if G_DEBUG_WS then
          begin
            dbg_ws(Format('ReceiveData Stream WARNING: (TID:%d): %s', [GetCurrentThreadID, FLastError]));
          end;
        end;
      end;

      Result := ReadAndProcessData();

      if (not Result) and (not AHasData) then
      begin
        if ws.Connected and not ws.Readable(0) then
          FLastError := 'not read data bin by timeout';
      end;

    except
      on e: Exception do
      begin
        FLastError := e.Message;
        if G_DEBUG_WS then
        begin
          dbg_ws(Format('ReceiveData Stream ERROR: (E: %s; TID:%d): %s', [e.ClassName, GetCurrentThreadID, FLastError]));
        end;
        if ARaise then
          raise;
      end;
    end;
  finally
    NoAsyncRead := _NoAsyncRead;
    OnBinData := _OnBinData;
    OnTextData := _OnTextData;
    FReceivedDataStm := nil;
  end;
end;

function TClientWebSocket.DoReceiveData(ARaise: Boolean; var aData: string): Boolean;
var
  _NoAsyncRead: Boolean;
  _OnBinData: TWebsocketMsgBin;
  _OnTextData: TWebsocketMsgText;
  //
  AHasData: Boolean;
  ws: TIdIOHandlerWebsocket;
  AStartWait: TDateTime;
  ATimeout: Cardinal;
begin
  //FLastError := '';
  Result := False;
  ws := IOHandler as TIdIOHandlerWebsocket;

  _NoAsyncRead := NoAsyncRead;
  _OnBinData := OnBinData;
  _OnTextData := OnTextData;
  try
    try
      aData := '';

      NoAsyncRead := True; //!!!
      OnBinData := nil;
      OnTextData := Received_OnTextData;
      FReceivedDataStr := '';

      AHasData := ws.HasData or (ws.Connected and ws.Readable(0));
      if not AHasData then
      begin // wait data ...
        AStartWait := Now();

        if ReadTimeout > 0 then
          ATimeout := ReadTimeout
        else
          ATimeout := 0;
        if ATimeout < 2000 then
          ATimeout := 2000;
        while (not AHasData) and (MilliSecondOfTheMinute(Now()-AStartWait) < ATimeout)  do
        begin
          AHasData := (not ws.Closing) and
            (TIdIOHandlerAccess(ws).ReadFromSource(False{no disconnect error}, 1 * 100, False) > 0);

          if not AHasData then
            AHasData := ws.HasData or (ws.Connected and ws.Readable(0));
        end;
        if not AHasData then
        begin
          FLastError := 'not read data text by timeout';
          if G_DEBUG_WS then
          begin
            dbg_ws(Format('ReceiveData Text WARNING: (TID:%d): %s', [GetCurrentThreadID, FLastError]));
          end;
        end;
      end;

      Result := ReadAndProcessData();

      if (not Result) and (not AHasData) then
      begin
        if ws.Connected and not ws.Readable(0) then
          FLastError := 'not read data text by timeout';
      end;

      aData := FReceivedDataStr;
    except
      on e: Exception do
      begin
        FLastError := e.Message;
        if G_DEBUG_WS then
        begin
          dbg_ws(Format('ReceiveData Text ERROR: (E: %s; TID:%d): %s', [e.ClassName, GetCurrentThreadID, FLastError]));
        end;
        if ARaise then
          raise;
      end;
    end;

  finally
    NoAsyncRead := _NoAsyncRead;
    OnBinData := _OnBinData;
    OnTextData := _OnTextData;
    FReceivedDataStr := '';
  end;
end;

function TClientWebSocket.DoSendData(ARaise: Boolean; AData: TStream; ADataType: TWSDataType): Boolean;
var
  ws: TIdIOHandlerWebsocket;
begin
  Result := False;

  if (not Connected) then
  begin
    FLastError := 'not connected';
    Exit
  end;
  if SocketIOConnectBusy then
  begin
    FLastError := 'socket is busy';
    Exit
  end;

  try
    ws := IOHandler as TIdIOHandlerWebsocket;

    if not ws.IsWebsocket then
    begin
      FLastError := 'is not websocket';
      Exit;
    end;

    ws.WriteBufferClear;
    ws.Write(AData, ADataType);
    ws.WriteBufferFlush;

    sleep(1);
    Result := True;
  except
    on e: Exception do
    begin
      FLastError := e.Message;
      if G_DEBUG_WS then
      begin
        dbg_ws(Format('SendData Stream ERROR: (E: %s; TID:%d): %s', [e.ClassName, GetCurrentThreadID, FLastError]));
      end;
      if ARaise then
        raise;
    end;
  end;
end;

function TClientWebSocket.DoSendData(ARaise: Boolean; const AData: string; AEncoding: IIdTextEncoding): Boolean;
var
  ws: TIdIOHandlerWebsocket;
begin
  Result := False;

  if (not Connected) then
  begin
    FLastError := 'not connected';
    Exit
  end;
  if SocketIOConnectBusy then
  begin
    FLastError := 'socket is busy';
    Exit
  end;

  try
    ws := IOHandler as TIdIOHandlerWebsocket;

    if not ws.IsWebsocket then
    begin
      FLastError := 'is not websocket';
      Exit;
    end;

    ws.WriteBufferClear;
    ws.Write(AData, AEncoding);
    ws.WriteBufferFlush;

    Result := True;
  except
    on e: Exception do
    begin
      FLastError := e.Message;
      if G_DEBUG_WS then
      begin
        dbg_ws(Format('SendData Text ERROR: (E: %s; TID:%d): %s', [e.ClassName, GetCurrentThreadID, FLastError]));
      end;
      if ARaise then
        raise;
    end;
  end;
end;

procedure TClientWebSocket.Open(const AURL: string);
begin
  DoOpen({Raise:}True, AURL);
end;

procedure TClientWebSocket.Ping;
var
  _NoAsyncRead: Boolean;
  S: string;
begin
  if (not Connected) then
  begin
    FLastError := 'not connected';
    Exit
  end;
  if SocketIOConnectBusy then
  begin
    FLastError := 'socket is busy';
    Exit
  end;

  _NoAsyncRead := NoAsyncRead;
  NoAsyncRead := True;
  try
    inherited;
    TryReceiveData(S); // !!! ѕосле пинга нужно вычитать данные иначе следующа€ команда захлебнЄтс€
  finally
    NoAsyncRead := _NoAsyncRead;
  end;
end;

procedure TClientWebSocket.ReceiveData(var aData: string);
begin
  DoReceiveData({Raise:}True, aData);
end;

procedure TClientWebSocket.ReceiveData(aData: TStream);
begin
  DoReceiveData({Raise:}True, aData);
end;

procedure TClientWebSocket.Received_OnBinData(const aData: TStream);
begin
  if G_DEBUG_WS then
  begin
    dbg_ws('Received Bin Part: Size: ' + IntToStr(aData.Size));
  end;
  if Assigned(FReceivedDataStm) then
  begin
    FReceivedDataStm.CopyFrom(aData, aData.Size - aData.Position);
  end;
end;

procedure TClientWebSocket.Received_OnTextData(const aData: string);
begin
  if G_DEBUG_WS then
  begin
    dbg_ws('Received Text Part: "' + aData + '"');
  end;
  FReceivedDataStr := FReceivedDataStr + aData;
end;

procedure TClientWebSocket.SendData(AData: TStream; ADataType: TWSDataType);
begin
  DoSendData({Raise:}True, AData, ADataType);
end;

procedure TClientWebSocket.SendData(const AData: string; AEncoding: IIdTextEncoding);
begin
  DoSendData({Raise:}True, AData, AEncoding);
end;

function TClientWebSocket.TryOpen(const AURL: string): Boolean;
begin
  Result := DoOpen({Raise:}False, AURL);
end;

function TClientWebSocket.TryReceiveData(var aData: string): Boolean;
begin
  Result := DoReceiveData({Raise:}False, aData);
end;

function TClientWebSocket.TryReceiveData(aData: TStream): Boolean;
begin
  Result := DoReceiveData({Raise:}False, aData);
end;

function TClientWebSocket.TrySendData(AData: TStream; ADataType: TWSDataType): Boolean;
begin
  Result := DoSendData({Raise:}False, AData, ADataType);
end;

function TClientWebSocket.TrySendData(const AData: string; AEncoding: IIdTextEncoding): Boolean;
begin
  Result := DoSendData({Raise:}False, AData, AEncoding);
end;
{+.}

initialization

finalization
  GUnitFinalized := True;
  if TIdWebsocketMultiReadThread.Instance <> nil then
    TIdWebsocketMultiReadThread.Instance.Terminate;
  TIdWebsocketDispatchThread.RemoveInstance();
  TIdWebsocketMultiReadThread.RemoveInstance();

end.
