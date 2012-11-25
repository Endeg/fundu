unit Parser;

{$I config.inc}

interface

type
  TTockenType = (tcBracketOpen, tcBracketClose, tcSymbol, tcString, tcInt, tcFloat);

  TParser = class
  private
    _raw: String;
    _pos: Integer;
    _tocken: String;
    _tockenType: TTockenType;

    function HandleBrackets: String;
    function HandleWord: String;
    procedure HandleWhitespace;
    procedure HandleComments;
    function HandleString: String;
    function DetectNumber: TTockenType;
  public
    procedure Step;
    function Finished: Boolean;

    property Tocken: String read _tocken;
    property TockenType: TTockenType read _tockenType;

    constructor Create(expr: String);
  end;

implementation


const
  BRACKET_OPEN: Char = '(';
  //BRACKET_CLOSE: Char = ')';
  BRACKETS: array[0..1] of Char = ('(', ')');
  QUOTE: Char = '"';
  WHITESPACE: array[0..3] of Char = (chr(9), chr(10), chr(13), chr(32));
  ENDLINE: array[0..1] of Char = (chr(10), chr(13));
  COMMENTS: array[0..1] of Char = (';', '#');
  NUMBER: array[0..11] of Char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '-');
  DECIMAL_SEPARATOR: Char = '.';
  MINUS: Char = '-';


function CharIn(c: Char; a: array of Char): Boolean;
var
  i: Integer;
begin
  for i := 0 to pred(length(a)) do
    if c = a[i] then
      exit(True);

  exit(False);
end;

function CountChar(AStr: String; ASymbol: Char): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(AStr) do
    if AStr[i] = ASymbol then
      Inc(Result);
end;

function ConsistOf(AStr: String; ASymbols: array of Char): Boolean;
var
  i: Integer;
begin
  for i := 1 to length(AStr) do
  begin
    if not CharIn(AStr[i], ASymbols) then
      exit(False);
  end;

  exit(True);
end;

function TParser.HandleBrackets: String;
begin
  Result := _raw[_pos];
  Inc(_pos);
end;

function TParser.HandleWord: String;
begin
  Result := '';
  while not Finished do
  begin
    Result := Result + _raw[_pos];
    Inc(_pos);
    if CharIn(_raw[_pos], BRACKETS) or CharIn(_raw[_pos], WHITESPACE) then
      break;
  end;
end;

procedure TParser.HandleWhitespace;
begin
  while not Finished do
  begin
    Inc(_pos);
    if not CharIn(_raw[_pos], WHITESPACE) then
      break;
  end;
end;

procedure TParser.HandleComments;
begin
  while not Finished do
  begin
    Inc(_pos);
    if CharIn(_raw[_pos], ENDLINE) then
      break;
  end;
end;

function TParser.HandleString: String;
begin
  Result := '';
  while not Finished do
  begin
    Inc(_pos);
    if _raw[_pos] <> QUOTE then
      Result := Result + _raw[_pos]
    else
      break;
  end;
  Inc(_pos);
end;

function TParser.DetectNumber: TTockenType;
var
  i, TockenLeigth: Integer;
begin
  Result := tcSymbol;

  if ConsistOf(_tocken, NUMBER) then
    Result := tcInt;

  if (Result = tcInt) and (CountChar(_tocken, DECIMAL_SEPARATOR) = 1) then
    Result := tcFloat;
end;

procedure TParser.Step;
begin
  while not Finished do
  begin
    //TODO: this is need to be refactored badly
    if CharIn(_raw[_pos], COMMENTS) then
    begin
      HandleComments;
    end else if CharIn(_raw[_pos], BRACKETS) then
    begin
      _tocken := HandleBrackets;
      if _tocken = BRACKET_OPEN then
        _tockenType := tcBracketOpen
      else
        _tockenType := tcBracketClose;
      break;
    end else if _raw[_pos] = QUOTE then
    begin
      _tocken := HandleString;
      _tockenType := tcString;
      break;
    end else if CharIn(_raw[_pos], WHITESPACE) then
    begin
      HandleWhitespace;
    end else
    begin
      _tocken := HandleWord;
      _tockenType := DetectNumber; //TODO: add num check
      break;
    end;
  end;
end;

function TParser.Finished: Boolean;
begin
  Result := _pos > length(_raw);
end;

constructor TParser.Create(expr: String);
begin
  _raw := expr;
  _pos := 1;
end;

end.
