unit AtomTest;

{$I config.inc}

interface

uses
  Classes, FunDu, SysUtils, Testing;

procedure RunAtomTests;

implementation

function TestStrAtomCopy(AName: string): TTestResult;
var
  OriginalAtom, CopyAtom: TAtom;
begin
  OriginalAtom := TStrAtom.Create('foo');
  CopyAtom := OriginalAtom.Copy;
  if (CopyAtom.StrValue <> OriginalAtom.StrValue) then
    exit(Fail(AName, 'Atom copied incorrectly'))
  else
    exit(Success(AName));
end;

procedure RunAtomTests;
begin
  RunTest('TestStrAtomCopy', @TestStrAtomCopy);
end;

end.

