unit FunUtils;

{$I config.inc}

interface

uses
  Classes, FunDu, SysUtils;

type
  TStack = class
  private
    _values: TFPList;
  public
    constructor Create;
    procedure Push(Value: TAtom);
    function Pop: TAtom;
    function Empty: Boolean;
  end;

  TListItem = class
  private
    _next: TListItem;
    _prev: TListItem;
    _data: Pointer;

  public
    property Next: TListItem read _next write _next;
    property Prev: TListItem read _prev write _prev;
    property Data: Pointer read _data;
    constructor Create(obj: Pointer);
  end;

  TList = class
  private
    _head: TListItem;
    _tail: TListItem;


  public
    property Head: TListItem read _head write _head;
    property Tail: TListItem read _tail write _tail;

    function Count: Integer;
    procedure Add(Data: Pointer);
    procedure Remove(Data: Pointer);

    constructor Create();
  end;

procedure SwapItems(left, right: TListItem);
function BuildSyntaxTree(code: String): TAtom;
function hashString(AStr: String): Longint;
procedure RegFunction(env: TEnv; AName: String; AFun: TNativeFunctionPointer);

implementation

uses
  Parser;

constructor TStack.Create;
begin
  _values := TFPList.Create;
end;

procedure TStack.Push(Value: TAtom);
begin
  _values.Add(Value);
end;

function TStack.Pop: TAtom;
begin
  if _values.Count > 0 then
  begin
    Result := TAtom(_values.Items[_values.Count - 1]);
    _values.Delete(_values.Count - 1); //d'oh
  end else
    Result := nil;
end;

function TStack.Empty: Boolean;
begin
  Result := _values.Count = 0;
end;

constructor TListItem.Create(obj: Pointer);
begin
  //writeln('TListItem.Create(', Integer(obj), ': Pointer);');
  _data := obj;
end;

constructor TList.Create();
begin
  _head := nil;
  _tail := nil;
end;

procedure TList.Add(Data: Pointer);
var
  item: TListItem;
begin
  item := TListItem.Create(Data);
  if _head = nil then
  begin
    _head := item;
    item.Prev := nil;
    item.Next := nil;
    _tail := item;
  end else
  begin
    _tail.Next := item;
    item.Prev := _tail;
    item.Next := nil;
    _tail := item;
  end;
end;

procedure TList.Remove(Data: Pointer);
var
  iter: TListItem;
begin
  iter := _head;
  while iter <> nil do
  begin
    if iter.Data = Data then
      with iter do
      begin
        Prev.Next := Next;
        Next.Prev := Prev;
        Destroy;
        break;
      end;
    iter := iter.Next;
  end;
end;

function TList.Count: Integer;
var
  iter: TListItem;
  itemCount: Integer = 0;
begin
  iter := _head;
  while (iter <> nil) do
  begin
    iter := iter.Next;
    Inc(itemCount);
  end;

  Result := itemCount;
end;

procedure SwapItems(left, right: TListItem);
var
  tmp: TListItem;
begin
  tmp := left.Prev;
  left.Prev := right.Prev;
  right.Prev := tmp;

  tmp := left.Next;
  left.Next := right.Next;
  right.Next := tmp;
end;


function BuildSyntaxTree(code: String): TAtom;
var
  stack: TStack;
  root, current, newList: TListAtom;
begin
  stack := TStack.Create;
  root := TListAtom.Create;
  root.Add(TSymbolAtom.Create('do'));
  current := root;

  with TParser.Create(code) do
  begin
    while not Finished do
    begin
      Step;

      case TockenType of
        tcBracketOpen:
        begin
          newList := TListAtom.Create;
          current.Add(newList);
          stack.Push(current);
          current := newList;
        end;

        tcSymbol:
        begin
          TListAtom(current).Add(TSymbolAtom.Create(Tocken));
        end;

        tcString:
        begin
          TListAtom(current).Add(TStrAtom.Create(Tocken));
        end;

        tcBracketClose:
        begin
          current := TListAtom(stack.Pop);
          if current = nil then
          begin
            writeln('Something wrong with brackets!');
            break;
          end;
        end;
      end;

    end;
    if stack.pop <> nil then
      writeln('Something really wrong with brackets!');

    writeln('Syntax tree: ', root.StrValue);

    Result := TAtom(root);

    Free;
  end;

  stack.Free;
end;

function hashString(AStr: String): Longint;
var
  i: Integer;
begin
  Result := 0;

  for i := 0 to length(AStr) do
  begin
    Inc(Result, Ord(AStr[i]));
    Inc(Result, Result shl 10);
    Result := Result xor (Result shr 6);
  end;
  Inc(Result, Result shl 3);
  Result := Result xor (Result shr 11);
  Inc(Result, Result shl 15);
end;

//TODO: move to TEnv
procedure RegFunction(env: TEnv; AName: String; AFun: TNativeFunctionPointer);
begin
  env.MainScope.Put(AName, TNativeFunction.Create(AFun));
end;

end.
