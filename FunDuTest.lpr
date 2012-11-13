program FunDuTest;

{$I config.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}cthreads,{$ENDIF}{$ENDIF}
  Classes,
  { you can add units after this }
  Testing, Parser, ParserTest, AtomTest, FunDu, EvalTest;

begin
  InitTesting;

  RunParserTests;
  RunAtomTests;
  RunEvalTests;

  ShowResults;

  ReleaseTesting;
  readln;
end.

