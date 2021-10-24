Option Explicit On
Public Class TDiagramPlotter

    '###### Pf_Graph.PAS ######
    ' ... a unit file of screen graphic and plotting routines -
    '    Windows 95 Delphi Version 3.0
    '    Version 5.0  --  21/05/02
    '    Written by:
    '    Roy Harrison,
    '    Roy Harrison & Associates,
    '     Revision history :-
    '        29/ 7/90 - implemented ..
    '        31/ 1/92 - changed over to gadget walking windows ..
    '        28/ 2/96 - plots of delta and forces
    '         4/ 3/96 - main data structures made DYNAMIC
    '        11/ 3/96 - span bending moments added
    '        30/ 3/96 - graphics routines standardised
    '        07/06/02 - Converted to Delphi & Win95
    '.. Framework program debugged 14/1/92 ..

    Public MainAppFrm As MDIParent1

    Public diagramImage As TgraphViewer
    Public objbmp As Bitmap
    Public objGraph As Graphics

    Dim objPen As Pen

    Dim max_D As Double
    Dim max_W As Double
    Dim min_F As Double
    Dim max_F As Double

    Dim F_jj As Double
    Dim F_jk As Double

    Dim mn As Byte

    Public plotcase As Byte


    '===========================================================================

    Dim curvename() As String = {"Geometry", "Loads", "Moments", "Shears", "Axials", "Deflections"}

    Const stepInc = 0.01
    Const inset = 6
    Const lmargin = 2     '20   .. left margin in pixels for plotting ..
    Const red_fact = 0.9  '.. effective width of plot area ..
    Const n_xasp = 1000   '.. constants for SetAspectRatio ..
    Const n_yasp = 1215


    Dim y_scale As Double
    Dim x_scale As Double          '.. coord scaling factors for plotting ..
    Dim lx_max As Double
    Dim ly_max As Double
    Dim cos_a As Double
    Dim sin_a As Double
    Dim dx As Double
    Dim dy As Double
    Dim tmp_scale As Double
    Dim load_scale As Double

    Dim scrw As Integer
    Dim scrd As Integer       ' Useable plot window dimensions
    Dim clrnc As Integer

    Dim l_color As System.Drawing.Color

    Dim aspect_ratio
    Dim xa As Double
    Dim ya As Double
    Dim xb As Double
    Dim yb As Double   '.. temporary line coords for plotting ..
    Dim x1 As Double
    Dim y1 As Double
    Dim x2 As Double
    Dim y2 As Double    '.. given line coords for plotting ..


    Dim maxx As Integer
    Dim maxy As Integer    ' The maximum resolution of the screen


    Dim plotwidth As Integer        '.. width of plot area ..
    Dim ydatum As Integer

    Dim xoff As Integer
    Dim yoff As Integer       ' The offset from the axes of the screen to graph
    Dim xasp As Integer
    Dim yasp As Integer        ' The maximum resolution of the screen

    'Dim mi_curveas(order) As Tpoint


    '  >>> Plot_Edge <<<
    '  ... a Sub TO plot the Network on the screen  -- 31/10/91..
    Sub Plot_Edge(ByVal xmum As Double, ByVal ymum As Double, ByVal xson As Double, ByVal yson As Double, ByVal colr As System.Drawing.Color)
        Dim x1, x2, y1, y2 As Integer

        With objGraph
            'Pen.Style = psSolid
            'Pen.Color = colr
            objPen = New Pen(colr, 1)                    '(Color.Blue, 1)
            x1 = lmargin + xoff + Int(xmum * x_scale)
            y1 = scrd - yoff - Int(ymum * y_scale)
            x2 = lmargin + xoff + Int(xson * x_scale)
            y2 = scrd - yoff - Int(yson * y_scale)
            'MoveTo(x1, y1)
            .DrawLine(objPen, x1, y1, x2, y2)
        End With

    End Sub '...Plot_Edge...


    '  >>> Plot_Node_Nos <<<
    '  ... a Sub TO plot network vertices on the screen  -- 31/10/91..
    Sub Plot_Node_Nos(ByVal ndx As String, ByVal xvect As Double, ByVal yvect As Double, ByVal offset As Integer, ByVal colour As System.Drawing.Color)
        Dim xch As Integer
        Dim ych As Integer
        Dim txtFont As New Font("Arial", 10, FontStyle.Regular)

        With objGraph
            xch = lmargin + Int(xvect * x_scale) + xoff
            ych = scrd - Int(yvect * y_scale) - yoff
            .DrawString(ndx, txtFont, Brushes.DarkRed, xch + 5, ych - (offset * 5))
            .DrawEllipse(objPen, xch - 3, ych - 3, 3, 3)
        End With
        '  CIRCLE(xch, ych, 1)
    End Sub   '...Plot_Node_Nos...


    '  >>> Plot_Screen <<<
    '  ... display the network on the screen for visualization..
    Sub Plot_Screen()
        Dim lnstr As Byte
        Dim txtFont As New Font("Arial", 10, FontStyle.Regular)

        With objGraph
            scrd = objbmp.Height
            scrw = objbmp.Width
            .DrawString(">> WinFRAME <<", txtFont, Brushes.DarkRed, 350, 2) '  textout(350, 2, 
            lnstr = Len(curvename(plotcase))
            .DrawString(curvename(plotcase), txtFont, Brushes.DarkRed, 350, 20)
        End With
        'Plot_Coord_Symbol(20,y2-40)
    End Sub  '...Plot_Screen...




    '  << Draw_Arrow >>
    '     algorithm
    '     Modified RGH :-
    '     8/3/96 - implemented ..
    Sub Draw_Arrow(ByVal x1 As Double, ByVal y1 As Double, ByVal fx As Double, ByVal dir As Integer, ByVal a_color As System.Drawing.Color)
        Const xco = 0
        Dim dl As Double

        dl = 0.2 * load_scale * fx
        '.. plot arrow edge 1 ..
        xa = x1 - dl
        ya = y1 + dl
        Plot_Edge(x1, y1, xa, ya, a_color)

        '.. plot arrow edge 2 ..
        If dir = xco Then
            xb = xa
            yb = y1 - dl
        Else
            xb = x1 + dl
            yb = ya
        End If

        Plot_Edge(x1, y1, xb, yb, a_color)
    End Sub '.. Draw_Arrow ..


    '  << Plot_Joint_Load_X >>
    '     algorithm
    '     Modified RGH :-
    '     8/3/96 - implemented ..
    Sub Plot_Joint_Load_X(ByVal x1 As Double, ByVal y1 As Double, ByVal fx As Double, ByVal p_color As System.Drawing.Color)
        xa = x1 - load_scale * fx
        Plot_Edge(x1, y1, xa, y1, p_color)
        Draw_Arrow(x1, y1, fx, 0, p_color)
    End Sub '.. Plot_Joint_Load_X ..


    '  << Plot_Joint_Load_Y >>
    '     algorithm
    '     Modified RGH :-
    '     8/3/96 - implemented ..
    Sub Plot_Joint_Load_Y(ByVal x1 As Double, ByVal y1 As Double, ByVal fy As Double, ByVal p_color As System.Drawing.Color)
        yb = y1 - load_scale * fy
        Plot_Edge(x1, y1, x1, yb, p_color)
        Draw_Arrow(x1, y1, -fy, 1, p_color)
    End Sub '.. Plot_Joint_Load_Y ..




    '<< Get_Max_Load >>
    '   algorithm
    '   Modified RGH :-
    '   24/2/96 - implemented ..
    Sub Get_Max_Load()
        Dim i As Integer
        Dim max_W = 0

        For i = 0 To pfModel.GModel.structParam.nml - 1
            If max_W < Math.Abs(pfModel.GModel.mem_lod(i).ld_mag1) Then
                max_W = Math.Abs(pfModel.GModel.mem_lod(i).ld_mag1)
            End If
        Next i

        For i = 0 To pfModel.GModel.structParam.njl - 1
            With pfModel.GModel.jnt_lod(i)
                'begin
                If max_W < Math.Abs(.fx) Then max_W = Math.Abs(.fx)
                If max_W < Math.Abs(.fy) Then max_W = Math.Abs(.fy)
            End With
        Next i
        load_scale = ly_max * 0.2 / max_W
    End Sub '.. Get_Max_Load ..

    '<< Get_Load_Direction >>
    '   algorithm
    '   Modified RGH :-
    '   24/2/96 - implemented ..
    Sub Get_Load_Direction(ByVal w As Double, ByVal acode As Byte)

        Select Case acode
            Case local
                dx = w * sin_a * aspect_ratio
                dy = w * cos_a / aspect_ratio

            Case x_dir
                dx = w
                dy = 0

            Case y_dir
                dx = 0
                dy = w
        End Select
    End Sub '.. Get_Load_Direction ..

    '<< Plot_UDL >>
    '   algorithm
    '   Modified RGH :-
    '   8/3/96 - implemented ..
    Sub Plot_UDL()

        With pfModel.GModel.con_grp(mn)
            x1 = pfModel.GModel.nod_grp(.jj - 1).x
            y1 = pfModel.GModel.nod_grp(.jj - 1).y
            x2 = pfModel.GModel.nod_grp(.jk - 1).x
            y2 = pfModel.GModel.nod_grp(.jk - 1).y
        End With
        xa = x1 + dx
        ya = y1 - dy
        xb = x2 + dx
        yb = y2 - dy

        Plot_Edge(x1, y1, xa, ya, l_color)
        Plot_Edge(xa, ya, xb, yb, l_color)
        Plot_Edge(xb, yb, x2, y2, l_color)
    End Sub '.. Plot_UDL ..

    '<< Plot_PL >>
    '   algorithm
    '   Modified RGH :-
    '   8/3/96 - implemented ..
    Sub Plot_PL(ByVal aa As Double, ByVal pl As Double)
        Dim ddx As Double, ddy As Double
        Dim pl_st As String


        With pfModel.GModel.con_grp(mn)
            x1 = pfModel.GModel.nod_grp(.jj - 1).x
            y1 = pfModel.GModel.nod_grp(.jj - 1).y
        End With

        ddx = aa * cos_a
        ddy = aa * sin_a

        xa = x1 + ddx
        ya = y1 + ddy
        xb = xa + dx
        yb = ya - dy

        pl_st = Format(pl, "0.0")
        Plot_Node_Nos(pl_st, xb, yb, 2, Color.Black)

        Plot_Node_Nos("", xa, ya, 2, l_color)
        Plot_Edge(xa, ya, xb, yb, l_color)

        Draw_Arrow(xa, ya, 40, 0, l_color)
    End Sub '.. Plot_PL ..



    '<< Plot_Loads >>
    '   algorithm
    '   Modified RGH :-
    '   24/2/96 - implemented ..
    Sub Plot_Loads()
        Dim pl, udl As Double
        Dim i As Integer
        Dim x As Integer, y As Integer

        ' Plot_Loads ...
        Get_Max_Load()
        For i = 0 To pfModel.GModel.structParam.nml - 1
            With pfModel.GModel.mem_lod(i)
                'begin
                If .lcode = 1 Then
                    udl = load_scale * .ld_mag1
                    mn = .mem_no - 1
                    cos_a = pfModel.rot_mat(mn, 0)
                    sin_a = pfModel.rot_mat(mn, 1)
                    Get_Load_Direction(udl, .f_action)
                    Plot_UDL()
                End If

                If .lcode = 2 Then
                    pl = load_scale * .ld_mag1
                    mn = .mem_no - 1
                    cos_a = pfModel.rot_mat(mn, 0)
                    sin_a = pfModel.rot_mat(mn, 1)
                    Get_Load_Direction(pl, .f_action)
                    Plot_PL(.start, .ld_mag1)
                End If
            End With
        Next i

        For i = 0 To pfModel.GModel.structParam.njl - 1
            With pfModel.GModel.jnt_lod(i)
                x = pfModel.GModel.nod_grp(pfModel.GModel.jnt_lod(i).jt).x
                y = pfModel.GModel.nod_grp(pfModel.GModel.jnt_lod(i).jt).y
                If .fx <> 0 Then Plot_Joint_Load_X(x, y, .fx, Color.Black)
                If .fy <> 0 Then Plot_Joint_Load_Y(x, y, .fy, Color.Black)
            End With
        Next i

    End Sub '.. Plot_Loads

    ' << Get_Max_Delta >>
    '   algorithm
    '   Modified RGH :-
    '   24/2/96 - implemented ..
    Sub Get_Max_Delta()
        Dim i As Integer

        max_D = 0

        For i = 1 To pfModel.GModel.structParam.njt
            If max_D < Math.Abs(pfModel.dj(3 * i - 3)) Then max_D = Math.Abs(pfModel.dj(3 * i - 3))
            If max_D < Math.Abs(pfModel.dj(3 * i - 2)) Then max_D = Math.Abs(pfModel.dj(3 * i - 2))
        Next i
        load_scale = ly_max * 0.5 / max_D
    End Sub '.. Get_Max_Delta ..

    '<< Plot_Delta >>
    '   algorithm
    '   Modified RGH :-
    '   6/2/92 - implemented ..
    Sub Plot_Delta()
        Dim i As Integer

        Get_Max_Delta()
        For i = 0 To pfModel.GModel.structParam.nmb - 1
            With pfModel.GModel.con_grp(i)
                x1 = pfModel.GModel.nod_grp(.jj - 1).x
                y1 = pfModel.GModel.nod_grp(.jj - 1).y
                x2 = pfModel.GModel.nod_grp(.jk - 1).x
                y2 = pfModel.GModel.nod_grp(.jk - 1).y

                dx = load_scale * pfModel.dj(3 * .jj - 3)
                dy = load_scale * pfModel.dj(3 * .jj - 2)
                xa = x1 + dx
                ya = y1 + dy

                dx = load_scale * pfModel.dj(3 * .jk - 3)
                dy = load_scale * pfModel.dj(3 * .jk - 2)
                xb = x2 + dx
                yb = y2 + dy

                Plot_Edge(xa, ya, xb, yb, l_color)

            End With
        Next i
    End Sub '.. Plot_Delta ..

    '<< Plot_Supports >>
    '   algorithm
    '   Modified RGH :-
    '   6/2/92 - implemented ..
    Sub Plot_Supports()
        Dim dl As Double
        Dim i As Integer

        For i = 0 To pfModel.GModel.structParam.nrj - 1
            With pfModel.GModel.sup_grp(i)
                With pfModel.GModel.nod_grp(.js - 1)
                    dx = 20 / x_scale
                    dl = 0.25 * dx

                    load_scale = x_scale
                    '.. x-arrow ..
                    Plot_Edge(.x - dl, .y, .x - dx, .y, l_color)
                    Draw_Arrow(.x - dl, .y, dx / x_scale, 0, l_color)
                    '.. y-arrow ..
                    Plot_Edge(.x, .y - dl, .x, .y - dx, l_color)
                    Draw_Arrow(.x, .y - dl, -dx / x_scale, 1, l_color)
                End With
            End With
        Next i
    End Sub  '.. Plot_Supports ..


    '<< Plot_Moment >>
    '   algorithm
    '   Modified RGH :-
    '   8/3/96 - implemented ..
    Sub Plot_Moment(ByVal i As Byte)
        Dim j As Byte
        Dim station, segment, st_x, st_y As Double

        With pfModel.GModel.con_grp(i)
            'begin
            x1 = pfModel.GModel.nod_grp(.jj - 1).x
            y1 = pfModel.GModel.nod_grp(.jj - 1).y
            x2 = pfModel.GModel.nod_grp(.jk - 1).x
            y2 = pfModel.GModel.nod_grp(.jk - 1).y
            dx = -sin_a * load_scale * pfModel.mom_spn(i, 0)
            dy = -cos_a * load_scale * pfModel.mom_spn(i, 0)
            xa = x1 + dx
            ya = y1 - dy
            Plot_Edge(x1, y1, xa, ya, l_color)
            segment = pfModel.mlen(i) / n_segs
            For j = 0 To n_segs - 1
                'begin
                station = j * segment
                st_x = x1 + station * cos_a
                st_y = y1 + station * sin_a
                dx = -sin_a * load_scale * pfModel.mom_spn(i, j)
                dy = -cos_a * load_scale * pfModel.mom_spn(i, j)
                xb = st_x + dx
                yb = st_y - dy
                Plot_Edge(xa, ya, xb, yb, l_color)
                xa = xb
                ya = yb
            Next j
            Plot_Edge(xa, ya, x2, y2, l_color)
        End With
    End Sub '.. Plot_Moment ..



    '<< Get_Max_Force >>
    '   algorithm
    '   Modified RGH :-
    '   24/2/96 - implemented ..
    Sub Get_Max_Force()
        Dim i As Integer

        max_F = 0

        For i = 0 To pfModel.GModel.structParam.nmb - 1
            With pfModel.GModel.con_grp(i)
                Select Case plotcase
                    Case moments
                        F_jj = .jnt_jj.momnt
                        F_jk = .jnt_jk.momnt
                        l_color = Color.Aqua
                        
                    Case shears                    
                        F_jj = .jnt_jj.shear
                        F_jk = .jnt_jk.shear
                        l_color = Color.Fuchsia
                        

                    Case axial                       
                        F_jj = .jnt_jj.axial
                        F_jk = .jnt_jk.axial
                        l_color = Color.Olive
                    
                End Select

                If max_F < Math.Abs(F_jj) Then max_F = Math.Abs(F_jj)
                If max_F < Math.Abs(F_jk) Then max_F = Math.Abs(F_jk)
            End With
            min_F = Math.Abs(ly_max * 0.25)
            If max_F < min_F Then max_F = min_F
            load_scale = pfModel.GModel.structParam.mag * min_F / max_F

        Next i
    End Sub '.. Get_Max_Force ..



    '<< Plot_Force >>
    '   algorithm
    '   Modified RGH :-
    '   6/2/92 - implemented ..
    Sub Plot_Force()
        'Dim l_color As System.Drawing.Color
        Dim i As Integer

        'begin
        Get_Max_Force()
        For i = 0 To pfModel.GModel.structParam.nmb - 1
            With pfModel.GModel.con_grp(i)
                'begin
                cos_a = pfModel.rot_mat(i, 0)
                sin_a = pfModel.rot_mat(i, 1)
                Select Case plotcase
                    Case moments

                        F_jj = load_scale * .jnt_jj.momnt
                        F_jk = load_scale * .jnt_jk.momnt
                        l_color = Color.Teal

                    Case shears

                        F_jj = load_scale * .jnt_jj.shear
                        F_jk = load_scale * .jnt_jk.shear
                        l_color = Color.Purple


                    Case axial
                        F_jj = load_scale * .jnt_jj.axial
                        F_jk = load_scale * .jnt_jk.axial
                        l_color = Color.Navy

                End Select

                If plotcase = moments Then
                    Plot_Moment(i)
                Else
                    x1 = pfModel.GModel.nod_grp(.jj - 1).x
                    y1 = pfModel.GModel.nod_grp(.jj - 1).y
                    x2 = pfModel.GModel.nod_grp(.jk - 1).x
                    y2 = pfModel.GModel.nod_grp(.jk - 1).y

                    dx = F_jj * sin_a
                    dy = F_jj * cos_a
                    xa = x1 + dx
                    ya = y1 - dy

                    dx = F_jk * sin_a
                    dy = F_jk * cos_a
                    xb = x2 + dx
                    yb = y2 - dy

                    Plot_Edge(x1, y1, xa, ya, l_color)
                    Plot_Edge(xa, ya, xb, yb, l_color)
                    Plot_Edge(xb, yb, x2, y2, l_color)
                End If
            End With
        Next i
    End Sub '.. Plot_Force ..




    '<< Scale_Plot >>
    '   algorithm
    '   Modified RGH #/#/91 ..
    Sub Scale_Plot()
        Dim x_max, x_min, y_max, y_min As Double
        Dim i As Integer

        x_max = 0
        x_min = 1.0E+20
        y_max = 0
        y_min = 1.0E+20
        clrnc = 10

        aspect_ratio = n_xasp / n_yasp
        For i = 0 To pfModel.GModel.structParam.njt - 1
            With pfModel.GModel.nod_grp(i)

                If .x < x_min Then x_min = .x
                If .x > x_max Then x_max = .x
                If .y < y_min Then y_min = .y
                If .y > y_max Then y_max = .y
            End With
        Next i

        lx_max = x_max - x_min
        ly_max = y_max - y_min

        If lx_max <> 0 Then x_scale = scrw / lx_max

        If ly_max <> 0 Then
            y_scale = scrd / ly_max
        Else

            '.. modify for beams ..
            y_scale = x_scale
            ly_max = scrd / y_scale
        End If

        If x_scale < y_scale * aspect_ratio Then
            tmp_scale = x_scale
        Else
            tmp_scale = y_scale * aspect_ratio
        End If

        x_scale = 0.5 * tmp_scale
        y_scale = aspect_ratio * x_scale

        xoff = Int((scrw - Int(x_scale * lx_max)) / 2)
        yoff = Int((scrd - Int(y_scale * ly_max)) / 2)

        If y_min < 0 Then yoff = yoff - Int(y_scale * y_min)

    End Sub '.. Scale_Plot ..


    '<< Plot_Framework >>
    '   algorithm
    '   Modified RGH #/#/91 ..
    Sub Plot_Framework()
        Dim i, j As Byte
        Dim ist As String

        For i = 0 To pfModel.GModel.structParam.nmb - 1
            With pfModel.GModel.con_grp(i)

                Plot_Edge(pfModel.GModel.nod_grp(.jj - 1).x, pfModel.GModel.nod_grp(.jj - 1).y, _
                  pfModel.GModel.nod_grp(.jk - 1).x, _
                  pfModel.GModel.nod_grp(.jk - 1).y, Color.Red)
            End With
        Next i

        '.. plot the node annotation ..
        For i = 0 To pfModel.GModel.structParam.njt - 1
            With pfModel.GModel.nod_grp(i)
                ist = Format("%2d", .key)
                Plot_Node_Nos(ist, .x, .y, 0, Color.Black)
            End With
        Next i
    End Sub '.. Plot_Framework ..


    '<< Screen_Plot_Frame >>
    '   algorithm
    '   Modified RGH :-
    '   6/2/92 - implemented ..
    Sub Screen_Plot_Frame()

        Plot_Screen()
        Scale_Plot()
        Plot_Framework()
        Plot_Supports()
        Select Case plotcase
            Case loads
                If pfModel.GModel.structParam.nml + pfModel.GModel.structParam.njl + pfModel.GModel.structParam.ngl <> 0 Then Plot_Loads()
            Case moments
                Plot_Force()
            Case shears
                Plot_Force()
            Case axial
                Plot_Force()
            Case delta
                Plot_Delta()
        End Select

    End Sub ' ... Screen_Plot_Frame



    '   << Plot_To_Screen >>
    '      algorithm
    '      Modified RGH :-
    '      6/2/92 - implemented ..
    Sub Plot_To_Screen(ByVal lcase As Byte)
        ' Plot_To_Screen ..
        If isDataLoaded Then
            Screen_Plot_Frame()
        Else
            MsgBox("error")
        End If
    End Sub '.. Plot_To_Screen




    '    << Display_Graph >>
    '      algorithm
    '      Modified RGH :-
    '      8/3/96 - implemented ..
    Sub Display_Graph()

        l_color = Color.Black

        diagramImage = New TgraphViewer
        diagramImage.MdiParent = MDIParent1 'MainAppFrm

        diagramImage.Text = curvename(plotcase) + " as Plot"
        diagramImage.diagramType = plotcase
        diagramImage.Show()

        objbmp = New Bitmap(diagramImage.graphView.Width, diagramImage.graphView.Height)
        objGraph = Graphics.FromImage(objbmp)

        Plot_To_Screen(diagramImage.diagramType)


        diagramImage.graphView.Image = objbmp
        diagramImage.Show()
    End Sub '.. Display_Graph ..



End Class
