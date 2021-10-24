{###### Pf_Anal.PAS ######
 ... a unit file of Analysis Routines for the Framework Program -

    Windows 95 Delphi Version 3.0

    Version 5.0  --  21/05/02

    Written by:

    Roy Harrison,
    Roy Harrison & Associates,
    Incorporating TECTONIC Software Engineers,
    MODBURY HEIGHTS, SA 5092,

     Revision history :-
        31/12/95 - implemented ..
        17/ 2/96 - changed to MicroSTRAN sign convention for output ..
        29/ 2/96 - member end releases added
         4/ 3/96 - main data structures made DYNAMIC
        30/ 3/96 - graphics routines standardised
}
{.. Framework program debugged 14/1/92 ..}

UNIT Pf_anal;

{$MODE Delphi}

INTERFACE
USES
     Dialogs,
     Pf_vars,          {.. Application Variables ..}
     Pf_gen;

VAR
   n3        {.. No. of joints x 3 ..}
   : INTEGER;

   cl,
   ts                    {.. true length of a member ..}
   : double;



   PROCEDURE Analyse_Frame;
   FUNCTION Rl_Pos(i : BYTE) : INTEGER;
   FUNCTION B_Ndx(j : BYTE) : INTEGER;
   PROCEDURE Zero_Vars;

{
===========================================================================
}
IMPLEMENTATION
USES
     Pf_load;

VAR
   ci, cj,d,
   ai,aj,b,t  {.. elements of the member stiffness matrix ..}
   : double;

    size, i,j,k : WORD;

   hbw,       {.. upper band width of the joint stiffness matrix ..}
   nn         {.. No. of degrees of freedom @ the joints ..}
   : INTEGER;

   ok  :  BOOLEAN;


{<<< START CODE >>>>}

  {
  << Rl_Pos >>
  ..
  }
  FUNCTION Rl_Pos(i : BYTE) : INTEGER;
  BEGIN
    Rl_Pos := i - crl^[i];
    {WRITELN(trc,'Rl_Pos.. ',i-crl^[i]:8);}
  END;  {.. Rl_Pos ..}
  {
  << B_Ndx >>
  ..
  }
  FUNCTION B_Ndx(j : BYTE) : INTEGER;
  BEGIN
    B_Ndx := rl^[j] * (nn + crl^[j]) + (1 - rl^[j]) * Rl_Pos(j);
  END;  {.. B_Ndx ..}
  {
  << Zero_Vars >>
  ..
  }
  PROCEDURE Zero_Vars;
  BEGIN
    FILLCHAR(fc^, SizeOf(fc^), 0);
    FILLCHAR(dj^, SizeOf(dj^), 0);
    FILLCHAR(dd^, SizeOf(dd^), 0);
    FILLCHAR(ad^, SizeOf(ad^), 0);
    FILLCHAR(ar^, SizeOf(ar^), 0);
    FILLCHAR(af^, SizeOf(af^), 0);
    FILLCHAR(span_mom^, SizeOf(span_mom^), 0);
  END;  {.. Zero_Vars ..}
  {
  << Initialise >>
  ..
  }
  PROCEDURE Initialise;
  BEGIN
    {WriteXY('Initialise entered .. ',1,1);}
    size := SIZEOF(Float_matrix);
    GETMEM(sj,   size);
    size := SIZEOF(int_vector);
    GETMEM(rl,  size);
    GETMEM(crl, size);

    i   := 0;
    j   := 0;
    k   := 0;
    ai  := 0;
    aj  := 0;
    b   := 0;
    ci  := 0;
    cj  := 0;
    d   := 0;
    t   := 0;
    ok  := FALSE;

    FILLCHAR(sj^, SizeOf(sj^), 0);
    FILLCHAR(s^, SizeOf(s^), 0);
    FILLCHAR(crl^, SizeOf(crl^), 0);
    FILLCHAR(rl^, SizeOf(rl^), 0);

    Zero_Vars;
  END;  {.. Initialise ..}
  {
  << Restrained_Joints_Vector >>
  ..
  }
  PROCEDURE Restrained_Joints_Vector;
  VAR   j3,i : INTEGER;
  BEGIN
    {WriteXY('Restrained_Joints_Vector .. ',1,2);}
    n3 := 3 * no_jts;
    nn := n3 - nr;

    FOR i := 1 TO nrj DO
      WITH sup_grp[i] DO
      BEGIN
        {WriteXY('joint # '+ WordToString(i,4),28,2);}
        {WRITELN(trc,'restrained joint #        ? ',i:6,js:5);}
        j3 := 3 * js;
        rl^[j3 - 2] := rx;
        rl^[j3 - 1] := ry;
        rl^[j3]     := rm;
        {WRITELN(trc,'rl.. ',
                          rl^[j3 - 2] :4,
                          rl^[j3 - 1] :4,
                          rl^[j3]     :4);}
      END;

    crl^[1]   :=  rl^[1];

    FOR i := 2 TO n3 DO         crl^[i]  :=  crl^[i - 1] + rl^[i];

    WrVector('rl..  ',rl,n3);
    WrVector('crl..  ',crl,n3);

  END;  {.. Restrained_Joints_Vector ..}
  {
  << Calc_Bandwidth >>
  ..
  }
  PROCEDURE Calc_Bandwidth;
  VAR  j,j1,j2,j3,k,k1,k2,k3 : INTEGER;
       diff : INTEGER;
  {
  << Check_J >>
  ..
  }
  FUNCTION End_J : BOOLEAN;
  BEGIN
    End_J := FALSE ;
    j  := j1;
    IF rl^[j] = 1 THEN
      BEGIN
        j := j2;
        IF rl^[j] = 1 THEN
          BEGIN
            j := j3;
            IF rl^[j] = 1 THEN
              BEGIN
                diff :=  Rl_Pos(k3) - Rl_Pos(k1) + 1;
                End_J := TRUE;
              END;
          END;
      END;
      {WRITELN(trc,'End_J j..  ',j:4);}
  END;  {.. End_J ..}
  {
  << End_K >>
  ..
  }
  FUNCTION End_K : BOOLEAN;
  BEGIN
    End_K := FALSE;
    k  :=  k3;
    IF rl^[k] = 1 THEN
      BEGIN
         k := k2;
         IF rl^[k] = 1 THEN
           BEGIN
             k := k1;
             IF rl^[k] = 1 THEN
               BEGIN
                 diff :=  Rl_Pos(j3) - Rl_Pos(j1) + 1;
                 End_K := TRUE;
               END;
           END;
      END;
      {WRITELN(trc,'End_K k..  ',k:4);}
  END;  {.. End_K ..}


  var i : integer;
  BEGIN
    {WriteXY('Calc_Bandwidth entered .. ',1,4);}
    hbw := 0;
    diff := 0;
    FOR i := 1 TO m DO
      WITH con_grp[i] DO
      BEGIN
        {WriteXY('member # '+ WordToString(i,4),28,4);}
        j3 := 3 * jj;   j2 := j3 - 1;   j1 := j2 - 1;
        k3 := 3 * jk;   k2 := k3 - 1;   k1 := k2 - 1;

        {
        WRITELN(trc,'i.. ',i:4, '  jj  ',jj:4,'  jk  ',jk:4);
        WRITELN(trc,'j3  ',j3:4,'  j2  ',j2:4,'  j1  ',j1:4);
        WRITELN(trc,'k3  ',k3:4,'  k2  ',k2:4,'  k1  ',k1:4);
        }

        IF NOT End_J THEN
          IF NOT End_K THEN
            diff :=  Rl_Pos(k) - Rl_Pos(j) + 1;

        IF diff > hbw THEN       hbw := diff;

        {WRITELN(trc,'hbw..  ',hbw:4);}
      END;
  END;  {.. Calc_Bandwidth ..}
  {
  << Get_Stiff_Elements >>
  ..
  }
  PROCEDURE Get_Stiff_Elements(i:BYTE);
  VAR flag : BYTE;
      tmp  : double;
  BEGIN
    WITH con_grp[i], mem_grp[sect], mat_grp[mat] DO
      BEGIN
        flag := rel_i + rel_j;
        tmp  :=  emod * iz / l^[i];

        IF flag = 0 THEN
          BEGIN
            ai   :=  4 * tmp;
            aj   :=  ai;
            b    :=  ai / 2;
          END
        ELSE
          IF flag = 2 THEN
            BEGIN
              ai   :=  0;
              aj   :=  ai;
              b    :=  ai / 2;
            END
          ELSE
            IF (rel_i = 0) THEN
              BEGIN
                ai   :=  3 * tmp;;
                aj   :=  0;
                b    :=  0;
              END
            ELSE
              BEGIN
                ai   :=  0;
                aj   :=  3 * tmp;
                b    :=  0;
              END;
        ci   :=  (ai + b) / l^[i];
        cj   :=  (aj + b) / l^[i];
        d    :=  (ci + cj) / l^[i];
        t    :=  emod * ax / l^[i];
      END;
    cx   :=  r^[i,1];
    cy   :=  r^[i,2];
  END;  {.. Get_Stiff_Elements ..}
  {
  << Assemble_Stiff_Mat >>
  ..
  }
  PROCEDURE Assemble_Stiff_Mat(i : BYTE);
  BEGIN
    Get_Stiff_Elements(i);

    s^[1,1] :=  t * cx; s^[1,2] := t * cy; s^[1,3] :=  0; s^[1,4] :=-s^[1,1]; s^[1,5] :=-s^[1,2]; s^[1,6] :=  0;
    s^[2,1] := -d * cy; s^[2,2] := d * cx; s^[2,3] := ci; s^[2,4] :=-s^[2,1]; s^[2,5] :=-s^[2,2]; s^[2,6] := cj;
    s^[3,1] :=-ci * cy; s^[3,2] :=ci * cx; s^[3,3] := ai; s^[3,4] :=-s^[3,1]; s^[3,5] :=-s^[3,2]; s^[3,6] :=  b;

    s^[4,1] :=  s^[1,4]; s^[4,2] := s^[1,5]; s^[4,3] :=  0; s^[4,4] := s^[1,1]; s^[4,5] := s^[1,2]; s^[4,6] :=  0;
    s^[5,1] :=  s^[2,4]; s^[5,2] := s^[2,5]; s^[5,3] :=-ci; s^[5,4] := s^[2,1]; s^[5,5] := s^[2,2]; s^[5,6] :=-cj;
    s^[6,1] :=-cj * cy; s^[6,2] :=cj * cx; s^[6,3] :=  b; s^[6,4] :=-s^[6,1]; s^[6,5] :=-s^[6,2]; s^[6,6] := aj;
    {WRITELN(trc,'member .. ',i:8);}
    WrMat('Assemble_Stiff_Mat  s^[] ..',s,6,6);
  END;  {.. Assemble_Stiff_Mat ..}
  {
  << Assemble_Member_Stiff_Matrix >>
  ..
  }
  PROCEDURE Assemble_Member_Stiff_Matrix(i : BYTE);
  BEGIN
    {WriteXY('Assemble_Member_Stiff_Matrix  member # '+ WordToString(i,4),1,5);}
    Get_Stiff_Elements(i);

    c2   :=  cx * cx;
    s2   :=  cy * cy;
    cs   :=  cx * cy;

    s^[1,1] := t*c2+d*s2; s^[1,2] := t*cs-d*cs; s^[1,3] :=-ci*cy; s^[1,4] :=-s^[1,1]; s^[1,5] := -s^[1,2]; s^[1,6] :=-cj*cy;
                         s^[2,2] := t*s2+d*c2; s^[2,3] := ci*cx; s^[2,4] := s^[1,5]; s^[2,5] := -s^[2,2]; s^[2,6] := cj*cx;
                                              s^[3,3] := ai;    s^[3,4] :=-s^[1,3]; s^[3,5] := -s^[2,3]; s^[3,6] := b;
                                                               s^[4,4] :=-s^[1,4]; s^[4,5] := -s^[1,5]; s^[4,6] :=-s^[1,6];
                                                                                 s^[5,5] :=  s^[2,2]; s^[5,6] :=-s^[2,6];
                                                                                                    s^[6,6] := aj;
    {WRITELN(trc,'member .. ',i:8);}
    WrMat('Assemble_Member_Stiff_Matrix   s^[] ..',s,6,6);
  END;  {.. Assemble_Member_Stiff_Matrix ..}
  {
  << Assemble_Struct_Stiff_Matrix >>
  ..
  }
  PROCEDURE Assemble_Struct_Stiff_Matrix(i : BYTE);
  VAR  j,j1,j2,j3,
       k,k1,k2,k3 : WORD;
    {
    << Load_Sj >>
    ..
    }
    PROCEDURE Load_Sj(j, kk : BYTE; stiffval : double);
    VAR k : BYTE;
    BEGIN
      k := Rl_Pos(kk) - j + 1;
      sj^[j,k]  :=  sj^[j,k] + stiffval;
    END;  {.. Load_Sj ..}
    {
    << Process_DOF_J1 >>
    ..
    }
    PROCEDURE Process_DOF_J1;
    BEGIN
      j := Rl_Pos(j1);
      sj^[j,1]  :=  sj^[j,1] + s^[1,1];
      IF rl^[j2] = 0 THEN  sj^[j,2]  :=  sj^[j,2] + s^[1,2];
      IF rl^[j3] = 0 THEN Load_Sj(j,j3, s^[1,3]);
      IF rl^[k1] = 0 THEN Load_Sj(j,k1, s^[1,4]);
      IF rl^[k2] = 0 THEN Load_Sj(j,k2, s^[1,5]);
      IF rl^[k3] = 0 THEN Load_Sj(j,k3, s^[1,6]);
    END;  {.. Process_DOF_J1 ..}
    {
    << Process_DOF_J2 >>
    ..
    }
    PROCEDURE Process_DOF_J2;
    BEGIN
      j := Rl_Pos(j2);
      sj^[j,1]  :=  sj^[j,1] + s^[2,2];
      IF rl^[j3] = 0 THEN   sj^[j,2]  :=  sj^[j,2] + s^[2,3];
      IF rl^[k1] = 0 THEN Load_Sj(j,k1, s^[2,4]);
      IF rl^[k2] = 0 THEN Load_Sj(j,k2, s^[2,5]);
      IF rl^[k3] = 0 THEN Load_Sj(j,k3, s^[2,6]);
    END;  {.. Process_DOF_J2 ..}
    {
    << Process_DOF_J3 >>
    ..
    }
    PROCEDURE Process_DOF_J3;
    BEGIN
      j := Rl_Pos(j3);
      sj^[j,1]  :=  sj^[j,1] + s^[3,3];
      IF rl^[k1] = 0 THEN Load_Sj(j,k1, s^[3,4]);
      IF rl^[k2] = 0 THEN Load_Sj(j,k2, s^[3,5]);
      IF rl^[k3] = 0 THEN Load_Sj(j,k3, s^[3,6]);
    END;  {.. Process_DOF_J3 ..}
    {
    << Process_DOF_K1 >>
    ..
    }
    PROCEDURE Process_DOF_K1;
    BEGIN
      j := Rl_Pos(k1);
      sj^[j,1]  :=  sj^[j,1] + s^[4,4];
      IF rl^[k2] = 0 THEN  sj^[j,2]  :=  sj^[j,2] + s^[4,5];
      IF rl^[k3] = 0 THEN Load_Sj(j,k3, s^[4,6]);
    END;  {.. Process_DOF_K1 ..}
    {
    << Process_DOF_K2 >>
    ..
    }
    PROCEDURE Process_DOF_K2;
    BEGIN
      j := Rl_Pos(k2);
      sj^[j,1]  :=  sj^[j,1] + s^[5,5];
      IF rl^[k3] = 0 THEN   sj^[j,2]  :=  sj^[j,2] + s^[5,6];
    END;  {.. Process_DOF_K2 ..}
    {
    << Process_DOF_K3 >>
    ..
    }
    PROCEDURE Process_DOF_K3;
    BEGIN
      j := Rl_Pos(k3);
      sj^[j,1]  :=  sj^[j,1] + s^[6,6];
    END;  {.. Process_DOF_K3 ..}

  BEGIN
    {WriteXY('Assemble_Struct_Stiff_Matrix  joint # ' + WordToString(i,4),1,6);}
    j3 := 3 * con_grp[i].jj;  j2 := j3 - 1;  j1 := j2 - 1;
    k3 := 3 * con_grp[i].jk;  k2 := k3 - 1;  k1 := k2 - 1;
    {
    WRITELN(trc,'i.. ',i:4,'  jj  ',con_grp[i].jj:4,'  jk  ',con_grp[i].jk:4);
    WRITELN(trc,'  j3  ',j3:4,'  j2  ',j2:4,'  j1  ',j1:4);
    WRITELN(trc,'  k3  ',k3:4,'  k2  ',k2:4,'  k1  ',k1:4);
    }

    IF rl^[j1] = 0 THEN    {.. do j1 ..} Process_DOF_J1;
    IF rl^[j2] = 0 THEN    {.. do j2 ..} Process_DOF_J2;
    IF rl^[j3] = 0 THEN    {.. do j3 ..} Process_DOF_J3;

    IF rl^[k1] = 0 THEN    {.. do k1 ..} Process_DOF_K1;
    IF rl^[k2] = 0 THEN    {.. do k2 ..} Process_DOF_K2;
    IF rl^[k3] = 0 THEN    {.. do k3 ..} Process_DOF_K3;

    
    //WrMat('Jnt_Stiff_Mat sj^[] ..',sj,nn,hbw);
    
    {WRITELN(trc,'member .. ',i:8);}
    WrMat('Assemble_Struct_Stiff_Matrix    sj^[] ..',sj,nn,hbw);
  END;  {.. Assemble_Struct_Stiff_Matrix ..}
  {
  << Choleski_Factor_Matrix >>
  .. Choleski decomposition ..
  }
  PROCEDURE Choleski_Factor_Matrix;
  VAR p,q,i,j,k : INTEGER;
      su,te : double;
  BEGIN
    {WriteXY('Choleski_Factor_Matrix  entered .. ',1,7);}
    WrMat('Decompose IN sj ..',sj,nn,hbw);
    FOR i := 1 TO nn DO
      BEGIN
        {WriteXY('row # '+ WordToString(i,4),28,7);}
        p := nn - i + 1;

        IF p > hbw THEN p := hbw;

        FOR j := 1 TO p DO
          BEGIN
            q := hbw - j;
            IF q > i - 1 THEN  q := i - 1;

            su  := sj^[i,j];

            IF q >= 1 THEN
              FOR k := 1 TO q DO
                IF i > k THEN
                  su := su - sj^[i - k, k + 1] * sj^[i - k, k + j];

            IF j <> 1 THEN
              sj^[i,j] := su * te
            ELSE
              IF su <= 0 THEN
                BEGIN
                  WRITELN('??? or -ve TERM ???');
                  HALT;
                END
              ELSE
                BEGIN
                  te := 1 / SQRT(su);
                  sj^[i,j] := te;
                END;
          END
      END;
    WrMat('Decompose OUT sj ..',sj,nn,hbw);
  END;  {.. Choleski_Factor_Matrix ..}
  {
  << Solve_Displacements >>
  .. perform forward and backward substitution to solve the system ..
  }
  PROCEDURE Solve_Displacements ;
  VAR   su : double;
       i,j,k : INTEGER;
  BEGIN
    {WriteXY('Solve_Displacements .. ',1,10);}
    FOR i := 1 TO nn DO
      BEGIN
         {WriteXY('row # '+ WordToString(i,4),28,10);}
        j := i + 1 - hbw;
        IF j < 1 THEN j := 1;
        su := fc^[i];
        IF j - i + 1 <= 0 THEN
          FOR k := j TO i - 1 DO
            IF i - k + 1 > 0 THEN
              su := su - sj^[k, i - k + 1] * dd^[k];
        dd^[i] := su * sj^[i,1];
      END;

    FOR i := nn DOWNTO 1 DO
      BEGIN
        j := i + hbw - 1;
        IF j > nn THEN j := nn;
        su := dd^[i];
        IF i + 1 <= j THEN
          FOR k := i + 1 TO j DO
            IF k+1 > i THEN
            su := su - sj^[i, k+ 1 - i] * dd^[k];
        dd^[i] := su * sj^[i,1]
      END;
      WrFVector('Solve Displacements  dd..  ',dd,nn);
  END;  {.. Solve_Displacements ..}
  {
  << Calc_Member_Forces >>
  ..
  }
  PROCEDURE Calc_Member_Forces;
  VAR  i,j,j1,j2,j3,k,k1,k2,k3 : INTEGER;

  BEGIN
    {WriteXY('Member Forces # ',1,2);}
    FOR i := 1 TO m DO
      BEGIN
        {WriteXY(WordToString(i,4),22,2);}

        Assemble_Stiff_Mat(i);

        j3 := 3 * con_grp[i].jj;  j2 := j3 - 1;  j1 := j2 - 1;
        k3 := 3 * con_grp[i].jk;  k2 := k3 - 1;  k1 := k2 - 1;

        FOR j := 1 TO 6 DO
          BEGIN
            ad^[j] := s^[j,1] * dj^[j1] + s^[j,2] * dj^[j2] + s^[j,3] * dj^[j3];
            ad^[j] := ad^[j] + s^[j,4] * dj^[k1] + s^[j,5] * dj^[k2] + s^[j,6] * dj^[k3];
          END;

        {.. store End forces ..}
        WITH con_grp[i] DO
          BEGIN
            jnt_jj.axial  := -(af^[i,1] + ad^[1]);
            jnt_jj.shear  := -(af^[i,2] + ad^[2]);
            jnt_jj.moment := -(af^[i,3] + ad^[3]);

            jnt_jk.axial  := af^[i,4] + ad^[4];
            jnt_jk.shear  := af^[i,5] + ad^[5];
            jnt_jk.moment := af^[i,6] + ad^[6];
          END;


        IF rl^[j1] <>0 THEN ar^[j1] := ar^[j1] + ad^[1] * cx - ad^[2] * cy;
        IF rl^[j2] <>0 THEN ar^[j2] := ar^[j2] + ad^[1] * cy + ad^[2] * cx;
        IF rl^[j3] <>0 THEN ar^[j3] := ar^[j3] + ad^[3];
        IF rl^[k1] <>0 THEN ar^[k1] := ar^[k1] + ad^[4] * cx - ad^[5] * cy;
        IF rl^[k2] <>0 THEN ar^[k2] := ar^[k2] + ad^[4] * cy + ad^[5] * cx;
        IF rl^[k3] <>0 THEN ar^[k3] := ar^[k3] + ad^[6];
      END;
  END;  {.. Calc_Member_Forces ..}
  {
  << Calc_Joint_Displacements >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Calc_Joint_Displacements ;
  var i : integer;
  BEGIN
    {WriteXY('Joint Displacements #',1,1);}
    FOR i := 1 TO n3 DO
      IF rl^[i] = 0 THEN dj^[i] := dd^[Rl_Pos(i)];
    
    //WrFVector('dj..  ',dj,n3);
    
  END; {.. Calc_Joint_Displacements ..}
  {
  << Get_Span_Moments >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     9/6/96 - implemented ..
  }
  PROCEDURE Get_Span_Moments;
  VAR   segment, station : REAL;
        i,j : BYTE;
  BEGIN  {.. Get_Span_Moments ..}
    FOR i := 1 TO m DO
      BEGIN
        segment := l^[i]/vn;
        WITH con_grp[i] DO
          FOR j := 0 TO vn DO
            BEGIN
              station :=  j*segment;
              WITH mem_lod[i] DO
              IF (lcode = 2)
                AND (station >= start)
                AND (station - start < segment) THEN    station := start;
              span_mom^[i,j] := span_mom^[i,j] + jnt_jj.shear * station - jnt_jj.moment;
              {WRITELN(trc,'i,j,station,-> span_mom.. ',i:8,j:8, station:9:3,span_mom^[i,j]:9:3);}
            END;
      END;
  END; {.. Get_Span_Moments ..}

   {
   << Analyse_Frame >>
   .. Procedure based on ref#? p?
      algorithm
      Modified RGH :-
      6/2/92 - implemented ..
   }
   PROCEDURE Analyse_Frame;
   var i : integer;
   BEGIN
     {PlainBox(autoX,autoY,'Analysis in Progress : ',50,10,BLACK,LIGHTGRAY);}
     Initialise;
     Restrained_Joints_Vector;
     Total_Section_Length;
     Calc_Bandwidth;

     FOR i := 1 TO m DO
       BEGIN
         Assemble_Member_Stiff_Matrix(i);
         Assemble_Struct_Stiff_Matrix(i);
       END;

     Choleski_Factor_Matrix;
     Process_Loadcases;
     Solve_Displacements;
     Calc_Joint_Displacements;
     Calc_Member_Forces;
     Get_Span_Moments;

     MessageDlg('>> Analysis Completed <<', mtInformation,[mbOk], 0);

     analysed     := TRUE;

   END; {.. Analyse_Frame ..}

BEGIN   {.. UNIT Pf_Anal..}
END.    {.. UNIT Pf_Anal..}

