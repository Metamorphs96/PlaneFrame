program WinFrm;

{$MODE Delphi}

uses
  Forms, Interfaces,
  Main in 'MAIN.PAS' {MainForm},
  About in 'about.pas' {AboutBox},
  Pf_Anal in 'Pf_anal.pas',
  Pf_Gen in 'Pf_gen.pas',
  Pf_Load in 'Pf_load.pas',
  Pf_Vars in 'Pf_vars.pas',
  Mi_Plot in 'Mi_Plot.pas' {GraphForm},
  Pf_Prt in 'Pf_Prt.pas';

{.$R *.RES}

begin
  Application.Title := 'Plane Frame Analysis for Windows';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TGraphForm, GraphForm);
  Application.Run;
end.
