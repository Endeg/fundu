unit ParserTest;

{$I config.inc}

interface

uses
  Classes, Parser, SysUtils, Testing;

const
  WRONG_TOCKEN_TYPE = 'Wrong tocken type: ';
  PARSING_NOT_FINISHED = 'Parsing not finished';

procedure RunParserTests;

implementation

function TestParser(AName: String): TTestResult;
begin
  with TParser.Create('"foo" bar') do
  begin
    Step;
    if (TockenType <> tcString) or (Tocken <> 'foo') then
      exit(Fail(AName, WRONG_TOCKEN_TYPE + Tocken));

    Step;
    if (TockenType <> tcSymbol) or (Tocken <> 'bar') then
      exit(Fail(AName, WRONG_TOCKEN_TYPE + Tocken));

    if not Finished then
      exit(Fail(AName, PARSING_NOT_FINISHED));
  end;

  exit(Success(AName));
end;

function TestParserNumeric(AName: String): TTestResult;
begin
  with TParser.Create('"foo" bar 12 42 12.42') do
  begin
    Step;
    if (TockenType <> tcString) or (Tocken <> 'foo') then
      exit(Fail(AName, WRONG_TOCKEN_TYPE + Tocken));

    Step;
    if (TockenType <> tcSymbol) or (Tocken <> 'bar') then
      exit(Fail(AName, WRONG_TOCKEN_TYPE + Tocken));

    Step;
    if (TockenType <> tcInt) or (Tocken <> '12') then
      exit(Fail(AName, WRONG_TOCKEN_TYPE + Tocken));

    Step;
    if (TockenType <> tcInt) or (Tocken <> '42') then
      exit(Fail(AName, WRONG_TOCKEN_TYPE + Tocken));

    Step;
    if (TockenType <> tcFloat) or (Tocken <> '12.42') then
      exit(Fail(AName, WRONG_TOCKEN_TYPE + Tocken));

    if not Finished then
      exit(Fail(AName, PARSING_NOT_FINISHED));
  end;

  exit(Success(AName));

end;

function TestParserBrakets(AName: String): TTestResult;
begin
  with TParser.Create('("foo" bar)') do
  begin
    Step;
    if TockenType <> tcBracketOpen then
      exit(Fail(AName, WRONG_TOCKEN_TYPE + Tocken));

    Step;
    if (TockenType <> tcString) or (Tocken <> 'foo') then
      exit(Fail(AName, WRONG_TOCKEN_TYPE + Tocken));

    Step;
    if (TockenType <> tcSymbol) or (Tocken <> 'bar') then
      exit(Fail(AName, WRONG_TOCKEN_TYPE + Tocken));

    Step;
    if TockenType <> tcBracketClose then
      exit(Fail(AName, WRONG_TOCKEN_TYPE + Tocken));

    if not Finished then
      exit(Fail(AName, PARSING_NOT_FINISHED));
  end;

  exit(Success(AName));
end;

procedure RunParserTests;
begin
  RunTest('TestParser', @TestParser);
  RunTest('TestParserNumeric', @TestParserNumeric);
  RunTest('TestParserBrakets', @TestParserBrakets);
end;

end.
