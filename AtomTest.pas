unit AtomTest;

{$I config.inc}

interface

uses
  Classes, SysUtils, Testing, FunDu;

procedure RunAtomTests;

implementation

function TestStrAtomCopy: boolean;
var
  OriginalAtom, CopyAtom: TAtom;
begin
  OriginalAtom := TStrAtom.Create('foo');
  CopyAtom := OriginalAtom.Copy;
  Exit(CopyAtom.StrValue = OriginalAtom.StrValue);
end;

procedure RunAtomTests;
begin
  RunTest('TestStrAtomCopy', @TestStrAtomCopy);
end;

end.

