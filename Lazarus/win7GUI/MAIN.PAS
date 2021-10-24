unit MAIN;

{$MODE Delphi}

interface

uses  LCLIntf, LCLType, LMessages, SysUtils, Classes, Graphics, Forms, Controls, Menus,
      StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileCloseItem: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    SpeedPanel: TPanel;
    OpenBtn: TSpeedButton;
    SaveBtn: TSpeedButton;
    CutBtn: TSpeedButton;
    CopyBtn: TSpeedButton;
    PasteBtn: TSpeedButton;
    ExitBtn: TSpeedButton;
    StatusBar: TStatusBar;
    Test1: TMenuItem;
    FileInput1: TMenuItem;
    DrawFrame1: TMenuItem;
    Model: TMenuItem;
    Anlysis1: TMenuItem;
    Display1: TMenuItem;
    Geometry1: TMenuItem;
    Moments1: TMenuItem;
    Axial1: TMenuItem;
    Shear1: TMenuItem;
    Deflection1: TMenuItem;
    Loads1: TMenuItem;
    SaveResults1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure WindowCascadeItemClick(Sender: TObject);
    procedure UpdateMenuItems(Sender: TObject);
    procedure WindowTileItemClick(Sender: TObject);
    procedure WindowArrangeItemClick(Sender: TObject);
 (*
    procedure FileNewItemClick(Sender: TObject);
    procedure FileCloseItemClick(Sender: TObject);
*)
    procedure FileOpenItemClick(Sender: TObject);
    procedure FileExitItemClick(Sender: TObject);
(*
    procedure FileSaveItemClick(Sender: TObject);
    procedure FileSaveAsItemClick(Sender: TObject);
 *)
    procedure CutItemClick(Sender: TObject);
    procedure CopyItemClick(Sender: TObject);
    procedure PasteItemClick(Sender: TObject);
    procedure WindowMinimizeItemClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpAboutItemClick(Sender: TObject);
    procedure FileInput1Click(Sender: TObject);
    procedure DrawFrame1Click(Sender: TObject);
    procedure Geometry1Click(Sender: TObject);
    procedure Moments1Click(Sender: TObject);
    procedure Axial1Click(Sender: TObject);
    procedure Shear1Click(Sender: TObject);
    procedure Delta1Click(Sender: TObject);
    procedure Anlysis1Click(Sender: TObject);
    procedure Loads1Click(Sender: TObject);
    procedure SaveResults1Click(Sender: TObject);
    procedure Display1Click(Sender: TObject);
    procedure ModelClick(Sender: TObject);
  private
    { Private declarations }
    procedure CreateMDIChild(const Name: string);
    procedure ShowHint(Sender: TObject);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses CHILDWIN, ABOUT, Mi_Plot,
     Pf_vars, Pf_Test, Pf_Graph, Pf_gen, Pf_Prt, Pf_anal;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  kk := 1;
  Application.OnHint := ShowHint;
  Screen.OnActiveFormChange := UpdateMenuItems;
  analysed     := FALSE;
end;

procedure TMainForm.ShowHint(Sender: TObject);
begin
  StatusBar.SimpleText := Application.Hint;
end;

procedure TMainForm.CreateMDIChild(const Name: string);
var
  Child: TInputFrm;
begin
  { create a new MDI child window }
  Child := TInputFrm.Create(Application);
  Child.Caption := Name;
end;
(*
procedure TMainForm.FileNewItemClick(Sender: TObject);
begin
  //data_updated := TRUE;
  if NOT data_updated then
    CreateMDIChild('NONAME' + IntToStr(MDIChildCount + 1))
  ELSE
    MessageDlg('Data Modified', mtWarning, [mbOk], 0);
end;
*)
procedure TMainForm.FileOpenItemClick(Sender: TObject);
begin
   if OpenDialog.Execute then
   begin
    // my file input code

    //CreateMDIChild(OpenDialog.FileName);
   end;
end;
(*
procedure TMainForm.FileCloseItemClick(Sender: TObject);
begin
  if ActiveMDIChild <> nil then
    ActiveMDIChild.Close;
end;

procedure TMainForm.FileSaveItemClick(Sender: TObject);
begin
  { save current file (ActiveMDIChild points to the window) }
end;

procedure TMainForm.FileSaveAsItemClick(Sender: TObject);
begin
  { save current file under new name }
end;
*)
procedure TMainForm.FileExitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.CutItemClick(Sender: TObject);
begin
  {cut selection to clipboard}
end;

procedure TMainForm.CopyItemClick(Sender: TObject);
begin
  {copy selection to clipboard}
end;

procedure TMainForm.PasteItemClick(Sender: TObject);
begin
  {paste from clipboard}
end;

procedure TMainForm.WindowCascadeItemClick(Sender: TObject);
begin
  Cascade;
end;

procedure TMainForm.WindowTileItemClick(Sender: TObject);
begin
  Tile;
end;

procedure TMainForm.WindowArrangeItemClick(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TMainForm.WindowMinimizeItemClick(Sender: TObject);
var
  I: Integer;
begin
  { Must be done backwards through the MDIChildren array }
  for I := MDIChildCount - 1 downto 0 do
    MDIChildren[I].WindowState := wsMinimized;
end;

procedure TMainForm.UpdateMenuItems(Sender: TObject);
begin
  FileCloseItem.Enabled := MDIChildCount > 0;
  FileSaveItem.Enabled := MDIChildCount > 0;
  FileSaveAsItem.Enabled := MDIChildCount > 0;
  CutItem.Enabled := MDIChildCount > 0;
  CopyItem.Enabled := MDIChildCount > 0;
  PasteItem.Enabled := MDIChildCount > 0;
  SaveBtn.Enabled := MDIChildCount > 0;
  CutBtn.Enabled := MDIChildCount > 0;
  CopyBtn.Enabled := MDIChildCount > 0;
  PasteBtn.Enabled := MDIChildCount > 0;
  WindowCascadeItem.Enabled := MDIChildCount > 0;
  WindowTileItem.Enabled := MDIChildCount > 0;
  WindowArrangeItem.Enabled := MDIChildCount > 0;
  WindowMinimizeItem.Enabled := MDIChildCount > 0;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Screen.OnActiveFormChange := nil;
  Free_Anal_Mem;
end;

procedure TMainForm.HelpAboutItemClick(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.FileInput1Click(Sender: TObject);
begin
 // Alloc_Anal_Mem;
  //RunTest;
end;

procedure TMainForm.DrawFrame1Click(Sender: TObject);
var plotcase : BYTE;
  mychrt : TGraphForm;
  Bitmap: Tbitmap;
  //i,h : integer;
begin
  Bitmap := TBitmap.Create;

  with BitMap do
  begin
     Width  := 800;
     Height := 600;

     With canvas do
         begin
            plotcase := moments;
            Plot_To_Screen (plotcase, Bitmap);
         end;
  end;

  mychrt := TGraphForm.create(application);
  mychrt.caption := IntToStr(kk)+' : Chart';
  mychrt.Image1.Picture.Graphic := Bitmap;
  mychrt.show;
  kk := kk + 1;
 
end;

procedure TMainForm.Geometry1Click(Sender: TObject);
begin
//Geometry Plot
     Display_Network(geometry)
end;

procedure TMainForm.Loads1Click(Sender: TObject);
begin
//Loads Plot
     Display_Network(loads)
end;

procedure TMainForm.Moments1Click(Sender: TObject);
begin
//Moment Plot
     Display_Network(moments)
end;

procedure TMainForm.Axial1Click(Sender: TObject);
begin
//Axial Plot
     Display_Network(axial)
end;

procedure TMainForm.Shear1Click(Sender: TObject);
begin
//Shear Plot
     Display_Network(shears)
end;

procedure TMainForm.Delta1Click(Sender: TObject);
begin
//Deflection Plot
     Display_Network(delta)
end;


procedure TMainForm.Anlysis1Click(Sender: TObject);
begin
//Analysis Unit
  Alloc_Anal_Mem;
  RunTest;
end;

procedure TMainForm.SaveResults1Click(Sender: TObject);
Const
   Mi_Results = 'TstResults.pfm';
begin
//Save Analysis Results
    if FOpen(Mi_Results,outf,'W') then
      begin
        Output_Results;
        FClose(outf);
        MessageDlg('Results in File > '+Mi_Results, mtInformation,[mbOk], 0);
       End
    else showmessage('Unable to create File');
end;

procedure TMainForm.Display1Click(Sender: TObject);
begin
//Display Screen Graphics
   Geometry1.Enabled     := Analysed;
   Loads1.Enabled        := Analysed;
   Moments1.Enabled      := Analysed;
   Axial1.Enabled        := Analysed;
   Shear1.Enabled        := Analysed;
   Deflection1.Enabled   := Analysed;
end;

procedure TMainForm.ModelClick(Sender: TObject);
begin
//Model Menu Options
   SaveResults1.Enabled  := Analysed;
   Anlysis1.Enabled      := NOT Analysed;
end;

end.
