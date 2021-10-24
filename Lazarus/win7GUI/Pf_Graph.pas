{###### Pf_Graph.PAS ######
 ... a unit file of screen graphic and plotting routines -

    Windows 95 Delphi Version 3.0

    Version 5.0  --  21/05/02

    Written by:

    Roy Harrison,
    Roy Harrison & Associates,
    Incorporating TECTONIC Software Engineers,
    MODBURY HEIGHTS, SA 5092,

     Revision history :-
        29/ 7/90 - implemented ..
        31/ 1/92 - changed over to gadget walking windows ..
        28/ 2/96 - plots of delta and forces
         4/ 3/96 - main data structures made DYNAMIC
        11/ 3/96 - span bending monets added
        30/ 3/96 - graphics routines standardised
        07/06/02 - Converted to Delphi & Win95
}
{.. Framework program debugged 14/1/92 ..}

UNIT Pf_Graph;

{$MODE Delphi}

INTERFACE
USES
     LCLIntf, LCLType, LMessages,
     Classes,
     Forms,
     Graphics,
     Controls,
     Dialogs,          {.. Dialog operations - standard unit ..}
     Mi_Plot,

     Pf_vars,
     Pf_anal;

   PROCEDURE Plot_To_Screen(lcase : BYTE; Var bitmap:Tbitmap );
   procedure Display_Network(crv_no : BYTE);

{
===========================================================================
}
IMPLEMENTATION
CONST
      curvename : ARRAY[0..5] OF STRING[12] =
      ( 'Geometry', 'Loads','Moments','Shears','Axials','Deflections');

      step = 0.01;
      inset = 6;
      lmargin  = 2; //20;   {.. left margin in pixels for plotting ..}
      red_fact = 0.9;  {.. effective width of plot area ..}
      n_xasp   = 1000;  {.. constants for SetAspectRatio ..}
      n_yasp   = 1215;

VAR
      y_scale,
      x_scale,          {.. coord scaling factors for plotting ..}
      lx_max, ly_max,
      cos_a, sin_a, dx, dy,
      tmp_scale, load_scale
      : double;

      scrw, scrd,       { Useable plot window dimensions }
      clrnc
      : WORD;

      l_color
      : LONGINT;

      aspect_ratio,
      xa, ya, xb, yb,   {.. temporary line coords for plotting ..}
      x1, y1, x2, y2    {.. given line coords for plotting ..}
      : REAL;

      maxx, maxy       { The maximum resolution of the screen }
      : WORD;


      plotwidth,        {.. width of plot area ..}
      ydatum
      : INTEGER;

      xoff, yoff,       { The offset from the axes of the screen to graph }
      xasp, yasp        { The maximum resolution of the screen }
      :  WORD;

      mi_curve : ARRAY[1..order] of Tpoint;

   {
   << Plot_To_Screen >>
   .. Procedure based on ref#? p?
      algorithm
      Modified RGH :-
      6/2/92 - implemented ..
   }
   PROCEDURE Plot_To_Screen(lcase : BYTE; Var bitmap:Tbitmap );

  {
  >>> Plot_Edge <<<
  ... a PROCEDURE TO plot the Network on the screen  -- 31/10/91..
  }
  PROCEDURE Plot_Edge( xmum, ymum, xson, yson : REAL; colr : longint);
  VAR x1,x2,y1,y2 : WORD;
  BEGIN   {..Plot_Edge..}
   With Bitmap.Canvas do
    begin
      pen.Style := psSolid;
      pen.color := colr;
      x1 := lmargin + xoff  + TRUNC(xmum * x_scale);
      y1 := scrd    - yoff  - TRUNC(ymum * y_scale);
      x2 := lmargin + xoff  + TRUNC(xson * x_scale);
      y2 := scrd    - yoff  - TRUNC(yson * y_scale);
      MoveTo(x1,y1);
      LineTo(x2,y2);
    end;
  END;    {...Plot_Edge...}
  {
  >>> Plot_Node_Nos <<<
  ... a PROCEDURE TO plot network vertices on the screen  -- 31/10/91..
  }
  PROCEDURE Plot_Node_Nos( ndx : STRING; xvect, yvect : REAL;
                           offset : INTEGER; color  : longint);
  VAR x, xch, ych  : WORD;
  BEGIN   {..Plot_Node_Nos..}
    With Bitmap.Canvas do
    begin
    pen.color := clred;
    xch := lmargin + TRUNC(xvect * x_scale) + xoff;
    ych := scrd    - TRUNC(yvect * y_scale) - yoff;
    TextOut(xch+5, ych-(offset*5), ndx);
    Ellipse(xch-3, ych-3, xch+3, ych+3);
    end;
  //  CIRCLE(xch, ych, 1);
  END;    {...Plot_Node_Nos...}

  {
  >>> Plot_Screen <<<
  ... display the network on the screen for visualization..
  }
  PROCEDURE Plot_Screen(plotcase : BYTE);
  VAR       lnstr : BYTE;
  BEGIN  {..Start Plot_Screen...}
       WITH Bitmap.canvas  DO
         BEGIN
           Font.color := clRed;
           //scrd := GraphForm.clientheight-20;
           scrd := Bitmap.height;
           scrw := Bitmap.width;
           //scrw := GraphForm.clientwidth -20;
           textout(350, 2,'>> WinFRAME <<');
           lnstr := LENGTH(curvename[plotcase]);
           textout(350, 20,curvename[plotcase]);
         END;
        //Plot_Coord_Symbol(20,y2-40);
  END;   {...Plot_Screen...}
  {
  << Draw_Arrow >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     8/3/96 - implemented ..
  }
  PROCEDURE Draw_Arrow( x1, y1, fx : double; dir, a_color: longint);
  CONST   xco = 0;
  VAR dl : double;
  BEGIN
    dl  := 0.2 * load_scale * fx;
    {.. plot arrow edge 1 ..}
    xa  := x1 - dl;
    ya  := y1 + dl;
    Plot_Edge(x1,y1,xa,ya,a_color);

    {.. plot arrow edge 2 ..}
    IF dir = xco THEN
      BEGIN
        xb := xa;
        yb := y1 - dl;
      END
    ELSE
      BEGIN
        xb := x1 + dl;
        yb := ya;
      END;
    Plot_Edge(x1,y1,xb,yb,a_color);
  END; {.. Draw_Arrow ..}
  {
  << Plot_Joint_Load_X >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     8/3/96 - implemented ..
  }
  PROCEDURE Plot_Joint_Load_X(x1,y1,fx : double; p_color : longint);
  BEGIN
    xa  := x1 - load_scale * fx;
    Plot_Edge(x1,y1,xa,y1,p_color);
    Draw_Arrow(x1,y1,fx,0,p_color);
  END; {.. Plot_Joint_Load_X ..}
  {
  << Plot_Joint_Load_Y >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     8/3/96 - implemented ..
  }
  PROCEDURE Plot_Joint_Load_Y(x1,y1,fy : double; p_color : longint);
  BEGIN
    yb  := y1 - load_scale * fy;
    Plot_Edge(x1,y1,x1,yb,p_color);
    Draw_Arrow(x1,y1,-fy,1,p_color);
  END; {.. Plot_Joint_Load_Y ..}
  {
  << Plot_Loads >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     24/2/96 - implemented ..
  }
  PROCEDURE Plot_Loads;
  VAR
       max_W, pl, udl  : double;
       mn : BYTE;
       i : integer;
    {
    << Get_Max_Load >>
    .. Procedure based on ref#? p?
       algorithm
       Modified RGH :-
       24/2/96 - implemented ..
    }
    PROCEDURE Get_Max_Load;
    Var i : integer;
    BEGIN
      max_W := 0;

      FOR i := 1 TO nml DO
        WITH mem_lod[i] DO
          IF max_W < ABS(load) THEN max_W := ABS(load);

      FOR i := 1 TO njl DO
        WITH jnt_lod[i] DO
          BEGIN
           IF max_W < ABS(fx) THEN max_W := ABS(fx);
           IF max_W < ABS(fy) THEN max_W := ABS(fy);
          END;

      load_scale := ly_max * 0.2 / max_W;
    END; {.. Get_Max_Load ..}
    {
    << Get_Load_Direction >>
    .. Procedure based on ref#? p?
       algorithm
       Modified RGH :-
       24/2/96 - implemented ..
    }
    PROCEDURE Get_Load_Direction(w : double; acode : BYTE);
    BEGIN
      CASE acode OF
        local  :  BEGIN
                    dx  := w * sin_a * aspect_ratio;
                    dy  := w * cos_a / aspect_ratio;
                  END;
        x_dir  :  BEGIN
                    dx  := w;
                    dy  := 0;
                  END;
        y_dir  :  BEGIN
                    dx  := 0;
                    dy  := w;
                  END;
      END;
    END; {.. Get_Load_Direction ..}
    {
    << Plot_UDL >>
    .. Procedure based on ref#? p?
       algorithm
       Modified RGH :-
       8/3/96 - implemented ..
    }
    PROCEDURE Plot_UDL;
    BEGIN
      WITH con_grp[mn] DO
         BEGIN
           x1  := nod_grp[jj].x;
           y1  := nod_grp[jj].y;
           x2  := nod_grp[jk].x;
           y2  := nod_grp[jk].y;
         END;
      xa  := x1 + dx;
      ya  := y1 - dy;
      xb  := x2 + dx;
      yb  := y2 - dy;

      Plot_Edge(x1,y1,xa,ya,l_color);
      Plot_Edge(xa,ya,xb,yb,l_color);
      Plot_Edge(xb,yb,x2,y2,l_color);
    END; {.. Plot_UDL ..}
    {
    << Plot_PL >>
    .. Procedure based on ref#? p?
       algorithm
       Modified RGH :-
       8/3/96 - implemented ..
    }
    PROCEDURE Plot_PL(aa, pl : double);
    VAR ddx, ddy : double;
        pl_st : STRING;

    BEGIN
      WITH con_grp[mn] DO
         BEGIN
           x1  := nod_grp[jj].x;
           y1  := nod_grp[jj].y;
         END;

      ddx  := aa * cos_a;
      ddy  := aa * sin_a;

      xa  := x1 + ddx;
      ya  := y1 + ddy;
      xb  := xa + dx;
      yb  := ya - dy;

      STR(pl:5:1,pl_st);
      Plot_Node_Nos(pl_st, xb, yb, 2, 1);

      Plot_Node_Nos('', xa, ya, 2, l_color);
      Plot_Edge(xa,ya,xb,yb,l_color);

      Draw_Arrow(xa,ya,40,0,l_color);
      END; {.. Plot_PL ..}

  BEGIN
    Get_Max_Load;
    FOR i := 1 TO nml DO
      BEGIN
        WITH mem_lod[i] DO
          BEGIN
           IF lcode = 1 THEN
             BEGIN
               udl := load_scale * load;
               mn  := mem_no;
               cos_a  := r^[mn,1];
               sin_a  := r^[mn,2];
               Get_Load_Direction(udl, acode);
               Plot_UDL;
             END;

           IF lcode = 2 THEN
             BEGIN
               pl := load_scale * load;
               mn  := mem_no;
               cos_a  := r^[mn,1];
               sin_a  := r^[mn,2];
               Get_Load_Direction(pl, acode);
               Plot_PL(start, load);
             END;
           END;
      END;

    FOR i := 1 TO njl DO
      BEGIN
        WITH jnt_lod[i], con_grp[i], nod_grp[jt]  DO
          BEGIN
            IF fx <> 0 THEN  Plot_Joint_Load_X(x,y,fx,clsilver);
            IF fy <> 0 THEN  Plot_Joint_Load_Y(x,y,fy,clLime);
          END;
      END;
  END; {.. Plot_Loads ..}
  {
  << Plot_Delta >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Plot_Delta;
  VAR
       D_jj, D_jk,
       max_D : double;
       i : integer;
    {
    << Get_Max_Delta >>
    .. Procedure based on ref#? p?
       algorithm
       Modified RGH :-
       24/2/96 - implemented ..
    }
    PROCEDURE Get_Max_Delta;
    Var i : integer;
    BEGIN
      max_D := 0;

      FOR i := 1 TO no_jts DO
        BEGIN
          IF max_D < ABS(dj^[3*i-2]) THEN max_D := ABS(dj^[3*i-2]);
          IF max_D < ABS(dj^[3*i-1]) THEN max_D := ABS(dj^[3*i-1]);
        END;
      load_scale := ly_max * 0.5 / max_D;
    END; {.. Get_Max_Delta ..}

  BEGIN
    Get_Max_Delta;
    FOR i := 1 TO m DO
      WITH con_grp[i] DO
        BEGIN

          x1  := nod_grp[jj].x;
          y1  := nod_grp[jj].y;
          x2  := nod_grp[jk].x;
          y2  := nod_grp[jk].y;

          dx  :=  load_scale * dj^[3*jj-2];
          dy  :=  load_scale * dj^[3*jj-1];
          xa  := x1 + dx;
          ya  := y1 + dy;

          dx  :=  load_scale * dj^[3*jk-2];
          dy  :=  load_scale * dj^[3*jk-1];
          xb  := x2 + dx;
          yb  := y2 + dy;

          Plot_Edge(xa,ya,xb,yb,l_color);

       END;
  END; {.. Plot_Delta ..}
  {
  << Plot_Supports >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Plot_Supports;
  VAR   dl  : double;
        i : integer;
  BEGIN
    FOR i := 1 TO nrj DO
      WITH sup_grp[i], nod_grp[js] DO
        BEGIN

          dx  :=  20 / x_scale;
          dl  :=  0.25 * dx;

          load_scale := x_scale;
          {.. x-arrow ..}
          Plot_Edge(x-dl,y,x-dx,y,l_color);
          Draw_Arrow(x-dl,y,dx/x_scale,0,l_color);
          {.. y-arrow ..}
          Plot_Edge(x,y-dl,x,y-dx,l_color);
          Draw_Arrow(x,y-dl,-dx/x_scale,1,l_color);
        END;
  END; {.. Plot_Supports ..}
  {
  << Plot_Moment >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     8/3/96 - implemented ..
  }
  PROCEDURE Plot_Moment(i:BYTE);
  VAR j : BYTE;
      station, segment, st_x, st_y : double;
  BEGIN
    WITH con_grp[i] DO
      BEGIN
        x1  := nod_grp[jj].x;
        y1  := nod_grp[jj].y;
        x2  := nod_grp[jk].x;
        y2  := nod_grp[jk].y;
        dx  := -sin_a * load_scale * span_mom^[i,0];
        dy  := -cos_a * load_scale * span_mom^[i,0];
        xa  := x1 + dx;
        ya  := y1 - dy;
        Plot_Edge(x1,y1,xa,ya,l_color);
        segment := l^[i]/vn;
        FOR j := 1 TO vn DO
          BEGIN
            station :=  j*segment;
            st_x := x1 + station * cos_a;
            st_y := y1 + station * sin_a;
            dx  :=  -sin_a * load_scale * span_mom^[i,j];
            dy  :=  -cos_a * load_scale * span_mom^[i,j];
            xb  := st_x + dx;
            yb  := st_y - dy;
            Plot_Edge(xa,ya,xb,yb,l_color);
            xa  := xb;
            ya  := yb;
          END;
        Plot_Edge(xa,ya,x2,y2,l_color);
      END;
  END; {.. Plot_Moment ..}
  {
  << Plot_Force >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Plot_Force(plotcase : BYTE);
  VAR
       F_jj, F_jk,
       min_F, max_F : double;
       l_color : longint;
       i : integer;

    {
    << Get_Max_Force >>
    .. Procedure based on ref#? p?
       algorithm
       Modified RGH :-
       24/2/96 - implemented ..
    }
    PROCEDURE Get_Max_Force;
    Var i : integer;

    BEGIN
      max_F := 0;

      FOR i := 1 TO m DO
        WITH con_grp[i] DO
          BEGIN
            CASE plotcase OF
              moments  :
                         BEGIN
                           F_jj := jnt_jj.moment;
                           F_jk := jnt_jk.moment;
                           l_color := clAqua;
                         END;
              shears   :
                         BEGIN
                           F_jj := jnt_jj.shear;
                           F_jk := jnt_jk.shear;
                           l_color := clFuchsia;
                         END;

              axial    :
                         BEGIN
                           F_jj := jnt_jj.axial;
                           F_jk := jnt_jk.axial;
                           l_color := clOlive;
                         END;
            END;

            IF max_F < ABS(F_jj) THEN max_F := ABS(F_jj);
            IF max_F < ABS(F_jk) THEN max_F := ABS(F_jk);
          END;
      min_F := ABS(ly_max * 0.25);
      IF max_F < min_F THEN max_F := min_F ;
      load_scale := mag * min_F / max_F;
    END; {.. Get_Max_Force ..}

  BEGIN
    Get_Max_Force;
    FOR i := 1 TO m DO
      WITH con_grp[i] DO
      BEGIN
        cos_a  := r^[i,1];
        sin_a  := r^[i,2];
        CASE plotcase OF
          moments  :
                       BEGIN
                         F_jj := load_scale * jnt_jj.moment;
                         F_jk := load_scale * jnt_jk.moment;
                         l_color := clTeal;
                       END;
          shears   :
                       BEGIN
                         F_jj := load_scale * jnt_jj.shear;
                         F_jk := load_scale * jnt_jk.shear;
                         l_color := clPurple;
                       END;

          axial    :
                       BEGIN
                         F_jj := load_scale * jnt_jj.axial;
                         F_jk := load_scale * jnt_jk.axial;
                         l_color := clNavy;
                       END;
        END;

        IF plotcase = moments THEN
          Plot_Moment(i)
        ELSE
        BEGIN
        x1  := nod_grp[jj].x;
        y1  := nod_grp[jj].y;
        x2  := nod_grp[jk].x;
        y2  := nod_grp[jk].y;

        dx  := F_jj * sin_a;
        dy  := F_jj * cos_a;
        xa  := x1 + dx;
        ya  := y1 - dy;

        dx  := F_jk * sin_a;
        dy  := F_jk * cos_a;
        xb  := x2 + dx;
        yb  := y2 - dy;

        Plot_Edge(x1,y1,xa,ya,l_color);
        Plot_Edge(xa,ya,xb,yb,l_color);
        Plot_Edge(xb,yb,x2,y2,l_color);
        END;

      END;
  END; {.. Plot_Force ..}
  {
  << Screen_Plot_Frame >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  }
  PROCEDURE Screen_Plot_Frame(plotcase : BYTE);
  VAR trash : CHAR;
  {
  << Scale_Plot >>
  .. Procedure based on ref#? p?
     algorithm
     Modified RGH #/#/91 ..
  }
  PROCEDURE Scale_Plot;
  VAR   x_max, x_min, y_max, y_min : double;
        i : WORD;
  BEGIN
    x_max := 0;            x_min := 1e20;
    y_max := 0;            y_min := 1e20;
    clrnc := 10;

{
    aspect_ratio := 0.85; (* 10/12;*)
    aspect_ratio := xasp / yasp;
}
    aspect_ratio := n_xasp / n_yasp;
    FOR i := 1 TO no_jts DO
      WITH nod_grp[i] DO
        BEGIN
          IF x < x_min THEN  x_min := x;
          IF x > x_max THEN  x_max := x;
          IF y < y_min THEN  y_min := y;
          IF y > y_max THEN  y_max := y;
        END;
     lx_max := x_max - x_min;
     ly_max := y_max - y_min;

     IF lx_max <> 0 THEN x_scale := scrw / lx_max;
     IF ly_max <> 0 THEN
        y_scale := scrd / ly_max
     ELSE
       BEGIN
        {.. modify for beams ..}
         y_scale := x_scale;
         ly_max  := scrd / y_scale;
       END;

     IF x_scale < y_scale * aspect_ratio THEN
       tmp_scale := x_scale
     ELSE
       tmp_scale := y_scale * aspect_ratio;

     x_scale := 0.5 * tmp_scale;
     y_scale := aspect_ratio * x_scale;

     xoff := (scrw - TRUNC(x_scale * lx_max)) DIV 2;
     yoff := (scrd - TRUNC(y_scale * ly_max)) DIV 2;

     IF y_min < 0 THEN
       yoff := yoff - TRUNC(y_scale * y_min);

   END; {.. Scale_Plot ..}
   {
   << Plot_Framework >>
   .. Procedure based on ref#? p?
      algorithm
      Modified RGH #/#/91 ..
   }
   PROCEDURE Plot_Framework;
   VAR i,j : BYTE;
       ist : STRING;
   BEGIN
     FOR i := 1 TO m DO
       WITH con_grp[i] DO
         Plot_Edge( nod_grp[jj].x, nod_grp[jj].y,
                    nod_grp[jk].x, nod_grp[jk].y,clred);

      {.. plot the node annotation ..}
     FOR i := 1 TO no_jts DO
       WITH nod_grp[i] DO
       BEGIN
         STR(i,ist);
         Plot_Node_Nos(ist, x, y, 0, clLime);
       END;
   END; {.. Plot_Framework ..}

   BEGIN
     Plot_Screen(plotcase);
     Scale_Plot;
     Plot_Framework;
     Plot_Supports;
     CASE plotcase OF
       loads    :   IF nml+njl+ngl <> 0 THEN     Plot_Loads;
       moments  :   Plot_Force(plotcase);
       shears   :   Plot_Force(plotcase);
       axial    :   Plot_Force(plotcase);
       delta    :   Plot_Delta;
     END;

   END; {.. Screen_Plot_Frame ..}


BEGIN
     IF data_loaded THEN
       Screen_Plot_Frame(lcase)
     ELSE
       showmessage('error')
       //Plot_Error_Msg;
   END; {.. Plot_To_Screen ..}


procedure Display_Network(crv_no : BYTE);
var
  mychrt : TGraphForm;
  Bitmap: Tbitmap;
   {
     << Display_Graph >>
     .. Procedure based on ref#? p?
        algorithm
        Modified RGH :-
        8/3/96 - implemented ..
     }
     PROCEDURE Display_Graph;
     BEGIN
        with BitMap do
        begin
           Width  := 800;
           Height := 600;
      
           With canvas do Plot_To_Screen (crv_no, Bitmap);
        end;
        mychrt := TGraphForm.create(application);
        mychrt.caption := curvename[crv_no]+' : Plot';
        mychrt.Image1.Picture.Graphic := Bitmap;
        mychrt.show;
     END; {.. Display_Graph ..}
  
begin
//Geometry Plot
  Bitmap := TBitmap.Create;
  IF analysed then
     Display_Graph
  else
    MessageDlg('>> Run Analysis First !!  <<', mtInformation,[mbOk], 0);

end;

BEGIN   {.. UNIT Pf_Graph..}

END.    {.. UNIT Pf_Graph..}
   {
   << zz >>
   .. Procedure based on ref#? p?
      algorithm
      Modified RGH :-
      8/3/96 - implemented ..
   }
   PROCEDURE zz;
   BEGIN
   END; {.. zz ..}
   {
     << zz >>
     .. Procedure based on ref#? p?
        algorithm
        Modified RGH :-
        8/3/96 - implemented ..
     }
     PROCEDURE zz;
     BEGIN
     END; {.. zz ..}

