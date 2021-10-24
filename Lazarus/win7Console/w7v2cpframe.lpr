program w7v2cpframe;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  Pf_Vars,
  pfFScan,
  Files000,
  Pf_Load,
  Pf_Gen,
  Pf_Prt,
  PString,
  Pf_Anal
  { you can add units before this comment};

type

  { TMyApplication }

  TMyApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

Var
  fDrv : string;
  fPath : string;
  fName : string;
  fExt : string;

  ifullName : FileNameAndPath;
  ofullName : FileNameAndPath;
  TraceFName : FileNameAndPath;

  s : string;
  isOk : Boolean;

{ TMyApplication }

procedure TMyApplication.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h','help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }

  if ParamCount = 0 then
  begin
    writeln('Not Enough Parameters');
    writeln(fnName2(ParamStr(0)) + ' [name of input file]');
  end
  else
  begin
     writeln('2D/Plane Frame Analysis ... ');
     ifullName :=   ParamStr(1);
     writeln('Input Data File     : ',ifullName);

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

     fnsplit2(ifullName, fDrv,fPath,fName,fExt);
     fnmerge(ofullName, fDrv,fPath,fName,'.rpt');
     writeln('Output Report File  : ',ofullName);

     fnmerge(TraceFName, fDrv,fPath,fName,'.trc');
     writeln('Trace Report File  : ',TraceFName);


     //RunMainMenu;
     Alloc_Anal_Mem;
     //Get_Default_Values;

     // Execute Command Option Here

     OpenIn(ifullName);
     Read_Data;
     IF data_loaded THEN   Get_Direction_Cosines;

     //OpenOut2(inf,ofullName);
     //Archive_Data;

     //OpenOut2(trc,TraceFName);
     writeln('Analysis ...');
     Analyse_Frame;
     OpenOut(ofullName);
     Output_Results;
     CLOSE(outf);
     writeln('... Analysis');



     //End of Interaction

     Free_Anal_Mem;

(*
    OpenOut('archive.dat');
    Archive_Data;
*)

     writeln('... 2D/Plane Frame Analysis');
  end;

  // stop program loop
  Terminate;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TMyApplication.Destroy;
begin
  inherited Destroy;
end;

procedure TMyApplication.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: TMyApplication;
begin
  Application:=TMyApplication.Create(nil);
  Application.Title:='My Application';
  Application.Run;
  Application.Free;
end.

