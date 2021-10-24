program w7cpframe;

uses
  Pf_Vars,
  pfFScan,
  Files000,
  Pf_Load,
  Pf_Gen,
  Pf_Prt,
  PString,
  Pf_Anal;

var
  fDrv: string;
  fPath: string;
  fName: string;
  fExt: string;

  ifullName: FileNameAndPath;
  ofullName: FileNameAndPath;
  TraceFName: FileNameAndPath;

  s: string;
  isOk: boolean;


Procedure MainApplication;
begin
  if ParamCount = 0 then
  begin
    writeln('Not Enough Parameters');
    writeln(fnName2(ParamStr(0)) + ' [name of input file]');
  end
  else
  begin
    writeln('2D/Plane Frame Analysis ... ');
    ifullName := ParamStr(1);
    writeln('Input Data File     : ', ifullName);

     {
     ofullName := fnName2(ifullName) + '.res';
     writeln('ExtractFileDrive  : ',ExtractFileDrive(ifullName));
     writeln('ExtractFileDir    : ',ExtractFileDir(ifullName));
     writeln('ExtractFilePath   : ',ExtractFilePath(ifullName));
     writeln('ExtractFileName   : ',ExtractFileName(ifullName));
     writeln('ExtractFileExt    : ',ExtractFileExt(ifullName));
     writeln('fnDir             : ',fnDir(ifullName));
     writeln(ofullName);
     }

    fnsplit2(ifullName, fDrv, fPath, fName, fExt);
    ofullName := fnmerge(ofullName, fDrv, fPath, fName, '.rpt');
    writeln('Output Report File  : ', ofullName);

    TraceFName := fnmerge(TraceFName, fDrv, fPath, fName, '.trc');
    writeln('Trace Report File  : ', TraceFName);


    {RunMainMenu;}
    Alloc_Anal_Mem;
    {Get_Default_Values;}

    {Execute Command Option Here}

    OpenIn(ifullName);
    Read_Data;
    if data_loaded then
      Get_Direction_Cosines;

    {OpenOut2(inf,ofullName);}
    {Archive_Data;}

    OpenOut2(trc,TraceFName);
    writeln('Analysis ...');
    Analyse_Frame;
    writeln('... Analysis');

    writeln('Report Results ...');
    OpenOut(ofullName);
    Output_Results;
    Close(outf);
    writeln('... Report Results');



    {End of Interaction}

    Free_Anal_Mem;

(*
    OpenOut('archive.dat');
    Archive_Data;
*)

    writeln('... 2D/Plane Frame Analysis');
  end;

end;

Begin
  MainApplication
end.



