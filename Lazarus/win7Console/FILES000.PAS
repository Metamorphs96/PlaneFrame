{
Copyright (c) 1991, Steven Conrad Harrison
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
}
{
By Steven CONRAD Harrison
Revisions
(05/12/91) : Boolean file functions added. All other functions rewritten
             in terms of these functions.
}
UNIT Files000;
INTERFACE
CONST
  StdIExt = 'CAE';  {'DAT';}
  StdOExt = 'RPT';  {'RES';}
  StdTExt = 'TRC';
TYPE
  Filename        = string; {STRING[8];}
  FileNameAndExt  = string; {STRING[12];}
  FileNameAndPath = string; {STRING[63];}

VAR
  {InFile,OutFile,Trace}
   tfp,ifp,ofp : TEXT;
   inf,outf,trc : TEXT;
   {inf,outf,trc : TextFile;}

  FUNCTION  FOpen(fname : FileNameAndPath;
                  VAR fp : TEXT; mode : CHAR) : BOOLEAN;

  PROCEDURE OpenIn(Origin : FileNameAndPath);
  PROCEDURE OpenDat(Origin : FileNameAndPath);
  PROCEDURE OpenOut(destination : FileNameAndPath);
  PROCEDURE OpenRes(destination : FileNameAndPath);
  FUNCTION  FClose(VAR fp : TEXT) : BOOLEAN;

  PROCEDURE OpenStdFiles(fname : FileName);
  PROCEDURE CloseStdFiles;
  PROCEDURE OpenTracer(fname : FileName);
  PROCEDURE CloseTracer;
  PROCEDURE GetFilename(VAR fname: FileNameAndPath;
                        VAR fp : TEXT; mode : CHAR);

  PROCEDURE OpenOut2(var ofp:TEXT; destination : FileNameAndPath);

IMPLEMENTATION
{
*************************
* File Opening function *
***************************************************}
FUNCTION  FOpen(fname : FileNameAndPath;
                VAR fp : TEXT; mode : CHAR) : BOOLEAN;
BEGIN   {...FUNCTION...FOpen}
  mode := UPCASE(mode);
  ASSIGN(fp,fname);
  CASE mode OF
    'R': {$I-} RESET(fp)   {$I+};
    'W': {$I-} REWRITE(fp) {$I+};
    'A': {$I-} APPEND(fp)  {$I+};
  END;
  FOpen := (IOresult = 0);
END;    {...FUNCTION...FOpen}

PROCEDURE OpenIn(Origin : FileNameAndPath);
BEGIN
  IF FOpen(Origin,inf,'R')
    THEN WRITELN('...INPUT FILE...<',Origin,'>...OPENED...')
  ELSE WRITELN('...FILE...<',Origin,'>...NOT FOUND...');
END;

PROCEDURE OpenDat(Origin : FileNameAndPath);
BEGIN
  IF FOpen(Origin+StdIExt,ifp,'R')
    THEN WRITELN('...INPUT FILE...<',Origin+StdIExt,'>...OPENED...')
  ELSE WRITELN('...FILE...<',Origin+StdIExt,'>...NOT FOUND...');
END;

PROCEDURE OpenOut(destination : FileNameAndPath);
BEGIN
  IF FOpen(Destination,outf,'W')
    THEN WRITELN('...OUTPUT FILE...<',Destination,'>...OPENED...')
  ELSE WRITELN('...FILE...<',Destination,'>...NOT FOUND...');
END;

PROCEDURE OpenOut2(var ofp:TEXT; destination : FileNameAndPath);
BEGIN
  IF FOpen(Destination,ofp,'W')
    THEN WRITELN('...OUTPUT FILE...<',Destination,'>...OPENED...')
  ELSE WRITELN('...FILE...<',Destination,'>...NOT FOUND...');
END;



PROCEDURE OpenRes(destination : FileNameAndPath);
BEGIN
  IF FOpen(Destination+StdOExt,ofp,'W')
    THEN WRITELN('...OUTPUT FILE...<',Destination+StdOExt,'>...OPENED...')
  ELSE WRITELN('...FILE...<',Destination+StdOExt,'>...NOT FOUND...');
END;

{
*************************
* File Closing function *
***************************************************}
FUNCTION  FClose(VAR fp : TEXT) : BOOLEAN;
BEGIN   {...FUNCTION...FClose}
  {$I-} Close(fp) {$I+};
  FClose := (IOresult = 0);
END;    {...FUNCTION...FClose}
{
**************************
* Open Standard File Set *
***************************************************}
PROCEDURE OpenStdFiles(fname : FileName);
VAR
  INname, OUTname : FileNameAndExt;
BEGIN   {...PROCEDURE...OpenStdFiles}
  INname  := fname + '.'+ StdIExt;
  OUTname := fname + '.'+ StdOExt;
  IF NOT(FOpen(INname,ifp,'R'))
    THEN WRITELN('...FILE...       <',INname,'>...NOT FOUND...')
    ELSE WRITELN('...INPUT FILE... <',INname,'>...OPENED...');
  IF NOT(FOpen(OUTname,ofp,'W'))
    THEN WRITELN('...OUTPUT FILE...<',OUTname,'>...NOT CREATED...')
    ELSE WRITELN('...OUTPUT FILE...<',OUTname,'>...OPENED...');
END;    {...PROCEDURE...OpenStdFiles}
{
***************************
* CLOSE STANDARD FILE SET *
***************************************************}
PROCEDURE CloseStdFiles;
BEGIN   {...PROCEDURE...CloseStdFiles}
  IF  FClose(ifp)
   THEN WRITELN('Input file successfully closed')
   ELSE WRITELN('Input file failed to close properly');
  IF  FClose(ofp)
   THEN WRITELN('Output file successfully closed')
   ELSE WRITELN('Output file failed to close properly');
END;    {...PROCEDURE...CloseStdFiles}
{
********************
* Open Tracer File *
***************************************************}
PROCEDURE OpenTracer(fname : FileName);
VAR
  TrcName : FileNameAndExt;
BEGIN   {...PROCEDURE...OpenTracer}
  TrcName := fname + '.'+ StdTExt;
  IF NOT(FOpen(TrcName,tfp,'W'))
    THEN WRITELN('...TRACE FILE... <',TrcName,'>...NOT CREATED...')
    ELSE WRITELN('...TRACE FILE... <',TrcName,'>...OPENED...');
END;    {...PROCEDURE...OpenTracer}
{
*********************
* CLOSE Tracer File *
***************************************************}
PROCEDURE CloseTracer;
BEGIN   {...PROCEDURE...CloseTracer}
  IF  FClose(tfp)
   THEN WRITELN('Trace file successfully closed')
   ELSE WRITELN('Trace file failed to close properly');
END;    {...PROCEDURE...CloseTracer}
{
******************************
* GET FILENAME AND OPEN FILE *
***************************************************}
PROCEDURE GetFilename(VAR fname: FileNameAndPath;
                      VAR fp : TEXT; mode : CHAR);
BEGIN   {...PROCEDURE...GetFilename}
  REPEAT
    WRITELN('..Enter filename ...');
    READLN(fname);
  UNTIL FOpen(fname,fp,mode);
END;    {...PROCEDURE...GetFilename}

END.  {of unit FILES000 }


