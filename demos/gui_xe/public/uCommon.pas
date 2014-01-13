unit uCommon;

interface

function StrToCase(StringOf: string; CasesList: array of string): Integer;

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

end.
