unit uCommon;

interface

uses Graphics, Classes;

function StrToCase(StringOf: string; CasesList: array of string): Integer;
//convert htmlcolor
function HtmlToColor(sColor: string): TColor;

implementation

uses SysUtils;

function StrToCase(StringOf: string; CasesList: array of string): Integer;
var
   Idx: integer;
begin
   Result := -1;
   for Idx := 0 to Length(CasesList) - 1 do
      begin
         if CompareText(StringOf, CasesList[Idx]) = 0 then
            begin
               Result := Idx;
               Break;
            end;
      end;
end;


function HtmlToColor(sColor: string): TColor;
var
  i,len : integer;
  function RGB(r, g, b: Byte): TColor;
  begin
    Result := (r or (g shl 8) or (b shl 16));
  end;
begin
  sColor := Trim(sColor);
  if sColor[1]= '#' then Delete(sColor, 1, 1);
  len := Length(sColor);
  //short color:length=3
  if len=3 then
  begin
    sColor := sColor + sColor[1] + sColor[2] + sColor[3];
  end
  else
  begin
    for i := len to 6 do  sColor := sColor + '0';
  end;
  try
    Result :=
    RGB(
      StrToInt(#36 + Copy(sColor, 1, 2)),
      StrToInt(#36 + Copy(sColor, 3, 2)),
      StrToInt(#36 + Copy(sColor, 5, 2))
    );
  except
    Result := 0;
  end;
end;

end.
