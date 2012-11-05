unit StandartLib;

{$I config.inc}

interface

uses
  FunDu;

procedure InitStandartLib(env: TEnv);
function FunDo(env: TEnv; args: TListAtom): TAtom;
function FunPrint(env: TEnv; args: TListAtom): TAtom;

implementation

uses
  FunUtils;

procedure InitStandartLib(env: TEnv);
begin
  RegFunction(env, 'print', @FunPrint);
  RegFunction(env, 'do', @FunDo);
end;

function FunDo(env: TEnv; args: TListAtom): TAtom;
var
  i: Integer;
begin
  Result := nil;
  if args = nil then
    exit;

  for i := 0 to Pred(args.Atoms.Count) do
  begin
    with TAtom(args.Atoms.Items[i]) do
    begin
      Result := Eval(env);
    end;
  end;
end;

function FunPrint(env: TEnv; args: TListAtom): TAtom;
var
  i: Integer;
  EvaluatedAtom: TAtom;
begin
  Result := nil;
  if args = nil then
    exit;

  if args.Atoms.Count > 1 then
  begin
    for i := 1 to Pred(args.Atoms.Count) do
    begin
      with TAtom(args.Atoms.Items[i]) do
      begin
        EvaluatedAtom := Eval(env);
        if Assigned(EvaluatedAtom) then
          Write(EvaluatedAtom.StrValue)
        else
          Write('nil');
      end;
    end;
    WriteLn;
  end;

  Result := nil;
end;

end.
