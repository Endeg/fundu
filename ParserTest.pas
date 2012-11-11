unit ParserTest;

{$mode objfpc}{$H+}

interface

uses
  Classes, Parser, SysUtils, Testing;

procedure RunParserTests;

implementation

function TestParser: Boolean;
begin
  Result := True;
  with TParser.Create('"foo" bar') do
  begin
    Step;
    if (TockenType <> tcString) or (Tocken <> 'foo') then
      exit(False);

    Step;
    if (TockenType <> tcSymbol) or (Tocken <> 'bar') then
      exit(False);

    if not Finished then
      exit(False);
  end;
end;

function TestParserNumeric: Boolean;
begin
  Result := True;
  with TParser.Create('"foo" bar 12 42 12.42') do
  begin
    Step;
    if (TockenType <> tcString) or (Tocken <> 'foo') then
      exit(False);

    Step;
    if (TockenType <> tcSymbol) or (Tocken <> 'bar') then
      exit(False);

    Step;
    if (TockenType <> tcInt) or (Tocken <> '12') then
      exit(False);

    Step;
    if (TockenType <> tcInt) or (Tocken <> '42') then
      exit(False);

    Step;
    if (TockenType <> tcFloat) or (Tocken <> '12.42') then
      exit(False);

    if not Finished then
      exit(False);
  end;
end;

procedure RunParserTests;
begin
  RunTest('TestParser', @TestParser);
  RunTest('TestParserNumeric', @TestParserNumeric);
end;

end.
