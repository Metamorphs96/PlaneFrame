{
Copyright (c) 2014, Steven Conrad Harrison
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are 
met:

1. Redistributions of source code must retain the above copyright 
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright 
notice, this list of conditions and the following disclaimer in the 
documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its 
contributors may be used to endorse or promote products derived from 
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}

{---------------------------------------------------------------------
file containing general string handling procedures
(2/2/90) S.C.Harrison
(1993) S.C. Harrison
   C programming language & Dbase III application language
   string functions implemented in Pascal for Turbo Pascal
   type strings.
(2014) Modifications for compatibility with Free Pascal & Lazarus  
---------------------------------------------------------------------}

UNIT PString;
INTERFACE
{USES; Crt,Dos;}
CONST
  Space = ' ';

  MaxStrSize = 255;

TYPE
  DateStr = STRING[10];
  TimeStr = STRING[8];
{  PStr    = STRING[MaxStrSize];}
  PStr    = string;

  PROCEDURE PStrSet(VAR s:PStr; ch : char);
  FUNCTION PStrNSet(VAR s:PStr; ch : char; n : integer) : PStr;
  PROCEDURE PStrSetAllSpaces(VAR s:PStr);
  FUNCTION  PStrSpaces(s:PStr) : PStr;
  FUNCTION  PStrNSpaces(len : INTEGER) : PStr;
  FUNCTION  PStrNZeros(len : INTEGER) : PStr;
  FUNCTION  PStrRPad(s:PStr;len:integer) : PStr;
  FUNCTION  PStrRPadZeros(s:PStr;len:integer) : PStr;
  FUNCTION  PStrLPad(s:PStr;len:integer) : PStr;
  FUNCTION  PStrLPadZeros(s:PStr;len:integer) : PStr;
  FUNCTION  PStrLTrim(s:PStr) : PStr;
  FUNCTION  PStrRTrim(s:PStr) : PStr;
  FUNCTION  PStrUpr(s:PStr) : PStr;
  FUNCTION  PStrLwr(s:PStr) : PStr;
  FUNCTION  PStrRChr(s:PStr; c : CHAR) : INTEGER;
  FUNCTION  PStrRev(s:PStr) : PStr;
  FUNCTION  PStrCmp(s1,s2:PStr) : INTEGER;
  FUNCTION  PStrICmp(s1,s2:PStr) : INTEGER;

  Function fnName2(fPath : String) : String;
  Function fnDir(fPath : String) : String;
  Procedure fnsplit2( fPath :string; var drv , fdir , fname , fext : String);
  Function fnmerge(var fPath:string; drv , fdir, fname , fext:string ) : String;

  {
  FUNCTION  StrDate : DateStr;
  FUNCTION  StrTime : TimeStr;
  }

IMPLEMENTATION

{---------------------------------------------------------------------
Fill a String with given Character
---------------------------------------------------------------------}
PROCEDURE PStrSet(VAR s:PStr; ch : char);
BEGIN   {...PStrSet}
  FILLCHAR(s,SIZEOF(s),ch);
  {s[0] := CHR(PRED(SIZEOF(s)));}
  setlength(s, SIZEOF(s));
END;    {...PStrSet}

{---------------------------------------------------------------------
Set n characters of a String with given Character
---------------------------------------------------------------------}
FUNCTION PStrNSet(VAR s:PStr; ch : char; n : integer) : PStr;
BEGIN   {...PStrNSet}
{starts fill at s[0]}
  FILLCHAR(s,n+1,ch);
  {s[0] := CHR(n); }
  setlength(s, SIZEOF(s));
  PStrNSet := s;
END;    {...PStrNSet}

{---------------------------------------------------------------------
Fill a String with Blanks/Spaces
NB: only to be used with strings of type PStr, even when string
    checking is relaxed.
---------------------------------------------------------------------}
PROCEDURE PStrSetAllSpaces(VAR s:PStr);
BEGIN   {...PStrSetAllSpaces}
  FILLCHAR(s,SIZEOF(s),Space);
  {s[0] := CHR(PRED(SIZEOF(s))); }
  setlength(s, SIZEOF(s));
END;    {...PStrSetAllSpaces}

{---------------------------------------------------------------------
Fill a String with Blanks/Spaces
---------------------------------------------------------------------}
FUNCTION PStrSpaces(s:PStr) : PStr;
BEGIN   {...PStrFill}
  FILLCHAR(s,SIZEOF(s),Space);
  {s[0] := CHR(PRED(SIZEOF(s)));}
  setlength(s, SIZEOF(s));
  PStrSpaces := s;
END;    {...PStrSpaces}

{---------------------------------------------------------------------
Fill a String with N Blanks/Spaces
---------------------------------------------------------------------}
FUNCTION PStrNSpaces(len : INTEGER) : PStr;
VAR s : PStr;
BEGIN   {...PStrNSpaces}
{starts fill at s[0]}
  FILLCHAR(s,len+1,Space);
  {s[0] := CHR(len);}
  setlength(s, SIZEOF(s));
  PStrNSpaces := s;
END;    {...PStrNSpaces}

{---------------------------------------------------------------------
Fill a String with N Zeros
---------------------------------------------------------------------}
FUNCTION PStrNZeros(len : INTEGER) : PStr;
VAR s : PStr;
BEGIN   {...PStrNZeros}
{starts fill at s[0]}
  FILLCHAR(s,len+1,'0');
  {s[0] := CHR(len);}
  setlength(s, SIZEOF(s));
  PStrNZeros := s;
END;    {...PStrNZeros}

{---------------------------------------------------------------------
Pad Right of Character String with Trailing Spaces
---------------------------------------------------------------------}
FUNCTION PStrRPad(s:PStr;len:integer) : PStr;
VAR ss : PStr;
BEGIN   {...PStrRPad}
  ss := PStrNSpaces(len-LENGTH(s));
  PStrRPad := s+ss;
END;    {...PStrRPad}

{---------------------------------------------------------------------
Pad Right of Character String with Trailing Zeros
---------------------------------------------------------------------}
FUNCTION PStrRPadZeros(s:PStr;len:integer) : PStr;
VAR ss : PStr;
BEGIN   {...PStrRPadZeros}
  ss := PStrNZeros(len-LENGTH(s));
  PStrRPadZeros := s+ss;
END;    {...PStrRPadZeros}

{---------------------------------------------------------------------
Pad Left of Character String with Leading Spaces
---------------------------------------------------------------------}
FUNCTION PStrLPad(s:PStr;len:integer) : PStr;
VAR ss : PStr;
BEGIN   {...PStrLPad}
  ss := PStrNSpaces(len-LENGTH(s));
  PStrLPad := ss+s;
END;    {...PStrLPad}

{---------------------------------------------------------------------
Pad Left of Character String with Leading Zeros
---------------------------------------------------------------------}
FUNCTION PStrLPadZeros(s:PStr;len:integer) : PStr;
VAR ss : PStr;
BEGIN   {...PStrLPadZeros}
  ss := PStrNZeros(len-LENGTH(s));
  PStrLPadZeros := ss+s;
END;    {...PStrLPadZeros}

{---------------------------------------------------------------------
 Delete Leading Blanks from String
---------------------------------------------------------------------}
FUNCTION PStrLTrim(s:PStr) : PStr;
BEGIN   {...PStrLTrim}
  WHILE ( LENGTH(s) > 0 ) AND (s[1] = Space)
    DO DELETE(s,1,1);
  PStrLTrim := s;
END;    {...PStrLTrim}

{---------------------------------------------------------------------
 Delete Trailing Blanks from String
---------------------------------------------------------------------}
FUNCTION PStrRTrim(s:PStr) : PStr;
VAR n,tail : INTEGER;
BEGIN
  tail := LENGTH(s);
  WHILE (s[tail] = space)
    DO DEC(tail);
  n := (LENGTH(s) - tail);
  DELETE(s,tail+1,n);
  PStrRTrim := s;
END;

{---------------------------------------------------------------------
 Convert String To Upper Case Characters
---------------------------------------------------------------------}
FUNCTION PStrUpr(s:PStr) : PStr;
VAR
  i : INTEGER;
BEGIN   {...PStrUpr}
  FOR i := 1 TO LENGTH(s)
    DO s[i] := UPCASE(s[i]);
  PStrUpr := s;
END;    {...PStrUpr}

{---------------------------------------------------------------------
 Convert String To Lower Case Characters
---------------------------------------------------------------------}
FUNCTION PStrLwr(s:PStr) : PStr;
VAR
  i : INTEGER;
BEGIN   {...PStrUpr}
  FOR i := 1 TO LENGTH(s)
    DO IF s[i] in ['A'..'Z']
      THEN s[i] := CHR(ORD(s[i])+32);
  PStrLwr := s;
END;    {...PStrUpr}

{---------------------------------------------------------------------
 Find the last occurence of character c
---------------------------------------------------------------------}
FUNCTION  PStrRChr(s:PStr; c : CHAR) : INTEGER;
VAR
  n : INTEGER;
BEGIN   {...PStrRChr}
  n := LENGTH(s);
  if n > 0 then
  begin
       WHILE (n > 1) and (s[n] <> c) DO
       begin
            DEC(n);
       end;
       if s[n] = c then  PStrRChr := n else PStrRChr := 0;

  end
  else PStrRChr := 0;

{  PStrRChr := n;}
END;    {...PStrRChr}

{---------------------------------------------------------------------
 Reverse the order of characters in string
---------------------------------------------------------------------}
FUNCTION  PStrRev(s:PStr) : PStr;
VAR
  ss : PStr;
  tail,head,i : INTEGER;
BEGIN   {...PStrRev}
  tail := LENGTH(s);
  ss := PStrNSpaces(tail);
  head := 1;
  FOR i := tail DOWNTO 1
   DO BEGIN
     ss[head] := s[i];
     INC(head);
   END;

  PStrRev := ss;
END;    {...PStrRev}

{---------------------------------------------------------------------
 Compare Strings Case counts
 returns :
    <  0; if s1 < s2; lexiographically;
    == 0; if s1 = s2;
    >  0; if s1 > s2;
---------------------------------------------------------------------}
FUNCTION  PStrCmp(s1,s2:PStr) : INTEGER;
VAR i,l1,l2,a,b  : INTEGER;
BEGIN   {...PStrCmp}
  l1 := LENGTH(s1);
  l2 := LENGTH(s2);

  i := 1;
  while( (s1[i] = s2[i]) AND (i < l1) )
    do INC(i);

  if( l1 < l2)then
  begin
    a := 0; b := ORD(s2[i+1]);
  end
  else if( l1 > l2)then
  begin
    a := ORD(s1[i]); b := 0;
  end
  else
  begin
    a := ORD(s1[i]); b := ORD(s2[i]);
  end;
  PStrCmp := a - b;
END;    {...PStrCmp}


{---------------------------------------------------------------------
 Compare Strings Ignoring Case
 returns :
    <  0; if s1 < s2; lexiographically;
    == 0; if s1 = s2;
    >  0; if s1 > s2;
---------------------------------------------------------------------}
FUNCTION  PStrICmp(s1,s2:PStr) : INTEGER;
VAR i,l1,l2,a,b  : INTEGER;
BEGIN   {...PStrICmp}
  s1 := PStrUpr(s1); l1 := LENGTH(s1);
  s2 := PStrUpr(s2); l2 := LENGTH(s2);

  i := 1;
  while( (s1[i] = s2[i]) AND (i < l1) )
    do INC(i);

  if( l1 < l2)then
  begin
    a := 0; b := ORD(s2[i+1]);
  end
  else if( l1 > l2)then
  begin
    a := ORD(s1[i]); b := 0;
  end
  else
  begin
    a := ORD(s1[i]); b := ORD(s2[i]);
  end;
  PStrICmp := a - b;

END;    {...PStrICmp}

{-----------------------------------------------------------------------------}

Function fnDrv(fPath : String) : String;
VAR
  p1 : Integer;
begin

  {p1 = InStr(1, fPath, ":", vbTextCompare)}
  p1 := pos(':', fPath);
  If p1 = 0 Then
    fnDrv := ''
  Else
    fnDrv := copy(fPath, 1, p1);


End;

Function fnDir(fPath : String) : String;
Var
  s : String;
  p1 , p2 : Integer;

begin
{find last occurence of directory delimiter}
  p1 := pos(':', fPath);
  p2 := PStrRChr(fPath, '\');

  If (p1 = 0) And (p2 = 0) Then
    fnDir := ''
  Else If p1 = 0 Then
    fnDir := copy(fPath, 1, p2)
  Else
    fnDir := copy(fPath, p1 + 1, p2 - p1);

End;

(*
//Allowing for long filenames
//filename assumed to exist between, last path separator character '\'
//and last extension separator character '.'
*)
Function fnName2(fPath : String) : String;
var
  s : String;
  p1, p2, l : Integer;
begin
  {find last occurence of directory delimiter}
  s := fPath;
 { writeln('fPath: ',s);}
  p1 := PStrRChr(s, '\');
 { writeln('p1: ',p1);}
  p2 := PStrRChr(s, '.'); {Can be part of folder name}
 { writeln('p2: ',p2);}

  l := Length(s);
  If (p1 = 0) And (p2 = 0) Then
    fnName2 := s
  Else If p1 = 0 Then {No path statement}
    {fnName2 := Mid(fPath, 1, p2 - 1)}
    fnName2 := copy(s, 1, p2 - 1)
  Else If p2 = 0 Then {No file extension}
    fnName2 := copy(s, p1 + 1, Length(s) - p1)
  Else If (p2 < p1) And (l = p1) Then {folder name includes '.' and no filename given}
    fnName2 := ''
  Else
    fnName2 := copy(s, p1 + 1, p2 - p1 - 1);

End;

{
'Allowing for long filenames
'file extension assumed to lie between the end of the string
'and the last extension separator character '.'
'thus filename can have more than 1 '.' in its name such as 'fn.txt.bak'
'But '.' also permitted in folder paths
}

Function fnExt(fPath : String) : String;
VAR
 s : String;
 p1 : Integer;
 p2 : Integer;

begin
{
'First extension separator character
'  p1 = InStr(1, fPath, ".", vbTextCompare)
'  If p1 = 0 Then
'    fnExt = ""
'  Else
'    fnExt = Mid(fPath, p1, Len(fPath))
'  End If
}
  p1 := PStrRChr(fPath, '\');
  p2 := PStrRChr(fPath, '.');
  If p2 = 0 Then
    fnExt := ''
  Else If p2 > p1 Then
    fnExt := Copy(fPath, p2, Length(fPath))
  Else
    fnExt := '';

End;


Procedure fnsplit2( fPath :string; var drv , fdir , fname , fext : String);
begin

  drv := fnDrv(fPath);
  fdir := fnDir(fPath);
  fname := fnName2(fPath);
  fext := fnExt(fPath);

End;

Function fnmerge(var fPath:string; drv , fdir, fname , fext:string ) : String;
begin
  fPath := drv + fdir + fname + fext;
  fnmerge := fPath;
End;






{---------------------------------------------------------------------
Convert Date Type to a String
---------------------------------------------------------------------}
{
FUNCTION StrDate : DateStr;
VAR
  Year,Month,Day,DayOfWeek : WORD;
  yr  : STRING[4];
  mth,da,wkday : STRING[2];
BEGIN
  GetDate(Year,Month,Day,DayOfWeek);
  STR(Year:2,yr);
  IF Month < 10
    THEN STR(Month:1,mth)
  ELSE STR(Month:2,mth);

  IF Day < 10
    THEN STR(Day:1,da)
  ELSE STR(Day:2,da);

  StrDate := da+'/'+mth+'/'+yr;
END;
}
{---------------------------------------------------------------------
Convert Time Type to a String
---------------------------------------------------------------------}
{
FUNCTION StrTime : TimeStr;
VAR
  Hour,Minute,Second,Sec100 : WORD;
  hr,min,sec : STRING[2];
BEGIN
  GetTime(Hour,Minute,Second,Sec100);
  STR(Hour:2,hr);
  STR(Minute:2,min);
  STR(Second:2,sec);
  IF Min[1] = Space THEN Min[1] := '0';
  IF Sec[1] = Space THEN Sec[1] := '0';
  StrTime := hr+':'+min+':'+sec;
END;
}


END.

