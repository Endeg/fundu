program FunDuRepl;

{$I config.inc}

uses
  Classes,
  StandartLib,
  FunUtils,
  FunDu;

var
  t: TEnv;
  strIn: String;
  evaluatedAtom: TAtom;

begin
  t := TEnv.Create;
  InitStandartLib(t);

  while True do
  begin
    readln(strIn);
    evaluatedAtom := t.EvalCode(strIn);
    if (evaluatedAtom <> nil) then begin
      writeln(evaluatedAtom.StrValue);
      evaluatedAtom.Free
    end
    else
      writeln('nil');
  end;
end.
