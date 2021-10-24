unit CHILDWIN;

{$MODE Delphi}

interface

uses LCLIntf, LCLType, LMessages, Classes, Graphics, Forms, Controls, ComCtrls, Grids, StdCtrls, SysUtils;

type
  TInputFrm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    TabSheet9: TTabSheet;
    TabSheet10: TTabSheet;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    StringGrid4: TStringGrid;
    StringGrid5: TStringGrid;
    StringGrid6: TStringGrid;
    StringGrid7: TStringGrid;
    StringGrid8: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.lfm}

uses
   Pf_vars,
   Pf_Input;

procedure TInputFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //GetCtrlData(StringGrid1);
  Get_Node_Data(StringGrid2);
  Get_Member_Data(StringGrid3);
  Get_Support_Data(StringGrid4);
  Get_MatGrp_Data(StringGrid5);
  Get_Section_Data(StringGrid6);
  Get_JointLoads_Data(StringGrid7);
  Get_MemberLoads_Data(StringGrid8);

  Action := caFree;
end;

procedure TInputFrm.FormCreate(Sender: TObject);
var i : integer;
begin

 {Nodes}
  with StringGrid2 do
  begin
    cells[1,0] := 'X-Coord';
    cells[1,1] := '[m]';
    cells[2,0] := 'Y-Coord';
    cells[2,1] := '[m]';
    //cells[3,0] := 'Description';

    for i:=1 to RowCount do cells[0,i+1] := IntToStr(i);

  end;

  {Connectivity}
  with StringGrid3 do
  begin
    cells[1,0] := 'End';
    cells[1,1] := '1';
    cells[2,0] := 'End';
    cells[2,1] := '2';
    cells[3,0] := 'Sect';
    cells[3,1] := 'Group';
    cells[4,0] := 'End 1';
    cells[4,1] := 'FIX';
    cells[5,0] := 'End 2';
    cells[5,1] := 'FIX';

    for i:=1 to RowCount do cells[0,i+1] := IntToStr(i);

  end;

  {Supports}
  with StringGrid4 do
  begin
    cells[1,0] := 'Node';
    cells[1,1] := 'No.';
    cells[2,0] := 'Trans';
    cells[2,1] := 'X';
    cells[3,0] := 'Trans';
    cells[3,1] := 'Y';
    cells[4,0] := 'Rotation';
    cells[4,1] := 'Z';

    for i:=1 to RowCount do cells[0,i+1] := IntToStr(i);

  end;

  {Material Groups}
  with StringGrid5 do
  begin
    cells[1,0] := 'Density';
    cells[1,1] := 'kg/m3';
    cells[2,0] := 'Mod. Elasticity';
    cells[2,1] := 'kPa';
    cells[3,0] := 'Thermal';
    cells[3,1] := 'Coeff';

    for i:=1 to RowCount do cells[0,i+1] := IntToStr(i);

  end;

  {Section Groups}
  with StringGrid6 do
  begin
    cells[1,0] := 'Area';
    cells[1,1] := 'm2';
    cells[2,0] := 'Inertia';
    cells[2,1] := 'm6';
    cells[3,0] := 'Material';
    cells[4,0] := 'Description';

    for i:=1 to RowCount do cells[0,i+1] := IntToStr(i);

  end;

  {Joint Loads}
  with StringGrid7 do
  begin
    cells[1,0] := 'Joint';
    cells[1,1] := 'No.';
    cells[2,0] := 'Force';
    cells[2,1] := 'X';
    cells[3,0] := 'Force';
    cells[3,1] := 'Y';
    cells[4,0] := 'Force';
    cells[4,1] := 'Z';


    for i:=1 to RowCount do cells[0,i+1] := IntToStr(i);

  end;

 {Member Loads}
  with StringGrid8 do
  begin
    cells[1,0] := 'Member';
    cells[1,1] := 'No.';
    cells[2,0] := 'Load';
    cells[2,1] := 'Type';
    cells[3,0] := 'Load';
    cells[3,1] := 'Action';
    cells[4,0] := 'Load';
    cells[4,1] := 'kN';
    cells[5,0] := 'Start';
    cells[5,1] := 'Cover';

    for i:=1 to RowCount do cells[0,i+1] := IntToStr(i);

  end;

  with StringGrid1 do
  begin
    cells[1,0] := 'Force';
    cells[1,1] := 'Action';
    cells[2,0] := 'Gravity';
    cells[2,1] := 'm/s2';

    for i:=1 to RowCount do cells[0,i+1] := IntToStr(i);

  end;
  
  Get_Default_Values;
  Get_Init_Data;

end;

procedure TInputFrm.StringGrid1Click(Sender: TObject);
begin
//
end;

procedure TInputFrm.PageControl1Change(Sender: TObject);
begin
//Page Control
end;

end.
