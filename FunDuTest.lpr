program FunDuTest;

{$I config.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, Testing, Parser, ParserTest, AtomTest, FunDu
  { you can add units after this };

begin
  InitTesting;

  RunParserTests;
  RunAtomTests;

  ShowResults;

  ReleaseTesting;
  readln;
end.

