unit Testing;

{$I config.inc}

interface

uses
  Classes, SysUtils;

type
  TTestResult = class
  private
    _message: String;
    _name: String;
    function _Errored: Boolean;
  public
    property Errored: Boolean read _Errored;
    property Name: String read _name;
    property Message: String read _message;

    constructor Create(ATestName: String);
    constructor Create(ATestName, AMessage: String);
  end;

  TPlainProc = procedure;
  TTestProc = function(AName: String): TTestResult;



procedure EmptyProc;
procedure RunTest(AName: String; ATest: TTestProc; AInit, ARelease: TPlainProc);
procedure RunTest(AName: String; ATest: TTestProc);

procedure InitTesting;
procedure ReleaseTesting;
procedure ShowResults;

function Success(ATestName: String): TTestResult;
function Fail(ATestName, AMessage: String): TTestResult;

function PassedCount: Integer;
function FailedCount: Integer;

var
  Results: TFPList;

implementation

function TTestResult._Errored: Boolean;
begin
  Result := Length(_message) > 0;
end;

constructor TTestResult.Create(ATestName: String);
begin
  _name := ATestName;
  _message := '';
end;

constructor TTestResult.Create(ATestName, AMessage: String);
begin
  Self.Create(ATestName);
  _message := AMessage;
end;

function Success(ATestName: String): TTestResult;
begin
  Result := TTestResult.Create(ATestName);
end;

function Fail(ATestName, AMessage: String): TTestResult;
begin
  Result := TTestResult.Create(ATestName, AMessage);
end;

procedure EmptyProc;
begin
  //writeln('EmptyProc;');
end;

procedure RunTest(AName: String; ATest: TTestProc; AInit, ARelease: TPlainProc);
begin
  AInit;

  Results.Add(ATest(AName));

  ARelease;
end;

procedure RunTest(AName: String; ATest: TTestProc);
begin
  RunTest(AName, ATest, @EmptyProc, @EmptyProc);
end;

procedure InitTesting;
begin
  Results := TFPList.Create;
end;

procedure ReleaseTesting;
begin
  Results.Free;
end;

procedure WriteTestLine(AIndex: Integer; AResult: TTestResult);
var
  OStr: String;
begin
  OStr := '    ' + IntToStr(AIndex + 1) + '. ';

  if AResult.Errored then

    OStr := OStr + '[FAILED] ' + AResult.Name + ': "' + AResult.Message + '".'

  else

    OStr := OStr + '[PASSED] ' + AResult.Name + '.';


  writeln(OStr);
end;

procedure ShowResultLine;
begin
  writeln;
  writeln('-------------------------------------------');
  if (FailedCount > 0) then
    writeln('|||THIS LINE IS RED||||||||||||||||||||||||')
  else
    writeln('|||THIS LINE IS GREEN||||||||||||||||||||||');
  writeln('-------------------------------------------');
  writeln;
end;

procedure ShowResults;
var
  i: Integer;
begin
  writeln('===========================================');
  writeln;
  for i := 0 to Pred(Results.Count) do
  begin
    WriteTestLine(i, TTestResult(Results[i]));
  end;

  ShowResultLine;

  writeln('    Total tests: ', Results.Count);
  writeln('    Passed: ', PassedCount);
  if FailedCount > 0 then
    writeln('    Failed: ', FailedCount);
  writeln;
  writeln('===========================================');
end;

function PassedCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Pred(Results.Count) do
    if not TTestResult(Results[i]).Errored then
      Inc(Result);
end;

function FailedCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Pred(Results.Count) do
    if TTestResult(Results[i]).Errored then
      Inc(Result);
end;

end.
