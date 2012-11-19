unit EvalTest;

{$I config.inc}

interface

uses
  Classes, SysUtils, Testing;

procedure RunEvalTests;

implementation

uses
  FunDu, StandartLib;

var
  env: TEnv;

procedure InitEvalTest;
begin
  env := TEnv.Create;
  InitStandartLib(env);
end;

procedure ReleaseEvalTest;
begin
  env.Free;
end;

function TestSyntaxError(AName: String): TTestResult;
var
  Evaluated: TAtom;
begin
  Evaluated := env.EvalCode(')(');
  if env.Error = 0 then
    exit(Fail(AName, 'Error not raised'));
  if env.Error <> SYNTAX_ERROR then
    exit(Fail(AName, 'Wrong error code'));
  if Assigned(Evaluated) then
    exit(Fail(AName, 'Value in errored expression'));

  exit(Success(AName));
end;

function TestSymbolNotFoundError(AName: String): TTestResult;
var
  Evaluated: TAtom;
begin
  Evaluated := env.EvalCode('(hey-not-real-function 1 2 3)');
  if env.Error = 0 then
    exit(Fail(AName, 'Error not raised'));
  if env.Error <> SYMBOL_NOT_FOUND then
    exit(Fail(AName, 'Wrong error code'));
  if Assigned(Evaluated) then
    exit(Fail(AName, 'Value in errored expression'));

  exit(Success(AName));
end;

function TestAddFunction(AName: String): TTestResult;
var
  Evaluated: TAtom;
begin
  Evaluated := env.EvalCode('(+ 4 2)');
  if env.Error > 0 then
    exit(Fail(AName, 'Error was raised: "' + env.ErrorMessage + '"'));
  if Evaluated.AtomType <> atInt then
    exit(Fail(AName, 'Wrong atom type'));
  //if Evaluated.IntValue <> 6 then
  //  exit(Fail(AName, 'Wrong result'));

  exit(Success(AName));
end;

function TestMulFunction(AName: String): TTestResult;
var
  Evaluated: TAtom;
begin
  Evaluated := env.EvalCode('(* 4 2)');
  if env.Error > 0 then
    exit(Fail(AName, 'Error was raised: "' + env.ErrorMessage + '"'));
  if Evaluated.AtomType <> atInt then
    exit(Fail(AName, 'Wrong atom type'));
  //if Evaluated.IntValue <> 8 then
  //  exit(Fail(AName, 'Wrong result'));

  exit(Success(AName));
end;

function TestSubFunction(AName: String): TTestResult;
var
  Evaluated: TAtom;
begin
  Evaluated := env.EvalCode('(- 4 2)');
  if env.Error > 0 then
    exit(Fail(AName, 'Error was raised: "' + env.ErrorMessage + '"'));
  if Evaluated.AtomType <> atInt then
    exit(Fail(AName, 'Wrong atom type'));
  //if Evaluated.IntValue <> 2 then
  //  exit(Fail(AName, 'Wrong result'));

  exit(Success(AName));
end;

function TestDivFunction(AName: String): TTestResult;
var
  Evaluated: TAtom;
begin
  Evaluated := env.EvalCode('(/ 4 2)');
  if env.Error > 0 then
    exit(Fail(AName, 'Error was raised: "' + env.ErrorMessage + '"'));
  if Evaluated.AtomType <> atFloat then
    exit(Fail(AName, 'Wrong atom type'));
  //if Evaluated.FloatValue <> 2.0 then
  //  exit(Fail(AName, 'Wrong result'));

  exit(Success(AName));
end;

procedure RunEvalTest(AName: String; ATest: TTestProc);
begin
  RunTest(AName, ATest, @InitEvalTest, @ReleaseEvalTest);
end;

procedure RunEvalTests;
begin
  RunEvalTest('TestSyntaxError', @TestSyntaxError);
  RunEvalTest('TestSymbolNotFoundError', @TestSymbolNotFoundError);
  RunEvalTest('TestAddFunction', @TestAddFunction);
  RunEvalTest('TestMulFunction', @TestMulFunction);
  RunEvalTest('TestSubFunction', @TestSubFunction);
  RunEvalTest('TestDivFunction', @TestDivFunction);
end;

end.
