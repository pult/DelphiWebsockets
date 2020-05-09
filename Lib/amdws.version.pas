unit amdws.version;
// AndreMussche: DelphiWebsockets
// fork from: https://github.com/andremussche/DelphiWebsockets

interface
{-I amdws.wsdefines.inc}

const
  amdws_version = 201908151937; // == yyyymmddhhnn
  {$EXTERNALSYM amdws_version}
  (*
  // Sample for checking module version ("amdws.version.pas")":
  // <sample>
  {$warn comparison_true off}
  {$if (not declared(amdws_version)) or (amdws_version < 201908151937)}
    //{$warn message_directive on}{$MESSAGE WARN 'Need update library "AndreMussche: DelphiWebsockets"'}
    {$MESSAGE FATAL 'Need update library "AndreMussche: DelphiWebsockets"'}
  {$ifend}{$warnings on}
  // <\sample>
  //*)

implementation

end.
