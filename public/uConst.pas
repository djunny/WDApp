unit uConst;

interface

const
  //protocol name : two char or more
  WDAPP_PROTOCOL: string = 'mz';
  //port of devtool
  WDAPP_DEV_PORT: Integer = 9080;
  //external Object Name for window
  WDAPP_EXTERNAL: string = 'external';

var
  //store data path
  WDAPP_DATAPATH : string = 'data';

function getAppPath(PathName: string): string;

implementation

uses windows, SysUtils;

function getAppPath(PathName: string): string;
begin
  result := WDAPP_PROTOCOL + '://' + PathName + '/'
end;

function getDataPath:string;
var
  tmp : array[0..255] of char;
begin
  GetCurrentDirectory(Length(tmp), @tmp);
  result := ExpandFileName(String(tmp) + '/'+WDAPP_DATAPATH + '/');
end;


initialization
  WDAPP_DATAPATH := getDataPath;
  if not DirectoryExists(WDAPP_DATAPATH) then
    ForceDirectories(WDAPP_DATAPATH);
  if not DirectoryExists(WDAPP_DATAPATH + 'cache/') then
    ForceDirectories(WDAPP_DATAPATH+ 'cache/');

finalization

end.

