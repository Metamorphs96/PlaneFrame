{###### Pf_TEST.PAS ######
    Windows 95 Delphi Version 3.0

    Version 5.0  --  21/05/02

    Written by:

    Roy Harrison,
    Roy Harrison & Associates,
    Incorporating TECTONIC Software Engineers,
    MODBURY HEIGHTS, SA 5092,

    Purpose:

        a unit file of Test procedures for the Windows Tank Wall program ...

    Revisions:
        21 May 02 - completed;
    -----------------------------------------------------------------------
}
UNIT Pf_Test;
INTERFACE
USES
  
      Dialogs,          {.. Dialog operations - standard unit ..}
      Pf_Vars,          {.. Tank wall analysis types and declarations..}
      MathFun,          {.. General maths routines for power function ..}
      Pf_Gen,           {.. Tank wall general routines ..}
      Pf_anal,          {.. Tank wall analysis routines ..}
      //TnkGraf,          {.. Tank wall screen plot routines ..}
      //TnkReo,           {.. Tank wall reinforcement routines ..}
      Pf_Prt;           {.. Tank wall print output routines ..}

                
PROCEDURE RunTest;

{
===========================================================================
}
IMPLEMENTATION

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
  << RunTest >>
  }
  PROCEDURE RunTest;
  Const
  //      Data    = 'C146_2.dat';
  //     Data    = 'HIP-03.DAT';
       Data    = 'refFwrk3.dat';
        //Mi_Results = 'C146_2.pfm';
  var
    i,n : integer;
    dummy_str : STRING;
    dummy : BYTE;

  BEGIN
    //Alloc_Anal_Mem;
    Get_Default_Values;
  
    {memo1.lines.Clear;}
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
    
    IF data_loaded THEN   Get_Direction_Cosines;

    
    Analyse_Frame;
    
  END;  {.. RunTest ..}



End.
