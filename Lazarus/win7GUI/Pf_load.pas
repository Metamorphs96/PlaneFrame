{###### Pf_Load.PAS ######
 ... a unit file of load analysis routines for the Framework Program-
     R G Harrison   --  Version 5.2  --  30/ 3/96  ...

     Revision history :-
        29/7/90 - implemented ..
        31/1/92 - changed over to gadget walking windows ..
        4/ 3/96 - main data structures made DYNAMIC
        30/ 3/96 - graphics routines standardised
}
{.. Framework program debugged 14/1/92 ..}

UNIT Pf_load;

{$MODE Delphi}

INTERFACE
USES
(*
     Crt,              {.. Basic video operations  - standard unit ..}
     Utils,            {.. General purpose constants and procedures ..}
     Windows,          {.. Redefine Window Manager ..}
     Gadgets,          {.. Pulldown walking menus ..}

     ScrFile,
*)
     Pf_vars,          {.. Application Variables ..}
     Pf_gen;

  PROCEDURE Process_Loadcases;

{
===========================================================================
}
IMPLEMENTATION
USES
     Pf_anal;

  {
  << Process_Loadcases >>
  ..
  }
  PROCEDURE Process_Loadcases;
  CONST hi_end = -1;
        lo_end = 1;
  VAR   {.. loading variables ..}

        a,       {.. dist from end "i" to centroid of load ..}
        b,       {.. dist from end "j" to centroid of load ..}
        fi,      {.. member fixed end moment @ end "i" of a member ..}
        fj,      {.. member fixed end moment @ end "j" of a member ..}
        a_i,     {.. fixed end axial force @ end "i" ..}
        a_j,     {.. fixed end axial force @ end "j" ..}
        ri,      {.. fixed end shear @ end "i" ..}
        rj,      {.. fixed end shear @ end "j" ..}
        dii,     {.. slope function @ end "i" ..}
        djj,     {.. slope function @ end "j" ..}
        wt,      {.. total load on member ..}
        udl,
        norm_ld,
        axi_load,
        axi_pt,
        l1,     {.. start position ..}
        cvr,
        al,bl : double;

        lc,i,j,k : WORD;
  {
  << Calc_Moments >>
  .. RGH   12/4/92
  .. calc moments ..
  }
  PROCEDURE Calc_Moments(l, wt, aa, a, c: double; mn, t1 : BYTE);
  VAR   station, segment, w1, b1 : double;
        j : byte;
    {
    <<< In_Cover >>>
    }
    FUNCTION In_Cover : BOOLEAN;
    BEGIN
      IF (aa + c) >= l THEN
        In_Cover := TRUE
      ELSE
        In_Cover := ((station >= aa) AND (station <= aa + c));
    END;    {...In_Cover...}

  BEGIN  {.. Calc_Moments ..}
    IF c <> 0 THEN w1 := wt/c;
    segment := l/vn;
    FOR j := 0 TO vn DO
      BEGIN
        station :=  j*segment;
        b1 := station - aa;              {.. dist to sect from station ..}
        IF (t1 = 2) AND (station >= a) THEN
          BEGIN
            IF station - a < segment THEN
              station := a
            ELSE
              span_mom^[mn,j] := span_mom^[mn,j] - wt * (station - a);
            {WRITELN(trc,'mn j - span_mom.. ',mn:8,j:8, span_mom^[mn,j]:9:3);}
          END
        ELSE
        IF In_Cover THEN
          CASE t1 OF                      {.. calc moments inside load cover..}

            1 : BEGIN
                  span_mom^[mn,j] := span_mom^[mn,j] - w1 * b1*b1/2;
                  {WRITELN(trc,'mn j - span_mom.. ',mn:8,j:8, span_mom^[mn,j]:9:3);}
                END;

            3 : BEGIN
                  span_mom^[mn,j] := span_mom^[mn,j] - w1 * b1/3;
                END;

            4 : BEGIN
                  b1 := cvr - b1;
                  span_mom^[mn,j] := span_mom^[mn,j] - w1 * b1/3;
                END;
          END
        ELSE
          IF station > (aa + c) THEN
            BEGIN
              span_mom^[mn,j] := span_mom^[mn,j] - wt * (station - a);
              {WRITELN(trc,'mn j - span_mom.. ',mn:8,j:8, span_mom^[mn,j]:9:3);}
            END;

      END;
  END;   {.. Calc_Moments ..}
    {
    << Combine_Joint_Loads >>
    ..
    }
    PROCEDURE Combine_Joint_Loads(k:BYTE);
    VAR    j0,k0 : WORD;
    BEGIN
      j0       :=  3 * con_grp[k].jj;
      k0       :=  3 * con_grp[k].jk;

      cx       :=  r^[k,1];
      cy       :=  r^[k,2];

      fc^[B_Ndx(j0 - 2)] := fc^[B_Ndx(j0 - 2)] - a_i * cx + ri * cy;
      fc^[B_Ndx(k0 - 2)] := fc^[B_Ndx(k0 - 2)] - a_j * cx + rj * cy;
      fc^[B_Ndx(j0 - 1)] := fc^[B_Ndx(j0 - 1)] - a_i * cy - ri * cx;
      fc^[B_Ndx(k0 - 1)] := fc^[B_Ndx(k0 - 1)] - a_j * cy - rj * cx;
      fc^[B_Ndx(j0    )] := fc^[B_Ndx(j0    )] - fi;
      fc^[B_Ndx(k0    )] := fc^[B_Ndx(k0    )] - fj;

      WrFVector('fc..  ',fc,n3);

    END;  {.. Combine_Joint_Loads ..}
    {
    << Fixed_End_Forces >>
    ..
    }
    PROCEDURE Fixed_End_Forces(k, lt : BYTE; omega, aa, c : double);

    VAR
        cx,cy  : double;
      {
      << Calc_Fixed_End_forces >>
      ..
      }
      PROCEDURE Calc_Fixed_End_forces;
      VAR flag : BYTE;
      BEGIN
        fi  :=  (2 * djj - 4 * dii) / ts;
        fj  :=  (4 * djj - 2 * dii) / ts;
        WITH con_grp[k] DO
          BEGIN
            flag := rel_i + rel_j;
            IF flag = 2 THEN
              BEGIN
                fi := 0;
                fj := 0;
              END;

            IF flag = 1 THEN
              IF (rel_i = 0) THEN
                BEGIN
                  fi  :=  fi - fj/2;
                  fj  :=  0;
                END
              ELSE
                BEGIN
                  fj  :=  fj - fi/2;
                  fi  :=  0;
                END
          END;
        ri  :=  ( fi + fj - wt * b) / ts;
        rj  :=  (-fi - fj - wt * a) / ts;

        a_i  :=  0;
        a_j  :=  0;

        Calc_Moments(ts, wt, aa, a, c, k, lt);

      END;  {.. Calc_Fixed_End_forces ..}
      {
      << Do_Point_load >>
      ..
      }
      PROCEDURE Do_Point_load;
        {
        << PL_Slope >>
        ..
        }
        FUNCTION PL_Slope(v : double) : double;
        BEGIN
          PL_Slope := wt * v * (ts*ts - v*v) / (6 * ts);
        END;  {.. PL_Slope ..}

      BEGIN
        a    := aa;
        b    := ts - aa;
        wt   := omega;
        dii  := PL_Slope(b);
        djj  := PL_Slope(a);
        Calc_Fixed_End_forces;
      END;  {.. Do_Point_load ..}
      {
      << Do_Part_UDL >>
      ..
      }
      PROCEDURE Do_Part_UDL;
        {
        << UDL_Slope >>
        ..
        }
        FUNCTION UDL_Slope(v : double) : double;
        BEGIN
          UDL_Slope := wt * v * (4 * (ts*ts - v*v) - c*c) / (24 * ts);
        END;  {.. UDL_Slope ..}

      BEGIN
        a    := aa + c/2;
        b    := ts - a;
        wt   := omega * c;
        dii  := UDL_Slope(b);
        djj  := UDL_Slope(a);
        Calc_Fixed_End_forces;
      END;  {.. Do_Part_UDL ..}
      {
      << Tri_Slope >>
      ..
      }
      FUNCTION Tri_Slope(v : double; end_coef : SHORTINT) : double;
      BEGIN
        cl   := c / ts;
        v    := v / ts;
        Tri_Slope := wt * ts * ts *
               (270 * (v - v*v*v) - cl*cl * (45 * v + end_coef * 2 * cl)) / 1620;
      END;  {.. Tri_Slope ..}
      {
      << Do_Triangle >>
      ..
      }
      PROCEDURE Do_Triangle(orient : SHORTINT);
      BEGIN
        a    := aa + 2 * c/3;
        b    := ts - a;
        wt   := omega * c / 2;
        dii  := Tri_Slope(b,orient*lo_end);
        djj  := Tri_Slope(a,orient*hi_end);
        Calc_Fixed_End_forces;
      END;  {.. Do_Triangle ..}
      {
      << Do_Axial_Load >>
      ..
      }
      PROCEDURE Do_Axial_Load;
      BEGIN
        a    := aa;
        b    := ts - a;
        a_i   := - omega * b / ts;
        a_j   := - omega * a / ts;
        fi   := 0;
        fj   := 0;
        ri   := 0;
        rj   := 0;
      END;  {.. Do_Axial_Load ..}
      {
      << Accumulate_Fix_End_Actions >>
      ..
      }
      PROCEDURE Accumulate_Fix_End_Actions;
      BEGIN
        af^[k,1]  :=  af^[k,1] + a_i;
        af^[k,2]  :=  af^[k,2] + ri;
        af^[k,3]  :=  af^[k,3] + fi;
        af^[k,4]  :=  af^[k,4] + a_j;
        af^[k,5]  :=  af^[k,5] + rj;
        af^[k,6]  :=  af^[k,6] + fj;
        Combine_Joint_Loads(k);
      END;  {.. Accumulate_Fix_End_Actions ..}

    BEGIN    {.. Fixed_End_Forces ..}

      CASE lt OF
        1  :  Do_Part_UDL;
        2  :  Do_Point_load;
        3  :  { Do_Variable_load };
        4  :  { Do_Moment_load };
        5  :  Do_Axial_Load;
        6  :  { Do_Temperature_load };
        8  :  Do_Triangle(hi_end);
        9  :  Do_Triangle(lo_end);
      END;

      Accumulate_Fix_End_Actions;

    END;  {.. Fixed_End_Forces ..}
    {
    << Do_Gravity_Load >>
    ..
    }
    PROCEDURE Do_Gravity_Load(mem : BYTE);
    VAR sect, mat : BYTE;
    BEGIN
      a     := 0;
      cvr   := ts;
      sect  := con_grp[mem].sect;
      mat   := mem_grp[sect].mat;
      udl   := udl * mat_grp[mat].density * mem_grp[sect].ax * 1e-3;
    END;  {.. Do_Gravity_Load ..}
    {
    << Do_Global_Load >>
    ..
    }
    PROCEDURE Do_Global_Load(mem, acode : BYTE; start : double);
    BEGIN
      CASE acode OF
        x_dir  :  BEGIN
                    norm_ld  := cy * udl;
                    axi_load := cx * udl;
                  END;
        y_dir  :  BEGIN
                    norm_ld  := cx * udl;
                    axi_load := cy * udl;
                  END;
      END;

      IF lc = 1 THEN
        BEGIN
          axi_load := axi_load * cvr;
          axi_pt   := start + cvr/2;
        END;
      Fixed_End_forces(mem, 5, axi_load, axi_pt, 0);
    END;  {.. Do_Global_Load ..}

  BEGIN   {.. Process_Loadcases ..}
    {WriteXY('Process_Loadcases.. ',1,8);}
{    WRITELN('>> ENTER LOAD TITLE << ');}
    Zero_Vars;
    IF njl <> 0 THEN
      FOR i := 1 TO njl DO
        WITH jnt_lod[i] DO
        BEGIN
          {WriteXY('jt load # '+ WordToString(i,4),28,8);}
          j := 3 * jt;
          fc^[B_Ndx(j - 2)] := fx;
          fc^[B_Ndx(j - 1)] := fy;
          fc^[B_Ndx(j)    ] := mz;
        END;

    IF nml <> 0 THEN
      FOR i := 1 TO nml DO
        WITH mem_lod[i] DO
          BEGIN
            {WriteXY('mem load # '+ WordToString(i,4),28,9);}
            ts  :=   l^[mem_no];
            cx  :=   r^[mem_no,1];
            cy  :=   r^[mem_no,2];
            lc  :=   lcode;
            udl :=   load;
            cvr :=   cover;
            l1  :=   start;
            IF (lc = 1) AND (cvr = 0) THEN
              BEGIN
                l1    := 0;
                cvr   := ts;
              END;

            norm_ld  := udl;
            IF acode <> local THEN
              BEGIN
                Do_Global_Load(mem_no, acode, start);
              END;
            Fixed_End_forces(mem_no, lc, norm_ld, start, cvr);
          END;

    IF ngl <> 0 THEN
      FOR i := 1 TO m DO
        WITH grv_lod DO
          BEGIN
            {WriteXY('grv load # '+ WordToString(i,4),28,9);}
            ts  :=   l^[i];
            cx  :=   r^[i,1];
            cy  :=   r^[i,2];
            udl :=   load;
            lc  :=   1;
            Do_Gravity_Load(i);
            norm_ld  := udl;
            IF acode <> local THEN
              BEGIN
                Do_Global_Load(i,acode,0);
              END;
            Fixed_End_forces(i, 1, norm_ld, 0, cvr);
          END;
  END;  {.. Process_Loadcases ..}


BEGIN   {.. UNIT Pf_Load..}
END.    {.. UNIT Pf_Load..}
 
