unit Testing;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TPlainProc = procedure;
  TTestProc = function: Boolean;

procedure EmptyProc;
procedure RunTest(AName: String; ATest: TTestProc; AInit, ARelease: TPlainProc);
procedure RunTest(AName: String; ATest: TTestProc);

procedure InitTesting;
procedure ReleaseTesting;
procedure ShowResults;

var
  Total, Passed, Failed: Integer;
  Results: TStrings;

implementation

uses
  Crt;

procedure EmptyProc;
begin
  //writeln('EmptyProc;');
end;

procedure RunTest(AName: String; ATest: TTestProc; AInit, ARelease: TPlainProc);
begin
  AInit;

  if ATest() then
  begin
    Inc(Passed);
    Results.Add(AName + ': Passed');
  end else
  begin
    Inc(Failed);
    Results.Add(AName + ': Failed');
  end;

  Inc(Total);

  ARelease;
end;

procedure RunTest(AName: String; ATest: TTestProc);
begin
  RunTest(AName, ATest, @EmptyProc, @EmptyProc);
end;

procedure InitTesting;
begin
  Total := 0;
  Passed := 0;
  Failed := 0;
  Results := TStringList.Create;
end;

procedure ReleaseTesting;
begin
  Results.Free;
end;

procedure WriteTestLine(AIndex: integer; ALine: string);
begin
  if (Pos('Failed', ALine) > 0) then TextColor(Red) else TextColor(Green);
    writeln('    ', AIndex + 1, '. ', ALine, '.');
end;

procedure ShowResultLine;
begin
  TextColor(LightGray);

  writeln;
  writeln('-------------------------------------------');
  if (Failed > 0) then TextColor(Red) else TextColor(Green);
  writeln('|||||||||||||||||||||||||||||||||||||||||||');
  TextColor(LightGray);
  writeln('-------------------------------------------');
  writeln;

end;

procedure ShowResults;
var
  i: Integer;
begin
  TextColor(LightGray);
  writeln('===========================================');
  writeln;
  for i := 0 to Pred(Results.Count) do
  begin
    WriteTestLine(i, Results[i]);
  end;

  ShowResultLine;

  writeln('    Total tests: ', Total);
  writeln('    Passed: ', Passed);
  if Failed > 0 then
    writeln('    Failed: ', Failed);
  writeln;
  writeln('===========================================');
end;

end.
