unit uConst;

interface

const
  //protocol name : two char or more
  DAPP_PROTOCOL: string = 'mz';
  //port of devtool
  DAPP_DEV_PORT: Integer = 9080;
  //external Object Name for window
  DAPP_EXTERNAL: string = 'external';

function getAppPath(PathName: string): string;

implementation

function getAppPath(PathName: string): string;
begin
  result := DAPP_PROTOCOL + '://' + PathName + '/'
end;

end.

