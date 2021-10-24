unit AppMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus;

type

  { TfrmAppMain }

  TfrmAppMain = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmAppMain: TfrmAppMain;

implementation
Uses
  Child;

{$R *.lfm}

{ TfrmAppMain }

procedure TfrmAppMain.MenuItem1Click(Sender: TObject);
begin

end;

procedure TfrmAppMain.MenuItem4Click(Sender: TObject);
begin
  Form1 := TForm1.create(Application);
end;

end.

