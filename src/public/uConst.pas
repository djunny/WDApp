unit uConst;

interface

const
  //protocol name : two char or more
  TDAPP_PROTOCOL: string = 'mz';
  //port of devtool
  TDAPP_DEV_PORT: Integer = 9080;
  //external Object Name for window
  TDAPP_EXTERNAL: string = 'external';

function getAppPath(PathName: string): string;

implementation

function getAppPath(PathName: string): string;
begin
  result := TDAPP_PROTOCOL + '://' + PathName + '/'
end;

end.

