program FunDuTest;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, Testing, Parser, ParserTest
  { you can add units after this };

begin

  InitTesting;

  RunParserTests;

  ShowResults;

  ReleaseTesting;

  readln;

end.

