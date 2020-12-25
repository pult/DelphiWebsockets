# DelphiWebsockets
Websockets and Socket.io for Delphi XE3 Up over Indy network library

forked from "AndreMussche DelphiWebsockets" : https://github.com/andremussche/DelphiWebsockets

![](https://tokei.rs/b1/github/pult/DelphiWebsockets?category=code)
![](https://tokei.rs/b1/github/pult/DelphiWebsockets?category=files)
![](https://img.shields.io/github/last-commit/pult/DelphiWebsockets.svg)
![](https://img.shields.io/github/languages/top/pult/DelphiWebsockets.svg)


### Dependencies
- superobject: https://github.com/pult/SuperObject.Delphi

Sample sync access:
```delphi
uses
  ..., amdws.IdHTTPWebsocketClient, amdws.IdIOHandlerWebsocket;

  G_DEBUG_WS := True; // Optional: Enable debug messages
  ws := TClientWebSocket.Create(Self);
  TIdIOHandlerWebsocket.UseSingleWriteThread := True; // for sync access

  if ws.TryOpen('ws://localhost:3000/echo') then begin
    ws.Ping;
    if ws.TrySendData('{"method":"GetTerminalInfo","step":0}') then begin
      if ws.TryReceiveData(ws_received) then begin
        ShowMessage(ws_received);
      end;
    end;
  end;

  ws.Disconnect;
```

<img align="left" src="https://github.com/pult/DelphiWebsockets/blob/pult/Samples/002-privat-bank-pos-api/pClientWebSocketDemo.png"/>
