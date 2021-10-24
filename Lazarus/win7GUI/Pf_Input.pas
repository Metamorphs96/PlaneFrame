{###### Pf_Input.PAS ######
 ... a unit file of Input routines for the Framework program ...
     R G Harrison   --  Version 5.2  --  20/06/02  ...

     Revision history :-
        31/12/95 - implemented ..
        17/ 2/96 - changed to MicroSTRAN sign convention for output ..
        29/ 2/96 - member end releases added
         4/ 3/96 - main data structures made DYNAMIC
        30/ 3/96 - graphics routines standardised
        20/06/02 - converted to Delphi
}
UNIT Pf_Input;

{$MODE Delphi}

INTERFACE
uses
  SysUtils,
  Dialogs,          {.. Dialog operations - standard unit ..}
  ComCtrls,
  Grids;


//procedure  GetCtrlData(Var Grid0: TStringGrid);
procedure  Get_Node_Data(Var Grid1: TStringGrid);
procedure  Get_Member_Data(Var Grid2: TStringGrid);
procedure  Get_Support_Data(Var Grid3: TStringGrid);
procedure  Get_MatGrp_Data(Var Grid4: TStringGrid);
procedure  Get_Section_Data(Var Grid5: TStringGrid);
procedure  Get_JointLoads_Data(Var Grid6: TStringGrid);
procedure  Get_MemberLoads_Data(Var Grid7: TStringGrid);

PROCEDURE  Get_Default_Values;
PROCEDURE  Get_Init_Data;

(*
procedure  Init_Node_Data(Var Grid1: TStringGrid);
procedure  Init_Member_Data(Var Grid2: TStringGrid);
procedure  Init_Support_Data(Var Grid3: TStringGrid);
procedure  Init_MatGrp_Data(Var Grid4: TStringGrid);
procedure  Init_Section_Data(Var Grid5: TStringGrid);
procedure  Init_JointLoads_Data(Var Grid6: TStringGrid);
procedure  Init_MemberLoads_Data(Var Grid7: TStringGrid);
procedure  Init_Control_Data(Var TabSht : TTabSheet);
procedure  Init_Job_Data(Var TabSht : TTabSheet);
*)
{
===========================================================================
}
IMPLEMENTATION

USES
      CHILDWIN,
      Pf_vars,          {.. Application Variables ..}
      Pf_gen,
      Pf_Graph,
      Pf_anal,
      Pf_Prt;

procedure Get_Node_Data(Var grid1: TStringGrid);
// Coordinates Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO no_jts DO
    WITH nod_grp[j] DO
      begin
        x       := StrToFloat(grid1.Cells [1,j]);
        y       := StrToFloat(grid1.Cells [2,j]);
      end;
end;

procedure  Get_Member_Data(Var grid2: TStringGrid);
//  Connectivity  Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO m DO
    WITH con_grp[j] DO
      begin
        //READLN(inf, dummy, jj, jk, sect, rel_i, rel_j);
        jj     := StrToInt(grid2.Cells [1,j]);
        jk     := StrToInt(grid2.Cells [2,j]);
        sect   := StrToInt(grid2.Cells [3,j]);
        rel_i  := StrToInt(grid2.Cells [4,j]);
        rel_j  := StrToInt(grid2.Cells [5,j]);
      end;
end;

procedure  Get_Support_Data(Var Grid3: TStringGrid);
//  Support Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO nrj DO
    WITH sup_grp[j] DO
      begin
        js       := StrToInt(grid3.Cells [1,j]);
        rx       := StrToInt(grid3.Cells [2,j]);
        ry       := StrToInt(grid3.Cells [3,j]);
        rm       := StrToInt(grid3.Cells [4,j]);
        nr       := nr + rx + ry + rm;
      end;
    //READLN(inf, dummy, js, rx, ry, rm);
end;

procedure  Get_MatGrp_Data(Var Grid4: TStringGrid);
//  Materials Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO nmg  DO
    WITH mat_grp[j] DO
      begin
        density := StrToFloat(grid4.Cells [1,j]);
        emod    := StrToFloat(grid4.Cells [2,j]);
        therm   := StrToFloat(grid4.Cells [3,j]);
       end;
      //READLN(inf, dummy, density, emod, therm);
end;

procedure  Get_Section_Data(Var Grid5: TStringGrid);
//  Sections Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO nsg  DO
    WITH mem_grp[j] DO
      begin
        ax      := StrToFloat(grid5.Cells [1,j]);
        iz      := StrToFloat(grid5.Cells [2,j]);
        mat     := StrToInt(grid5.Cells [3,j]);
        descr   := grid5.Cells [4,j];
      end;
      //READLN(inf, dummy, ax, iz, mat, descr);
end;

procedure  Get_JointLoads_Data(Var Grid6: TStringGrid);
//  Joint Loads Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO njl DO
    WITH jnt_lod[j] DO
      begin
        jt       := StrToInt(grid6.Cells [1,j]);
        fx       := StrToFloat(grid6.Cells [2,j]);
        fy       := StrToFloat(grid6.Cells [3,j]);
        mz       := StrToFloat(grid6.Cells [4,j]);
      end;
      //READLN(inf, dummy, jt, fx, fy, mz );
end;

procedure  Get_MemberLoads_Data(Var Grid7: TStringGrid);
//  Member Loads Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO nml DO
    WITH mem_lod[j] DO
      begin
        mem_no      := StrToInt(grid7.Cells [1,j]);
        lcode       := StrToInt(grid7.Cells [2,j]);
        acode       := StrToInt(grid7.Cells [3,j]);
        load        := StrToFloat(grid7.Cells [4,j]);
        start       := StrToFloat(grid7.Cells [5,j]);
        cover       := StrToFloat(grid7.Cells [6,j]);
      end;
      //READLN(inf, dummy, mem_no, lcode, acode, load, start, cover);
end;

 {
  << Get_Default_Values >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH
     7/2/92 - implemented ..
  }
  PROCEDURE Get_Default_Values;
  VAR row : BYTE;
  BEGIN
    FILLCHAR(mat_grp, SIZEOF(mat_grp), 0);
    FILLCHAR(nod_grp, SIZEOF(nod_grp), 0);
    FILLCHAR(con_grp, SIZEOF(con_grp), 0);
    FILLCHAR(sup_grp, SIZEOF(sup_grp), 0);
    FILLCHAR(mem_grp, SIZEOF(mem_grp), 0);
    FILLCHAR(jnt_lod, SIZEOF(jnt_lod), 0);
    FILLCHAR(mem_lod, SIZEOF(mem_lod), 0);
    FILLCHAR(grv_lod, SIZEOF(grv_lod), 0);
    job     := blank;
    loadname:= blank;
    projno  := blank;
    author  := blank;
    run_no  := blank;
    no_jts  :=  1;
    m       :=  1;
    nrj     :=  1;
    nmg     :=  1;
    nsg     :=  1;
    ngl     :=  0;
    nml     :=  0;
    njl     :=  0;
    mag     :=  1;

    mat_grp[1].density := 7850;
    mat_grp[1].emod    := 2e8;
    mat_grp[1].therm   := 1.17e-5;
    sup_grp[1].js      := 1;
    sup_grp[1].rx      := 1;
    sup_grp[1].ry      := 1;
    sup_grp[1].rm      := 1;
  END; {.. Get_Default_Values ..}
 
  {
  << Get_Init_Data >>
  }
  PROCEDURE Get_Init_Data;
  Const
//        Data    = 'C146_2.dat';
        Data    = 'HIP-03.DAT';
  var
    i,n : integer;
    dummy_str : STRING;
    dummy : BYTE;
   
  BEGIN
    //Get_Default_Values;

    if FOpen(Data,inf,'r') then 
     begin
       while NOT(EOF(inf)) DO
         begin
       READLN(inf,dummy_str);
      READLN(inf,job);
      READLN(inf,loadname);
      READLN(inf,projno);
      READLN(inf,author);
      READLN(inf,run_no);
  
      READLN(inf,dummy_str);
      READLN(inf,no_jts, m, nrj, nmg, nsg, njl, nml, ngl, mag);
      //WriteXY( 'Coordinates ! ',1,2);
      READLN(inf,dummy_str);
      FOR i := 1 TO no_jts DO
        WITH nod_grp[i] DO   READLN(inf, dummy, x, y);
      //WriteXY( 'Connectivity ! ',1,2);
      READLN(inf,dummy_str);
      FOR i := 1 TO m DO
        WITH con_grp[i] DO
          BEGIN
            READLN(inf, dummy, jj, jk, sect, rel_i, rel_j);
          END;
      //WriteXY( 'Supports ! ',1,2);
      READLN(inf,dummy_str);
      nr := 0;
      FOR i := 1 TO nrj DO
        WITH sup_grp[i] DO
        BEGIN
          READLN(inf, dummy, js, rx, ry, rm);
          nr := nr + rx + ry + rm;
        END;
      //WriteXY( 'Material Groups ! ',1,2);
      READLN(inf,dummy_str);
      FOR i := 1 TO nmg DO
        WITH mat_grp[i] DO   READLN(inf, dummy, density, emod, therm);
      //WriteXY( 'Section Groups ! ',1,2);
      READLN(inf,dummy_str);
      FOR i := 1 TO nsg DO
        WITH mem_grp[i] DO   READLN(inf, dummy, ax, iz, mat, descr);
      //WriteXY( 'Joint Forces ! ',1,2);
      READLN(inf,dummy_str);
      FOR i := 1 TO njl DO
        WITH jnt_lod[i] DO   READLN(inf, dummy, jt, fx, fy, mz );
      //WriteXY( 'Member Forces ! ',1,2);
      READLN(inf,dummy_str);
      FOR i := 1 TO nml DO
        WITH mem_lod[i] DO   READLN(inf, dummy, mem_no, lcode, acode, load, start, cover);
      READLN(inf,dummy_str);
      WITH grv_lod DO        READLN(inf, acode, load);
         end;
       data_loaded := TRUE;
  
       FClose(inf);
     end
    else showmessage('File Not Found');

  END;  {.. Get_Init_Data ..}


(*
procedure Init_Node_Data(Var grid1: TStringGrid);
// Coordinates Data
var
  i,j,n : integer;
begin
  //i := 2;
  FOR j := 1 TO no_jts DO
    WITH nod_grp[j] DO
      begin
        grid1.Cells [1,j]  := FloattoStr(x);
        grid1.Cells [2,j]  := FloattoStr(y);
      end;
end;
procedure  Init_Member_Data(Var grid2: TStringGrid);
//  Connectivity  Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO m DO
    WITH con_grp[j] DO
      begin
        grid2.Cells [1,j] := IntToStr(jj)    ;
        grid2.Cells [2,j] := IntToStr(jk)    ;
        grid2.Cells [3,j] := IntToStr(sect)  ;
        grid2.Cells [4,j] := IntToStr(rel_i) ;
        grid2.Cells [5,j] := IntToStr(rel_j) ;
      end;                                     
end;                                           

procedure  Init_Support_Data(Var Grid3: TStringGrid);
//  Support Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO nrj DO
    WITH sup_grp[j] DO
      begin
       grid3.Cells [1,j]        := IntToStr(js) ;
       grid3.Cells [2,j]        := IntToStr(rx) ;
       grid3.Cells [3,j]        := IntToStr(ry) ;
       grid3.Cells [4,j]        := IntToStr(rm) ;
       //nr       := nr + rx + ry + rm;   
      end;
    //READLN(inf, dummy, js, rx, ry, rm);
end;

procedure  Init_MatGrp_Data(Var Grid4: TStringGrid);
//  Materials Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO nmg  DO
    WITH mat_grp[j] DO
      begin
        grid4.Cells [1,j]:= FloattoStr(density)  ;
        grid4.Cells [2,j]:= FloattoStr(emod)     ;
        grid4.Cells [3,j]:= FloattoStr(therm)    ;
       end;         
      //READLN(inf, dummy, density, emod, therm); 
end;

procedure  Init_Section_Data(Var Grid5: TStringGrid);
//  Sections Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO nsg  DO
    WITH mem_grp[j] DO
      begin
        grid5.Cells [1,j]         :=   FloattoStr(ax) ;
        grid5.Cells [2,j]         :=   FloattoStr(iz) ;
        grid5.Cells [3,j]         :=   IntToStr(mat);
        grid5.Cells [4,j]         :=   descr;
      end;    
      //READLN(inf, dummy, ax, iz, mat, descr); 
end;

procedure  Init_JointLoads_Data(Var Grid6: TStringGrid);
//  Joint Loads Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO njl DO
    WITH jnt_lod[j] DO
      begin
       grid6.Cells [1,j]      :=    IntToStr(jt)  ;
       grid6.Cells [2,j]      :=    FloattoStr(fx)    ;
       grid6.Cells [3,j]      :=    FloattoStr(fy)    ;
       grid6.Cells [4,j]      :=    FloattoStr(mz)   ;
      end;     
      //READLN(inf, dummy, jt, fx, fy, mz );  
end;

procedure  Init_MemberLoads_Data(Var Grid7: TStringGrid);
//  Member Loads Data
var
  i,j,n : integer;
begin
  //i := 1;
  FOR j := 1 TO nml DO
    WITH mem_lod[j] DO
      begin
        grid7.Cells [1,j]    :=       IntToStr(mem_no) ;
        grid7.Cells [2,j]    :=       IntToStr(lcode)  ;
        grid7.Cells [3,j]    :=       IntToStr(acode)  ;
        grid7.Cells [4,j]    :=       FloattoStr(load) ;
        grid7.Cells [5,j]    :=       FloattoStr(start);
        grid7.Cells [6,j]    :=       FloattoStr(cover);
      end;       
      //READLN(inf, dummy, mem_no, lcode, acode, load, start, cover);
end;

procedure  Init_Control_Data(Var TabSht : TTabSheet);
//  Member Loads Data
var
  i,j,n : integer;
begin

   //READLN(inf,no_jts, m, nrj, nmg, nsg, njl, nml, ngl, mag);

   Edit1   :=   IntToStr(no_jts);
   InputFrm.Edit2   :=   IntToStr(m);
   InputFrm.Edit3   :=   IntToStr(nsg);
   InputFrm.Edit4   :=   IntToStr(nmg);
   InputFrm.Edit5   :=   IntToStr(nrj);
   InputFrm.Edit6   :=   IntToStr(njl);
   
end;

procedure  Init_Job_Data(Var TabSht : TTabSheet);
//  Member Loads Data
var
  i,j,n : integer;
begin

   InputFrm.Edit7   :=   job;
   InputFrm.Edit8   :=   loadname;
   InputFrm.Edit9   :=   projno;
   InputFrm.Edit10  :=   author;
   InputFrm.Edit11  :=   run_no;
   InputFrm.Edit12  :=   plot_mag;

end;
*)
BEGIN
END.    {.. UNIT Pf_Input..}

  E  := strtofloat(form1.ed_e.text);
  Iz := strtofloat(form1.edIz.text);
