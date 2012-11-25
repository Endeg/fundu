program FunDuTest;

{$I config.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}cthreads,{$ENDIF}{$ENDIF}
  Classes,
  { you can add units after this }
  Testing, Parser, ParserTest, AtomTest, FunDu, EvalTest, ListTest;

begin
  InitTesting;

  RunListTests;
  RunParserTests;
  RunAtomTests;
  RunEvalTests;

  ShowResults;

  ReleaseTesting;
  readln;
end.

