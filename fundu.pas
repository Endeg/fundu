unit FunDu;

{$I config.inc}

interface

uses
  Classes, SysUtils;

type
  TEnv = class;
  TAtom = class;
  TStrAtom = class;
  TSymbolAtom = class;
  TListAtom = class;
  TNativeFunction = class;
  TDict = class;

  TDictItem = class;

  TAtomType = (atStr, atSymbol, atInt, atFloat, atList, atDict, atNativeFunction);
  TNativeFunctionPointer = function(env: TEnv; args: TListAtom): TAtom;

  TEnv = class
  private
    _mainScope: TDict;

    function LoadFile(fileName: String): String;
  public
    constructor Create();
    procedure ExecFile(fileName: String);
    function EvalCode(code: String): TAtom;

    property MainScope: TDict read _mainScope;
  end;


  TAtom = class
  private
    _id: Integer;
    _type: TAtomType;
  public
    property AtomType: TAtomType read _type;
    property Id: Integer read _id;

    function StrValue: String; virtual;
    function Eval(env: TEnv): TAtom; virtual;

    constructor Create(AType: TAtomType);
    destructor Destroy; override;

    function Copy: TAtom; virtual;
  end;

  TStrAtom = class(TAtom)
  private
    _str: String;
  public
    function StrValue: String; override;

    constructor Create(AType: TAtomType);
    constructor Create(AStr: String);
    function Copy: TAtom; override;
  end;

  TSymbolAtom = class(TStrAtom)
  private
    _hash: Longint;
  public
    constructor Create(AStr: String);
    function Eval(env: TEnv): TAtom; override;
    property HashValue: Longint read _hash;
  end;

  TListAtom = class(TAtom)
  private
    _list: TFPList; //TODO: replace with own implementation
  public
    property Atoms: TFPList read _list;
    function StrValue: String; override;
    procedure Add(AValue: TAtom);

    function Get(index: Integer): TAtom;

    function Eval(env: TEnv): TAtom; override;

    constructor Create;
    destructor Destroy; override;
    function Copy: TAtom; override;
  end;

  TNativeFunction = class(TAtom)
  private
    _fun: TNativeFunctionPointer;
  public
    constructor Create(AFun: TNativeFunctionPointer);
    function Exec(env: TEnv; args: TListAtom): TAtom;
    function Copy: TAtom; override;
  end;

  TDict = class(TAtom)
  private
    _items: TFPList;

    function FindItem(AName: String; AHash: Longint): TDictItem;
    function FindItem(AName: String): TDictItem;
  public
    constructor Create;
    procedure Put(AName: String; AValue: TAtom);
    function Get(AName: String; AHash: Longint): TAtom;
    function Get(AName: String): TAtom;
  end;

  TDictItem = class
  private
    _name: String;
    _hash: Longint;
    _value: TAtom;

  public
    constructor Create(AName: String; AValue: TAtom);

    property Name: String read _name;
    property Hash: Longint read _hash;
    property Value: TAtom read _value write _value;
  end;

var
  Atoms: TFPList;
  IdCounter: Integer = 0;

procedure ShowDebugInfo();

implementation

uses
  FunUtils;

procedure ShowDebugInfo();
var
  i: Integer;
begin
  writeln('---------------------------');
  for i := 0 to Pred(Atoms.Count) do
    with TAtom(Atoms.Items[i]) do
    begin
      writeln('  Type: ', AtomType, '; StrValue: ', StrValue, '; Id: ', Id);
    end;
  writeln('---------------------------');
end;

{--== TEnv implementation ==--}
function TEnv.LoadFile(fileName: String): String;
var
  f: TextFile;
  b: Char;
begin
  Result := '';
  writeln('Using generic file loader');
  AssignFile(f, fileName);
  Reset(f);
  repeat
    Read(f, b);
    Result := Result + b;
  until EOF(f);

  CloseFile(f);
end;

constructor TEnv.Create();
begin
  writeln('Creating toy env');

  _mainScope := TDict.Create;
end;

procedure TEnv.ExecFile(fileName: String);
var
  contents: String;
begin
  contents := LoadFile(fileName);
  EvalCode(contents);
end;

//TODO: числовые типы!
function TEnv.EvalCode(code: String): TAtom;
var
  root: TListAtom;
begin
  Result := nil;
  root := TListAtom(BuildSyntaxTree(code));
  if root <> nil then
  begin

    writeln('==========================================');
    Result := root.Eval(Self);
    writeln('==========================================');
  end;//TODO: else some message
  root.Free;
  ShowDebugInfo();
end;

{--== TAtom implementation==--}
constructor TAtom.Create(AType: TAtomType);
begin
  _type := AType;
  _id := IdCounter;
  Inc(IdCounter);
  writeln('Creating atom: ', _type, '; Id: ', _id);
  //writeln('Creating ', _type);

  Atoms.Add(Pointer(Self));
  writeln('  Atoms total: ', Atoms.Count);
end;

destructor TAtom.Destroy;
begin
  writeln('Destroying atom: ', _type);
  Atoms.Remove(Pointer(Self));
  writeln('  Atoms total: ', Atoms.Count);

  inherited Destroy;
end;

function TAtom.Copy: TAtom;
begin
  Result := TAtom.Create(_type);
end;

function TAtom.StrValue: String;
begin
  Result := 'Value';
end;

function TAtom.Eval(env: TEnv): TAtom;
begin
  Result := Copy;
end;

{--== TStrAtom implementation==--}
constructor TStrAtom.Create(AType: TAtomType);
begin
  inherited Create(AType);
end;

constructor TStrAtom.Create(AStr: String);
begin
  inherited Create(atStr);
  _str := AStr;
end;

function TStrAtom.StrValue: String;
begin
  Result := _str;
end;

function TStrAtom.Copy: TAtom;
begin
  Result := TAtom(TStrAtom.Create(_str));
end;

{--== TSymbolAtom implementation==--}
constructor TSymbolAtom.Create(AStr: String);
begin
  inherited Create(atSymbol);
  _str := AStr;
  _hash := hashString(AStr);
end;

function TSymbolAtom.Eval(env: TEnv): TAtom;
var
  FoundAtom: TAtom;
begin
  FoundAtom := env.MainScope.Get(StrValue, HashValue);
  if Assigned(FoundAtom) then
    Result := FoundAtom //Copy?
  else
    Result := nil;
    //TODO: error message here
end;

{--== TListAtom implementation==--}
constructor TListAtom.Create;
begin
  inherited Create(atList);
  _list := TFPList.Create;
end;

destructor TListAtom.Destroy;
var
  i: Integer;

begin
  //writeln('destroying list atom');

  for i := 0 to Pred(_list.Count) do
    TAtom(_list.Items[i]).Free;

  FreeAndNil(_list);
  inherited Destroy;
end;

function TListAtom.StrValue: String;
var
  i: Integer;
begin
  Result := '[';
  for i := 0 to _list.Count - 1 do
  begin
    Result := Result + TAtom(_list[i]).StrValue;
    if i <> _list.Count - 1 then
      Result := Result + ' ';
  end;
  Result := Result + ']';
end;

procedure TListAtom.Add(AValue: TAtom);
begin
  _list.Add(AValue);
end;

function TListAtom.Get(index: Integer): TAtom;
begin
  if _list.Count >= index then
    Result := TAtom(_list.Items[index])
  else
    Result := nil;
end;

function TListAtom.Eval(env: TEnv): TAtom;
var
  Head, Found, Evaluated: TAtom;
begin
  //writeln('TListAtom.Eval');
  Result := nil;
  Head := Get(0);
  if (Head <> nil) and (Head.AtomType = atStr) then
  begin
    Found := TAtom(env.MainScope.Get(Head.StrValue));
    if Found <> nil then
    begin
      case Found.AtomType of
        atNativeFunction: Result := TNativeFunction(Found).Exec(env, Self);
      end;
      {if Evaluated <> nil then Result := Evaluated.Copy
      else Result := nil;}

    end else
    begin
      writeln('Enable to find native function named "', Head.StrValue, '"');
    end;
  end;
end;

function TListAtom.Copy: TAtom;
var
  i: Integer;
  ListCopy: TListAtom;
begin
  ListCopy := TListAtom.Create;
  for i := 0 to Pred(_list.Count) do
  begin
    ListCopy.Add(TAtom(_list.Items[i]).Copy);
  end;
  Result := TAtom(ListCopy);
end;

{--== TNativeFunction implementation==--}
constructor TNativeFunction.Create(AFun: TNativeFunctionPointer);
begin
  inherited Create(atNativeFunction);
  _fun := AFun;
end;

function TNativeFunction.Exec(env: TEnv; args: TListAtom): TAtom;
var
  Evaluated: TAtom;
begin
  //Write('TNativeFunction.Exec');
  if (args <> nil) then
    writeln(args.StrValue);
  Evaluated := _fun(env, args);
  if Evaluated <> nil then
  begin
    Result := Evaluated.Copy;
    Evaluated.Free;
  end
  else
    Result := nil;
end;

function TNativeFunction.Copy: TAtom;
begin
  Result := TAtom(TNativeFunction.Create(_fun));
end;

{--== TDict implementation==--}
constructor TDict.Create;
begin
  inherited Create(atDict);

  _items := TFPList.Create;
end;

procedure TDict.Put(AName: String; AValue: TAtom);
var
  foundItem: TDictItem;
begin
  foundItem := FindItem(AName);
  if foundItem <> nil then
    foundItem.Value := AValue
  else
  begin
    foundItem := TDictItem.Create(AName, AValue);
    _items.Add(foundItem);
  end;
end;

function TDict.Get(AName: String; AHash: Longint): TAtom;
var
  FoundItem: TDictItem;
begin
  FoundItem := FindItem(AName, AHash);
  if FoundItem <> nil then
    Result := FoundItem.Value
  else
    Result := nil;
end;

function TDict.Get(AName: String): TAtom;
var
  FoundItem: TDictItem;
begin
  FoundItem := FindItem(AName);
  if Assigned(FoundItem) then
    Result := FoundItem.Value
  else
    Result := nil;
end;

function TDict.FindItem(AName: String; AHash: Longint): TDictItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Pred(_items.Count) do
  begin
    with TDictItem(_items[i]) do
    begin
      if (AHash = Hash) and (AName = Name) then
      begin
        Result := TDictItem(_items[i]);
        break;
      end;
    end;
  end;
end;

function TDict.FindItem(AName: String): TDictItem;
var
  findHash: Longint;
begin
  findHash := hashString(AName);
  Result := FindItem(AName, findHash);
end;

{--== TDictItem implementation==--}
constructor TDictItem.Create(AName: String; AValue: TAtom);
begin
  _name := AName;
  _hash := hashString(AName);
  _value := AValue;
end;


begin
  Atoms := TFPList.Create;
end.
