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



function CharIn(c: Char; a: array of Char): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to length(a) - 1 do
  begin
    if c = a[i] then
    begin
      Result := True;
      break;
    end;
  end;
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
      _tockenType := tcSymbol; //TODO: add num check
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
