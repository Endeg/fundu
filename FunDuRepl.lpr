program FunDuRepl;

{$I config.inc}

uses
  Classes,
  StandartLib,
  FunUtils,
  FunDu;

var
  Env: TEnv;
  StrIn: String;
  EvaluatedAtom: TAtom;
  Done: Boolean;

  function FunExit(env: TEnv; args: TListAtom): TAtom;
  begin
    Done := True;
    Result := nil;
  end;

begin
  Done := False;

  Env := TEnv.Create;
  InitStandartLib(Env);
  RegFunction(Env, 'exit', @FunExit);

  while not Done do
  begin
    readln(StrIn);
    EvaluatedAtom := Env.EvalCode(StrIn);
    if (EvaluatedAtom <> nil) then
    begin
      writeln(EvaluatedAtom.StrValue);
      EvaluatedAtom.Free;
    end
    else
      writeln('nil');
  end;

  Env.Free;
end.
