unit ListTest;

{$I config.inc}

interface

uses
  Classes, SysUtils, Testing;

procedure RunListTests;

implementation

uses
  FunDu, StandartLib;

var
  env: TEnv;

procedure InitListTest;
begin
  env := TEnv.Create;
  InitStandartLib(env);
end;

procedure ReleaseListTest;
begin
  env.Free;
end;

function TestEmpyList(AName: String): TTestResult;
var
  EmptyList: TListAtom;
  Item: TAtom;
begin
  EmptyList := TListAtom.Create;
  Item := EmptyList.Get(0);
  if Assigned(Item) then
  begin
    exit(Fail(AName, 'Empty list doesn''t seems to be so empty'));
  end;
  exit(Success(AName));
end;

procedure RunListTest(AName: String; ATest: TTestProc);
begin
  RunTest(AName, ATest, @InitListTest, @ReleaseListTest);
end;

procedure RunListTests;
begin
  RunListTest('TestEmpyList', @TestEmpyList);
end;

end.
