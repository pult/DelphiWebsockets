{ amdws.wsdefines.inc }
// AndreMussche: DelphiWebsockets
// fork from: https://github.com/andremussche/DelphiWebsockets

{-DEFINE WEBSOCKETSSL}
  // TODO: "amdws.IdServerIOHandlerWebsocket.pas"(24) Error: E2137 Method 'CreateOpenSSLSocket' not found in base class
{-DEFINE WEBSOCKETBRIDGE}

{$DEFINE SUPEROBJECT}

{+}
{.$DEFINE DEBUG_WS}

{$define NOSETTHREADNAME}

{$IFDEF DEBUG_WS}
  {$C+} { Evaluate assertions at runtime }
  {$undef NOSETTHREADNAME} { optional }
{$ELSE}
  {$C-} { Evaluate assertions at runtime }
{$ENDIF}


{$IFDEF CONDITIONALEXPRESSIONS}{$IF CompilerVersion >= 33.00} // 33 == DX 10.3 Rio; 24 == XE3
  // http://docwiki.embarcadero.com/RADStudio/Rio/en/Warning_messages_(Delphi)

  {$WARN IMPLICIT_INTEGER_CAST_LOSS OFF}  // W1071
  {$WARN IMPLICIT_CONVERSION_LOSS OFF}    // W1072

  {$WARN EXPLICIT_STRING_CAST OFF}      // W1059

  {$WARN UNSAFE_TYPE OFF} // W1046
  {$WARN UNSAFE_CODE OFF} // W1047
  {$WARN UNSAFE_CAST OFF} // W1048

{$IFEND}{$ENDIF CONDITIONALEXPRESSIONS}
{+.}
