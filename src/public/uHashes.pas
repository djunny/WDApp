unit uHashes;

interface 
 
  uses SysUtils;
 
  const 
    {** This constant controls the initial size of the hash. }
    c_HashInitialItemShift = 7;

    {** How inefficient do we have to be before we automatically Compact? }
    c_HashCompactR         = 2;   { This many spaces per item. }
    c_HashCompactM         = 100; { Never for less than this number of spaces. }

type
    {** General exception classes. } 
    EHashError = class(Exception);
{    EHashErrorClass = class of EHashError;} 
 
    {** Exception for when an item is not found. } 
    EHashFindError = class(EHashError); 

    {** Exception for invalid Next op. } 
    EHashIterateError = class(EHashError); 
 
    {** Exception for invalid keys. } 
    EHashInvalidKeyError = class(EHashError); 
 
    {** Record, should really be private but OP won't let us... } 
    THashRecord = record 
      Hash: Cardinal; 
      ItemIndex: integer; 
      Key: string; 
    end; 
 
    {** Iterator Record. This should also be private. This makes me almost like 
        the way Java does things. Almost. Maybe. } 
    THashIterator = record 
      ck, cx: integer; 
    end; 
 
    {** Base Hash class. Don't use this directly. } 
    THash = class
      protected 
        {** The keys. } 
        f_Keys: array of array of THashRecord; 
 
        {** Current bucket shift. } 
        f_CurrentItemShift: integer; 
 
        {** These are calculated from f_CurrentItemShift. } 
        f_CurrentItemCount: integer; 
        f_CurrentItemMask: integer; 
        f_CurrentItemMaxIdx: integer; 
 
        {** Spare items. } 
        f_SpareItems: array of integer; 
 
        {** Whether Next is allowed. } 
        f_NextAllowed: boolean; 
 
        {** Current key. } 
        f_CurrentKey: string; 
 
        {** Can we compact? } 
        f_AllowCompact: boolean; 
 
        {** Our current iterator. } 
        f_CurrentIterator: THashIterator;

        FUseExceptions : boolean;
        FIgnoreCase    : boolean;
 
        {** Update the masks. } 
        procedure FUpdateMasks; 
 
        {** Update the buckets. } 
        procedure FUpdateBuckets; 
 
        {** Find a key's location. } 
        function FFindKey(const Key: string; var k, x: integer): boolean; 
 
        {** Add a new key, or change an existing one. Don't call this directly. } 
        procedure FSetOrAddKey(const Key: string; ItemIndex: integer); 
 
        {** Abstract method, delete value with a given index. Override this. } 
        procedure FDeleteIndex(i: integer); virtual; abstract; 
 
        {** Get the number of items. } 
        function FGetItemCount: integer; 
 
        {** Allocate an item index. } 
        function FAllocItemIndex: integer; 
 
        {** Abstract method, move an item with index OldIndex to NewIndex. 
            Override this. } 
        procedure FMoveIndex(oldIndex, newIndex: integer); virtual; abstract; 
 
        {** Abstract method, trim the indexes down to count items. Override 
            this. } 
        procedure FTrimIndexes(count: integer); virtual; abstract; 
 
        {** Abstract method, clear all items. Override this. } 
        procedure FClearItems; virtual; abstract; 
 
        {** Tell us where to start our compact count from. Override this. } 
        function FIndexMax: integer; virtual; abstract; 
 
        {** Compact, but only if we're inefficient. } 
        procedure FAutoCompact; 
 
      public 
        {** Our own constructor. } 
        constructor Create(ignoreCase : boolean = true); reintroduce; virtual;

        destructor Destroy; override;
 
        {** Does a key exist? } 
        function Exists(const Key: string): boolean; 
 
        {** Rename a key. } 
        function Rename(const Key, NewName: string):boolean;
 
        {** Delete a key. } 
        function Delete(const Key: string):boolean;
 
        {** Reset iterator. } 
        procedure Restart; 
 
        {** Next key. } 
        function Next: boolean; 
 
        {** Previous key. } 
        function Previous: boolean; 
 
        {** Current key. }
        function CurrentKey: string;


 
        {** The number of items. } 
        property ItemCount: integer read FGetItemCount;
 
        {** Compact the hash. } 
        procedure Compact; 
 
        {** Clear the hash. } 
        procedure Clear; 
 
        {** Allow compacting? } 
        property AllowCompact: boolean read f_AllowCompact write f_AllowCompact; 
 
        {** Current iterator. } 
        property CurrentIterator: THashIterator read f_CurrentIterator write 
          f_CurrentIterator; 
 
        {** Create a new iterator. } 
        function NewIterator: THashIterator;

        //add by djunny
        property Key: string read CurrentKey;

        property IgnoreCase : boolean read FIgnoreCase;
 
    end; 
 
    {** Hash of strings. } 
    TStringHash = class(THash)
      protected 
        {** The index items. } 
        f_Items: array of string; 
 
        {** Override FDeleteIndex abstract method. } 
        procedure FDeleteIndex(i: integer); override; 

        {** Get an item or raise an exception. }
        function FGetItem(const Key: string): string;

        {** Set or add an item. }
        procedure FSetItem(const Key, Value: string);
 
        {** Move an index. } 
        procedure FMoveIndex(oldIndex, newIndex: integer); override; 
 
        {** Trim. } 
        procedure FTrimIndexes(count: integer); override; 
 
        {** Clear all items. } 
        procedure FClearItems; override; 
 
        {** Where to start our compact count from. } 
        function FIndexMax: integer; override; 
        {** Get an item or raise an exception. }
        function FGetValue(): string;

        {** Set or add an item. }
        procedure FSetValue(const Value: string);


        {** Get an integer item or raise an exception. }
        function  FGetInteger(const Key: string): integer;

        {** Set or add an integer item. }
        procedure FSetInteger(const Key: string; const Value: integer);

        {** Get an float item or raise an exception. }
        function  FGetFloat(const Key: string): double;

        {** Set or add an float item. }
        procedure FSetFloat(const Key: string; const Value: double);

        {** Get an boolean item or raise an exception. }
        function  FGetBoolean(const Key: string): boolean;

        {** Set or add an boolean item. }
        procedure FSetBoolean(const Key: string; const Value: boolean);

        {** Get an object item or raise an exception. }
        function  FGetObject(const Key : string): TObject;

        {** Set or add an object item. }
        procedure FSetObject(const Key : string; const Value: TObject);

      public
        //add by djunny get defaultvalue
        property Value : string read FGetValue Write FSetValue;
        {** Items property. }
        property Items[const Key: string]: string read FGetItem
          write FSetItem; default;

        {** Integer items property. }
        property Integers[const Key: string]: integer read FGetInteger write FSetInteger;

        {** Float items property. }
        property Floats[const Key: string]: double read FGetFloat write FSetFloat;

        {** Boolean items property. }
        property Booleans[const Key: string]: boolean read FGetBoolean write FSetBoolean;

        {** Object items property. }
        property Objects[const Key: string]: TObject read FGetObject write FSetObject;

    end; 
 
    {** Hash of integers. } 
    TIntegerHash = class(THash)
      protected 
        {** The index items. } 
        f_Items: array of integer; 
 
        {** Override FDeleteIndex abstract method. } 
        procedure FDeleteIndex(i: integer); override; 
 
        {** Get an item or raise an exception. } 
        function FGetItem(const Key: string): integer; 
 
        {** Set or add an item. } 
        procedure FSetItem(const Key: string; Value: integer); 
 
        {** Move an index. } 
        procedure FMoveIndex(oldIndex, newIndex: integer); override; 
 
        {** Trim. } 
        procedure FTrimIndexes(count: integer); override; 
 
        {** Clear all items. } 
        procedure FClearItems; override; 
 
        {** Where to start our compact count from. } 
        function FIndexMax: integer; override;


        procedure FSetValue(const Value: Integer);
        function  FGetValue(): Integer;
 
      public
        //add by djunny get defaultvalue
        property Value : Integer read FGetValue Write FSetValue;

        {** Items property. } 
        property Items[const Key: string]: integer read FGetItem 
          write FSetItem; default;
    end; 
 
    {** Hash of objects. } 
    TObjectHash = class(THash) 
      protected 
        {** The index items. } 
        f_Items: array of TObject; 
 
        {** Override FDeleteIndex abstract method. } 
        procedure FDeleteIndex(i: integer); override; 
 
        {** Get an item or raise an exception. } 
        function FGetItem(const Key: string): TObject; 
 
        {** Set or add an item. } 
        procedure FSetItem(const Key: string; Value: TObject); 
 
        {** Move an index. } 
        procedure FMoveIndex(oldIndex, newIndex: integer); override; 
 
        {** Trim. } 
        procedure FTrimIndexes(count: integer); override; 
 
        {** Clear all items. } 
        procedure FClearItems; override; 
 
        {** Where to start our compact count from. } 
        function FIndexMax: integer; override; 

        procedure FSetValue(const Value: TObject);
        function  FGetValue(): TObject;

      public
        //add by djunny get defaultvalue
        property Value : TObject read FGetValue Write FSetValue;

        {** Items property. }
        property Items[const Key: string]: TObject read FGetItem
          write FSetItem; default;


        {** Destructor must destroy all items. } 
        destructor Destroy; override; 

    end;
    //
    TInfo        = class(TStringHash);

function HashThis(data: pointer; dataLength: integer): cardinal;overload;
function HashThis(const key: string; ignoreCase : boolean): cardinal; overload;
function serialize(Info:TStringHash;utf8:boolean=false):string;
procedure unserialize(info:TStringHash;source:ansistring;overwrite:boolean=false);

procedure CopyFromInfo(FromInfo,ToInfo:TInfo);

implementation

//uses idhash;
procedure CopyFromInfo(FromInfo,ToInfo:TInfo);
begin
  FromInfo.Restart;
  while FromInfo.Next do
  begin
    ToInfo[FromInfo.Key] := FromInfo.Value;
  end;
end;

function countlength(s:string;utf8:boolean):integer;
var
  k : integer;
  c : char;
begin
  result := 0;
  for c in s do
  begin
    k := ord(c);
    if k>255 then
    begin
      if utf8 then
        inc(result, 3)
      else
        inc(result, 2);
    end
    else inc(result);
  end;
end;

function serialize(Info:TStringHash;utf8:boolean=false):string;
begin
  Result := 's:0:"";';
  if Info = Nil then exit;
  Info.Restart;
  Result := 'a:'+Inttostr(Info.ItemCount)+':{';
  while Info.Next do
  begin
     Result := Result + 's:'+inttostr(countlength(Info.key, utf8))+':"'+Info.key+'";s:'+
                inttostr(countlength(Info.Value, utf8))+':"'+Info.Value+'";';
  end;
  Result := Result +'}';
end;

procedure unserialize(info:TStringHash;source:ansistring;overwrite:boolean=false);
var
  len     : integer;
  idx,i,l : integer;
  key,val : string;
  error   : boolean;
  function getquotval:string;
  begin
    //去除：s:或i:
    source:= copy(source, 3, MAXINT);
    //取长度
    idx   := pos(':', source);
    len   := strtointdef(copy(source, 1, idx-1), 0);
    //取到错误的
    if len=0 then
    begin
      error := true;
      exit;
    end;
    //inc(i, 3+idx);
    //去掉长度信息
    delete(source, 1, idx);
    if source[1]='"' then
    begin
      //修正utf8编码
      if(copy(source, len+2, 2)<>'";')then
      begin
        len    := pos('";', source)+1;
        Result := copy(source, 2, len-2);
      end
      else begin
        result := copy(source, 2, len);
        inc(len, 2);
      end;
    end
    else begin
      if(copy(source, len+1, 1)<>';')then
      begin
        len    := pos(';', source);
        Result := copy(source, 2, -1);
      end
      else begin
        result := copy(source, 1, len);
      end;
    end;
    //inc(i, len);
    //去掉 ;
    source:= copy(source, len+2, MAXINT);
  end;
begin
  if overwrite then info.Clear;
  error  := false;
  l      := length(source);
  i      := 1;
  //去掉a:N:{(xxxx)}留下(xxxx)
  idx    := pos('{', source);
  l      := l-idx-1;
  source := copy(source, idx+1, l);
  while source<>'' do
  begin
     key   := getquotval;
     val   := getquotval;
     if error then exit;
     Info[key] := val;
  end;
end;
{
function HashOf(const Key: string): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(Key) do
    Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor
      Ord(Key[I]);

  result := result mod hashSize
end;
}
{** A basic hash function. This is pretty fast, and fairly good general
    purpose, but you may want to swap in a specialised version. }
{
function HashThis(const text: string): cardinal;
var
  h, g, i: cardinal;
begin
  if (text = '') then
  begin
    result := 0;
    //raise EHashInvalidKeyError.Create('Key cannot be an empty string');
    exit;
  end;
    //
  h := $12345670;
  for i := 1 to Length(text) do begin
    h := (h shl 4) + ord(text[i]);
    g := h and $f0000000;
    if (g > 0) then
      h := h or (g shr 24) or g;
  end;
  result := h;
end;
}
{
function HashThis(const text: string): cardinal;

  function SubHash(P: PCardinal): cardinal;
  var
    s1,s2: cardinal;
    i, L: Cardinal;
  const
    Mask: array[0..3] of cardinal = (0,$ff,$ffff,$ffffff);
  begin
    if P<>nil then
    begin
      L := PCardinal(Cardinal(P)-4)^; // fast lenght(Text)
      s1 := 0;
      s2 := 0;
      for i := 1 to L shr 4 do
      begin
        // 16 bytes (4 DWORD) by loop - aligned read
        inc(s1,P^);
        inc(s2,s1);
        inc(P);
        inc(s1,P^);
        inc(s2,s1);
        inc(P);
        inc(s1,P^);
        inc(s2,s1);
        inc(P);
        inc(s1,P^);
        inc(s2,s1);
        inc(P);
      end;
      for i := 1 to (L shr 2)and 3 do
      begin
        // 4 bytes (DWORD) by loop
        inc(s1,P^);
        inc(s2,s1);
        inc(P);
      end;
      inc(s1,P^ and Mask[L and 3]);      // remaining 0..3 bytes
      inc(s2,s1);
      result := s1 xor (s2 shl 16);
    end
    else result := 0;
  end;

begin
  // use a sub function for better code generation under Delphi
  result := SubHash(@Text[1]);
end;
}


function HashThis(data: pointer; dataLength: integer): cardinal;
// Pascal translation of the SuperFastHash function by Paul Hsieh
// more info: http://www.azillionmonkeys.com/qed/hash.html
// Translation by: Davy Landman
// No warranties, but have fun :)
var
  TempPart: longword;
  RemainingBytes: integer;
begin
  if not Assigned(data) or (dataLength <= 0) then
  begin
    Result := 0;
    Exit;
  end;
  Result := dataLength;
  RemainingBytes := dataLength and 3;
  dataLength := dataLength shr 2; // div 4, so var name is not correct anymore..
  // main loop
  while dataLength > 0 do
  begin
    inc(Result, PWord(data)^);
    TempPart := (PWord(Pointer(NativeInt(data)+2))^ shl 11) xor Result;
    Result := (Result shl 16) xor TempPart;
    data := Pointer(NativeInt(data) + 4);
    inc(Result, Result shr 11);
    dec(dataLength);
  end;
  // end case
  if RemainingBytes = 3 then
  begin
    inc(Result, PWord(data)^);
    Result := Result xor (Result shl 16);
    Result := Result xor (PByte(Pointer(NativeInt(data)+2))^ shl 18);
    inc(Result, Result shr 11);
  end
  else if RemainingBytes = 2 then
  begin
    inc(Result, PWord(data)^);
    Result := Result xor (Result shl 11);
    inc(Result, Result shr 17);
  end
  else if RemainingBytes = 1 then
  begin
    inc(Result, PByte(data)^);
    Result := Result xor (Result shl 10);
    inc(Result, Result shr 1);
  end;
  // avalance
  Result := Result xor (Result shl 3);
  inc(Result, Result shr 5);
  Result := Result xor (Result shl 4);
  inc(Result, Result shr 17);
  Result := Result xor (Result shl 25);
  inc(Result, Result shr 6);
end; { HashOf }

function HashThis(const key: string;ignoreCase :boolean): cardinal;
var skey : string;
begin
  if Length(key) = 0 then
    Result := 0
  else begin
    //ignore case
    skey   := LowerCase(key);
    Result := HashThis(@skey[1], Length(skey) * SizeOf(Char));
  end;
end; { HashOf }
 
{ THash } 
 
constructor THash.Create(ignoreCase : boolean = true);
begin 
  inherited Create;
  self.f_CurrentIterator.ck := -1;
  self.f_CurrentIterator.cx := 0;
  self.f_CurrentItemShift := c_HashInitialItemShift;
  self.FUpdateMasks;
  self.FUpdateBuckets;
  self.f_AllowCompact := true;
  self.FUseExceptions := false;
  self.FIgnoreCase    := ignoreCase;
end;

destructor THash.Destroy;
begin
  inherited;
end;
 
function THash.Delete(const Key: string):boolean;
var 
  k, x, i: integer; 
begin
  result := true;
  { Hash has been modified, so disallow Next. } 
  self.f_NextAllowed := false; 
  if (self.FFindKey(Key, k, x)) then begin 
    { Delete the Index entry. } 
    i := self.f_Keys[k][x].ItemIndex;
    try
      self.FDeleteIndex(i);
    except
    end;
    { Add the index to the Spares list. }
    SetLength(self.f_SpareItems, Length(self.f_SpareItems) + 1); 
    self.f_SpareItems[High(self.f_SpareItems)] := i; 
    { Overwrite key with the last in the list. } 
    self.f_Keys[k][x] := self.f_Keys[k][High(self.f_Keys[k])]; 
    { Delete the last in the list. } 
    SetLength(self.f_Keys[k], Length(self.f_Keys[k]) - 1); 
  end else
    result := false;
 
  self.FAutoCompact; 
end; 
 
function THash.Exists(const Key: string): boolean; 
var 
  dummy1, dummy2: integer; 
begin 
  result := FFindKey(Key, dummy1, dummy2); 
end; 
 
procedure THash.FSetOrAddKey(const Key: string; ItemIndex: integer); 
var 
  k, x, i: integer; 
begin 
  { Exists already? } 
  if (self.FFindKey(Key, k, x)) then begin 
    { Yep. Delete the old stuff and set the new value. } 
    i := self.f_Keys[k][x].ItemIndex; 
    self.FDeleteIndex(i); 
    self.f_Keys[k][x].ItemIndex := ItemIndex; 
    { Add the index to the spares list. } 
    SetLength(self.f_SpareItems, Length(self.f_SpareItems) + 1); 
    self.f_SpareItems[High(self.f_SpareItems)] := i; 
  end else begin 
    { No, create a new one. } 
    SetLength(self.f_Keys[k], Length(self.f_Keys[k]) + 1); 
    self.f_Keys[k][High(self.f_Keys[k])].Key := Key; 
    self.f_Keys[k][High(self.f_Keys[k])].ItemIndex := ItemIndex; 
    self.f_Keys[k][High(self.f_Keys[k])].Hash := HashThis(Key, IgnoreCase);
  end; 
end; 
 
function THash.FFindKey(const Key: string; var k, x: integer): boolean;
var 
  i: integer; 
  h: cardinal; 
begin 
  { Which bucket? }
  result := false;
  h := HashThis(Key, IgnoreCase);
  if h=0 then exit;

  k := h and f_CurrentItemMask;
  { Look for it. } 
  for i := 0 to High(self.f_Keys[k]) do 
    if (self.f_Keys[k][i].Hash = h) or true then
      if((IgnoreCase)AND(CompareText(self.f_Keys[k][i].Key, Key)=0))
        OR((not IgnoreCase)AND(self.f_Keys[k][i].Key = Key)) then begin
        { Found it! } 
        result := true; 
        x := i; 
        break; 
      end; 
end; 
 
function  THash.Rename(const Key, NewName: string):boolean;
var 
  k, x, i: integer; 
begin
  result := true;
  { Hash has been modified, so disallow Next. } 
  self.f_NextAllowed := false; 
  if (self.FFindKey(Key, k, x)) then begin 
    { Remember the ItemIndex. } 
    i := self.f_Keys[k][x].ItemIndex; 
    { Overwrite key with the last in the list. } 
    self.f_Keys[k][x] := self.f_Keys[k][High(self.f_Keys[k])]; 
    { Delete the last in the list. } 
    SetLength(self.f_Keys[k], Length(self.f_Keys[k]) - 1); 
    { Create the new item. } 
    self.FSetOrAddKey(NewName, i); 
  end else 
    result := false;
 
  self.FAutoCompact; 
end; 
 
function THash.CurrentKey: string;
begin 
  if (not (self.f_NextAllowed)) then 
    //raise EHashIterateError.Create('Cannot find CurrentKey as the hash has '
      //+ 'been modified since Restart was called')
    result := ''
  else if (self.f_CurrentKey = '') then
    result := ''
    //raise EHashIterateError.Create('Cannot find CurrentKey as Next has not yet '
      //+ 'been called after Restart')
  else 
    result := self.f_CurrentKey; 
end; 
 
function THash.Next: boolean;
begin
  if (not (self.f_NextAllowed)) then
  begin
    result := false;
    exit;
    //raise EHashIterateError.Create('Cannot get Next as the hash has '
      //+ 'been modified since Restart was called');
  end;
  result := false;
  if (self.f_CurrentIterator.ck = -1) then begin
    self.f_CurrentIterator.ck := 0;
    self.f_CurrentIterator.cx := 0;
  end;
  while ((not result) and (self.f_CurrentIterator.ck <= f_CurrentItemMaxIdx)) do begin
    if (self.f_CurrentIterator.cx < Length(self.f_Keys[self.f_CurrentIterator.ck])) then begin
      result := true;
      self.f_CurrentKey := self.f_Keys[self.f_CurrentIterator.ck][self.f_CurrentIterator.cx].Key;
      inc(self.f_CurrentIterator.cx);
    end else begin
      inc(self.f_CurrentIterator.ck);
      self.f_CurrentIterator.cx := 0;
    end;
  end;
end;


 
procedure THash.Restart; 
begin 
  self.f_CurrentIterator.ck := -1; 
  self.f_CurrentIterator.cx := 0; 
  self.f_NextAllowed := true; 
end; 
 
function THash.FGetItemCount: integer; 
var 
  i: integer; 
begin 
  { Calculate our item count. } 
  result := 0; 
  for i := 0 to f_CurrentItemMaxIdx do 
    inc(result, Length(self.f_Keys[i])); 
end; 
 
function THash.FAllocItemIndex: integer; 
begin 
  if (Length(self.f_SpareItems) > 0) then begin 
    { Use the top SpareItem. } 
    result := self.f_SpareItems[High(self.f_SpareItems)]; 
    SetLength(self.f_SpareItems, Length(self.f_SpareItems) - 1); 
  end else begin 
    result := self.FIndexMax + 1; 
  end; 
end; 
 procedure THash.Compact;
var
  aSpaces: array of boolean;
  aMapping: array of integer;
  i, j: integer;
begin
  { Find out where the gaps are. We could do this by sorting, but that's at
    least O(n log n), and sometimes O(n^2), so we'll go for the O(n) method,
    even though it involves multiple passes. Note that this is a lot faster
    than it looks. Disabling this saves about 3% in my benchmarks, but uses a
    lot more memory. }
  if (self.AllowCompact) then begin
    SetLength(aSpaces, self.FIndexMax + 1);
    SetLength(aMapping, self.FIndexMax + 1);
    for i := 0 to High(aSpaces) do
      aSpaces[i] := false;
    for i := 0 to High(aMapping) do
      aMapping[i] := i;
    for i := 0 to High(self.f_SpareItems
    ) do
      aSpaces[self.f_SpareItems[i]] := true;

    { Starting at the low indexes, fill empty ones from the high indexes. }
    i := 0;
    j := self.FIndexMax;
    while (i < j) do begin
      if (aSpaces[i]) then begin
        while ((i < j) and (aSpaces[j])) do
          dec(j);
        if (i < j) then begin
          aSpaces[i] := false;
          aSpaces[j] := true;
          self.FMoveIndex(j, i);
          aMapping[j] := i
        end;
      end else
        inc(i);
    end;

    j := self.FIndexMax;
    while (aSpaces[j]) do
      dec(j);

    { Trim the items array down to size. }
    self.FTrimIndexes(j + 1);

    { Clear the spaces. }
    SetLength(self.f_SpareItems, 0);

    { Update our buckets. }
    for i := 0 to f_CurrentItemMaxIdx do
      for j := 0 to High(self.f_Keys[i]) do
        self.f_Keys[i][j].ItemIndex := aMapping[self.f_Keys[i][j].ItemIndex];
  end;
end;


 
procedure THash.FAutoCompact; 
begin 
  if (self.AllowCompact) then 
    if (Length(self.f_SpareItems) >= c_HashCompactM) then
      if (self.FIndexMax * c_HashCompactR > Length(self.f_SpareItems)) then 
        self.Compact; 
end; 
 
procedure THash.Clear; 
var 
  i: integer; 
begin 
  self.FClearItems; 
  SetLength(self.f_SpareItems, 0); 
  for i := 0 to f_CurrentItemMaxIdx do 
    SetLength(self.f_Keys[i], 0); 
end; 
 
procedure THash.FUpdateMasks; 
begin 
  f_CurrentItemMask := (1 shl f_CurrentItemShift) - 1; 
  f_CurrentItemMaxIdx := (1 shl f_CurrentItemShift) - 1; 
  f_CurrentItemCount := (1 shl f_CurrentItemShift); 
end; 
 
procedure THash.FUpdateBuckets; 
begin 
  { This is just a temporary thing. } 
  SetLength(self.f_Keys, self.f_CurrentItemCount); 
end; 
 
function THash.NewIterator: THashIterator; 
begin 
  result.ck := -1; 
  result.cx := 0; 
end; 
 
function THash.Previous: boolean; 
begin 
  if (not (self.f_NextAllowed)) then 
    raise EHashIterateError.Create('Cannot get Next as the hash has ' 
      + 'been modified since Restart was called'); 
  result := false; 
  if (self.f_CurrentIterator.ck >= 0) then begin 
    while ((not result) and (self.f_CurrentIterator.ck >= 0)) do begin 
      dec(self.f_CurrentIterator.cx); 
      if (self.f_CurrentIterator.cx >= 0) then begin 
        result := true; 
        self.f_CurrentKey := self.f_Keys[self.f_CurrentIterator.ck][self.f_CurrentIterator.cx].Key; 
      end else begin 
        dec(self.f_CurrentIterator.ck); 
        if (self.f_CurrentIterator.ck >= 0) then 
          self.f_CurrentIterator.cx := Length(self.f_Keys[self.f_CurrentIterator.ck]);
      end; 
    end; 
  end; 
end;
 
{ TStringHash }


function TStringHash.FGetValue(): string;
begin
  Result := FGetItem(f_CurrentKey);
end;

{** Set or add an item. }
procedure TStringHash.FSetValue(const Value: string);
begin
  FSetItem(f_CurrentKey, value);
end;


procedure TStringHash.FDeleteIndex(i: integer);
begin 
  self.f_Items[i] := ''; 
end; 
 
function TStringHash.FGetItem(const Key: string): string; 
var 
  k, x: integer; 
begin 
  if (self.FFindKey(Key, k, x)) then 
    result := self.f_Items[self.f_Keys[k][x].ItemIndex] 
  else 
    result := '';
end;



function  TStringHash.FGetInteger(const Key: string): integer;
begin
  if (FUseExceptions) then
    result := StrToInt(self[Key])
  else
    result := StrToIntDef(self[Key], 0);
end;


procedure TStringHash.FSetInteger(const Key: string; const Value: integer);
begin
  FSetItem(Key, IntToStr(Value));
end;


function  TStringHash.FGetFloat(const Key: string): double;
begin
  if (FUseExceptions) then
    result := StrToFloat(FGetItem(Key))
  else
    try
      result := StrToFloat(FGetItem(Key));
    except
      result := 0;
    end;
end;


procedure TStringHash.FSetFloat(const Key: string; const Value: double);
begin
  FSetItem(Key, FloatToStr(Value));
end;


function  TStringHash.FGetBoolean(const Key: string): boolean;
begin
  if (FUseExceptions) then
    result := boolean(StrToInt(FGetItem(Key)))
  else
    result := boolean(StrToIntDef(FGetItem(Key), 0));
end;


procedure TStringHash.FSetBoolean(const Key: string; const Value: boolean);
begin
  FSetItem(Key, IntToStr(integer(Value)));
end;


function  TStringHash.FGetObject(const Key: string): TObject;
var tmp : ^pointer;
    s   : string;
begin
  { string -> object conversion }
  s := FGetItem(Key) + #0#0#0#0;
  tmp := @s[1];
  result := tmp^;
end;


procedure TStringHash.FSetObject(const Key: string; const Value: TObject);
var tmp : ^pointer;
    s   : string;
begin
  { object -> string conversion }
  setlength(s, 4);
  tmp := @s[1];
  tmp^ := Value;
  FSetItem(Key, s);
end;


 
procedure TStringHash.FMoveIndex(oldIndex, newIndex: integer); 
begin 
  self.f_Items[newIndex] := self.f_Items[oldIndex]; 
end; 
 
procedure TStringHash.FSetItem(const Key, Value: string);
var
  k, x, i: integer;
begin
  if (self.FFindKey(Key, k, x)) then
    self.f_Items[self.f_Keys[k][x].ItemIndex] := Value
  else begin
    { New index entry, or recycle an old one. }
    i := self.FAllocItemIndex;
    if (i > High(self.f_Items)) then
      SetLength(self.f_Items, i + 1);
    self.f_Items[i] := Value;
    { Add it to the hash. }
    SetLength(self.f_Keys[k], Length(self.f_Keys[k]) + 1);
    self.f_Keys[k][High(self.f_Keys[k])].Key := Key;
    self.f_Keys[k][High(self.f_Keys[k])].ItemIndex := i;
    self.f_Keys[k][High(self.f_Keys[k])].Hash := HashThis(Key, IgnoreCase);
    { Hash has been modified, so disallow Next. }
    self.f_NextAllowed := false;
  end;
end; 
 
function TStringHash.FIndexMax: integer; 
begin 
  result := High(self.f_Items); 
end; 
 
procedure TStringHash.FTrimIndexes(count: integer); 
begin 
  SetLength(self.f_Items, count); 
end; 
 
procedure TStringHash.FClearItems; 
begin 
  SetLength(self.f_Items, 0); 
end; 
 
{ TIntegerHash }



function TIntegerHash.FGetValue(): Integer;
begin
  Result := FGetItem(f_CurrentKey);
end;

{** Set or add an item. }
procedure TIntegerHash.FSetValue(const Value: Integer);
begin
  FSetItem(f_CurrentKey, value);
end;
 
procedure TIntegerHash.FDeleteIndex(i: integer); 
begin 
  self.f_Items[i] := 0; 
end; 
 
function TIntegerHash.FGetItem(const Key: string): integer; 
var 
  k, x: integer; 
begin 
  if (self.FFindKey(Key, k, x)) then 
    result := self.f_Items[self.f_Keys[k][x].ItemIndex] 
  else 
    result := -1;
end; 
 
procedure TIntegerHash.FMoveIndex(oldIndex, newIndex: integer); 
begin 
  self.f_Items[newIndex] := self.f_Items[oldIndex]; 
end; 
 
procedure TIntegerHash.FSetItem(const Key: string; Value: integer); 
var 
  k, x, i: integer; 
begin 
  if (self.FFindKey(Key, k, x)) then 
    self.f_Items[self.f_Keys[k][x].ItemIndex] := Value 
  else begin 
    { New index entry, or recycle an old one. } 
    i := self.FAllocItemIndex; 
    if (i > High(self.f_Items)) then 
      SetLength(self.f_Items, i + 1); 
    self.f_Items[i] := Value; 
    { Add it to the hash. } 
    SetLength(self.f_Keys[k], Length(self.f_Keys[k]) + 1); 
    self.f_Keys[k][High(self.f_Keys[k])].Key := Key; 
    self.f_Keys[k][High(self.f_Keys[k])].ItemIndex := i; 
    self.f_Keys[k][High(self.f_Keys[k])].Hash := HashThis(Key, IgnoreCase);
    { Hash has been modified, so disallow Next. } 
    self.f_NextAllowed := false; 
  end; 
end; 
 
function TIntegerHash.FIndexMax: integer; 
begin 
  result := High(self.f_Items); 
end; 
 
procedure TIntegerHash.FTrimIndexes(count: integer); 
begin 
  SetLength(self.f_Items, count); 
end; 
 
procedure TIntegerHash.FClearItems; 
begin 
  SetLength(self.f_Items, 0); 
end; 
 
{ TObjectHash } 

function TObjectHash.FGetValue(): Tobject;
begin
  Result := FGetItem(f_CurrentKey);
end;

{** Set or add an item. }
procedure TObjectHash.FSetValue(const Value: Tobject);
begin
  FSetItem(f_CurrentKey, value);
end;

procedure TObjectHash.FDeleteIndex(i: integer); 
begin    
  if(assigned(self.f_Items[i]))AND(self.f_Items[i]<>Nil) then
    try
        FreeAndNil(self.f_Items[i]);
    except
    end;
end;

 
function TObjectHash.FGetItem(const Key: string): TObject; 
var 
  k, x: integer; 
begin 
  if (self.FFindKey(Key, k, x)) then 
    result := self.f_Items[self.f_Keys[k][x].ItemIndex] 
  else 
    Result := Nil;
end; 
 
procedure TObjectHash.FMoveIndex(oldIndex, newIndex: integer); 
begin 
  self.f_Items[newIndex] := self.f_Items[oldIndex]; 
end; 
 
procedure TObjectHash.FSetItem(const Key: string; Value: TObject); 
var 
  k, x, i: integer; 
begin 
  if (self.FFindKey(Key, k, x)) then begin 
    self.f_Items[self.f_Keys[k][x].ItemIndex].Free; 
    self.f_Items[self.f_Keys[k][x].ItemIndex] := Value; 
  end else begin 
    { New index entry, or recycle an old one. } 
    i := self.FAllocItemIndex; 
    if (i > High(self.f_Items)) then 
      SetLength(self.f_Items, i + 1); 
    self.f_Items[i] := Value; 
    { Add it to the hash. } 
    SetLength(self.f_Keys[k], Length(self.f_Keys[k]) + 1); 
    self.f_Keys[k][High(self.f_Keys[k])].Key := Key; 
    self.f_Keys[k][High(self.f_Keys[k])].ItemIndex := i; 
    self.f_Keys[k][High(self.f_Keys[k])].Hash := HashThis(Key, IgnoreCase);
    { Hash has been modified, so disallow Next. } 
    self.f_NextAllowed := false; 
  end; 
end; 
 
function TObjectHash.FIndexMax: integer; 
begin 
  result := High(self.f_Items); 
end; 
 
procedure TObjectHash.FTrimIndexes(count: integer); 
begin 
  SetLength(self.f_Items, count); 
end; 
 
procedure TObjectHash.FClearItems; 
var 
  i: integer; 
begin 
  for i := 0 to High(self.f_Items) do
    if (Assigned(self.f_Items[i])AND(f_Items[i] <>Nil)) then
    try
      FreeAndNil(self.f_Items[i]);
    except
    end;
  SetLength(self.f_Items, 0); 
end; 
 
destructor TObjectHash.Destroy; 
var 
  i: integer; 
begin 
  for i := 0 to High(self.f_Items) do 
    if (Assigned(self.f_Items[i])AND(f_Items[i]<>Nil)) then
    try
      FreeAndNil(self.f_Items[i]);
    except
    end;
  SetLength(self.f_Items, 0);
  inherited;
end; 
 
end. 
