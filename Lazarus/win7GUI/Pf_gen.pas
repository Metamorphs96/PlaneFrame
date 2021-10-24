{###### Pf_Gen.PAS ######
 ... a unit file of general routines for the Framework analysis program ...
     R G Harrison   --  Version 5.2  --  30/ 3/96  ...

     Revision history :-
        29/ 7/90 - implemented ..
        29/ 2/96 - member end releases added
         4/ 3/96 - main data structures made DYNAMIC
        30/ 3/96 - graphics routines standardised
}
UNIT Pf_gen;

{$MODE Delphi}

INTERFACE
USES
  Pf_vars;          {.. Application Variables ..}


  //FUNCTION  StrToByte(inp_s : STRING) : BYTE;
  PROCEDURE WrVector(msg : STRING; d : ivec_ptr; n : BYTE);
  PROCEDURE WrFVector(msg : STRING; d : vec_ptr; n : BYTE);
  PROCEDURE WrMat(msg : STRING; m : mat_ptr; r,c : INTEGER);
  PROCEDURE Get_Direction_Cosines;
  PROCEDURE Total_Section_Length;
  PROCEDURE Alloc_Anal_Mem;
  PROCEDURE Free_Anal_Mem;
  FUNCTION  FOpen(fname : FileNameAndPath;
                VAR fp : TextFile; mode : CHAR) : BOOLEAN;
  FUNCTION  FClose(VAR fp : TextFile) : BOOLEAN;

{
===========================================================================
}
IMPLEMENTATION
  {
<< UpperCase >>
... convert a string TO upper CASE characters   6/4/89 ...
}
FUNCTION UpperCase(inp_s : string80) : string80;
VAR i : BYTE;
BEGIN
  FOR i := 1 TO LENGTH(inp_s) DO
    inp_s[i] := UPCASE(inp_s[i]);
  UpperCase := inp_s;
END;
{
  << WrVector >>
  ...a procedure to print out vectors  ...
  }
  PROCEDURE WrVector(msg : STRING; d : ivec_ptr; n : BYTE);
  VAR  i  : BYTE;
  BEGIN
  (*
    WRITELN(trc,msg,'  integer vector   ');
    FOR i := 1 TO n DO
      WRITE(trc,d^[i]:8);
    WRITELN(trc);
  *)
  END;      {...WrVector...}
  {
  << WrFVector >>
  ...a procedure to print out vectors  ...
  }
  PROCEDURE WrFVector(msg : STRING; d : vec_ptr; n : BYTE);
  VAR  i  : BYTE;
  BEGIN
  (*
    WRITELN(trc,msg,'  float vector   ');
    FOR i := 1 TO n DO
      WRITE(trc,d^[i]:15:6);
    WRITELN(trc);
  *)
  END;      {...WrFVector...}
  {
  << WrMat  >>
  ...a procedure to print out the matrix a and  n - vector b ...
  }
  PROCEDURE WrMat(msg : STRING; m : mat_ptr; r,c : INTEGER);
  VAR  i,j  : INTEGER;
  BEGIN
  (*
    WRITELN(trc,msg,' matrix ');
    FOR i := 1 TO r DO
      BEGIN
        FOR j := 1 TO c DO
          WRITE(trc,m^[i,j]:15:6);
        WRITELN(trc);
      END;       {...for i do...}
  *)
  END;      {...WrMat...}
  {
  << Get_Direction_Cosines >>
  ..
  }
  PROCEDURE Get_Direction_Cosines;
  VAR xm,     {.. component of a member's length along frame X_axis ..}
      ym      {.. component of a member's length along frame Y_axis ..}
      : double;
      i, tmp, rel_tmp : BYTE;
  BEGIN
    {OpenTraceFiles;}

    FILLCHAR(l^, SizeOf(l^), 0);
    FOR i := 1 TO m DO
      WITH con_grp[i] DO
      BEGIN
        IF jk < jj THEN  {.. swap end1 with end2 if smaller !! ..}
          BEGIN
            tmp := jj;
            jj  := jk;
            jk  := tmp;

            rel_tmp := rel_j;
            rel_j   := rel_i;
            rel_i   := rel_tmp;
          END;
        xm   := nod_grp[jk].x - nod_grp[jj].x;
        ym   := nod_grp[jk].y - nod_grp[jj].y;
        l^[i] := SQRT(xm * xm + ym * ym);
        r^[i,1] := xm / l^[i];
        r^[i,2] := ym / l^[i];
      END;
  END;  {.. Get_Direction_Cosines ..}
  {
  << Total_Section_Mass >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Total_Section_Mass;
  var i : integer;
  BEGIN
    {WriteXY('>> Total_Section_Mass << ',1,3);}
    FOR i := 1 TO nsg DO
      WITH mem_grp[i], mat_grp[mat] DO
      BEGIN
        {WriteXY('member # '+ WordToString(i,4),28,3);}
        t_mass := ax * density * t_len;
      END;
  END; {.. Total_Section_Mass ..}
  {
  << Total_Section_Length >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Total_Section_Length;
  var i : integer;
  BEGIN
    {WriteXY('>> Total_Section_Length << ',1,3);}
    FOR i := 1 TO m DO
       WITH con_grp[i] DO
      BEGIN
        {WriteXY('member # '+ WordToString(i,4),28,3);}
        //mem_grp[sect].t_len := mem_grp[sect].t_len + l^[i];
      END;
      Total_Section_Mass;
  END; {.. Total_Section_Length ..}
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
  FREEMEM(sj,   size);

  size := SIZEOF(Memb_Mom);
  FREEMEM(span_mom,  size);

  size := SIZEOF(int_vector);
  FREEMEM(rl,  size);
  FREEMEM(crl, size);
   
END;     {...Free_Anal_Mem...}

{
*************************
* File Opening function *
***************************************************}
FUNCTION  FOpen(fname : FileNameAndPath;
                VAR fp : TextFile; mode : CHAR) : BOOLEAN;
BEGIN   {...FUNCTION...FOpen}
  mode := UPCASE(mode);
  AssignFile(fp,fname);
  CASE mode OF
    'R': {$I-} RESET(fp)   {$I+};
    'W': {$I-} REWRITE(fp) {$I+};
    'A': {$I-} APPEND(fp)  {$I+};
  END;
  FOpen := (IOresult = 0);
END;    {...FUNCTION...FOpen}
{
*************************
* File Closing function *
***************************************************}
FUNCTION  FClose(VAR fp : TextFile) : BOOLEAN;
BEGIN   {...FUNCTION...FClose}
  {$I-} CloseFile(fp) {$I+};
  FClose := (IOresult = 0);
END;    {...FUNCTION...FClose}



BEGIN
END.    {.. UNIT Pf_Gen..}

