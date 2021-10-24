{###### Pf_Prt.PAS ######
 ... a unit file of output printer routines for the Framework analysis program ...
     R G Harrison   --  Version 5.2  --  30/ 3/96  ...

     Revision history :-
        31/12/95 - implemented ..
        17/ 2/96 - changed to MicroSTRAN sign convention for output ..
        29/ 2/96 - member end releases added
         4/ 3/96 - main data structures made DYNAMIC
        30/ 3/96 - graphics routines standardised

}
UNIT Pf_Prt;

{$MODE Delphi}

INTERFACE
USES
      LCLIntf, LCLType, LMessages,
      SysUtils,
      Pf_anal,
      Pf_vars;          {.. Application Variables ..}

   PROCEDURE Output_Results;

{
===========================================================================
}
IMPLEMENTATION
CONST   lm = 10;
        page_len = 66;
        line_tol = 2;
VAR
   pageno, title_len,
   count,
   k : INTEGER;
   firstpage : BOOLEAN;


  function GetCurrentDateTime: TDateTime;

var
  SystemTime: TSystemTime;
begin
  GetLocalTime(SystemTime);
  Result := SystemTimeToDateTime(SystemTime);
end;

  {
  <<< Pad >>>
  ... Pads a string on the right with spaces TO a specified LENGTH
  }
  FUNCTION Pad(s_inp : string80; len : WORD) : string80;
  BEGIN
    IF LENGTH(s_inp) < len THEN
      FILLCHAR(s_inp[SUCC(LENGTH(s_inp))], len - LENGTH(s_inp), ' ');
    s_inp[0] := CHR(len);
    Pad := s_inp;
  END; { Pad }
  {
  <<<  Tab  >>>
   ...   commence
   ...   RGH   23/5/95
  }
  PROCEDURE Tab(lm : BYTE);
  Var i : integer;
  BEGIN
     FOR i := 1 TO lm DO
       WRITE(outf,' ');
  END; {...Tab ..}
  {
  <<< UnderLine >>>
   ...   commence
   ...   RGH   23/5/95
  }
  PROCEDURE UnderLine;
  BEGIN
    WRITELN(outf,'':lm,'-------------------------------------------------------------------------');
  END; {...UnderLine ..}
  {
  <<< HeadLine >>>
  ' ...   commence
  ' ...   RGH   23/5/95
  }
  PROCEDURE HeadLine;
  VAR tmp_str, date_str : String80;
  BEGIN
    UnderLine;
    //WRITE(outf,'':lm,'>>> FRAMEwork <<< (Version 5.1 Mar 96)');
    WRITE(outf,'':lm,'>>> Win_FRAME <<< (Version 6.1 June 2002)');
    tmp_str := DateTimeToStr(GetCurrentDateTime);
    //date_str := COPY(tmp_str,LENGTH(tmp_str)-8,9);
    date_str := COPY(tmp_str,1,POS(' ',tmp_str));
    WRITELN(outf,'Date   :':19,date_str:14);
  END; {...HeadLine  }
  {
  << Prt_Titles >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Titles(title, title_len : BYTE);
  BEGIN
    WRITELN(outf);
    CASE title OF
    1 : BEGIN
          WRITELN(outf,'':lm,'Structure Data');
          UnderLine;
        END;

    2 : BEGIN
          WRITELN(outf,'':lm,'Joint Coordinates');
          UnderLine;
          WRITELN(outf,'JOINT':6+lm,'X(m)':10,'Y(m)':10);
        END;

    3 : BEGIN
          WRITELN(outf,'':lm,'Member Connectivity');
          UnderLine;
          WRITELN(outf,'MEMBER':7+lm,'Node':6,'Node':6,'Section':8,
                                     'Zi':6,'Zj':3,'Length':10);
        END;

    4 : BEGIN
          WRITELN(outf,'':lm,'Support Restraints ');
          UnderLine;
          WRITELN(outf,'SUPPORT':8+lm,'X':8,'Y':2,'Z':2);
        END;

    5 : BEGIN
          WRITELN(outf,'':lm,'Member Section Properties ');
          UnderLine;
          WRITELN(outf,'SECTION':8+lm,'A':13,'I':13,'Material':10,'Description':20);
          WRITELN(outf,'':8+lm,'[mý]':13,'[m^4]':13);
        END;

    6 : BEGIN
          WRITELN(outf,'':lm,'Material Properties ');
          UnderLine;
          WRITELN(outf,'Material':9+lm,'Density':10,' -E- ':11,' - u - ':14);
        END;

    7 : BEGIN
          WRITELN(outf,'':lm,'Framework Quantities ');
          UnderLine;
          WRITELN(outf,'SECTION':8+lm,'TOTAL':12,'TOTAL':12,'Description':20);
          WRITELN(outf,'':8+lm,'Length':12,'Mass':12);
        END;

    8 : BEGIN
          WRITELN(outf,'':lm,'Applied Member Loads');
          UnderLine;
          WRITE(outf,'Memb':8+lm,'Type':8,'Action':8,'Load':12);
          (*
          IF mem_lod[i].cover <> 0 THEN
          *)
            WRITELN(outf,'start':12,'Cover':12)
            (*
          ELSE
            WRITELN(outf);
            *)
        END;  {.. Prt_Member_Loads_Header ..}

    9 : BEGIN
          WRITELN(outf,'':lm,'Applied Joint Loads');
          UnderLine;
          WRITELN(outf,'Joint':8+lm,'X':12,'Y':12,'Z':12);
        END;  {.. Prt_Joint_Loads_Header ..}

    10: BEGIN
          WRITELN(outf,'':lm,'Joint displacements {.. Global Co-ords ..}');
          UnderLine;
          WRITELN(outf,'Node':8+lm,'  X  ':10,'  Y  ':10,'  Rot ':10);
          WRITELN(outf,' [m]':18+lm,' [m]':10,'[rads]':10);
        END;  {.. Prt_Joint_Disp_Head ..}

    11: BEGIN
          WRITELN(outf,'':lm,'Support Reactions   {.. Global Co-ords ..}');
          UnderLine;
          WRITELN(outf,'Node':8+lm,'  X  ':12,'  Y  ':12,'   M  ':12);
          WRITELN(outf,' [kN]':20+lm,' [kN]':12,' [kNm]':12);
        END;  {.. Supp_React_Head ..}

    12: BEGIN
          WRITELN(outf,'':lm,'Member Forces       {.. Local Co-ords ..} ');
          UnderLine;
          WRITELN(outf,'Memb':8+lm,'Node':8,'Shear':12,'Axial':12,'Moment':12);
          WRITELN(outf,' [kN]':28+lm,' [kN]':12,' [kNm]':12);
        END;  {.. Prt_Member_Forces_Head ..}

    13: BEGIN
          WRITELN(outf,'':lm,'Member Maximum/Minimum End Forces');
          UnderLine;
          WRITE(outf,'':lm,'Maximum End Forces':30);
          WRITELN(outf,'Minimum End Forces':30);
          WRITE(outf,'':lm,'Memb':16,'Node':8,'Force':12);
          WRITELN(outf,'Memb':10,'Node':8,'Force':12);
        END;

    14: BEGIN
          WRITELN(outf,'':lm,'Gravity Loads');
          UnderLine;
          WRITELN(outf,'Load':8+lm,'Gravity':12);
          WRITELN(outf,'Action':8+lm,'[m/sý]':12);
        END;  {.. Prt_Member_Loads_Header ..}

    15: BEGIN
          WRITELN(outf,'':lm,'Span Moments');
          UnderLine;
          WRITELN(outf,'Member':8+lm,'segment':10,'station':10,'Moment':10);
          WRITELN(outf,' ':18+lm,' [m]':10,'[kNm]':10);
        END;  {.. Prt_Member_Loads_Header ..}

      ELSE
        count := count-1;

    END;  {.. Case ..}
    count := count + title_len +1;
  END; {.. Prt_Titles ..}
  {
  <<< Prt_Page_Header >>>
   ...   commence
   ...   RGH   23/5/95
  }
  PROCEDURE Prt_Page_Header(title, title_len : BYTE);
  VAR   str_w : BYTE;
  BEGIN
    WRITELN(outf);
    UnderLine;
    WRITELN(outf,'':lm,'ROY HARRISON & ASSOCIATES   -   354 Milne Road,  MODBURY HEIGHTS   SA5092');

    HeadLine;
    str_w := 42;
    WRITE(outf,'':lm,'Author : ',PAD(author,str_w):str_w);
    WRITELN(outf,'Job No.: ':10,projno:12);
    //WRITELN(outf,'File   : ':10,result:12);
    WRITELN(outf,'':lm,'Job    : ',PAD(job,str_w):str_w);
    WRITE(outf,'':lm,'Load   : ',PAD(loadname,str_w):str_w);
    WRITELN(outf,'PAGE   : ':10, pageno:12);
(*
    WRITELN(outf,'Run No.: ':10,run_no:4);
*)
    UnderLine;
    pageno := SUCC(pageno);
    count :=  9;
    firstpage := FALSE;

    Prt_Titles(title, title_len);
  END; {...Prt_Page_Header}
  {
  << Chk_Output_Length >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Chk_Output_Length (title, title_len : BYTE; datacont : BOOLEAN);
  BEGIN
    IF count > page_len THEN
      BEGIN
        IF datacont = TRUE THEN
          WRITELN(outf,'':lm+65,'(Cont.)');
        IF NOT firstpage THEN WRITELN(outf,'');
        Prt_Page_Header(title, title_len);
      END;
  END; {.. Chk_Output_Length ..}
  {
  << Chk_Title_Position >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Chk_Title_Position(title, title_len : BYTE);
  BEGIN
    IF count + title_len + line_tol > page_len THEN
      BEGIN
       count := count + title_len + line_tol;
       Chk_Output_Length(title, title_len, FALSE);
      END
    ELSE
     Prt_Titles(title, title_len);
  END; {.. Chk_Title_Position ..}
  {
  << Incr_Chk_Count >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Incr_Chk_Count(title, title_len : BYTE);
  BEGIN
    count := SUCC(count);
    Chk_Output_Length(title, title_len, TRUE);
  END; {.. Incr_Chk_Count ..}
  {
  << Prt_Parameters >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Parameters;
  BEGIN
     Chk_Title_Position(1,2);
     WRITELN(outf,'':lm,'   Number of Joints........', no_jts:6);
     WRITELN(outf,'':lm,'   Number of Members.......', m:6);
     WRITELN(outf,'':lm,'   Number of Supports......', nrj:6);
     WRITELN(outf,'':lm,'   Number of Materials.....', nmg:6);
     WRITELN(outf,'':lm,'   Number of Sections......', nsg:6);
     WRITELN(outf,'':lm,'   Number of Joints Loads..', njl:6);
     WRITELN(outf,'':lm,'   Number of Member Loads..',nml:6);
     count := count+10;
  END; {.. Prt_Parameters ..}
  {
  << Prt_Joint_Coords >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Joint_Coords;
  VAR i : integer;
  BEGIN
    Chk_Title_Position(2,3);
    FOR i := 1 TO no_jts DO
      WITH nod_grp[i] DO
        BEGIN
          Incr_Chk_Count(2,3);
          WRITELN(outf,i:6+lm, x:10:3,y:10:3);
        END;
  END; {.. Prt_Joint_Coords ..}
  {
  << Prt_Connectivity >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Connectivity;
  VAR i : integer;

  BEGIN
    Chk_Title_Position(3,3);
     FOR i := 1 TO m DO
       WITH con_grp[i] DO
        BEGIN
          Incr_Chk_Count(3,3);
          WRITELN(outf,i:7+lm, jj:6, jk:6, sect:8, rel_i:6, rel_j:3, l^[i]:10:3);
        END;
  END; {.. Prt_Connectivity ..}
  {
  << Prt_Supports >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Supports;
  VAR i : integer;
  BEGIN
    Chk_Title_Position(4,3);
     FOR i := 1 TO nrj DO
       WITH sup_grp[i] DO
        BEGIN
          Incr_Chk_Count(4,3);
          WRITELN(outf,js:8+lm, rx:8,ry:2,rm:2);
        END;
  END; {.. Prt_Supports ..}
  {
  << Prt_Section_Props >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Section_Props;
  VAR i : integer;
  BEGIN
    Chk_Title_Position(5,4);
     FOR i := 1 TO nsg DO
       WITH mem_grp[i] DO
        BEGIN
          Incr_Chk_Count(5,4);
          WRITELN(outf,i:8+lm,'':3,ax:10,'':3,iz:10,mat:10,descr:28);
        END;
  END; {.. Prt_Section_Props ..}
  {
  << Prt_Material_Props >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Material_Props;
  VAR i : integer;
  BEGIN
    Chk_Title_Position(6,3);
     FOR i := 1 TO nmg DO
       WITH mat_grp[i] DO
        BEGIN
          Incr_Chk_Count(6,3);
          WRITELN(outf,i:lm+9, density:10:0,'':3, emod:10,'':3,therm:10);
        END;
  END; {.. Prt_Material_Props ..}
  {
  << Prt_Quantities >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Quantities;
  VAR sum_len, sum_mass : double;
      i : integer;
    {
    << Prt_Sum_Quants >>
    ..
    }
    PROCEDURE Prt_Sum_Quants;
    BEGIN
      Incr_Chk_Count(7,4);
      UnderLine;
      Incr_Chk_Count(7,4);
      WRITE(outf,'SUM':8+lm);
      WRITE(outf,sum_len:12:3);
      WRITE(outf,sum_mass:12:3);
      WRITELN(outf);
      count := count + 2;
    END;  {.. Prt_Sum_Quants..}

  BEGIN
    sum_len  := 0;
    sum_mass := 0;
    Chk_Title_Position(7,4);
     FOR i := 1 TO nsg DO
       WITH mem_grp[i] DO
         BEGIN
           Incr_Chk_Count(7,4);
           WRITELN(outf,i:8+lm, t_len:12:3,t_mass:12:3,descr);
           sum_len  := sum_len + t_len;
           sum_mass := sum_mass + t_mass;
         END;
    Prt_Sum_Quants;
  END; {.. Prt_Quantities ..}
  {
  <<<  Echo_Input  >>>
   ...   commence
   ...   RGH   23/5/95
  }
  PROCEDURE Echo_Input;
  BEGIN
     Prt_Parameters;
     Prt_Joint_Coords;
     Prt_Connectivity;
     Prt_Supports;
     Prt_Section_Props;
     Prt_Material_Props;
     Prt_Quantities;
  END; {...Echo_Input ..}
  {
  << Prt_Gravity_Loads >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Gravity_Loads;
  BEGIN
    Chk_Title_Position(14,4);
    WITH grv_lod DO
      BEGIN
        Incr_Chk_Count(14,4);
        WRITELN(outf,acode:8+lm, load:12:3);
      END;
  END; {.. Prt_Gravity_Loads ..}
  {
  << Prt_Member_Loads >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Member_Loads;
  VAR i : integer;
  BEGIN
    Chk_Title_Position(8,3);
    FOR i := 1 TO nml DO
      WITH mem_lod[i] DO
        BEGIN
          Incr_Chk_Count(8,3);
          WRITE(outf,mem_no:8+lm, lcode:8, acode:8, load:12:3);
          IF (start + cover) <> 0 THEN
            BEGIN
              WRITE(outf,start:12:3);
              IF cover <> 0 THEN
                WRITE(outf,cover:12:3);
            END;
          WRITELN(outf);
        END;
  END; {.. Prt_Member_Loads ..}
  {
  << Prt_Joint_Loads >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Joint_Loads;
  VAR i : integer;
  BEGIN
    Chk_Title_Position(9,3);
    FOR i := 1 TO njl DO
      WITH jnt_lod[i] DO
        BEGIN
          Incr_Chk_Count(9,3);
          WRITELN(outf,jt:8+lm, fx:12:3, fy:12:3, mz:12:3);
        END;
  END; {.. Prt_Joint_Loads ..}
  {
  << Prt_Joint_Displacements >>
  ..
  }
  PROCEDURE Prt_Joint_Displacements;
  VAR i : integer;
  BEGIN
    //WriteXY('Joint Displacements #',1,1);
    Chk_Title_Position(10,4);

    FOR i := 1 TO no_jts DO
      BEGIN
        Incr_Chk_Count(10,4);
        //WriteXY(WordToString(i,4+lm),22,1);
        WRITE(outf,i:8+lm);
        WRITELN(outf,dj^[3*i-2]:10:4,dj^[3*i-1]:10:4,dj^[3*i]:10:5);
      END;
  END;  {.. Prt_Joint_Displacements ..}
  {
  << Prt_Support_Reactions >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     31/12/95 - implemented ..
     23/8/96  - FOR routine changed to directly address support nodes.
  }
  PROCEDURE Prt_Support_Reactions;
  CONST  step = 3;
  VAR i,limit, jnt_r, kk, k, flag : INTEGER;
      sumx, sumy : double;
   {
    << Prt_Reaction_Sum >>
    ..
    }
    PROCEDURE Prt_Reaction_Sum;
    BEGIN
      Incr_Chk_Count(11,4);
      UnderLine;
      Incr_Chk_Count(11,4);
      WRITE(outf,'SUM':8+lm);
      WRITE(outf,sumx:12:3);
      WRITE(outf,sumy:12:3);
      WRITELN(outf,'(All nodes)':15);
      count := count + 2;
    END;  {.. Prt_Reaction_Sum ..}

  BEGIN
    sumx := 0;
    sumy := 0;
    //WriteXY('Support Reaction # ',1,3);
    Chk_Title_Position(11,4);

    FOR k := 1 TO n3 DO
      IF rl^[k] = 1 THEN ar^[k] := ar^[k] - fc^[B_Ndx(k)];

    FOR i := 1 TO nrj DO
      WITH sup_grp[i] DO
        BEGIN
          Incr_Chk_Count(11,4);
          //WriteXY(WordToString(i,4),22,3);
          k := 3 * js;
          flag := 0;
          WRITE(outf,js:8+lm);
          FOR kk := k-2 TO k DO
            IF kk MOD 3 = 0 THEN
              WRITE(outf,ar^[kk]:12:3)
            ELSE
              BEGIN
                WRITE(outf,ar^[kk] :12:3);
                IF flag = 0 THEN
                  sumx := sumx + ar^[kk]
                ELSE
                  sumy := sumy + ar^[kk];
                  flag := flag + 1;
              END;
          WRITELN(outf);
          flag := 0;
        END;
    Prt_Reaction_Sum;
  END;  {.. Prt_Support_Reactions ..}
  {
  << Prt_Member_Forces >>
  ..
  }
  PROCEDURE Prt_Member_Forces;
  VAR  i,j,j1,j2,j3,k,k1,k2,k3 : INTEGER;
       tmp : double;
  BEGIN
    //WriteXY('Member Forces # ',1,2);
    Chk_Title_Position(12,4);
    FOR i := 1 TO m DO
      WITH con_grp[i] DO
      BEGIN
        //WriteXY(WordToString(i,4),22,2);

        Incr_Chk_Count(12,4);
        WRITE(outf,i:8+lm);

        WRITE(outf,jj:8);
        WRITE(outf,jnt_jj.shear:12:3);
        WRITE(outf,jnt_jj.axial:12:3);
        WRITE(outf,jnt_jj.moment:12:3);
        WRITELN(outf);

        Incr_Chk_Count(12,4);
        WRITE(outf,'':8+lm);

        WRITE(outf,jk:8);
        WRITE(outf,jnt_jk.shear:12:3);
        WRITE(outf,jnt_jk.axial:12:3);
        WRITE(outf,jnt_jk.moment:12:3);
        WRITELN(outf);

      END;
    UnderLine;
  END;  {.. Prt_Member_Forces ..}
  {
  << Prt_Max_Forces >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Prt_Max_Forces;
  VAR
       maxM,MinM,maxQ,MinQ,maxA,MinA : double;

       MaxMJnt, maxMmemb,  MinMJnt, MinMmemb,
       MaxQJnt, maxQmemb,  MinQJnt, MinQmemb,
       MaxAJnt, maxAmemb,  MinAJnt, MinAmemb : BYTE;
    {
    << Get_Min_Max >>
    ..
    }
    PROCEDURE Get_Min_Max;
    VAR i : integer;
    BEGIN
      maxM  := 0; MaxMJnt := 0;  maxMmemb := 0;
      MinM  := infinity; MinMJnt := 0;  MinMmemb := 0;
      maxQ  := 0; MaxQJnt := 0;  maxQmemb := 0;
      MinQ  := infinity; MinQJnt := 0;  MinQmemb := 0;
      maxA  := 0; MaxAJnt := 0;  maxAmemb := 0;
      MinA  := infinity; MinAJnt := 0;  MinAmemb := 0;

      FOR i := 1 TO m DO
        BEGIN
          //WriteXY(WordToString(i,4),22,2);

          {.. store End forces ..}
          WITH con_grp[i] DO
            BEGIN
              IF maxA < jnt_jj.axial THEN
                BEGIN
                  maxA  := jnt_jj.axial;
                  MaxAJnt := jj;
                  maxAmemb := i;
                END;

              IF maxQ < jnt_jj.shear THEN
                BEGIN
                  maxQ  := jnt_jj.shear;
                  MaxQJnt := jj;
                  maxQmemb := i;
                END;

              IF maxM < jnt_jj.moment THEN
                BEGIN
                  maxM  := jnt_jj.moment;
                  MaxMJnt := jj;
                  maxMmemb := i;
                END;

              IF maxA < jnt_jk.axial THEN
                BEGIN
                  maxA  := jnt_jk.axial;
                  MaxAJnt := jk;
                  maxAmemb := i;
                END;

              IF maxQ < jnt_jk.shear THEN
                BEGIN
                  maxQ  := jnt_jk.shear;
                  MaxQJnt := jk;
                  maxQmemb := i;
                END;

              IF maxM < jnt_jk.moment THEN
                BEGIN
                  maxM  := jnt_jk.moment;
                  MaxMJnt := jk;
                  maxMmemb := i;
                END;

              IF minA > jnt_jj.axial THEN
                BEGIN
                  minA  := jnt_jj.axial;
                  MinAJnt := jj;
                  minAmemb := i;
                END;

              IF minQ > jnt_jj.shear THEN
                BEGIN
                  minQ  := jnt_jj.shear;
                  MinQJnt := jj;
                  minQmemb := i;
                END;

              IF minM > jnt_jj.moment THEN
                BEGIN
                  minM  := jnt_jj.moment;
                  MinMJnt := jj;
                  minMmemb := i;
                END;

              IF minA > jnt_jk.axial THEN
                BEGIN
                  minA  := jnt_jk.axial;
                  MinAJnt := jk;
                  minAmemb := i;
                END;

              IF minQ > jnt_jk.shear THEN
                BEGIN
                  minQ  := jnt_jk.shear;
                  MinQJnt := jk;
                  minQmemb := i;
                END;

              IF minM > jnt_jk.moment THEN
                BEGIN
                  minM  := jnt_jk.moment;
                  MinMJnt := jk;
                  minMmemb := i;
                END;
            END;
        END;
    END;  {.. Get_Min_Max ..}

  BEGIN
    //WriteXY('Max Forces # ',1,2);
    Get_Min_Max;

    Chk_Title_Position(13,4);
    Incr_Chk_Count(13,4);

    WRITE(outf,'Axial':8+lm);
    WRITE(outf,maxAmemb:8);
    WRITE(outf,MaxAjnt:8);
    WRITE(outf,maxA:12:3);
    WRITE(outf,minAmemb:8);
    WRITE(outf,MinAjnt:10);
    WRITE(outf,minA:12:3);
    WRITELN(outf);

    Incr_Chk_Count(13,4);
    WRITE(outf,'Shear':8+lm);
    WRITE(outf,maxQmemb:8);
    WRITE(outf,MaxQjnt:8);
    WRITE(outf,maxQ:12:3);
    WRITE(outf,minQmemb:8);
    WRITE(outf,MinQjnt:10);
    WRITE(outf,minQ:12:3);
    WRITELN(outf);

    Incr_Chk_Count(13,4);
    WRITE(outf,'Moment':8+lm);
    WRITE(outf,maxMmemb:8);
    WRITE(outf,MaxMjnt:8);
    WRITE(outf,maxM:12:3);
    WRITE(outf,minMmemb:8);
    WRITE(outf,MinMjnt:10);
    WRITE(outf,minM:12:3);
    WRITELN(outf);
    UnderLine;

  END; {.. Prt_Max_Forces ..}
  {
  << Prt_Span_Moments >>
  ..
  }
  PROCEDURE Prt_Span_Moments;
  VAR  i,j : INTEGER;
       station, segment : double;
  BEGIN
    count := SUCC(page_len);
    //WriteXY('Span Moments # ',1,2);
    Chk_Title_Position(15,4);
    FOR i := 1 TO m DO
      BEGIN
        segment := l^[i]/vn;
        Incr_Chk_Count(15,5);
        WRITELN(outf,i:8+lm);
        //WriteXY(WordToString(i,4),22,2);
        WITH con_grp[i] DO
          FOR j := 0 TO vn DO
            BEGIN
              station :=  j * segment;
              Incr_Chk_Count(15,4);
              WRITELN(outf,j:18+lm, station:10:4,span_mom^[i,j]:10:2);
            END;
      END;
    UnderLine;
  END;  {.. Prt_Span_Moments ..}
  {
  << Output_Results >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Output_Results;
  BEGIN
    //OpenOutFiles;
    firstpage := TRUE;
    
    //IF updated THEN
      //BEGIN
        //PlainBox(autoX,autoY,'Storing Results : ',40,6,MAGENTA,LIGHTGRAY);
        
        pageno := 1;
        count := page_len - 1;

        {
        IF Get_Yes_No('Prompt !!',' Omit INPUT Data :') THEN
          GetInteger('> 1st Page is ? <',pageno,pageno,0,100)
        ELSE
          Echo_Input;
        }

        IF nml <> 0 THEN Prt_Member_Loads;
        IF njl <> 0 THEN Prt_Joint_Loads;
        IF ngl <> 0 THEN Prt_Gravity_Loads;
        Prt_Joint_Displacements;
        Prt_Member_Forces;
        Prt_Support_Reactions;
        Prt_Max_Forces;

        Prt_Span_Moments;

   END; {.. Output_Results ..}

BEGIN

END.    {.. UNIT Pf_Prt..}
  {
  << zz >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/7/96 - implemented ..
  }
  PROCEDURE zz;
  BEGIN
  END; {.. zz ..}
    {
    << zz >>
    ..
    }
    PROCEDURE zz;
    BEGIN
    END;  {.. zz ..}
  {

