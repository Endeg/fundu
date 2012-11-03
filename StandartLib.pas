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
  write('Standart.FunDo');
  if (args <> nil) then writeln(args.StrValue);
  Result := nil;
  if args = nil then exit;

  for i := 0 to args.Atoms.Count - 1 do
  begin
    with TAtom(args.Atoms.Items[i]) do
    begin
      writeln('FunDo:  preEval');
      Result := Eval(env);
      writeln('FunDo: postEval');
    end;
  end;
end;

function FunPrint(env: TEnv; args: TListAtom): TAtom;
var
  i: Integer;
  CurrentAtom: TAtom;
begin
  write('Standart.Print');
  if (args <> nil) then writeln(args.StrValue);
  Result := nil;
  if args = nil then exit;

  if args.Atoms.Count > 1 then
  begin
    for i := 1 to args.Atoms.Count - 1 do
    begin
      with TAtom(args.Atoms.Items[i]) do
      begin
        CurrentAtom := Eval(env);
        if CurrentAtom <> nil then
          Write(CurrentAtom.StrValue)
        else
          Write('nil');
      end;
    end;
    WriteLn;
  end;

  Result := nil;
end;

end.
