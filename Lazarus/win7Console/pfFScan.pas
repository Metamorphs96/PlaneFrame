{###### Pf_Input.PAS ######
 ... a unit file of Input routines for the Framework program ...
     R G Harrison   --  Version 5.2  --  30/ 3/96  ...

     Revision history :-
        31/12/95 - implemented ..
        17/ 2/96 - changed to MicroSTRAN sign convention for output ..
        29/ 2/96 - member end releases added
         4/ 3/96 - main data structures made DYNAMIC
        30/ 3/96 - graphics routines standardised
}
UNIT pfFScan;
INTERFACE

USES
      Files000,
      Pf_Vars;          {.. Application Variables ..}


  PROCEDURE Read_Data;
  PROCEDURE Archive_Data;
  PROCEDURE Alloc_Anal_Mem;
  PROCEDURE Get_Default_Values;

{
===========================================================================
}
IMPLEMENTATION
 {
<<< Alloc_Anal_Mem >>>
    ..16/9/89..
...A procedure to allocate dynamic memory for variables ...
}
PROCEDURE Alloc_Anal_Mem;
VAR      size : WORD;
BEGIN
  size := SIZEOF(Float_vector);
  GETMEM(l,  size);
  GETMEM(ad, size);
  GETMEM(fc, size);
  GETMEM(ar, size);
  GETMEM(dj, size);
  GETMEM(dd,  size);

  size := SIZEOF(Rot_matrix);
  GETMEM(r,  size);

  size := SIZEOF(Float_matrix);
  GETMEM(af, size);
  GETMEM(s,   size);

  size := SIZEOF(Memb_Mom);
  GETMEM(span_mom,  size);

END;     {...Alloc_Anal_Mem...}
{
<<< Free_Anal_Mem >>>
    ..16/9/89..
...A procedure to allocate dynamic memory for variables ...
}
PROCEDURE Free_Anal_Mem;
VAR      size : WORD;
BEGIN
  size := SIZEOF(Float_vector);
  FREEMEM(l,  size);
  FREEMEM(ad, size);
  FREEMEM(fc, size);
  FREEMEM(ar, size);
  FREEMEM(dj, size);
  FREEMEM(dd,  size);

  size := SIZEOF(Rot_matrix);
  FREEMEM(r,  size);

  size := SIZEOF(Float_matrix);
  FREEMEM(af, size);
  FREEMEM(s,  size);

  size := SIZEOF(Memb_Mom);
  FREEMEM(span_mom,  size);
END;     {...Free_Anal_Mem...}



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
  << Archive_Data >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH
     7/2/92 - implemented ..
  }
  PROCEDURE Archive_Data;
  CONST pwid = 40;
  VAR i : BYTE;
  BEGIN

(*   quitmenu := TRUE;
//    PlainBox(AutoX,AutoY,'Action : ',pwid,2,white,blue);
//    WriteXY( 'Data being SAVED ! ',1,1);
//    WriteXY( 'Control Parameters ! ',1,2);
//    REWRITE(inf);
*)

    writeln('Archive_Data: Saving Data File ...');
    WRITELN(inf,'JOB DETAILS::');
    WRITELN(inf,job);
    WRITELN(inf,loadname);
    WRITELN(inf,projno);
    WRITELN(inf,author);
    WRITELN(inf,run_no);

    WRITELN('CONTROL DATA::');
    WRITELN(inf,'CONTROL DATA::');
    {WRITELN(inf,no_jts:6, m:6, nrj:6, nmg:6, nsg:6, njl:6, nml:6, ngl:6, mag:6);}
    WRITELN(inf,no_jts:6, m:6, nrj:6, nmg:6, nsg:6, njl:6, nml:6, ngl:6);

    WRITELN('NODES::');
    WRITELN(inf,'NODES::');
    FOR i := 1 TO no_jts DO
      WITH nod_grp[i] DO   WRITELN(inf,i:8,x:12:4,y:12:4);

    WRITELN('MEMBERS::');
    WRITELN(inf,'MEMBERS::');
    FOR i := 1 TO m DO
      WITH con_grp[i] DO   WRITELN(inf,i:8,jj:6,jk:6,sect:6,rel_i:6,rel_j:2);

    WRITELN('SUPPORTS::');
    WRITELN(inf,'SUPPORTS::');
    FOR i := 1 TO nrj DO
      WITH sup_grp[i] DO   WRITELN(inf,i:8,js :6, rx:6, ry:2, rm:2);

    WRITELN('MATERIALS::');
    WRITELN(inf,'MATERIALS::');
    FOR i := 1 TO nmg DO
      WITH mat_grp[i] DO   WRITELN(inf,i:8,density:15:3, emod:15:3, therm:15:10);

    WRITELN('SECTIONS::');
    WRITELN(inf,'SECTIONS::');
    FOR i := 1 TO nsg DO
      WITH mem_grp[i] DO   WRITELN(inf,i:8,ax:15, iz:15, mat:6, descr  : 28);

    WRITELN('JOINT LOADS ::');
    WRITELN(inf,'JOINT LOADS ::');
    FOR i := 1 TO njl DO
      WITH jnt_lod[i] DO   WRITELN(inf,i:8,jt: 6, fx:15:7, fy:15:7, mz :15:7);
{    WriteXY( PAD('Member Loads ! ',pwid),1,2);}

    WRITELN('MEMBER LOADS ::');
    WRITELN(inf,'MEMBER LOADS ::');
    FOR i := 1 TO nml DO
      WITH mem_lod[i] DO   WRITELN(inf,i:8,mem_no:6, lcode : 6, acode : 6, load:15:7, start:15:7, cover : 12:4);

    WRITELN('GRAVITY LOADS ::');
    WRITELN(inf,'GRAVITY LOADS ::');
    FOR i := 1 TO ngl DO
    WITH grv_lod DO        WRITELN(inf,acode:6, load:15:7);

    CLOSE(inf);
(*
      DELAY(500);
//    CloseWindow;
//    Stay;
*)


    writeln('... Archive_Data');
  END; {.. Archive_Data ..}
  {
  << Read_Data >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH
     7/2/92 - implemented ..
  }
  PROCEDURE Read_Data;
  CONST pwid = 20;
  VAR dummy, i  (*, tmp*) : BYTE;
      {dummy_str : string80;}
      dummy_str : STRING;
  BEGIN
    Get_Default_Values;
(*
      quitmenu := TRUE;
//    PlainBox(AutoX,AutoY,'Reading Data : ',pwid,2,white,blue);
//    WriteXY( 'Data being READ ! ',1,1);
//    WriteXY( 'Control Parameters !  ',1,2);
*)

    writeln('Read_Data ...');

    writeln('Reading: Job Data');
    READLN(inf,dummy_str);
    READLN(inf,job);
    READLN(inf,loadname);
    READLN(inf,projno);
    READLN(inf,author);
    READLN(inf,run_no);

    writeln('Reading: Control Data');
    READLN(inf,dummy_str);
    READLN(inf,no_jts, m, nrj, nmg, nsg, njl, nml, ngl, mag);

{    READLN(inf,no_jts, m, nrj, nmg, nsg, njl, nml, ngl);}

    writeln('Reading: Coordinates');
    {    WriteXY( 'Coordinates ! ',1,2);}
    READLN(inf,dummy_str);
    FOR i := 1 TO no_jts DO
      WITH nod_grp[i] DO   READLN(inf, dummy, x, y);

    writeln('Reading: Connectivity');
    {    WriteXY( 'Connectivity ! ',1,2);}
    READLN(inf,dummy_str);
    FOR i := 1 TO m DO
      WITH con_grp[i] DO
        BEGIN
          READLN(inf, dummy, jj, jk, sect, rel_i, rel_j);
        END;

      writeln('Reading: Supports');
{    WriteXY( 'Supports ! ',1,2);}
    READLN(inf,dummy_str);
    nr := 0;
    FOR i := 1 TO nrj DO
      WITH sup_grp[i] DO
      BEGIN
        READLN(inf, dummy, js, rx, ry, rm);
        nr := nr + rx + ry + rm;
      END;

    writeln('Reading: Materials');
{    WriteXY( 'Material Groups ! ',1,2);}
    READLN(inf,dummy_str);
    FOR i := 1 TO nmg DO
      WITH mat_grp[i] DO   READLN(inf, dummy, density, emod, therm);

    writeln('Reading: Section');
{    WriteXY( 'Section Groups ! ',1,2);}
    READLN(inf,dummy_str);
    FOR i := 1 TO nsg DO
      WITH mem_grp[i] DO   READLN(inf, dummy, ax, iz, mat, descr);

    writeln('Reading: Joint Forces');
 {   WriteXY( 'Joint Forces ! ',1,2);}
    READLN(inf,dummy_str);
    FOR i := 1 TO njl DO
      WITH jnt_lod[i] DO
      begin
         writeln(i);
         READLN(inf, dummy, jt, fx, fy, mz );
      end;

     writeln('Reading: Member Forces');
 {   WriteXY( 'Member Forces ! ',1,2);}
    READLN(inf,dummy_str);
    writeln(dummy_str);
    FOR i := 1 TO nml DO
      WITH mem_lod[i] DO
      begin
         READLN(inf, dummy, mem_no, lcode, acode, load, start, cover);
         {writeln(i, dummy);}
      end;

    writeln('Reading: Gravity Loads');
    READLN(inf,dummy_str);
    if ngl <> 0 then
       if not(eof(inf)) then
          WITH grv_lod DO READLN(inf, acode, load);

    CLOSE(inf);
 (*
 //   DELAY(500);
 //   CloseWindow;
 //   Stay;
 *)
    data_loaded := TRUE;

    writeln('... Read_Data');
  END; {.. Read_Data ..}


BEGIN
END.    {.. UNIT ..}
