'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On
Imports System.Math

Public Class PlaneFrame

    '------------------------------------------------------------------------------
    'Plane Frame Analysis Program Modified to Class Object by:
    'S C Harrison (July 2010)
    'Modified to zero based array indexing
    'S C Harrison (2014)
    '###### Frame.PAS ######
    '    Written by:
    '    Roy Harrison & Associates
    ' Purpose:
    '
    '    The program analyses structural frameworks based upon the stiffness
    '    method and its application to computer programming.
    '    .. References:-
    '       1. Microcomputer Applications in Structural Engineering - W.H.Mosley
    '          & W.J.Spencer
    ' Revisions:
    '      17 Feb 91 - implemented ..
    '------------------------------------------------------------------------------


    '------------------------------------------------------------------------------
    'INTERFACE
    '------------------------------------------------------------------------------
    'File Parser: Limit State Machine
    Const MachineOFF As Integer = 0
    Const MachineTurnOFF As Integer = 0

    Const MachineON As Integer = 1
    Const MachineTurnON As Integer = 1
    Const MachineRunning As Integer = 1
    Const MachineScanning As Integer = 1

    Const RecognisedSection As Integer = 2
    Const DataBlockFound As Integer = 3

    Const startIndex As Integer = 1
    Const startZero As Integer = 0
    Const StartCounter As Integer = 1  'Counting starting at 1

    Const baseIndex As Integer = 0 'Counting starting at base index of array
    Const ndx0 As Integer = 0 'Index Zero

    Const ndx1 As Integer = 0
    Const ndx2 As Integer = 1

    Const df1 As Integer = 0  'degree of freedom 1
    Const df2 As Integer = 1
    Const df3 As Integer = 2
    Const df4 As Integer = 3
    Const df5 As Integer = 4
    Const df6 As Integer = 5

    Const dataBlockTag As String = "::"

    '.. enumeration constants ..
    '... Load Actions
    Const local_act As Byte = 0
    Const global_x As Byte = 1
    Const global_y As Byte = 2

    '... Load Types
    Const dst_ld As Byte = 1    '.. distributed loads udl, trap, triangular
    Const pnt_ld As Byte = 2    '.. point load
    Const axi_ld As Byte = 3    '.. axial load

    Const udl_ld As Byte = 4    '.. uniform load
    Const tri_ld As Byte = 5    '.. triangular load

    '... Constant declarations ...
    Const numloads As Integer = 80
    Const order As Integer = 50
    Const v_size As Integer = 50
    Const max_grps As Integer = 25
    Const max_mats As Integer = 10
    Const n_segs As Byte = 7 '10

    Const mega As Double = 1000000
    Const kilo As Double = 1000
    Const cent As Double = 100

    Const tolerance As Double = 0.0001
    Const infinity As Double = 2.0E+20
    Const neg_slope As Integer = 1
    Const pos_slope As Integer = -1
    
    
    'Structural Parameters
    'Public njt As Byte        '.. No. of joints ..
    'Public nmb As Byte        '.. No. of members ..
    'Public nmg As Byte        '.. No. of material groups ..
    'Public nsg As Byte        '.. No. of member section groups ..
    'Public nrj As Byte        '.. No. of supported reaction joints ..
    'Public njl As Byte        '.. No. of loaded joints ..
    'Public nml As Byte        '.. No. of loaded members ..
    'Public ngl As Byte        '.. No. of gravity load cases .. Self weight
    'Public nr As Byte        '.. No. of restraints @ the supports ..

    'Variable declarations

    'Dim mat_grp(max_mats) As material_rec
    'Dim sec_grp(max_grps) As section_rec
    'Dim nod_grp(max_grps) As coord_rec
    'Dim con_grp(max_grps) As connect_rec
    'Dim sup_grp(max_grps) As support_rec
    'Dim jnt_lod(numloads) As jnt_ld_rec
    'Dim mem_lod(numloads) As mem_ld_rec
    'Dim grv_lod As grv_ld_rec

    'Dim mat_grp(max_mats) As clsPfMaterial
    'Dim sec_grp(max_grps) As clsPfSection
    'Dim nod_grp(max_grps) As clsPfCoordinate
    'Dim con_grp(max_grps) As clsPfConnectivity
    'Dim sup_grp(max_grps) As clsPfSupport
    'Dim jnt_lod(numloads) As clsPfJointLoad
    'Dim mem_lod(numloads) As clsPfMemberLoad
    'Dim grv_lod As clsPfGravityLoad
    
    'Public jotterbk As Workbook
    'Public MiWrkBk As Workbook
    'Public wrkSht As Worksheet
    'Public TblRange As Range
    
    Public GModel As New clsGeomModel
    Public fpTracer As Integer

    Public data_loaded As Boolean

    Public sumx As Double
    Public sumy As Double

    Public poslope As Boolean

    '------------------------------------------------------------------------------
    'IMPLEMENTATION
    '------------------------------------------------------------------------------
    'Dim schTrace2 As New debugTracer
    'Dim startCell2 As Range

    'Dim schTrace3 As New debugTracer
    'Dim startCell3 As Range

    Dim jobData(5) As String

    Dim cosa As Double               '   .. member's direction cosines ..
    Dim sina As Double               '   .. member's direction cosines ..
    Dim c2 As Double                 '   .. Cos^2
    Dim s2 As Double                 '   .. Sin^2
    Dim cs As Double                 '   .. Cos x Sin
    Dim fi As Double                 '   .. fixed end moment @ end "i" of a member ..
    Dim fj As Double                 '   .. fixed end moment @ end "j" of a member ..
    Dim a_i As Double                '   .. fixed end axial force @ end "i" ..
    Dim a_j As Double                '   .. fixed end axial force @ end "j" ..
    Dim ri As Double                 '   .. fixed end shear @ end "i" ..
    Dim rj As Double                 '   .. fixed end shear @ end "j" ..
    Dim dii As Double                '   .. slope function @ end "i" ..
    Dim djj As Double                '   .. slope function @ end "j" ..
    Dim ao2 As Double
    Dim ldc As Integer               '   .. load type
    Dim x1 As Double                 '   .. start position ..
    Dim la As Double                 '   .. dist from end "i" to centroid of load ..
    Dim lb As Double                 '   .. dist from end "j" to centroid of load ..
    Dim udl As Double                '   .. uniform load
    Dim wm1 As Double                '   .. load magnitude 1
    Dim wm2 As Double                '   .. load magnitude 2
    Dim cvr As Double                '   .. length covered by load
    Dim w1 As Double
    Dim ra As Double                 '   .. reaction @ end A
    Dim rb As Double                 '   .. reaction @ end B
    Dim w_nrm As Double              '   .. total load normal to member ..
    Dim w_axi As Double              '   .. total load axial to member ..
    Dim wchk As Double               '   .. check reaction sum on span
    Dim nrm_comp As Double           '   .. load normal to member
    Dim axi_comp As Double           '   .. load axial to member
    Dim poa As Double                '   .. point of application ..
    Dim stn As Double
    Dim seg As Double

    '..  Analysis module
    '...Variable declarations...

    Dim hbw As Integer               '   .. upper band width of the joint stiffness matrix ..
    Dim nn As Integer               '   .. No. of degrees of freedom @ the joints ..
    Dim n3 As Integer                '   .. No. of joints x 3 ..
    Dim eaol As Double               '   .. elements of the member stiffness matrix ..
    Dim trl As Double                '   .. true length of a member ..
    Dim gam As Double                '   .. gamma =  cover/length

    Dim ci As Double
    Dim cj As Double
    Dim ccl As Double
    Dim ai As Double
    Dim aj As Double

    Dim global_i As Byte
    Dim global_j As Integer
    Dim global_k As Integer


    'Index Variables
    Dim j0 As Integer
    Dim j1 As Integer
    Dim j2 As Integer
    Dim j3 As Integer

    'Index Variables
    Dim k0 As Integer
    Dim k1 As Integer
    Dim k2 As Integer
    Dim k3 As Integer

    Dim diff As Integer
    Dim flag As Byte
    Dim sect As Byte
    Dim rel As Byte

    Dim maxM As Double, MinM As Double
    Dim MaxMJnt As Byte, maxMmemb As Byte, MinMJnt As Byte, MinMmemb As Byte
    Dim maxA As Double, MinA As Double
    Dim MaxAJnt As Byte, maxAmemb As Byte, MinAJnt As Byte, MinAmemb As Byte
    Dim maxQ As Double, MinQ As Double
    Dim MaxQJnt As Byte, maxQmemb As Byte, MinQJnt As Byte, MinQmemb As Byte

    '------------------
    'Array Variables
    '------------------

    'Vectors
    Dim mlen(v_size) As Double                       '.. member length ..
    Dim rjl(v_size) As Integer                       '.. restrained joint list ..
    Dim crl(v_size) As Integer                       '.. cumulative joint restraint list ..

    Dim fc(v_size) As Double                         '.. combined joint loads ..

    Dim dd(v_size) As Double                         '.. joint displacements @ free nodes ..
    Dim dj(v_size) As Double                         '.. joint displacements @ ALL the nodes ..
    Dim ad(v_size) As Double                         '.. member end forces not including fixed end forces ..
    Dim ar(v_size) As Double                         '.. support reactions ..

    'Matrices
    Dim rot_mat(v_size, ndx2) As Double              '.. member rotation  matrix ..
    Dim s(order, v_size) As Double                 '.. member stiffness matrix ..
    Dim sj(order, v_size) As Double                  '.. joint  stiffness matrix ..

    Dim af(order, v_size) As Double                 '.. member fixed end forces ..
    Dim mom_spn(max_grps, n_segs) As Double  '.. member span moments ..
    'Dim mom_spn(max_grps, ndx0 To n_segs) As Double

    '------------------------------------------------------------------------------
    'CLASS: PROPERTIES
    '------------------------------------------------------------------------------
    'Property Get SectionGroup(item As Integer) As section_rec
    '  SectionGroup = sec_grp(item)
    '    End Property

    'Property Get MemberProp(item As Integer) As connect_rec
    '  MemberProp = con_grp(item)
    '    End Property

    'Property Get SupportProp(item As Integer) As support_rec
    '  SupportProp = sup_grp(item)
    '    End Property



    '==============================================================================
    'CLASS: INTERNAL/EXTERNAL PROCEDURES
    '==============================================================================


    '------------------------------------------------------------------------------
    'BEGIN:: SOLVER
    '------------------------------------------------------------------------------

    '###### Pf_Solve.PAS ######
    ' ... a module of Bandsolver routines for the Framework Program-
    '     R G Harrison   --  Version 1.1  --  12/05/05  ...
    '     Revision history as-
    '        12/05/05 - implemented ..

    '<<< START CODE >>>>}
    '===========================================================================


    '<< Choleski_Decomposition >>
    '...  matrix decomposition by the Choleski method..
    'A=L.U
    'Matrix used is the reduced storage form of a banded matrix.
    '
    Private Sub Choleski_Decomposition(ByRef sj(,) As Double, Byval ndof As Integer, Byval hbw As Integer)
        Dim p As Integer, q As Integer
        Dim su As Double, te As Double

        Dim indx1 As Integer, indx2 As Integer, indx3 As Integer
        '   Call WrMat("Decompose IN sj ..", sj, ndof, hbw)
        '   Call PrintMat("Choleski_Decomposition  IN sj() ..", sj(), dd(), ndof, hbw)

        Dim r As Integer, c As Integer

        On Error GoTo ErrHandler_Choleski_Decomposition

        Console.WriteLine("Choleski_Decomposition ...")
        Console.WriteLine("ndof, hbw" + format(ndof,"0") + format( hbw,"0"))

        'Call schTrace2.wbkWriteCell(0, 0, "p")
        'Call schTrace2.wbkWriteCell(0, 1, "q")
        'Call schTrace2.wbkWriteCell(0, 2, "i")
        'Call schTrace2.wbkWriteCell(0, 3, "j")
        'Call schTrace2.wbkWriteCell(0, 4, "k")

        'Call schTrace2.wbkWriteCell(0, 17, "indx1")
        'Call schTrace2.wbkWriteCell(0, 18, "indx2")
        'Call schTrace2.wbkWriteCell(0, 19, "indx3")


        r = 1
        c = 0


        For global_i = baseIndex To ndof - 1 'From first to last index of array: rows of matrix
            Console.WriteLine("global_i=" + format( global_i,"0"))

            'Trace Change to Matrix
            '        Call schTrace2.wbkWriteln("SJ[]: " & Format(global_i, "#"))
            '        Call schTrace2.wbkWriteMatrix(sj)


            p = ndof - global_i - 1                            '+ 1 'convert index to compact form of banded matrix
            If p > hbw - 1 Then p = hbw - 1
            Console.WriteLine("p=" +format( p,"0"))

            'Call schTrace2.wbkWriteCell(r, 2, global_i)
            'Call schTrace2.wbkWriteCell(r, 0, p)

            For global_j = baseIndex To p

                q = (hbw - 2) - global_j        'convert index to compact form of banded matrix
                If q > global_i - 1 Then q = global_i - 1
                Console.WriteLine("q=" + format(q,"0"))

                'Call schTrace2.wbkWriteCell(r, 3, global_j)
                'Call schTrace2.wbkWriteCell(r, 1, q)


                su = sj(global_i, global_j)
                'Call schTrace2.wbkWriteCell(r, 10, sj(global_i, global_j))
                Console.WriteLine("su = " + Format(su, "0.0000"))

                If q >= 0 Then 'valid array index and not first element of array
                    '              console.writeLine( "Testing: Valid Array Index"
                    For global_k = baseIndex To q
                        'Call schTrace2.wbkWriteCell(r, 4, global_k)
                        If global_i > global_k Then
                            'Calculate sum
                            '                  su = su - sj(global_i - global_k, global_k + 1) * sj(global_i - global_k, global_k + global_j)
                            '                  Call schTrace2.wbkWriteCell(r, 5, su)
                            '                  Call schTrace2.wbkWriteCellColoured(r, 6, sj(global_i - global_k, global_k + 1), 4)
                            '                  Call schTrace2.wbkWriteCellColoured(r, 7, sj(global_i - global_k, global_k + global_j), 4)

                            indx1 = global_i - global_k - 1
                            indx2 = global_k + 1
                            indx3 = global_k + global_j + 1
                            su = su - sj(indx1, indx2) * sj(indx1, indx3)
                            'Call schTrace2.wbkWriteCell(r, 5, su)
                            'Call schTrace2.wbkWriteCellColoured(r, 6, sj(indx1, indx2), 4)
                            'Call schTrace2.wbkWriteCellColoured(r, 7, sj(indx1, indx3), 4)
                            'Call schTrace2.wbkWriteCell(r, 17, indx1)
                            'Call schTrace2.wbkWriteCell(r, 18, indx2)
                            'Call schTrace2.wbkWriteCell(r, 19, indx3)
                        End If
                        r = r + 1
                    Next global_k
                End If

                If global_j <> 0 Then 'Not First Element of array
                    sj(global_i, global_j) = su * te
                    '              sj(global_i, global_j) = 999 'testing
                    'Call schTrace2.wbkWriteCellColoured(r, 8, sj(global_i, global_j), 7)
                Else 'is first element
                    If su <= 0 Then
                        'MsgBox ("Choleski_Decomposition: matrix -ve TERM Terminated ???")
                        Console.WriteLine("Choleski_Decomposition: matrix -ve TERM Terminated ???")
                        Console.WriteLine("Cannot find square root of negative number")
                        Console.WriteLine("su = " + format( su,"0.0000"))
                        Console.WriteLine("global_i, global_j : " + format(global_i,"0") + " " + format(global_j,"0"))

                        Err.Clear()
                        Call Err.Raise(vbObjectError + 1001, , "Attempt to pass Negative Number to Square Root Function")


                    Else 'First Element
                        '                console.writeLine( "Testing Index: su>0"
                        te = 1 / Sqrt(su)

                        '                te = 1 'testing
                        sj(global_i, global_j) = te                        'Over write original matrix
                        Console.WriteLine("te = " + format( te,"0.0000"))
                        'Call schTrace2.wbkWriteCellColoured(r, 8, sj(global_i, global_j), 22)
                    End If ' Check postive value for su

                End If 'Processing array items

                r = r + 1
            Next global_j


            'Call schTrace.wbkWriteln("SJ[]: " & Format(global_i, "0"))
            'Call schTrace.wbkWriteMatrix(sj)

            r = r + 1
        Next global_i

        '  Call PrintMat("Choleski_Decomposition  OUT sj() ..", sj(), dd(), ndof, hbw)

        Console.WriteLine("... Choleski_Decomposition")

Exit_Choleski_Decomposition:
        Exit Sub

ErrHandler_Choleski_Decomposition:
        FileClose()
        Console.WriteLine("--------------------------------------------------------------")
        Console.WriteLine("ERRORS: ")
        Console.WriteLine("--------------------------------------------------------------")
        Console.WriteLine("... Choleski_Decomposition: Exit Errors!")
        Console.WriteLine(Err.Number - vbObjectError, Err.Description)
        Err.Clear()
        Console.WriteLine("--------------------------------------------------------------")
        '    Resume Exit_Choleski_Decomposition
        Stop

    End Sub  '.. Choleski_Decomposition ..


    '<< Solve_Displacements >>
    '.. perform forward and backward substitution to solve the system ..
    Private Sub Solve_Displacements()
        Dim su As Double
        Dim i As Integer, j As Integer
        Dim idx1 As Integer, idx2 As Integer

        'Call schTrace.wbkWriteln("Solve_Displacement:1 [" & Format(nn, "0") & "]")
        For i = baseIndex To nn - 1
            j = i + 1 - hbw
            If j < 0 Then j = 0
            su = fc(i)

            If j - i + 1 <= 0 Then
                For global_k = j To i - 1
                    If i - global_k + 1 > 0 Then

                        idx1 = i - global_k '+ 1
                        su = su - sj(global_k, idx1) * dd(global_k)

                        'Call schTrace.wbkWritelnCell(0, i)
                        'Call schTrace.wbkWritelnCell(1, j)
                        'Call schTrace.wbkWritelnCell(2, global_k)
                        'Call schTrace.wbkWritelnCell(3, idx1)
                        'Call schTrace.wbkWritelnCell(4, sj(global_k, idx1))
                        'Call schTrace.wbkWritelnCell(5, su)

                    End If
                Next global_k
            End If
            dd(i) = su * sj(i, 0)

            'Call schTrace.wbkWritelnCell(6, dd(i))
            'Call schTrace.wbkWritelnCell(7, sj(i, 0))
            'schTrace.IncTracerRow()
        Next i


        'schTrace.wbkWriteln("Solve_Displacement:1")
        For i = (nn - 1) To baseIndex Step -1
            j = i + hbw - 1
            If j > (nn - 1) Then j = nn - 1

            su = dd(i)
            If i + 1 <= j Then
                For global_k = i + 1 To j
                    If global_k + 1 > i Then

                        idx2 = global_k - i
                        su = su - sj(i, idx2) * dd(global_k)

                        'Call schTrace.wbkWritelnCell(0, i)
                        'Call schTrace.wbkWritelnCell(1, j)
                        'Call schTrace.wbkWritelnCell(2, global_k)
                        'Call schTrace.wbkWritelnCell(3, idx2)
                        'Call schTrace.wbkWritelnCell(4, sj(i, idx2))
                        'Call schTrace.wbkWritelnCell(5, su)

                    End If
                Next global_k
            End If

            dd(i) = su * sj(i, 0)

            'Call schTrace.wbkWritelnCell(6, dd(i))
            'Call schTrace.wbkWritelnCell(7, sj(i, 0))
            'schTrace.IncTracerRow()
        Next i


        '      Call WrFVector("Solve Displacements  dd..  ", dd(), nn)
    End Sub  '.. Solve_Displacements ..

    'End    ''.. CholeskiDecomp Module ..
    '===========================================================================


    '------------------------------------------------------------------------------
    'BEGIN:: ANALYSIS
    '------------------------------------------------------------------------------
    '###### Pf_Anal.PAS ######
    ' ... a module of Analysis Routines for the Framework Program -
    '     R G Harrison   --  Version 1.1  --  12/05/05  ...
    '     Revision history as-
    '        12/05/05 - implemented ..

    '<<< START CODE >>>>}
    '===========================================================================

    Function getArrayIndex(ByVal key) As Integer
        Select Case baseIndex

            Case 0
                getArrayIndex = (key - 1)

            Case 1
                getArrayIndex = key

        End Select
    End Function


    '<< Fill_Restrained_Joints_Vector >>
    'Contains all joints, with initial values of zero.
    'Restrained joints are then set to specified value.
    Private Sub Fill_Restrained_Joints_Vector()
        n3 = 3 * GModel.structParam.njt
        nn = n3 - GModel.structParam.nr

        For global_i = baseIndex To GModel.structParam.nrj - 1
            With GModel.sup_grp(global_i)
                j3 = (3 * .js) - 1
                rjl(j3 - 2) = .rx
                rjl(j3 - 1) = .ry
                rjl(j3) = .rm
                Console.WriteLine("rjl.. " + format( rjl(j3 - 2),"0.0000") + " " + format( rjl(j3 - 1),"0.0000") + " " +  format(rjl(j3),"0.0000"))
            End With
        Next global_i
        crl(baseIndex) = rjl(baseIndex)

        For global_i = baseIndex + 1 To n3 - 1
            crl(global_i) = crl(global_i - 1) + rjl(global_i)
            Console.WriteLine("crl.. " + format( crl(global_i),"0"))
        Next global_i

        Console.WriteLine("Fill_Restrained_Joints_Vector n3, nn, nr .. " + Format(n3, "0") + Format(nn, "0") + Format(GModel.structParam.nr, "0"))

    End Sub  '.. Fill_Restrained_Joints_Vector ..


    '<< Check_J >>
    Private Function End_J() As Boolean
        End_J = False
        global_j = j1
        If rjl(global_j) = 1 Then
            global_j = j2
            If rjl(global_j) = 1 Then
                global_j = j3
                If rjl(global_j) = 1 Then
                    diff = Translate_Ndx(k3) - Translate_Ndx(k1) + 1
                    End_J = True
                End If
            End If
        End If
    End Function  '.. End_J ..


    '<< End_K >>
    Private Function End_K() As Boolean
        End_K = False
        global_k = k3
        If rjl(global_k) = 1 Then
            global_k = k2
            If rjl(global_k) = 1 Then
                global_k = k1
                If rjl(global_k) = 1 Then
                    diff = Translate_Ndx(j3) - Translate_Ndx(j1) + 1
                    End_K = True
                End If
            End If
        End If
    End Function  '.. End_K ..


    '<< Calc_Bandwidth >>
    Private Sub Calc_Bandwidth()
        hbw = 0
        diff = 0
        For global_i = baseIndex To GModel.structParam.nmb - 1
            With GModel.con_grp(global_i)
                j3 = (3 * .jj) - 1
                j2 = j3 - 1
                j1 = j2 - 1

                k3 = (3 * .jk) - 1
                k2 = k3 - 1
                k1 = k2 - 1

                If Not End_J() Then
                    If Not End_K() Then
                        diff = Translate_Ndx(global_k) - Translate_Ndx(global_j) + 1
                    End If
                End If

                If diff > hbw Then
                    hbw = diff
                End If

            End With
        Next global_i

        Console.WriteLine("Calc_Bandwidth hbw, nn .. " + format( hbw,"0") + " " + format( nn,"0"))

    End Sub  '.. Calc_Bandwidth ..


    '<< Get_Stiff_Elements >>
    Private Sub Get_Stiff_Elements(ByVal i As Byte)
        Dim flag As Byte, msect As Byte, mnum As Byte
        Dim eiol As Double

        With GModel.con_grp(i)
            msect = getArrayIndex(.sect)
            mnum = getArrayIndex(GModel.sec_grp(msect).mat)
            flag = .rel_i + .rel_j
            eiol = GModel.mat_grp(mnum).emod * GModel.sec_grp(msect).iz / mlen(i)

            '        .. initialise temp variables ..
            ai = 0
            aj = ai
            ao2 = ai / 2

            Select Case flag
                Case 0
                    ai = 4 * eiol
                    aj = ai
                    ao2 = ai / 2
                Case 1
                    If (.rel_i = 0) Then
                        ai = 3 * eiol
                    Else
                        aj = 3 * eiol
                    End If

            End Select

            ci = (ai + ao2) / mlen(i)
            cj = (aj + ao2) / mlen(i)
            ccl = (ci + cj) / mlen(i)
            eaol = GModel.mat_grp(mnum).emod * GModel.sec_grp(msect).ax / mlen(i)
        End With

        cosa = rot_mat(i, ndx1)
        sina = rot_mat(i, ndx2)
    End Sub  '.. Get_Stiff_Elements ..

    '<< Assemble_Stiff_Mat >>
    Private Sub Assemble_Stiff_Mat(ByVal i As Byte)

        Console.WriteLine("Assemble_Stiff_Mat ...")

        Call Get_Stiff_Elements(i)

        Console.WriteLine("eaol: " + format(eaol,"0.0000"))
        Console.WriteLine("cosa: " + format(cosa,"0.0000"))
        Console.WriteLine("sina: " + format(sina,"0.0000"))
        Console.WriteLine("ccl: " + format(ccl,"0.0000"))
        Console.WriteLine("ci: " + format(ci,"0.0000"))
        Console.WriteLine("cj: " + format(cj,"0.0000"))
        Console.WriteLine("ai: " + format(ai,"0.0000"))
        Console.WriteLine("ao2: " + format(ao2,"0.0000"))
        Console.WriteLine("aj: " + format(aj,"0.0000"))

        s(df1, df1) = eaol * cosa
        s(df1, df2) = eaol * sina
        s(df1, df3) = 0
        s(df1, df4) = -s(df1, df1)
        s(df1, df5) = -s(df1, df2)
        s(df1, df6) = 0
        s(df2, df1) = -ccl * sina
        s(df2, df2) = ccl * cosa
        s(df2, df3) = ci
        s(df2, df4) = -s(df2, df1)
        s(df2, df5) = -s(df2, df2)
        s(df2, df6) = cj
        s(df3, df1) = -ci * sina
        s(df3, df2) = ci * cosa
        s(df3, df3) = ai
        s(df3, df4) = -s(df3, df1)
        s(df3, df5) = -s(df3, df2)
        s(df3, df6) = ao2
        s(df4, df1) = s(df1, df4)
        s(df4, df2) = s(df1, df5)
        s(df4, df3) = 0
        s(df4, df4) = s(df1, df1)
        s(df4, df5) = s(df1, df2)
        s(df4, df6) = 0
        s(df5, df1) = s(df2, df4)
        s(df5, df2) = s(df2, df5)
        s(df5, df3) = -ci
        s(df5, df4) = s(df2, df1)
        s(df5, df5) = s(df2, df2)
        s(df5, df6) = -cj
        s(df6, df1) = -cj * sina
        s(df6, df2) = cj * cosa
        s(df6, df3) = ao2
        s(df6, df4) = -s(df6, df1)
        s(df6, df5) = -s(df6, df2)
        s(df6, df6) = aj

        '  '  Call PrintMat("Assemble_Stiff_Mat   s () ..", s, dd(), 6, 6)

        Console.WriteLine("... Assemble_Stiff_Mat")

    End Sub  '.. Assemble_Stiff_Mat ..

    '<< Assemble_Global_Stiff_Matrix >>
    Private Sub Assemble_Global_Stiff_Matrix(ByVal i As Byte)

        Console.WriteLine("Assemble_Global_Stiff_Matrix ...")

        Call Get_Stiff_Elements(i)

        c2 = cosa * cosa
        s2 = sina * sina
        cs = cosa * sina

        '  console.writeLine( "eaol :", eaol)
        '  console.writeLine( "cosa :", cosa)
        '  console.writeLine( "sina :", sina)
        '
        '  console.writeLine( "c2 :", c2)
        '  console.writeLine( "s2 :", s2)
        '  console.writeLine( "cs :", cs)
        '  console.writeLine( "ccl :", ccl)
        '  console.writeLine( "ci :", ci)
        '  console.writeLine( "cj :", cj)
        '  console.writeLine( "ai :", ai)
        '  console.writeLine( "ao2 :", ao2)
        '  console.writeLine( "aj :", aj)
        '  console.writeLine( "-----------------------")

        s(df1, df1) = eaol * c2 + ccl * s2
        s(df1, df2) = eaol * cs - ccl * cs
        s(df1, df3) = -ci * sina
        s(df1, df4) = -s(df1, df1)
        s(df1, df5) = -s(df1, df2)
        s(df1, df6) = -cj * sina
        s(df2, df2) = eaol * s2 + ccl * c2
        s(df2, df3) = ci * cosa
        s(df2, df4) = s(df1, df5)
        s(df2, df5) = -s(df2, df2)
        s(df2, df6) = cj * cosa
        s(df3, df3) = ai
        s(df3, df4) = -s(df1, df3)
        s(df3, df5) = -s(df2, df3)
        s(df3, df6) = ao2
        s(df4, df4) = -s(df1, df4)
        s(df4, df5) = -s(df1, df5)
        s(df4, df6) = -s(df1, df6)
        s(df5, df5) = s(df2, df2)
        s(df5, df6) = -s(df2, df6)
        s(df6, df6) = aj

        Console.WriteLine("... Assemble_Global_Stiff_Matrix")

    End Sub  '.. Assemble_Global_Stiff_Matrix ..

    '<< Load_Sj >>
    Private Sub Load_Sj(ByVal j As Byte, ByVal kk As Byte, ByVal stiffval As Double)
        Console.WriteLine("Load_Sj: " + format( j,"0") + " " + format(kk,"0") + " " + format( stiffval,"0.0000"))
        'Call schTrace3.wbkWriteln("Load_Sj")
        global_k = Translate_Ndx(kk) - j '+ 1
        'Call schTrace3.wbkWritelnCell(11, global_k)

        'Call schTrace3.wbkWritelnCell(13, sj(j, global_k))

        sj(j, global_k) = sj(j, global_k) + stiffval

        'Call schTrace3.wbkWritelnCell(14, sj(j, global_k))
        'Call schTrace3.wbkWritelnCell(15, stiffval)

        'Call schTrace3.wbkWritelnCell(18, j)
        'Call schTrace3.wbkWritelnCell(19, global_k)

    End Sub  '.. Load_Sj ..

    '<< Process_DOF_J1 >>
    Private Sub Process_DOF_J1()
        Console.WriteLine("Process_DOF_J1 ...")
        'Call schTrace3.wbkWriteln("Process_DOF_J1")
        global_j = Translate_Ndx(j1)
        'Call schTrace3.wbkWritelnCell(10, global_j)

        'Call schTrace3.wbkWritelnCell(13, sj(global_j, df1))
        sj(global_j, df1) = sj(global_j, df1) + s(df1, df1)
        'Call schTrace3.wbkWritelnCell(14, sj(global_j, df1))
        'Call schTrace3.wbkWritelnCell(15, s(df1, df1))

        'Call schTrace3.wbkWritelnCell(18, global_j)
        'Call schTrace3.wbkWritelnCell(19, df1)
        'schTrace3.IncTracerRow()

        If rjl(j2) = 0 Then
            'schTrace3.IncTracerRow()
            'Call schTrace3.wbkWritelnCell(13, sj(global_j, df2))
            sj(global_j, df2) = sj(global_j, df2) + s(df1, df2)
            'Call schTrace3.wbkWritelnCell(14, sj(global_j, df2))
            'Call schTrace3.wbkWritelnCell(15, s(df1, df2))
        End If

        If rjl(j3) = 0 Then
            Call Load_Sj(global_j, j3, s(df1, df3))
        End If

        If rjl(k1) = 0 Then
            Call Load_Sj(global_j, k1, s(df1, df4))
        End If

        If rjl(k2) = 0 Then
            Call Load_Sj(global_j, k2, s(df1, df5))
        End If

        If rjl(k3) = 0 Then
            Call Load_Sj(global_j, k3, s(df1, df6))
        End If

    End Sub  '.. Process_DOF_J1 ..

    '<< Process_DOF_J2 >>
    Private Sub Process_DOF_J2()
        Console.WriteLine("Process_DOF_J2 ...")
        'Call schTrace3.wbkWriteln("Process_DOF_J2")
        global_j = Translate_Ndx(j2)
        'Call schTrace3.wbkWritelnCell(10, global_j)

        'Call schTrace3.wbkWritelnCell(13, sj(global_j, df1))
        sj(global_j, df1) = sj(global_j, df1) + s(df2, df2)
        'Call schTrace3.wbkWritelnCell(14, sj(global_j, df1))
        'Call schTrace3.wbkWritelnCell(15, s(df2, df2))

        'Call schTrace3.wbkWritelnCell(18, global_j)
        'Call schTrace3.wbkWritelnCell(19, df1)
        'schTrace3.IncTracerRow()

        If rjl(j3) = 0 Then
            'schTrace3.IncTracerRow()
            'Call schTrace3.wbkWritelnCell(13, sj(global_j, df2))
            sj(global_j, df2) = sj(global_j, df2) + s(df2, df3)
            'Call schTrace3.wbkWritelnCell(14, sj(global_j, df2))
            'Call schTrace3.wbkWritelnCell(15, s(df2, df3))
        End If

        If rjl(k1) = 0 Then
            Call Load_Sj(global_j, k1, s(df2, df4))
        End If

        If rjl(k2) = 0 Then
            Call Load_Sj(global_j, k2, s(df2, df5))
        End If

        If rjl(k3) = 0 Then
            Call Load_Sj(global_j, k3, s(df2, df6))
        End If

    End Sub  '.. Process_DOF_J2 ..

    '<< Process_DOF_J3 >>
    Private Sub Process_DOF_J3()
        Console.WriteLine("Process_DOF_J3 ...")
        'Call schTrace3.wbkWriteln("Process_DOF_J3")
        global_j = Translate_Ndx(j3)
        'Call schTrace3.wbkWritelnCell(10, global_j)

        'Call schTrace3.wbkWritelnCell(13, sj(global_j, df1))
        sj(global_j, df1) = sj(global_j, df1) + s(df3, df3)
        'Call schTrace3.wbkWritelnCell(14, sj(global_j, df1))
        'Call schTrace3.wbkWritelnCell(15, s(df3, df3))

        'Call schTrace3.wbkWritelnCell(18, global_j)
        'Call schTrace3.wbkWritelnCell(19, df1)
        'schTrace3.IncTracerRow()

        If rjl(k1) = 0 Then
            Call Load_Sj(global_j, k1, s(df3, df4))
        End If

        If rjl(k2) = 0 Then
            Call Load_Sj(global_j, k2, s(df3, df5))
        End If

        If rjl(k3) = 0 Then
            Call Load_Sj(global_j, k3, s(df3, df6))
        End If

    End Sub  '.. Process_DOF_J3 ..

    '<< Process_DOF_K1 >>
    Private Sub Process_DOF_K1()
        Console.WriteLine("Process_DOF_K1 ...")
        'Call schTrace3.wbkWriteln("Process_DOF_K1")
        global_j = Translate_Ndx(k1)
        'Call schTrace3.wbkWritelnCell(10, global_j)

        'Call schTrace3.wbkWritelnCell(13, sj(global_j, df1))
        sj(global_j, df1) = sj(global_j, df1) + s(df4, df4)
        'Call schTrace3.wbkWritelnCell(14, sj(global_j, df1))
        'Call schTrace3.wbkWritelnCell(15, s(df4, df4))

        'Call schTrace3.wbkWritelnCell(18, global_j)
        'Call schTrace3.wbkWritelnCell(19, df1)
        'schTrace3.IncTracerRow()

        If rjl(k2) = 0 Then
            'schTrace3.IncTracerRow()
            'Call schTrace3.wbkWritelnCell(13, sj(global_j, df2))
            sj(global_j, df2) = sj(global_j, df2) + s(df4, df5)
            'Call schTrace3.wbkWritelnCell(14, sj(global_j, df2))
            'Call schTrace3.wbkWritelnCell(15, s(df4, df5))
        End If

        If rjl(k3) = 0 Then
            Call Load_Sj(global_j, k3, s(df4, df6))
        End If

    End Sub  '.. Process_DOF_K1 ..

    '<< Process_DOF_K2 >>
    Private Sub Process_DOF_K2()
        Console.WriteLine("Process_DOF_K2 ...")
        'Call schTrace3.wbkWriteln("Process_DOF_K2")
        global_j = Translate_Ndx(k2)
        'Call schTrace3.wbkWritelnCell(10, global_j)

        'Call schTrace3.wbkWritelnCell(13, sj(global_j, df1))
        sj(global_j, df1) = sj(global_j, df1) + s(df5, df5)
        'Call schTrace3.wbkWritelnCell(14, sj(global_j, df1))
        'Call schTrace3.wbkWritelnCell(15, s(df5, df5))

        'Call schTrace3.wbkWritelnCell(18, global_j)
        'Call schTrace3.wbkWritelnCell(19, df1)
        'schTrace3.IncTracerRow()

        If rjl(k3) = 0 Then
            'schTrace3.IncTracerRow()
            'Call schTrace3.wbkWritelnCell(13, sj(global_j, df2))
            sj(global_j, df2) = sj(global_j, df2) + s(df5, df6)
            'Call schTrace3.wbkWritelnCell(14, sj(global_j, df2))
            'Call schTrace3.wbkWritelnCell(15, s(df5, df6))
        End If

    End Sub  '.. Process_DOF_K2 ..

    '<< Process_DOF_K3 >>
    Private Sub Process_DOF_K3()
        Console.WriteLine("Process_DOF_K3 ...")
        'Call schTrace3.wbkWriteln("Process_DOF_K3")
        global_j = Translate_Ndx(k3)
        'Call schTrace3.wbkWritelnCell(10, global_j)

        'Call schTrace3.wbkWritelnCell(13, sj(global_j, df1))

        sj(global_j, df1) = sj(global_j, df1) + s(df6, df6)

        'Call schTrace3.wbkWritelnCell(14, sj(global_j, df1))
        'Call schTrace3.wbkWritelnCell(15, s(df6, df6))

        'Call schTrace3.wbkWritelnCell(18, global_j)
        'Call schTrace3.wbkWritelnCell(19, df1)

    End Sub  '.. Process_DOF_K3 ..

    '<< Assemble_Struct_Stiff_Matrix >>
    Private Sub Assemble_Struct_Stiff_Matrix(ByVal i As Byte)
        '        .. initialise temp variables ..

        Console.WriteLine("Assemble_Struct_Stiff_Matrix ..." + format(i,"0"))
        'Get indexes into the restrained joints list

        'Index for Node on near End of Member
        j3 = (3 * GModel.con_grp(i).jj) - 1
        j2 = j3 - 1
        j1 = j2 - 1

        'Index for Node on far End of Member
        k3 = (3 * GModel.con_grp(i).jk) - 1
        k2 = k3 - 1
        k1 = k2 - 1

        'Console.WriteLine(j3, j2, j1, k3, k2, k1)

        'Call schTrace3.wbkWritelnCell(1, con_grp(i).jj)
        'Call schTrace3.wbkWritelnCell(2, con_grp(i).jk)
        'Call schTrace3.wbkWritelnCell(3, j1)
        'Call schTrace3.wbkWritelnCell(4, j2)
        'Call schTrace3.wbkWritelnCell(5, j3)
        'Call schTrace3.wbkWritelnCell(6, k1)
        'Call schTrace3.wbkWritelnCell(7, k2)
        'Call schTrace3.wbkWritelnCell(8, k3)
        'schTrace3.IncTracerRow()

        If rjl(j3) = 0 Then Call Process_DOF_J3() '.. do j3 ..
        If rjl(j2) = 0 Then Call Process_DOF_J2() '.. do j2 ..
        If rjl(j1) = 0 Then Call Process_DOF_J1() '.. do j1 ..

        If rjl(k3) = 0 Then Call Process_DOF_K3() '.. do k3 ..
        If rjl(k2) = 0 Then Call Process_DOF_K2() '.. do k2 ..
        If rjl(k1) = 0 Then Call Process_DOF_K1() '.. do k1 ..

        Console.WriteLine("... Assemble_Struct_Stiff_Matrix")

    End Sub  '.. Assemble_Struct_Stiff_Matrix ..


    '------------------------------------------------------------------------------
    'BEGIN:: ACTION-EFFECTS
    '------------------------------------------------------------------------------

    '<< Calc_Member_Forces >>
    Private Sub Calc_Member_Forces()

        'Call schTrace.wbkWriteln("Calc_Member_Forces ..." & Format(nmb, "0"))



        For global_i = baseIndex To GModel.structParam.nmb - 1
            With GModel.con_grp(global_i)

                Call Assemble_Stiff_Mat(global_i)

                '        .. initialise temporary end restraint indices ..
                j3 = 3 * .jj - 1
                j2 = j3 - 1
                j1 = j2 - 1

                k3 = 3 * .jk - 1
                k2 = k3 - 1
                k1 = k2 - 1

                'Call schTrace.wbkWritelnCell(0, global_i)

                'Call schTrace.wbkWritelnCellColoured(1, .jj, 4)
                'Call schTrace.wbkWritelnCell(2, j3)
                'Call schTrace.wbkWritelnCell(3, j2)
                'Call schTrace.wbkWritelnCell(4, j1)

                'Call schTrace.wbkWritelnCellColoured(5, .jk, 4)
                'Call schTrace.wbkWritelnCell(6, k3)
                'Call schTrace.wbkWritelnCell(7, k2)
                'Call schTrace.wbkWritelnCell(8, k1)


                For global_j = baseIndex To df6
                    ad(global_j) = s(global_j, df1) * dj(j1) + s(global_j, df2) * dj(j2) + s(global_j, df3) * dj(j3)
                    ad(global_j) = ad(global_j) + s(global_j, df4) * dj(k1) + s(global_j, df5) * dj(k2) + s(global_j, df6) * dj(k3)
                Next global_j

                '.. Store End forces ..
                .jnt_jj.axial = -(af(global_i, df1) + ad(df1))
                .jnt_jj.shear = -(af(global_i, df2) + ad(df2))
                .jnt_jj.momnt = -(af(global_i, df3) + ad(df3))

                .jnt_jk.axial = af(global_i, df4) + ad(df4)
                .jnt_jk.shear = af(global_i, df5) + ad(df5)
                .jnt_jk.momnt = af(global_i, df6) + ad(df6)

                'Call schTrace.wbkWritelnCell(9, .jnt_jj.axial)
                'Call schTrace.wbkWritelnCell(10, .jnt_jj.shear)
                'Call schTrace.wbkWritelnCell(11, .jnt_jj.momnt)
                'Call schTrace.wbkWritelnCell(12, .jnt_jk.axial)
                'Call schTrace.wbkWritelnCell(13, .jnt_jk.shear)
                'Call schTrace.wbkWritelnCell(14, .jnt_jk.momnt)

                '.. Member Joint j End forces
                If rjl(j1) <> 0 Then ar(j1) = ar(j1) + ad(df1) * cosa - ad(df2) * sina '.. Fx
                If rjl(j2) <> 0 Then ar(j2) = ar(j2) + ad(df1) * sina + ad(df2) * cosa '.. Fy
                If rjl(j3) <> 0 Then ar(j3) = ar(j3) + ad(df3) '.. Mz

                '.. Member Joint k End forces
                If rjl(k1) <> 0 Then ar(k1) = ar(k1) + ad(df4) * cosa - ad(df5) * sina '.. Fx
                If rjl(k2) <> 0 Then ar(k2) = ar(k2) + ad(df4) * sina + ad(df5) * cosa '.. Fy
                If rjl(k3) <> 0 Then ar(k3) = ar(k3) + ad(df6) '.. Mz

            End With

            'schTrace.IncTracerRow()
        Next global_i

    End Sub  '.. Calc_Member_Forces ..

    '<< Calc_Joint_Displacements >>
    Private Sub Calc_Joint_Displacements()
        For global_i = baseIndex To n3 - 1
            If rjl(global_i) = 0 Then dj(global_i) = dd(Translate_Ndx(global_i))
        Next global_i
    End Sub '.. Calc_Joint_Displacements ..

    '<< Get_Span_Moments >>
    Private Sub Get_Span_Moments()
        Dim seg, stn As Double
        Dim rx As Double
        Dim mx As Double
        Dim i, j As Byte

        '.. Get_Span_Moments ..
        For i = baseIndex To GModel.structParam.nmb - 1
            seg = mlen(i) / n_segs
            If poslope Then
                rx = GModel.con_grp(i).jnt_jj.shear
                mx = GModel.con_grp(i).jnt_jj.momnt
            Else
                rx = GModel.con_grp(i).jnt_jk.shear
                mx = GModel.con_grp(i).jnt_jk.momnt
            End If

            With GModel.con_grp(i)
                For j = startZero To n_segs
                    stn = j * seg
                    '          With mem_lod(i)
                    ''            If (.lcode = 2) _
                    ''              And (stn >= .start) _
                    ''              And (stn - .start < seg) Then
                    ''                stn = .start
                    ''            End If
                    If poslope Then
                        mom_spn(i, j) = mom_spn(i, j) + rx * stn - mx
                    Else
                        mom_spn(i, j) = mom_spn(i, j) + rx * (stn - mlen(i)) - mx
                    End If

                    '          End With
                Next j
            End With

        Next i
    End Sub  '.. Get_Span_Moments ..


    '===========================================================================
    '###### Pf_Load.PAS ######
    ' ... a unit file of load analysis routines for the Framework Program-
    '     R G Harrison   --  Version 5.2  --  30/ 3/96  ...
    '     Revision history as-
    '        29/7/90 - implemented ..
    '===========================================================================

    '<<< In_Cover >>>
    Private Function In_Cover(ByVal x1 As Double, ByVal x2 As Double, ByVal mlen As Double) As Boolean
        '    Call schTrace.wbkWriteln("In_Cover ...")

        If (x2 = mlen) Or (x2 > mlen) Then
            In_Cover = True
        Else
            In_Cover = ((stn >= x1) And (stn <= x2))
        End If
    End Function '...In_Cover...


    '<< Calc_Moments >>
    '.. RGH   12/4/92
    '.. calc moments ..
    Private Sub Calc_Moments(ByVal mn As Byte, ByVal mlen As Double, ByVal wtot As Double, _
                        ByVal x1 As Double, ByVal la As Double, ByVal cv As Double, ByVal wty As Byte, _
                        ByVal lslope As Integer)
        Dim x As Double
        Dim x2 As Double
        Dim Lx As Double
        Dim idx1 As Integer

        On Error GoTo ErrHandler_Calc_Moments

        'Call schTrace.wbkWritelnCell(0, "Calc_Moments ...")
        'Call schTrace.wbkWritelnCell(2, mn)
        'schTrace.IncTracerRow()

        idx1 = mn - 1

        x2 = x1 + cv

        seg = mlen / n_segs

        If cv <> 0 Then w1 = wtot / cv

        For global_j = startZero To n_segs
            stn = global_j * seg

            If poslope Then
                x = stn - x1                      '.. dist to sect from stn X-X..
                Lx = stn - la
            Else
                x = x2 - stn
                Lx = la - stn
            End If

            If In_Cover(x1, x2, mlen) Then
                Select Case wty                 '.. calc moments if inside load cover..
                    Case udl_ld                   '   Uniform Load
                        mom_spn(idx1, global_j) = mom_spn(idx1, global_j) - w1 * x ^ 2 / 2

                    Case tri_ld                   '   Triangular Loads
                        mom_spn(idx1, global_j) = mom_spn(idx1, global_j) - (w1 * x ^ 2 / cv) * x / 3
                End Select
            Else
                If x <= 0 Then
                    Lx = 0
                End If

                mom_spn(idx1, global_j) = mom_spn(idx1, global_j) - wtot * Lx

            End If

        Next global_j

Exit_Calc_Moments:
        Exit Sub

ErrHandler_Calc_Moments:
        FileClose()
        Console.WriteLine("... Calc_Moments: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Calc_Moments
        Stop

    End Sub     '.. Calc_Moments ..


    '<< Combine_Joint_Loads >>
    Private Sub Combine_Joint_Loads(ByVal kMember As Byte)
        Dim k As Integer

        On Error GoTo ErrHandler_Combine_Joint_Loads

        'Call schTrace.wbkWritelnCell(0, "Combine_Joint_Loads ...")
        'Call schTrace.wbkWritelnCell(2, kMember)
        'schTrace.IncTracerRow()

        k = kMember - 1

        Console.WriteLine("STEP:1")
        cosa = rot_mat(k, ndx1)
        sina = rot_mat(k, ndx2)

        'Call schTrace.wbkWritelnCell(0, "cosa")
        'Call schTrace.wbkWritelnCell(1, cosa)
        'schTrace.IncTracerRow()
        'Call schTrace.wbkWritelnCell(0, "sina")
        'Call schTrace.wbkWritelnCell(1, sina)
        'schTrace.IncTracerRow()



        '   ... Process end A
        Get_Joint_Indices(GModel.con_grp(k).jj)

        'Call schTrace.wbkWritelnCell(0, "fc[]")
        'Call schTrace.wbkWritelnCell(1, fc(j1))
        'Call schTrace.wbkWritelnCell(2, fc(j2))
        'Call schTrace.wbkWritelnCell(3, fc(j3))
        'schTrace.IncTracerRow()

        fc(j1) = fc(j1) - a_i * cosa + ri * sina    '.. Fx
        fc(j2) = fc(j2) - a_i * sina - ri * cosa    '.. Fy
        fc(j3) = fc(j3) - fi                        '.. Mz

        'Call schTrace.wbkWritelnCell(0, "fc[]")
        'Call schTrace.wbkWritelnCell(1, fc(j1))
        'Call schTrace.wbkWritelnCell(2, fc(j2))
        'Call schTrace.wbkWritelnCell(3, fc(j3))
        'schTrace.IncTracerRow()

        '   ... Process end B
        Get_Joint_Indices(GModel.con_grp(k).jk)
        'Call schTrace.wbkWritelnCell(0, "fc[]")
        'Call schTrace.wbkWritelnCell(1, fc(j1))
        'Call schTrace.wbkWritelnCell(2, fc(j2))
        'Call schTrace.wbkWritelnCell(3, fc(j3))
        'schTrace.IncTracerRow()

        fc(j1) = fc(j1) - a_j * cosa + rj * sina    '.. Fx
        fc(j2) = fc(j2) - a_j * sina - rj * cosa    '.. Fy
        fc(j3) = fc(j3) - fj                        '.. Mz

        'Call schTrace.wbkWritelnCell(0, "fc[]")
        'Call schTrace.wbkWritelnCell(1, fc(j1))
        'Call schTrace.wbkWritelnCell(2, fc(j2))
        'Call schTrace.wbkWritelnCell(3, fc(j3))
        'schTrace.IncTracerRow()

Exit_Combine_Joint_Loads:
        Exit Sub

ErrHandler_Combine_Joint_Loads:
        FileClose()
        Console.WriteLine("... Combine_Joint_Loads: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Combine_Joint_Loads
        Stop

    End Sub  '.. Combine_Joint_Loads ..

    '  << Calc_FE_Forces >>
    Private Sub Calc_FE_Forces(ByVal kMember As Byte, ByVal la As Double, ByVal lb As Double)
        Dim k As Byte

        On Error GoTo ErrHandler_Calc_FE_Forces

        k = kMember - 1

        'Call schTrace.wbkWritelnCell(0, "Calc_FE_Forces ...")
        'Call schTrace.wbkWritelnCell(2, kMember)
        'schTrace.IncTracerRow()
        'Call schTrace.wbkWritelnCell(0, "trl:")
        'Call schTrace.wbkWritelnCell(2, trl)
        'schTrace.IncTracerRow()
        'Call schTrace.wbkWritelnCell(0, "djj:")
        'Call schTrace.wbkWritelnCell(2, djj)
        'schTrace.IncTracerRow()
        'Call schTrace.wbkWritelnCell(0, "dii:")
        'Call schTrace.wbkWritelnCell(2, dii)
        'schTrace.IncTracerRow()

        '.. both ends fixed
        fi = (2 * djj - 4 * dii) / trl
        fj = (4 * djj - 2 * dii) / trl
        With GModel.con_grp(k)
            'Call schTrace.wbkWritelnCell(0, "jj and jk: ")
            'Call schTrace.wbkWritelnCell(2, con_grp(k).jj)
            'Call schTrace.wbkWritelnCell(3, con_grp(k).jk)
            'schTrace.IncTracerRow()

            flag = .rel_i + .rel_j
            'Call schTrace.wbkWritelnCell(0, "Flag:")
            'Call schTrace.wbkWritelnCell(1, flag)
            'schTrace.IncTracerRow()

            If flag = 2 Then              '.. both ends pinned
                fi = 0
                fj = 0
            End If

            If flag = 1 Then              '.. propped cantilever
                If (.rel_i = 0) Then        '.. end i pinned
                    fi = fi - fj / 2
                    fj = 0
                Else                        '.. end j pinned
                    fi = 0
                    fj = fj - fi / 2
                End If
            End If
        End With

        ri = (fi + fj - w_nrm * lb) / trl
        rj = (-fi - fj - w_nrm * la) / trl

        wchk = ri + rj

        a_i = 0
        a_j = 0

Exit_Calc_FE_Forces:
        Exit Sub

ErrHandler_Calc_FE_Forces:
        FileClose()
        Console.WriteLine("... Calc_FE_Forces: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Calc_FE_Forces
        Stop

    End Sub  '.. Calc_FE_Forces ..


    '<< Accumulate_FE_Actions >>
    Private Sub Accumulate_FE_Actions(ByVal kMemberNum As Byte)
        Dim k As Integer

        On Error GoTo ErrHandler_Accumulate_FE_Actions

        'Call schTrace.wbkWritelnCell(0, "Accumulate_FE_Actions ...")
        'Call schTrace.wbkWritelnCell(2, kMemberNum)
        'schTrace.IncTracerRow()

        k = kMemberNum - 1

        af(k, df1) = af(k, df1) + a_i
        af(k, df2) = af(k, df2) + ri
        af(k, df3) = af(k, df3) + fi
        af(k, df4) = af(k, df4) + a_j
        af(k, df5) = af(k, df5) + rj
        af(k, df6) = af(k, df6) + fj

Exit_Accumulate_FE_Actions:
        Exit Sub

ErrHandler_Accumulate_FE_Actions:
        FileClose()
        Console.WriteLine("... Accumulate_FE_Actions: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Accumulate_FE_Actions
        Stop

    End Sub  '.. Accumulate_FE_Actions ..


    '<< Process_FE_Actions >>
    Private Sub Process_FE_Actions(ByVal kMemberNum As Byte, ByVal la As Double, ByVal lb As Double)

        On Error GoTo ErrHandler_Process_FE_Actions

        'Call schTrace.wbkWritelnCell(0, "Process_FE_Actions ...")
        'Call schTrace.wbkWritelnCell(2, kMemberNum)
        'schTrace.IncTracerRow()

        Call Accumulate_FE_Actions(kMemberNum)
        Call Combine_Joint_Loads(kMemberNum)

Exit_Process_FE_Actions:
        Exit Sub

ErrHandler_Process_FE_Actions:
        FileClose()
        Console.WriteLine("... Process_FE_Actions: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Process_FE_Actions
        Stop

    End Sub  '.. Process_FE_Actions ..


    '<< Do_Global_Load >>
    Private Sub Do_Global_Load(ByVal mem As Byte, ByVal acd As Byte, ByVal w0 As Double, ByVal start As Double)

        'Call schTrace.wbkWritelnCell(0, "Do_Global_Load ...")
        'schTrace.IncTracerRow()

        Select Case acd
            Case global_x            ' .. global X components
                nrm_comp = w0 * sina
                axi_comp = w0 * cosa

            Case global_y            ' .. global Y components
                nrm_comp = w0 * cosa
                axi_comp = w0 * sina
        End Select

    End Sub  '.. Do_Global_Load ..


    '<< Do_Axial_Load >>
    '.. Load type = "v" => #3
    Private Sub Do_Axial_Load(ByVal mno As Byte, ByVal wu As Double, ByVal x1 As Double)

        On Error GoTo ErrHandler_Do_Axial_Load

        'Call schTrace.wbkWritelnCell(0, "Do_Axial_Load ...")
        'schTrace.IncTracerRow()

        w_nrm = wu
        la = x1
        lb = trl - la
        a_i = -wu * lb / trl
        a_j = -wu * la / trl
        fi = 0
        fj = 0
        ri = 0
        rj = 0
        Call Process_FE_Actions(mno, la, lb)


Exit_Do_Axial_Load:
        Exit Sub

ErrHandler_Do_Axial_Load:
        FileClose()
        Console.WriteLine("... Do_Axial_Load: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Do_Axial_Load
        Stop

    End Sub  '.. Do_Axial_Load ..


    '<< Do_Self_Weight >>
    Private Sub Do_Self_Weight(ByRef mem As Byte)
        Dim msect As Byte, mat As Byte
        Dim idxMem As Byte, idxMsect As Byte, idxMat As Byte

        'Call schTrace.wbkWritelnCell(0, "Do_Self_Weight ...")
        'schTrace.IncTracerRow()

        'Convert Member Number to Array Index
        idxMem = mem - 1

        'Convert Section Number to Array Index
        msect = GModel.con_grp(idxMem).sect
        idxMsect = msect - 1

        'Convert Material Number to Array Index
        mat = GModel.sec_grp(idxMsect).mat
        idxMat = mat - 1

        udl = udl * GModel.mat_grp(idxMat).density * GModel.sec_grp(idxMsect).ax / kilo
    End Sub  '.. Do_Self_Weight ..


    '<< UDL_Slope >>
    Private Function UDL_Slope(ByVal w0 As Double, ByVal v As Double, ByVal c As Double) As Double

        On Error GoTo ErrHandler_UDL_Slope

        'Call schTrace.wbkWriteln("UDL_Slope ...")

        UDL_Slope = w0 * v * (4 * (trl ^ 2 - v ^ 2) - c ^ 2) / (24 * trl)

Exit_UDL_Slope:
        Exit Function

ErrHandler_UDL_Slope:
        FileClose()
        Console.WriteLine("... UDL_Slope: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_UDL_Slope
        Stop

    End Function '.. UDL_Slope ..


    '<< Do_Part_UDL >>
    '.. Load type = "u" => #1
    Private Sub Do_Part_UDL(ByVal mno As Double, ByVal wu As Double, ByVal x1 As Double, _
                                         ByVal cv As Double, ByRef wact As Byte)

        Dim la As Double, lb As Double

        On Error GoTo ErrHandler_Do_Part_UDL

        'Call schTrace.wbkWritelnCell(0, "Do_Part_UDL ...")
        'Call schTrace.wbkWritelnCell(2, mno)
        'schTrace.IncTracerRow()


        la = x1 + cv / 2
        lb = trl - la

        If wact <> local_act Then
            Call Do_Global_Load(mno, wact, wu, x1)
            w_axi = axi_comp * cv
            Call Do_Axial_Load(mno, w_axi, la)
        Else
            nrm_comp = wu
            axi_comp = 0
        End If

        w_nrm = nrm_comp * cv
        dii = UDL_Slope(w_nrm, lb, cv)
        djj = UDL_Slope(w_nrm, la, cv)

        Call Calc_Moments(mno, trl, w_nrm, x1, la, cv, udl_ld, pos_slope) '.. Calculate the span moments
        Call Calc_FE_Forces(mno, la, lb)
        Call Process_FE_Actions(mno, la, lb)


        'Call schTrace.wbkWritelnCell(0, "... Do_Part_UDL")
        'schTrace.IncTracerRow()


Exit_Do_Part_UDL:
        Exit Sub

ErrHandler_Do_Part_UDL:
        FileClose()
        Console.WriteLine("... Do_Part_UDL: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Do_Part_UDL
        Stop

    End Sub      '.. Do_Part_UDL ..


    '<< PL_Slope >>
    Private Function PL_Slope(ByVal v As Double) As Double

        'Call schTrace.wbkWritelnCell(0, "PL_Slope ...")
        'schTrace.IncTracerRow()

        PL_Slope = w_nrm * v * (trl ^ 2 - v ^ 2) / (6 * trl)
    End Function '.. PL_Slope ..


    '<< Do_Point_load >>
    '.. Load type = "p" => #2
    Private Sub Do_Point_load(ByVal mno As Double, ByVal wu As Double, ByVal x1 As Double, ByVal wact As Byte)

        On Error GoTo ErrHandler_Do_Point_load

        'Call schTrace.wbkWritelnCell(0, "Do_Point_load ...")
        'schTrace.IncTracerRow()

        la = x1
        lb = trl - la

        If wact <> local_act Then
            Call Do_Global_Load(mno, wact, wu, x1)
            w_axi = axi_comp
            Call Do_Axial_Load(mno, w_axi, la)
        Else
            nrm_comp = wu
            axi_comp = 0
        End If

        w_nrm = nrm_comp

        dii = PL_Slope(lb)
        djj = PL_Slope(la)

        Call Calc_Moments(mno, trl, w_nrm, x1, la, 0, pnt_ld, pos_slope) '.. Calculate the span moments
        Call Calc_FE_Forces(mno, la, lb)
        Call Process_FE_Actions(mno, la, lb)

Exit_Do_Point_load:
        Exit Sub

ErrHandler_Do_Point_load:
        FileClose()
        Console.WriteLine("... Do_Point_load: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Do_Point_load
        Stop

    End Sub '.. Do_Point_load ..


    '<< Tri_Slope >>
    Private Function Tri_Slope(ByVal v As Double, ByVal w_nrm As Double, ByVal cv As Double, _
                        ByVal sl_switch As Integer) As Double



        On Error GoTo ErrHandler_Tri_Slope

        'Call schTrace.wbkWritelnCell(0, "Tri_Slope ...")
        'schTrace.IncTracerRow()

        gam = cv / trl
        v = v / trl
        Tri_Slope = w_nrm * _
                    trl ^ 2 * (270 * (v - v ^ 3) - gam ^ 2 * (45 * v + sl_switch * 2 * gam)) / 1620


Exit_Tri_Slope:
        Exit Function

ErrHandler_Tri_Slope:
        FileClose()
        Console.WriteLine("... Tri_Slope: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Tri_Slope
        Stop

    End Function '.. Tri_Slope ..

    '<< Do_Triangle >>
    '.. Load type =
    Private Sub Do_Triangle(ByVal mno As Double, ByVal w0 As Double, ByVal la As Double, _
                      ByVal x1 As Double, ByVal cv As Double, ByRef wact As Byte, ByVal slopedir As Integer)
        Dim lb As Double


        On Error GoTo ErrHandler_Do_Triangle

        'Call schTrace.wbkWritelnCell(0, "Do_Triangle ...")
        'schTrace.IncTracerRow()

        lb = trl - la

        If wact <> local_act Then
            Call Do_Global_Load(mno, wact, w0, x1)
            w_axi = axi_comp * cv / 2
            Call Do_Axial_Load(mno, w_axi, la)
        Else
            nrm_comp = w0
            axi_comp = 0
        End If

        w_nrm = nrm_comp * cv / 2

        dii = Tri_Slope(lb, w_nrm, cv, pos_slope * slopedir)     '.. /!  => +ve when +ve slope
        djj = Tri_Slope(la, w_nrm, cv, neg_slope * slopedir)     '.. !\  => +ve when -ve slope

        Call Calc_Moments(mno, trl, w_nrm, x1, la, cv, tri_ld, slopedir)  '.. Calculate the span moments
        Call Calc_FE_Forces(mno, la, lb)
        Call Process_FE_Actions(mno, la, lb)


Exit_Do_Triangle:
        Exit Sub

ErrHandler_Do_Triangle:
        FileClose()
        Console.WriteLine("... Do_Triangle: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Do_Triangle
        Stop


    End Sub  '.. Do_Triangle ..

    '<< Do_Distributed_load >>
    '.. Load type = "v" => #1
    Private Sub Do_Distributed_load(ByVal mno As Byte, ByVal wm1 As Double, ByVal wm2 As Double, _
                          ByVal x1 As Double, ByVal cv As Double, ByRef lact As Byte)

        Dim wudl As Double, wtri As Double, slope As Double, ltri As Double

        On Error GoTo ErrHandler_Do_Distributed_load

        'Call schTrace.wbkWritelnCell(0, "Do_Distributed_load ...")
        'Call schTrace.wbkWritelnCell(2, mno)
        'schTrace.IncTracerRow()


        If wm1 = wm2 Then                 '..  load is a UDL
            Call Do_Part_UDL(mno, wm1, x1, cv, lact)
        Else
            If Abs(wm1) < Abs(wm2) Then     '..  positive slope ie sloping upwards / left to right
                wudl = wm1
                wtri = wm2 - wudl
                slope = pos_slope
                ltri = x1 + 2 * cv / 3
            Else                            '..  negative slope ie sloping upwards \ right to left
                wudl = wm2
                wtri = wm1 - wudl
                slope = neg_slope
                ltri = x1 + cv / 3
            End If

            poslope = (slope = pos_slope)

            If wudl <> 0 Then
                Call Do_Part_UDL(mno, wudl, x1, cv, lact)
            End If

            If wtri <> 0 Then
                Call Do_Triangle(mno, wtri, ltri, x1, cv, lact, slope)
            End If

        End If

        'Call schTrace.wbkWritelnCell(0, "... Do_Distributed_load")
        'schTrace.IncTracerRow()

Exit_Do_Distributed_load:
        Exit Sub

ErrHandler_Do_Distributed_load:
        FileClose()
        Console.WriteLine("... Do_Distributed_load: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Do_Distributed_load
        Stop

    End Sub  '.. Do_Distributed_load ..

    '<< Get_FE_Forces >>
    Private Sub Get_FE_Forces(ByVal kMemberNum As Byte, ByVal ldty As Byte, ByVal wm1 As Double, _
                           ByVal wm2 As Double, ByVal x1 As Double, ByVal cvr As Double, ByRef lact As Byte)

        On Error GoTo ErrHandler_Get_FE_Forces

        'schTrace.IncTracerRow()
        'Call schTrace.wbkWritelnCell(0, "Get_FE_Forces ...")
        'Call schTrace.wbkWritelnCell(2, kMemberNum)

        Select Case ldty                '.. Get_FE_Forces ..

            Case dst_ld                                             '..  "v" = #1
                Call Do_Distributed_load(kMemberNum, wm1, wm2, x1, cvr, lact)
            Case pnt_ld                                             '..  "p" = #2
                Call Do_Point_load(kMemberNum, wm1, x1, lact)
            Case axi_ld                                             '..  "a" = #3
                Call Do_Axial_Load(kMemberNum, wm1, x1)

        End Select

Exit_Get_FE_Forces:
        Exit Sub

ErrHandler_Get_FE_Forces:
        FileClose()
        Console.WriteLine("... Get_FE_Forces: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Get_FE_Forces
        Stop

    End Sub  '.. Get_FE_Forces ..

    '  << Process_Loadcases >>
    Private Sub Process_Loadcases()

        Dim r As Integer
        Dim idxMem As Byte

        On Error GoTo ErrHandler_Process_Loadcases

        'Call schTrace.wbkWriteln("Process_Loadcases ...")
        'schTrace.IncTracerRow()

        'Joint Loads
        If GModel.structParam.njl <> 0 Then 'Have Joint Loads
            'schTrace.wbkWriteln("FC[]:")
            For global_i = baseIndex To GModel.structParam.njl - 1
                With GModel.jnt_lod(global_i)
                    Get_Joint_Indices(.jt)

                    fc(j1) = .fx
                    fc(j2) = .fy
                    fc(j3) = .mz

                    'Call schTrace.wbkWriteCell(r, 0, fc(j1))
                    'Call schTrace.wbkWriteCell(r, 1, fc(j2))
                    'Call schTrace.wbkWriteCell(r, 2, fc(j3))
                    r = r + 1
                End With
            Next global_i
        Else
            'schTrace.wbkWriteln("njl=0 : No Joint Loads")
        End If

        'Member Loads
        If GModel.structParam.nml <> 0 Then 'Have Member Loads
            'schTrace.wbkWriteln("nml = " & Format(nml, "0"))

            For global_i = baseIndex To GModel.structParam.nml - 1
                '        Call schTrace.wbkWriteln("global_i = " & Format(global_i, "0"))
                'Call schTrace.wbkWritelnCell(0, global_i)

                With GModel.mem_lod(global_i)
                    idxMem = .mem_no - 1 'Member Numbers start at 1, arrays indexed from 0
                    'Call schTrace.wbkWritelnCell(1, .mem_no)
                    trl = mlen(idxMem)
                    'Call schTrace.wbkWritelnCell(2, trl)

                    cosa = rot_mat(idxMem, ndx1)    '.. Cos
                    sina = rot_mat(idxMem, ndx2)    '.. Sin
                    ldc = .lcode
                    wm1 = .ld_mag1
                    wm2 = .ld_mag2
                    cvr = .cover
                    x1 = .start
                    If (ldc = dst_ld) And (cvr = 0) Then
                        x1 = 0
                        cvr = trl
                    End If
                    'Pass Member Numbers, Convert to Index internally
                    Call Get_FE_Forces(.mem_no, ldc, wm1, wm2, .start, cvr, .f_action)

                    'Call schTrace.wbkWriteln("FC[]:" & Format(global_i, "0"))
                    'Call schTrace.wbkWriteVector(fc)


                End With

                'schTrace.IncTracerRow()
            Next global_i
        Else
            'schTrace.wbkWriteln("nml=0 : No Member Loads")
        End If

        'Gravity Loads
        If GModel.structParam.ngl <> 0 Then 'Have Gravity Loads
            For global_i = baseIndex To GModel.structParam.nmb - 1
                With GModel.grv_lod
                    x1 = 0
                    trl = mlen(global_i)
                    cvr = trl
                    cosa = rot_mat(global_i, ndx1)
                    sina = rot_mat(global_i, ndx2)
                    udl = .load
                    ldc = dst_ld        ' ud_ld        '.. 1
                    Call Do_Self_Weight(global_i)
                    nrm_comp = udl
                    If .f_action <> local_act Then
                        Call Do_Global_Load(global_i, .f_action, udl, 0)
                    End If
                    Call Get_FE_Forces(global_i, dst_ld, nrm_comp, nrm_comp, x1, cvr, .f_action)
                End With
            Next global_i
        Else
            'schTrace.wbkWriteln("ngl=0 : No Gravity Loads")
        End If


        'Call schTrace.wbkWriteln("... Process_Loadcases")

Exit_Process_Loadcases:
        Exit Sub

ErrHandler_Process_Loadcases:
        FileClose()
        Console.WriteLine("... Process_Loadcases: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Process_Loadcases
        Stop

    End Sub  '.. Process_Loadcases ..


    '<< Zero_Vars >>
    Public Sub Zero_Vars()

        'Call schTrace.wbkWritelnCell(0, "Zero_Vars ...")
        'schTrace.IncTracerRow()

        Console.WriteLine("Zero_Vars ...")
        'In Vb.net Erase also removes from memory
        'Erase mlen  ' Each element set to 0.
        'Erase ad
        'Erase fc
        'Erase ar
        'Erase dj
        'Erase dd
        'Erase rjl
        'Erase crl
        'Erase rot_mat

        af.Initialize() ' Each element set to 0.
        sj.Initialize()
        s.Initialize()
        mom_spn.Initialize()
        mlen.Initialize()
        ad.Initialize()
        fc.Initialize()
        ar.Initialize()
        dj.Initialize()
        dd.Initialize()
        rjl.Initialize()
        crl.Initialize()
        rot_mat.Initialize()
        af.Initialize()
        sj.Initialize()
        s.Initialize()
        mom_spn.Initialize()

        Console.WriteLine("... Zero_Vars")
    End Sub  '.. Zero_Vars ..

    '<< Initialise >>
    Public Sub initialise()

        'Call schTrace.wbkWritelnCell(0, "initialise ...")
        'schTrace.IncTracerRow()

        Console.WriteLine("Initialise ...")
        ra = 0
        rb = 0
        global_i = 0
        global_j = 0
        global_k = 0
        ai = 0
        aj = 0
        lb = 0
        ci = 0
        cj = 0
        ccl = 0
        eaol = 0

        Call Zero_Vars()

        If data_loaded Then Call Get_Direction_Cosines()

        'With GModel
        '    .initialise()
        'End With

        Console.WriteLine("... Initialise")

    End Sub  '.. Initialise ..

    '<< Translate_Ndx >>
    '.. Restrained joint index
    Private Function Translate_Ndx(ByVal i As Byte) As Integer

        'Call schTrace.wbkWritelnCell(0, "Translate_Ndx ...")
        'schTrace.IncTracerRow()

        Translate_Ndx = i - crl(i)

    End Function  '.. Translate_Ndx ..

    '<< Equiv_Ndx >>
    '..equivalent matrix configuration  joint index numbers
    Private Function Equiv_Ndx(ByVal j As Byte) As Integer

        'Call schTrace.wbkWritelnCell(0, "Equiv_Ndx ...")
        'schTrace.IncTracerRow()

        Equiv_Ndx = rjl(j) * (nn + crl(j)) + (1 - rjl(j)) * Translate_Ndx(j)

    End Function '.. Equiv_Ndx ..

    '<< Get_Joint_Indices >>
    '..  get equivalent matrix index numbers
    Private Sub Get_Joint_Indices(ByVal nd As Byte)

        'Call schTrace.wbkWritelnCell(0, "Get_Joint_Indices ...")
        'Call schTrace.wbkWritelnCell(2, nd)
        'schTrace.IncTracerRow()

        j0 = (3 * nd) - 1
        j3 = Equiv_Ndx(j0)
        j2 = j3 - 1
        j1 = j2 - 1

        'Call schTrace.wbkWritelnCell(0, "j0")
        'Call schTrace.wbkWritelnCell(1, j0)
        'schTrace.IncTracerRow()
        'Call schTrace.wbkWritelnCell(0, "j1")
        'Call schTrace.wbkWritelnCell(1, j1)
        'schTrace.IncTracerRow()
        'Call schTrace.wbkWritelnCell(0, "j2")
        'Call schTrace.wbkWritelnCell(1, j2)
        'schTrace.IncTracerRow()
        'Call schTrace.wbkWritelnCell(0, "j3")
        'Call schTrace.wbkWritelnCell(1, j3)
        'schTrace.IncTracerRow()

    End Sub      '.. Get_Joint_Indices ..

    '<< Get_Direction_Cosines >>
    Private Sub Get_Direction_Cosines()
        Dim i As Byte, tmp As Byte, rel_tmp As Byte
        Dim xm As Double, ym As Double

        Console.WriteLine("Get_Direction_Cosines ...")

        'Call schTrace.wbkWriteln("Get_Direction_Cosines ...")

        Console.WriteLine("nmb: " + Format(GModel.structParam.nmb, "0"))
        For i = baseIndex To GModel.structParam.nmb - 1
            'console.writeLine( i, nmb)
            With GModel.con_grp(i)
                If .jk < .jj Then  '.. swap end1 with end2 if smaller !! ..
                    tmp = .jj
                    .jj = .jk
                    .jk = tmp

                    rel_tmp = .rel_j
                    .rel_j = .rel_i
                    .rel_i = rel_tmp
                End If

                'console.writeLine( "STEP:1", i, .jk, getArrayIndex(.jk), .jj, getArrayIndex(.jj)
                xm = GModel.nod_grp(getArrayIndex(.jk)).x - GModel.nod_grp(getArrayIndex(.jj)).x
                ym = GModel.nod_grp(getArrayIndex(.jk)).y - GModel.nod_grp(getArrayIndex(.jj)).y
                mlen(i) = Sqrt(xm * xm + ym * ym)

                'Call schTrace.wbkWritelnCell(0, i)
                'Call schTrace.wbkWritelnCell(1, mlen(i))


                Console.WriteLine(Format(i, "0") + ": mlen[i]: " + Format(mlen(i), "0.000"))

                rot_mat(i, ndx1) = xm / mlen(i)      '.. Cos
                rot_mat(i, ndx2) = ym / mlen(i)      '.. Sin

            End With

            'Call schTrace.IncTracerRow()
        Next i

        Console.WriteLine("... Get_Direction_Cosines")

    End Sub  '.. Get_Direction_Cosines ..



    '<< Total_Section_Mass >>
    Private Sub Total_Section_Mass()
        Dim i As Integer

        'Call schTrace.wbkWritelnCell(0, "Total_Section_Mass ...")
        'schTrace.IncTracerRow()

        For i = baseIndex To GModel.structParam.nsg - 1
            '      With mat_grp(sec_grp(i).mat)
            '        sec_grp(i).t_mass = sec_grp(i).ax * .Density * sec_grp(i).t_len
            GModel.sec_grp(i).t_mass = GModel.sec_grp(i).ax * GModel.mat_grp(getArrayIndex(GModel.sec_grp(i).mat)).density * GModel.sec_grp(i).t_len
            '      End With
        Next i
    End Sub '.. Total_Section_Mass ..



    '<< Total_Section_Length >>
    Private Sub Total_Section_Length()
        Dim ndx As Integer

        'Call schTrace.wbkWritelnCell(0, "Total_Section_Length ...")
        'schTrace.IncTracerRow()

        For global_i = baseIndex To GModel.structParam.nmb - 1
            ndx = getArrayIndex(GModel.con_grp(global_i).sect)
            'With con_grp(global_i)
            'sec_grp(.sect).t_len = sec_grp(.sect).t_len + mlen(global_i)
            GModel.sec_grp(ndx).t_len = GModel.sec_grp(ndx).t_len + mlen(global_i)
            'End With
        Next global_i
        Call Total_Section_Mass()
    End Sub '.. Total_Section_Length ..


    '<< Get_Min_Max >>
    '..find critical End forces ..
    Private Sub Get_Min_Max()

        'Call schTrace.wbkWritelnCell(0, "Get_Min_Max ...")
        'schTrace.IncTracerRow()

        maxM = 0
        MaxMJnt = 0
        maxMmemb = 0

        MinM = infinity
        MinMJnt = 0
        MinMmemb = 0

        maxA = 0
        MaxAJnt = 0
        maxAmemb = 0

        MinA = infinity
        MinAJnt = 0
        MinAmemb = 0

        For global_i = baseIndex To GModel.structParam.nmb - 1


            With GModel.con_grp(global_i)

                '         .. End moments ..
                If maxM < .jnt_jj.momnt Then
                    maxM = .jnt_jj.momnt
                    MaxMJnt = .jj
                    maxMmemb = global_i
                End If

                If maxM < .jnt_jk.momnt Then
                    maxM = .jnt_jk.momnt
                    MaxMJnt = .jk
                    maxMmemb = global_i
                End If

                If MinM > .jnt_jj.momnt Then
                    MinM = .jnt_jj.momnt
                    MinMJnt = .jj
                    MinMmemb = global_i
                End If

                If MinM > .jnt_jk.momnt Then
                    MinM = .jnt_jk.momnt
                    MinMJnt = .jk
                    MinMmemb = global_i
                End If

                '         .. End axials ..
                If maxA < .jnt_jj.axial Then
                    maxA = .jnt_jj.axial
                    MaxAJnt = .jj
                    maxAmemb = global_i
                End If

                If maxA < .jnt_jk.axial Then
                    maxA = .jnt_jk.axial
                    MaxAJnt = .jk
                    maxAmemb = global_i
                End If

                If MinA > .jnt_jj.axial Then
                    MinA = .jnt_jj.axial
                    MinAJnt = .jj
                    MinAmemb = global_i
                End If

                If MinA > .jnt_jk.axial Then
                    MinA = .jnt_jk.axial
                    MinAJnt = .jk
                    MinAmemb = global_i
                End If

                '         .. End shears..
                If maxQ < .jnt_jj.shear Then
                    maxQ = .jnt_jj.shear
                    MaxQJnt = .jj
                    maxQmemb = global_i
                End If

                If maxQ < .jnt_jk.shear Then
                    maxQ = .jnt_jk.shear
                    MaxQJnt = .jk
                    maxQmemb = global_i
                End If

                If MinQ > .jnt_jj.shear Then
                    MinQ = .jnt_jj.shear
                    MinQJnt = .jj
                    MinQmemb = global_i
                End If

                If MinQ > .jnt_jk.shear Then
                    MinQ = .jnt_jk.shear
                    MinQJnt = .jk
                    MinQmemb = global_i
                End If

            End With
        Next global_i
    End Sub     '.. Get_Min_Max ..


    '<< Analyse_Frame >>
    Sub Analyse_Frame()

        Dim i As Byte

        On Error GoTo ErrHandler_Analyse_Frame

        'Call schTrace.wbkWritelnCell(0, "Analyse_Frame ...")
        'schTrace.IncTracerRow()


        'Call schTrace2.SetMytracer(True)
        'Call schTrace2.SetTraceWrkBk(False, "Choleski")
        'startCell2 = schTrace2.TracerWrkSht.Range("F4:F4")

        'Call schTrace3.SetMytracer(True)
        'Call schTrace3.SetTraceWrkBk(False, "MatrixSJ")
        'startCell3 = schTrace2.TracerWrkSht.Range("A1:A1")

        'Get definition of the Plane Frame to Analyse

        '    Set MiWrkBk = ActiveWorkbook
        Console.WriteLine("Analyse_Frame ...")
        Console.WriteLine(">>> Design Frame Started <<<")
        '    Erase sec_grp
        '    Call Jotter
        '    Call GetData

        'Call schTrace.wbkWriteln("Analyse Frame")

        Call initialise()

        'BEGIN PLANEFRAME ANALYSIS

        GModel.cprint()

        Call Fill_Restrained_Joints_Vector()

        'Call schTrace.wbkWriteln("rjl")
        'startCell = schTrace.TracerRange
        'Call schTrace.wbkWriteVector(rjl)

        'Call schTrace.wbkWriteln("crl")
        'startCell = schTrace.TracerRange
        'Call schTrace.wbkWriteVector(crl)

        'Call schTrace.wbkWriteln("Calculate Total Section Length")
        Call Total_Section_Length()

        'Call schTrace.wbkWriteln("Calculate Band Width")
        Call Calc_Bandwidth()
        'Call schTrace.wbkWriteln("hbw:nn : " & Format(hbw, "#") & ":" & Format(nn, "#"))

        'Call schTrace3.wbkWritelnCellColoured(0, "i", 4)
        'Call schTrace3.wbkWritelnCellColoured(1, "Node jj", 4)
        'Call schTrace3.wbkWritelnCellColoured(2, "Node kk", 4)

        'Call schTrace3.wbkWritelnCellColoured(3, "j1", 4)
        'Call schTrace3.wbkWritelnCellColoured(4, "j2", 4)
        'Call schTrace3.wbkWritelnCellColoured(5, "j3", 4)
        'Call schTrace3.wbkWritelnCellColoured(6, "k1", 4)
        'Call schTrace3.wbkWritelnCellColoured(7, "k2", 4)
        'Call schTrace3.wbkWritelnCellColoured(8, "k3", 4)
        'Call schTrace3.wbkWritelnCellColoured(9, "Gi", 4)
        'Call schTrace3.wbkWritelnCellColoured(10, "Gj", 4)
        'Call schTrace3.wbkWritelnCellColoured(11, "Gk", 4)
        'Call schTrace3.wbkWritelnCellColoured(12, "s[]", 4)
        'Call schTrace3.wbkWritelnCellColoured(13, "sj[]-in", 4)
        'Call schTrace3.wbkWritelnCellColoured(14, "sj[]-out", 4)
        'schTrace3.IncTracerRow()

        For i = baseIndex To GModel.structParam.nmb - 1
            Console.WriteLine("Analyse_Frame:  i = " + format( i,"0"))
            Call Assemble_Global_Stiff_Matrix(i)
            'Call schTrace.wbkWriteln("S[]: " & Format(i, "0"))
            'Call schTrace.wbkWriteMatrix(s)

            'Call schTrace3.wbkWritelnCell(0, i)
            Call Assemble_Struct_Stiff_Matrix(i)
            'Call schTrace.wbkWriteln("SJ[]: " & Format(i, "0"))
            'Call schTrace.wbkWriteMatrix(sj)
            'schTrace3.IncTracerRow()

        Next i
        Console.WriteLine("End of Matrix Assembly")

        'Call schTrace.wbkWriteln("SJ[]: ")
        'Call schTrace.wbkWriteMatrix(sj)

        'Call schTrace.wbkWriteln("Choleski Decomposition")
        Call Choleski_Decomposition(sj, nn, hbw)
        PrintLine(fpTracer, "SJ[]: Result")
        fprintMatrix(fpTracer, sj)


        '------------------------------------------------------------------------------


        PrintLine(fpTracer, "Process_Loadcases")
        Call Process_Loadcases()
        PrintLine(fpTracer, "FC[]: Result: ")
        fprintVector(fpTracer, fc)

        PrintLine(fpTracer, "AF[]: ")
        fprintMatrix(fpTracer, af)

        PrintLine(fpTracer, "Solve_Displacements")
        Call Solve_Displacements()
        PrintLine(fpTracer, "DD[]: ")
        fprintVector(fpTracer, dd)

        PrintLine(fpTracer, "Calc_Joint_Displacements")
        Call Calc_Joint_Displacements()
        PrintLine(fpTracer, "DJ[]: ")
        fprintVector(fpTracer, dj)

        PrintLine(fpTracer, "Calc_Member_Forces")
        Call Calc_Member_Forces()
        PrintLine(fpTracer, "AD[]: ")
        fprintVector(fpTracer, ad)

        PrintLine(fpTracer, "AR[]: ")
        fprintVector(fpTracer, ar)



        PrintLine(fpTracer, "Get_Span_Moments")
        Call Get_Span_Moments()
        PrintLine(fpTracer, "mom_spn: ")
        fprintMatrix(fpTracer, mom_spn)


        PrintLine(fpTracer, "Get_Min_Max")
        Call Get_Min_Max()


        PrintLine(fpTracer, "Analysis Complete!")
        'END OF PLANEFRAME ANALYSIS

        'Trace all Arrays for Reference
        'Call schTrace.wbkWriteln("mlen: ")
        'Call schTrace.wbkWriteVector(mlen)

        'Call schTrace.wbkWriteln("ad: ")
        'Call schTrace.wbkWriteVector(ad)
        '
        '    Call schTrace.wbkWriteln("fc: ")
        '    Call schTrace.wbkWriteVector(fc)
        '
        'Call schTrace.wbkWriteln("ar: ")
        'Call schTrace.wbkWriteVector(ar)
        '
        '    Call schTrace.wbkWriteln("dj: ")
        '    Call schTrace.wbkWriteVector(dj)
        '
        '    Call schTrace.wbkWriteln("dd: ")
        '    Call schTrace.wbkWriteVector(dd)
        '
        '    Call schTrace.wbkWriteln("rot_mat: ")
        '    Call schTrace.wbkWriteMatrix(rot_mat)
        '
        '    Call schTrace.wbkWriteln("af: ")
        '    Call schTrace.wbkWriteMatrix(af)
        '
        '    Call schTrace.wbkWriteln("s: ")
        '    Call schTrace.wbkWriteMatrix(s)
        '
        '    Call schTrace.wbkWriteln("mom_spn: ")
        '    Call schTrace.wbkWriteMatrix(mom_spn)
        '
        '    Call schTrace.wbkWriteln("sj: ")
        '    Call schTrace.wbkWriteMatrix(sj)
        '
        '    Call schTrace.wbkWriteln("crl: ")
        '    Call schTrace.wbkWriteVector(crl)
        '
        '    Call schTrace.wbkWriteln("rjl: ")
        '    Call schTrace.wbkWriteVector(rjl)

        'End Trace of Arrays


        'Do something with the results of the analysis
        'This can be done in the main calling application

        Console.WriteLine("*** Analysis Completed *** ")
        Console.WriteLine("... Analyse_Frame")

Exit_Analyse_Frame:
        Exit Sub

ErrHandler_Analyse_Frame:
        FileClose()
        Console.WriteLine("... Analyse_Frame: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        '    Resume Exit_Analyse_Frame
        Stop

    End Sub '.. Analyse_Frame ..

    '===========================================================================
    'END    ''.. Main Module ..
    '===========================================================================



    '    '------------------------------------------------------------------------------
    '    'DISPLAY RESULTS TO EXCEL WORKBOOK
    '    '------------------------------------------------------------------------------
    '    '###### Pf_Prt.PAS ######
    '    ' ... a module of Output routines for the Framework Program-
    '    '     R G Harrison   --  Version 1.1  --  12/05/05  ...
    '    '     Revision history as-
    '    '        12/05/05 - implemented ..

    '    '<<< START CODE >>>>}
    '    '===========================================================================

    '    '<<< ClearOutputSheet >>>
    '    Sub ClearOutputSheet(ByVal clrng As String)
    '    console.writeLine( "ClearOutputSheet "
    '        MiWrkBk.Worksheets("Frm").Range(clrng).ClearContents()
    '    End Sub '...ClearOutputSheet

    '    '<<< PrtDeltas >>>
    '    Sub PrtDeltas(ByVal r As Integer, ByVal c As Integer, ByVal Prnge As Range)

    '        Dim idx1 As Integer, idx2 As Integer, idx3 As Integer


    '        On Error GoTo ErrHandler_PrtDeltas

    '  console.writeLine( "PrtDeltas "

    '        For global_i = baseIndex + 1 To njt
    '            Prnge.Offset(r, c + 0).Value = global_i

    '            idx1 = 3 * global_i - 3
    '            idx2 = 3 * global_i - 2
    '            idx3 = 3 * global_i - 1

    '            '      console.writeLine( "3 * global_i - 3 = ", 3 * global_i - 3
    '            '      console.writeLine( "3 * global_i - 2 = ", 3 * global_i - 2
    '            '      console.writeLine( "3 * global_i - 1 = ", 3 * global_i - 1

    '            Prnge.Offset(r, c + 1).Value = -dj(idx1)
    '            Prnge.Offset(r, c + 2).Value = -dj(idx2)
    '            Prnge.Offset(r, c + 3).Value = -dj(idx3)
    '            r = r + 1
    '        Next global_i

    'Exit_PrtDeltas:
    '        Exit Sub

    'ErrHandler_PrtDeltas:
    '        Close()
    '    console.writeLine( "... PrtDeltas: Exit Errors!"
    '    console.writeLine( Err.Number, Err.Description
    '        '    Resume Exit_PrtDeltas
    '        Stop

    '    End Sub '...PrtDeltas

    '    '<<< PrtEndForces >>>
    '    Sub PrtEndForces(ByVal r As Integer, ByVal c As Integer, ByVal Prnge As Range)

    '        On Error GoTo ErrHandler_PrtEndForces

    '  console.writeLine( "PrtEndForces "
    '        For global_i = baseIndex To nmb - 1
    '            With con_grp(global_i)
    '                Prnge.Offset(r, c + 0).Value = global_i + 1
    '                Prnge.Offset(r, c + 1).Value = mlen(global_i)
    '                Prnge.Offset(r, c + 2).Value = .jj
    '                Prnge.Offset(r, c + 3).Value = .jnt_jj.axial
    '                Prnge.Offset(r, c + 4).Value = .jnt_jj.shear
    '                Prnge.Offset(r, c + 5).Value = .jnt_jj.momnt
    '                Prnge.Offset(r, c + 6).Value = .jk
    '                Prnge.Offset(r, c + 7).Value = .jnt_jk.axial
    '                Prnge.Offset(r, c + 8).Value = .jnt_jk.shear
    '                Prnge.Offset(r, c + 9).Value = .jnt_jk.momnt
    '            End With
    '            r = r + 1
    '        Next global_i

    'Exit_PrtEndForces:
    '        Exit Sub

    'ErrHandler_PrtEndForces:
    '        Close()
    '    console.writeLine( "... PrtEndForces: Exit Errors!"
    '    console.writeLine( Err.Number, Err.Description
    '        '    Resume Exit_PrtEndForces
    '        Stop

    '    End Sub  '...PrtEndForces

    '    '<< Prt_Reaction_Sum >>
    '    Sub Prt_Reaction_Sum(ByVal r As Byte, ByVal c As Byte, ByVal Prnge As Range)
    '        Prnge.Offset(r, c + 1).Value = sumx
    '        Prnge.Offset(r, c + 2).Value = sumy
    '    End Sub       '.. Prt_Reaction_Sum ..

    '    '<<< PrtReactions >>>
    '    Sub PrtReactions(ByVal row1 As Integer, ByVal col1 As Integer, ByVal Prnge As Range)

    '        Dim i As Integer, k As Integer, k3 As Integer, c As Integer, r As Integer

    '        On Error GoTo ErrHandler_PrtReactions

    '    console.writeLine( "PrtReactions "

    '        Call schTrace.wbkWriteln("PrtReactions ...")

    '        Call schTrace.wbkWriteln("Table:1 [" & Format(n3, "0") & "]")
    '        For k = baseIndex To n3 - 1
    '            If rjl(k) = 1 Then ar(k) = ar(k) - fc(Equiv_Ndx(k))
    '            Call schTrace.wbkWriteln(k)
    '        Next k
    '        sumx = 0
    '        sumy = 0

    '        Call schTrace.wbkWriteln("Table:2")
    '        r = row1
    '        For i = baseIndex To nrj - 1
    '            c = col1 + 1

    '            Call schTrace.wbkWritelnCell(0, i)

    '            With sup_grp(i)
    '                Prnge.Offset(r, c).Value = .js
    '                flag = 0
    '                c = c + 1
    '                k3 = 3 * .js - 1

    '                Call schTrace.wbkWritelnCell(1, .js)
    '                Call schTrace.wbkWritelnCell(2, k3)
    '                Call schTrace.wbkWritelnCell(3, k3 - 2)

    '                For k = k3 - 2 To k3

    '                    If (k + 1) Mod 3 = 0 Then
    '                        Prnge.Offset(r, c).Value = ar(k)
    '                    Else
    '                        Prnge.Offset(r, c).Value = ar(k)
    '                        If flag = 0 Then
    '                            sumx = sumx + ar(k)
    '                        Else
    '                            sumy = sumy + ar(k)
    '                        End If
    '                        flag = flag + 1
    '                    End If

    '                    c = c + 1
    '                Next k
    '                flag = 0

    '                r = r + 1
    '            End With

    '            schTrace.IncTracerRow()
    '        Next i

    '        Call Prt_Reaction_Sum(row1 - 5, col1 + 1, Prnge)

    'Exit_PrtReactions:
    '        Exit Sub

    'ErrHandler_PrtReactions:
    '        Close()
    '    console.writeLine( "... PrtReactions: Exit Errors!"
    '    console.writeLine( Err.Number, Err.Description
    '        '    Resume Exit_PrtReactions
    '        Stop

    '    End Sub '...PrtReactions

    '    '<< Prt_Controls >>
    '    Sub Prt_Controls(ByVal r As Byte, ByVal c As Byte, ByVal Prnge As Range)
    '        Prnge.Offset(r + 1, c + 1).Value = njt
    '        Prnge.Offset(r + 2, c + 1).Value = nmb
    '        Prnge.Offset(r + 3, c + 1).Value = nmg
    '        Prnge.Offset(r + 4, c + 1).Value = nsg
    '        Prnge.Offset(r + 5, c + 1).Value = nrj
    '        Prnge.Offset(r + 6, c + 1).Value = njl
    '        Prnge.Offset(r + 7, c + 1).Value = nml
    '        Prnge.Offset(r + 8, c + 1).Value = ngl
    '        Prnge.Offset(r + 9, c + 1).Value = nr

    '    End Sub       '.. Prt_Controls ..

    '    '<<< Prt_Section_Details >>>
    '    Sub Prt_Section_Details(ByVal r As Integer, ByVal c As Integer, ByVal Prnge As Range)
    '  console.writeLine( "Prt_Section_Details "
    '        For global_i = baseIndex To nmg - 1
    '            Prnge.Offset(r, c + 1).Value = global_i
    '            Prnge.Offset(r, c + 2).Value = sec_grp(global_i).t_len
    '            Prnge.Offset(r, c + 3).Value = sec_grp(global_i).t_mass
    '            Prnge.Offset(r, c + 4).Value = sec_grp(global_i).Descr
    '            r = r + 1
    '        Next global_i
    '    End Sub '...Prt_Section_Details

    '    '<<< PrtSpanMoments >>>
    '    Sub PrtSpanMoments()
    '        Dim r As Integer
    '        Dim c As Integer
    '        Dim seg As Double
    '        Dim Prnge As Range

    '        On Error GoTo ErrHandler_PrtSpanMoments


    '  console.writeLine( "PrtSpanMoments "
    '        MiWrkBk.Worksheets("MSpan").Activate()
    '        Prnge = MiWrkBk.Worksheets("MSpan").Range("A1:A1")
    '        r = 7
    '        c = 1

    '        For global_i = baseIndex To nmb - 1
    '            seg = mlen(global_i) / n_segs
    '            Prnge.Offset(r, c + 1).Value = global_i
    '            r = r + 1
    '            For global_j = startZero To n_segs
    '                Prnge.Offset(r, c + 0).Value = global_j
    '                Prnge.Offset(r, c + 1).Value = global_j * seg
    '                Prnge.Offset(r, c + 2).Value = mom_spn(global_i, global_j)
    '                r = r + 1
    '            Next global_j
    '            r = 7
    '            c = c + 3
    '        Next global_i

    'Exit_PrtSpanMoments:
    '        Exit Sub

    'ErrHandler_PrtSpanMoments:
    '        Close()
    '    console.writeLine( "... PrtSpanMoments: Exit Errors!"
    '    console.writeLine( Err.Number, Err.Description
    '        '    Resume Exit_PrtSpanMoments
    '        Stop

    '    End Sub  '...PrtSpanMoments

    '    '<< Output Results to Table >>
    '    Sub PrintResults()
    '        Dim Prtrnge As Range

    '        On Error GoTo ErrHandler_PrintResults

    '  console.writeLine( "PrintResults "
    '        MiWrkBk.Worksheets("Frm").Activate()
    '        Prtrnge = MiWrkBk.Worksheets("Frm").Range("A1:A1")
    '        '--------------------------------------------------------------------
    '        Call ClearOutputSheet("b19:u35")
    '        Call Prt_Controls(4, 1, Prtrnge)
    '        Call PrtDeltas(18, 1, Prtrnge)
    '        Call PrtEndForces(18, 6, Prtrnge)
    '        Call PrtReactions(18, 16, Prtrnge)
    '        Call Prt_Section_Details(5, 6, Prtrnge)
    '        Call PrtSpanMoments()

    'Exit_PrintResults:
    '        Exit Sub

    'ErrHandler_PrintResults:
    '        Close()
    '    console.writeLine( "... PrintResults: Exit Errors!"
    '    console.writeLine( Err.Number, Err.Description
    '        '    Resume Exit_PrintResults
    '        Stop

    '    End Sub   '..PrintResults



    '    '###### Pf_Inp.PAS ######
    '    ' ... a module of Input routines for the Framework Program-
    '    '     R G Harrison   --  Version 1.1  --  12/05/05  ...
    '    '     Revision history as-
    '    '        12/05/05 - implemented ..
    '    '<<< START CODE >>>>}
    '    '===========================================================================
    '    '<<< GetData >>>
    '    ' ...   read in the data
    '    ' ...   RGH   24/4/05


    '    'Get Data From Excel Workbook
    '    Sub GetData()
    '        Dim r As Byte '.. Input Row ..]
    '        Dim sheetNames As Object

    '        Dim inputTable1 As Range
    '        Dim MaterialTable As Range
    '        Dim SectionTable As Range
    '        Dim NodeTable As Range
    '        Dim SupportTable As Range
    '        Dim MemberTable As Range
    '        Dim NodeLoadTable As Range
    '        Dim MemberLoadTable As Range
    '        Dim GravityLoadTable As Range

    '        On Error GoTo ErrHandler_GetData

    '  console.writeLine( "GetData ..."

    '        sheetNames = Array("Input", "Materials", "FrameSections", "Nodes", "Supports", "Members", "NodeLoads", "MemberLoads", "GravityLoads")

    '        Erase sec_grp

    '        njt = 0
    '        nmb = 0
    '        nmg = 0
    '        nsg = 0
    '        nrj = 0
    '        njl = 0
    '        nml = 0
    '        ngl = 0

    '        data_loaded = False
    '        nr = 0

    '        'Set Pointers to Structural Model Data Tables
    '        inputTable1 = MiWrkBk.Worksheets(sheetNames(0)).Range("A1:A1")
    '        MaterialTable = MiWrkBk.Worksheets(sheetNames(1)).Range("ptr" & CStr(sheetNames(1)) & "Table")
    '        SectionTable = MiWrkBk.Worksheets(sheetNames(2)).Range("ptr" & CStr(sheetNames(2)) & "Table")
    '        NodeTable = MiWrkBk.Worksheets(sheetNames(3)).Range("ptr" & CStr(sheetNames(3)) & "Table")
    '        SupportTable = MiWrkBk.Worksheets(sheetNames(4)).Range("ptr" & CStr(sheetNames(4)) & "Table")
    '        MemberTable = MiWrkBk.Worksheets(sheetNames(5)).Range("ptr" & CStr(sheetNames(5)) & "Table")
    '        NodeLoadTable = MiWrkBk.Worksheets(sheetNames(6)).Range("ptr" & CStr(sheetNames(6)) & "Table")
    '        MemberLoadTable = MiWrkBk.Worksheets(sheetNames(7)).Range("ptr" & CStr(sheetNames(7)) & "Table")
    '        GravityLoadTable = MiWrkBk.Worksheets(sheetNames(8)).Range("ptr" & CStr(sheetNames(8)) & "Table")


    '        '  With MiWrkBk.Worksheets("Input")
    '        '    Set Inputrnge = MiWrkBk.Worksheets("Nodes").Range("node")
    '        r = 0
    '        Do While Not (IsEmpty(NodeTable.Offset(r, 1)))
    '            Call addNode(NodeTable.Offset(r, 1).Value, NodeTable.Offset(r, 2).Value)
    '            r = r + 1
    '      console.writeLine( r, njt, nod_grp(njt).x, nod_grp(njt).y
    '        Loop

    '        '    Set Inputrnge = MiWrkBk.Worksheets("Materials").Range("matgrp")

    '        r = 0
    '        Do While Not (IsEmpty(MaterialTable.Offset(r, 1)))
    '            Call addMaterialGroup(MaterialTable.Offset(r, 1).Value, MaterialTable.Offset(r, 2).Value, MaterialTable.Offset(r, 3).Value)
    '            r = r + 1
    '      console.writeLine( r, nmg
    '        Loop

    '        '    Set Inputrnge = MiWrkBk.Worksheets("Sections").Range("sectgrp")
    '        r = 0
    '        Do While Not (IsEmpty(SectionTable.Offset(r, 1)))
    '            Call addSectionGroup(SectionTable.Offset(r, 1).Value, SectionTable.Offset(r, 2).Value, SectionTable.Offset(r, 3).Value, SectionTable.Offset(r, 4).Value)
    '            r = r + 1
    '      console.writeLine( r, nsg
    '        Loop


    '        '    Set Inputrnge = MiWrkBk.Worksheets("Members").Range("member")
    '        r = 0
    '        Do While Not (IsEmpty(MemberTable.Offset(r, 1)))
    '            Call addMember(MemberTable.Offset(r, 1).Value, MemberTable.Offset(r, 2).Value, _
    '                           MemberTable.Offset(r, 3).Value, MemberTable.Offset(r, 4).Value, MemberTable.Offset(r, 5).Value)
    '            r = r + 1
    '      console.writeLine( r, nmb
    '        Loop



    '        '    Set Inputrnge = MiWrkBk.Worksheets("Supports").Range("support")
    '        r = 0
    '        Do While Not (IsEmpty(SupportTable.Offset(r, 1)))
    '            Call addSupport(SupportTable.Offset(r, 1).Value, SupportTable.Offset(r, 2).Value, _
    '                           SupportTable.Offset(r, 3).Value, SupportTable.Offset(r, 4).Value)
    '            r = r + 1
    '      console.writeLine( r, nrj
    '        Loop
    '    console.writeLine( "No. Restrained nr .. ", nr


    '        '    Set Inputrnge = MiWrkBk.Worksheets("NodeLoads").Range("Joint_Load")
    '        r = 0
    '        Do While Not (IsEmpty(NodeLoadTable.Offset(r, 1)))
    '            Call addJointLoad(NodeLoadTable.Offset(r, 1).Value, NodeLoadTable.Offset(r, 2).Value, _
    '                           NodeLoadTable.Offset(r, 3).Value, NodeLoadTable.Offset(r, 4).Value)
    '            r = r + 1
    '      console.writeLine( r, njl
    '        Loop


    '        '    Set Inputrnge = MiWrkBk.Worksheets("MemberLoads").Range("Memb_Load")
    '        r = 0
    '        Do While Not (IsEmpty(MemberLoadTable.Offset(r, 1)))
    '            Call addMemberLoad(MemberLoadTable.Offset(r, 1).Value, MemberLoadTable.Offset(r, 2).Value, _
    '                           MemberLoadTable.Offset(r, 3).Value, MemberLoadTable.Offset(r, 4).Value, _
    '                           MemberLoadTable.Offset(r, 5).Value, MemberLoadTable.Offset(r, 6).Value, _
    '                           MemberLoadTable.Offset(r, 7).Value)
    '            r = r + 1
    '      console.writeLine( r, nml
    '        Loop

    '        '    Set Inputrnge = MiWrkBk.Worksheets("Gravity").Range("Grav_Load")
    '        r = 0
    '        Call addGravityLoad(GravityLoadTable.Offset(r, 1).Value, GravityLoadTable.Offset(r, 2).Value)

    '        '  End With
    '        data_loaded = True

    '  console.writeLine( "... GetData"

    'Exit_GetData:
    '        Exit Sub

    'ErrHandler_GetData:
    '        Close()
    '    console.writeLine( "... GetData: Exit Errors!"
    '    console.writeLine( Err.Number, Err.Description
    '        '    Resume Exit_GetData
    '        Stop

    '    End Sub  '... GetData



    '    '------------------------------------------------------------------------------
    '    'EXCEL WORKBOOK DATABOOK
    '    '------------------------------------------------------------------------------
    '    Sub makeNewModelBook()
    '        Const isDimensionsAbove As Boolean = True

    '        Dim sheetNames As Object
    '        Dim hdrs As Object
    '        Dim numRecs As Object

    '        Dim wrkBk As Workbook
    '        Dim wrkSht As Worksheet
    '        Dim i As Integer, n As Integer
    '        Dim wbkReport As New clsWbkReport
    '        Dim tableName As String

    '        sheetNames = Array("Input", "Materials", "FrameSections", "Nodes", "Supports", "Members", "NodeLoads", "MemberLoads", "GravityLoads")
    '        hdrs = Array(2, 3, 3, 3, 2, 2, 3, 3, 3)
    '        numRecs = Array(1, max_mats, max_grps, max_grps, max_grps, max_grps, numloads, numloads, 1)

    '        wrkBk = Workbooks.Add

    '        n = UBound(sheetNames)

    '        With wrkBk

    '            If Not (IsStyleAvailable(wrkBk, "unprotect")) Then
    '                Call .Styles.Add("unprotect")
    '            End If
    '            With .Styles("unprotect")
    '                .IncludeFont = True
    '                .Font.ColorIndex = xlColorIndexAutomatic
    '                .IncludePatterns = True
    '                With .Interior
    '                    .ColorIndex = 6 '41
    '                    '.PatternColorIndex = 25
    '                    .Pattern = xlSolid
    '                    '.Interior.Color = RGB(255, 255, 0) 'Yellow
    '                End With
    '            End With

    '            'Add Project Work Sheet
    '            wrkSht = .Worksheets.Add(, .Worksheets(.Worksheets.Count))
    '            wrkSht.Name = "ProjectData"
    '            Call wbkReport.SetReportWrkBk(False, wrkSht.Name)
    '            Call wbkReport.wbkWriteHeaderCell(0, "JOB DETAILS::", 4)
    '            wbkReport.IncReportRow()
    '            Call wbkReport.wbkWritelnVarDef("HdrTitle", "-")
    '            Call wbkReport.wbkWritelnVarDef("Loadcase", "-")
    '            Call wbkReport.wbkWritelnVarDef("Author", "-")
    '            Call wbkReport.wbkWritelnVarDef("RunNumber", "0")

    '            'Add Parameter Work Sheet
    '            wrkSht = .Worksheets.Add(, .Worksheets(.Worksheets.Count))
    '            wrkSht.Name = "Param"
    '            Call wbkReport.SetReportWrkBk(False, wrkSht.Name)
    '            Call wbkReport.wbkWriteHeaderCell(0, "CONTROL DATA::", 4)
    '            wbkReport.IncReportRow()
    '            Call wbkReport.wbkWritelnVarDef2("Number of Joints", "Njoints", 0)
    '            Call wbkReport.wbkWritelnVarDef2("Number of Members", "Nmembers", 0)
    '            Call wbkReport.wbkWritelnVarDef2("Number of Supports", "Nsupports", 0)
    '            Call wbkReport.wbkWritelnVarDef2("Number of Material Groups", "Nmaterials", 0)
    '            Call wbkReport.wbkWritelnVarDef2("Number of Section Groups", "Nsections", 0)
    '            Call wbkReport.wbkWritelnVarDef2("Number of Joint Loads", "Njloads", 0)
    '            Call wbkReport.wbkWritelnVarDef2("Number of Member Loads", "Nmloads", 0)
    '            Call wbkReport.wbkWritelnVarDef2("Number of Gravity Loads", "Ngloads", 0)
    '            Call wbkReport.wbkWritelnVarDef2("Magnification factor for graphics. Only used by some versions of program", "Mag", 4)


    '            'Add Frame Analysis Data Sheet Collection
    '            For i = 0 To n
    '                wrkSht = .Worksheets.Add(, .Worksheets(.Worksheets.Count))
    '                wrkSht.Name = sheetNames(i)
    '                Call wbkReport.SetReportWrkBk(False, CStr(sheetNames(i)))

    '                wbkReport.ReportRange.Font.Bold = True
    '                Call wbkReport.wbkWriteln(UCase(sheetNames(i)) & "::")


    '                tableName = "ptr" & sheetNames(i) & "Table"
    '      console.writeLine( tableName, hdrs(i), numRecs(i)

    '                Select Case i
    '                    Case 0 'Input, Micellaneous
    '                        Call wbkReport.wbkWriteHeaderCell(0, "Miscellaneous Input Sheet", 4)

    '                    Case 1 'Materials

    '                        'Field Name Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "Material_ID", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "Density", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "emod", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(3, "therm", 4)

    '                        wbkReport.IncReportRow()
    '                        'Dimension Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "kg/m" & Chr(179), 19)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "kPa", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(3, "-", 19)


    '                    Case 2 'Sections (Frame)
    '                        'Field Name Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "key", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "Ax", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "Iz", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(3, "mat", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(4, "descr", 4)
    '                        wbkReport.IncReportRow()

    '                        'Dimension Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "m" & Chr(178), 19)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "m4", 19)
    '                        wbkReport.ReportRange.Offset(0, 2).Characters(2).Font.Superscript = True
    '                        Call wbkReport.wbkWriteHeaderCell(3, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(4, "-", 19)

    '                    Case 3 'Nodes
    '                        'Field Name Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "Node", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "x", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "y", 4)
    '                        wbkReport.IncReportRow()

    '                        'Dimension Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "m", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "m", 19)


    '                    Case 4 'Supports
    '                        'Dimension Row

    '                        'Field Name Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "support", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "jt", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "TransX", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(3, "TransY", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(4, "RotZ", 4)


    '                    Case 5 'Members
    '                        'Dimension Row
    '                        'Field Name Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "member", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "endA", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "endB", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(3, "sect", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(4, "rel_I", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(5, "rel_j", 4)

    '                    Case 6 'Joint/Node Loads
    '                        'Field Name Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "Joint_Load", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "Jt no", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "fx", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(3, "fy", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(4, "mz", 4)
    '                        wbkReport.IncReportRow()

    '                        'Dimension Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "kN", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(3, "kN", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(4, "kNm", 19)

    '                    Case 7 'Member Loads
    '                        'Field Name Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "Memb_Load", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "mb no", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "lcode", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(3, "acode", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(4, "load#1", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(5, "load#2", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(6, "start", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(7, "cover", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(8, "ldtype", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(9, "ldtype", 4)
    '                        wbkReport.IncReportRow()

    '                        'Dimension Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(3, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(4, "kN/m", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(5, "kN/m", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(6, "m", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(7, "m", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(8, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(9, "-", 19)

    '                    Case 8 'Gravity Loads
    '                        'Field Name Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "Grav_Load", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "acode", 4)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "load", 4)
    '                        wbkReport.IncReportRow()

    '                        'Dimension Row
    '                        Call wbkReport.wbkWriteHeaderCell(0, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(1, "-", 19)
    '                        Call wbkReport.wbkWriteHeaderCell(2, "m/s", 19)


    '                End Select

    '                wbkReport.IncReportRow()
    '                wbkReport.ReportRange.Name = tableName

    '                Call ClearDataBlock(wrkSht, CInt(hdrs(i)), CInt(numRecs(i)))

    '            Next i

    '            'Add Tracer Work Sheets
    '            wrkSht = .Worksheets.Add(, .Worksheets(.Worksheets.Count))
    '            wrkSht.Name = "Tracer"
    '            wrkSht = .Worksheets.Add(, .Worksheets(.Worksheets.Count))
    '            wrkSht.Name = "Choleski"
    '            wrkSht = .Worksheets.Add(, .Worksheets(.Worksheets.Count))
    '            wrkSht.Name = "Frm"
    '            wrkSht = .Worksheets.Add(, .Worksheets(.Worksheets.Count))
    '            wrkSht.Name = "MSpan"

    '        End With

    '    End Sub


    '    '------------------------------------------------------------------------------
    '    'EXCEL WORKBOOK REPORTS
    '    '------------------------------------------------------------------------------
    '    Sub wbkControls(ByVal wbkReport As clsWbkReport)

    '        With wbkReport
    '            Call .wbkWriteln("Control Parameters")
    '            Call .wbkWritelnDescrVar("njt", njt)
    '            Call .wbkWritelnDescrVar("nmb", nmb)
    '            Call .wbkWritelnDescrVar("nmg", nmg)
    '            Call .wbkWritelnDescrVar("nsg", nsg)
    '            Call .wbkWritelnDescrVar("nrj", nrj)
    '            Call .wbkWritelnDescrVar("njl", njl)
    '            Call .wbkWritelnDescrVar("nml", nml)
    '            Call .wbkWritelnDescrVar("ngl", ngl)
    '            Call .wbkWritelnDescrVar("nr", nr)
    '            .IncReportRow()
    '        End With

    '    End Sub       '.. Prt_Controls ..

    '    Sub wbkDeltas(ByVal wbkReport As clsWbkReport)

    '        Dim idx1 As Integer, idx2 As Integer, idx3 As Integer

    '        On Error GoTo ErrHandler_wbkDeltas

    '  console.writeLine( "wbkDeltas "

    '        Call wbkReport.wbkWriteln("Displacements")
    '        Call wbkReport.wbkWriteHeaderCell(0, "Node", 4)
    '        Call wbkReport.wbkWriteHeaderCell(1, "X", 4)
    '        Call wbkReport.wbkWriteHeaderCell(2, "Y", 4)
    '        Call wbkReport.wbkWriteHeaderCell(3, "Rotation", 4)
    '        wbkReport.IncReportRow()

    '        Call wbkReport.wbkWriteHeaderCell(1, "m", 19)
    '        Call wbkReport.wbkWriteHeaderCell(2, "m", 19)
    '        Call wbkReport.wbkWriteHeaderCell(3, "rads", 19)

    '        wbkReport.IncReportRow()

    '        For global_i = baseIndex + 1 To njt
    '            '      Prnge.Offset(r, c + 0).Value = global_i
    '            Call wbkReport.wbkWritelnCell(0, global_i)

    '            idx1 = 3 * global_i - 3
    '            idx2 = 3 * global_i - 2
    '            idx3 = 3 * global_i - 1

    '            Call wbkReport.wbkWritelnCell(1, -dj(idx1))
    '            Call wbkReport.wbkWritelnCell(2, -dj(idx2))
    '            Call wbkReport.wbkWritelnCell(3, -dj(idx3))
    '            wbkReport.IncReportRow()

    '            '      r = r + 1
    '        Next global_i

    'Exit_wbkDeltas:
    '        Exit Sub

    'ErrHandler_wbkDeltas:
    '        Close()
    '    console.writeLine( "... wbkDeltas: Exit Errors!"
    '    console.writeLine( Err.Number, Err.Description
    '        '    Resume Exit_wbkDeltas
    '        Stop

    '    End Sub '...wbkDeltas


    '    Sub wbkEndForces(ByVal wbkReport As clsWbkReport)

    '        On Error GoTo ErrHandler_wbkEndForces

    '  console.writeLine( "wbkEndForces "
    '        wbkReport.IncReportRow()
    '        Call wbkReport.wbkWriteln("End Forces")
    '        Call wbkReport.wbkWriteHeaderCell(0, "Member", 4)
    '        Call wbkReport.wbkWriteHeaderCell(1, "Length", 4)
    '        Call wbkReport.wbkWriteHeaderCell(2, "Node A", 4)
    '        Call wbkReport.wbkWriteHeaderCell(3, "Axial", 4)
    '        Call wbkReport.wbkWriteHeaderCell(4, "Shear", 4)
    '        Call wbkReport.wbkWriteHeaderCell(5, "Moment", 4)
    '        Call wbkReport.wbkWriteHeaderCell(6, "Node B", 4)
    '        Call wbkReport.wbkWriteHeaderCell(7, "Axial", 4)
    '        Call wbkReport.wbkWriteHeaderCell(8, "Shear", 4)
    '        Call wbkReport.wbkWriteHeaderCell(9, "Moment", 4)
    '        wbkReport.IncReportRow()

    '        Call wbkReport.wbkWriteHeaderCell(1, "m", 19)

    '        Call wbkReport.wbkWriteHeaderCell(3, "kN", 19)
    '        Call wbkReport.wbkWriteHeaderCell(4, "kN", 19)
    '        Call wbkReport.wbkWriteHeaderCell(5, "kNm", 19)

    '        Call wbkReport.wbkWriteHeaderCell(7, "kN", 19)
    '        Call wbkReport.wbkWriteHeaderCell(8, "kN", 19)
    '        Call wbkReport.wbkWriteHeaderCell(9, "kNm", 19)

    '        wbkReport.IncReportRow()



    '        For global_i = baseIndex To nmb - 1
    '            With con_grp(global_i)

    '                Call wbkReport.wbkWritelnCell(0, global_i + 1)
    '                Call wbkReport.wbkWritelnCell(1, mlen(global_i))
    '                Call wbkReport.wbkWritelnCell(2, .jj)
    '                Call wbkReport.wbkWritelnCell(3, .jnt_jj.axial)
    '                Call wbkReport.wbkWritelnCell(4, .jnt_jj.shear)
    '                Call wbkReport.wbkWritelnCell(5, .jnt_jj.momnt)
    '                Call wbkReport.wbkWritelnCell(6, .jk)
    '                Call wbkReport.wbkWritelnCell(7, .jnt_jk.axial)
    '                Call wbkReport.wbkWritelnCell(8, .jnt_jk.shear)
    '                Call wbkReport.wbkWritelnCell(9, .jnt_jk.momnt)
    '                wbkReport.IncReportRow()

    '            End With
    '            '        r = r + 1
    '        Next global_i

    'Exit_wbkEndForces:
    '        Exit Sub

    'ErrHandler_wbkEndForces:
    '        Close()
    '    console.writeLine( "... wbkEndForces: Exit Errors!"
    '    console.writeLine( Err.Number, Err.Description
    '        '    Resume Exit_wbkEndForces
    '        Stop

    '    End Sub  '...wbkEndForces


    '    Sub wbkReaction_Sum(ByVal wbkReport As clsWbkReport)

    '        Call wbkReport.wbkWriteln("Reaction Sum")

    '        Call wbkReport.wbkWriteHeaderCell(1, "sumx", 4)
    '        Call wbkReport.wbkWriteHeaderCell(2, "sumy", 4)
    '        wbkReport.IncReportRow()

    '        Call wbkReport.wbkWriteHeaderCell(1, "kN", 19)
    '        Call wbkReport.wbkWriteHeaderCell(2, "kN", 19)

    '        wbkReport.IncReportRow()

    '        Call wbkReport.wbkWritelnCell(1, sumx)
    '        Call wbkReport.wbkWritelnCell(2, sumy)
    '        wbkReport.IncReportRow()

    '    End Sub       '.. wbkReaction_Sum ..



    '    Sub wbkReactions(ByVal row1 As Integer, ByVal col1 As Integer, ByVal wbkReport As clsWbkReport)

    '        Dim i As Integer, k As Integer, k3 As Integer, c As Integer, r As Integer

    '        On Error GoTo ErrHandler_wbkReactions

    '    console.writeLine( "wbkReactions "

    '        Call wbkReport.wbkWriteln("Reactions")
    '        Call wbkReport.wbkWriteHeaderCell(0, "Node", 4)
    '        Call wbkReport.wbkWriteHeaderCell(1, "Px", 4)
    '        Call wbkReport.wbkWriteHeaderCell(2, "Py", 4)
    '        Call wbkReport.wbkWriteHeaderCell(3, "Mz", 4)
    '        wbkReport.IncReportRow()

    '        Call wbkReport.wbkWriteHeaderCell(1, "kN", 19)
    '        Call wbkReport.wbkWriteHeaderCell(2, "kN", 19)
    '        Call wbkReport.wbkWriteHeaderCell(3, "kNm", 19)

    '        wbkReport.IncReportRow()


    '        For k = baseIndex To n3 - 1
    '            If rjl(k) = 1 Then ar(k) = ar(k) - fc(Equiv_Ndx(k))
    '        Next k
    '        sumx = 0
    '        sumy = 0

    '        r = wbkReport.ReportR  'row1
    '        For i = baseIndex To nrj - 1
    '            c = 0 'col1 + 1


    '            With sup_grp(i)
    '                Call wbkReport.wbkWritelnCell(c, .js)
    '                flag = 0
    '                c = c + 1
    '                k3 = 3 * .js - 1

    '                For k = k3 - 2 To k3
    '                    If (k + 1) Mod 3 = 0 Then
    '                        Call wbkReport.wbkWritelnCell(c, ar(k))
    '                    Else
    '                        Call wbkReport.wbkWritelnCell(c, ar(k))
    '                        If flag = 0 Then
    '                            sumx = sumx + ar(k)
    '                        Else
    '                            sumy = sumy + ar(k)
    '                        End If
    '                        flag = flag + 1

    '                    End If
    '                    c = c + 1
    '                Next k
    '                flag = 0

    '                r = r + 1
    '                wbkReport.IncReportRow()
    '            End With

    '        Next i

    '        Call wbkReaction_Sum(wbkReport)

    'Exit_wbkReactions:
    '        Exit Sub

    'ErrHandler_wbkReactions:
    '        Close()
    '    console.writeLine( "... wbkReactions: Exit Errors!"
    '    console.writeLine( Err.Number, Err.Description
    '        '    Resume Exit_wbkReactions
    '        Stop

    '    End Sub '...PrtReactions

    '    Sub wbkSection_Details(ByVal r As Integer, ByVal c As Integer, ByVal wbkReport As clsWbkReport)
    '  console.writeLine( "wbkSection_Details "

    '        Call wbkReport.wbkWriteln("Section Details")
    '        Call wbkReport.wbkWriteHeaderCell(0, "i", 4)
    '        Call wbkReport.wbkWriteHeaderCell(1, "Length", 4)
    '        Call wbkReport.wbkWriteHeaderCell(2, "Mass", 4)
    '        Call wbkReport.wbkWriteHeaderCell(3, "Descr", 4)
    '        wbkReport.IncReportRow()

    '        Call wbkReport.wbkWriteHeaderCell(1, "m", 19)
    '        Call wbkReport.wbkWriteHeaderCell(2, "kg", 19)


    '        wbkReport.IncReportRow()

    '        r = wbkReport.ReportR
    '        For global_i = baseIndex To nmg - 1
    '            Call wbkReport.wbkWritelnCell(0, global_i)
    '            Call wbkReport.wbkWritelnCell(1, sec_grp(global_i).t_len)
    '            Call wbkReport.wbkWritelnCell(2, sec_grp(global_i).t_mass)
    '            Call wbkReport.wbkWritelnCell(3, sec_grp(global_i).Descr)
    '            r = r + 1
    '            wbkReport.IncReportRow()
    '        Next global_i
    '    End Sub '...wbkSection_Details


    '    Sub wbkSpanMoments(ByVal wbkReport As clsWbkReport)
    '        Dim r As Integer
    '        Dim c As Integer
    '        Dim seg As Double
    '        Dim Prnge As Range

    '        On Error GoTo ErrHandler_wbkSpanMoments


    '  console.writeLine( "wbkSpanMoments "
    '        Call wbkReport.wbkWriteln("Span Moments")
    '        Call wbkReport.wbkWriteHeaderCell(0, "i", 4)
    '        Call wbkReport.wbkWriteHeaderCell(1, "Length", 4)
    '        Call wbkReport.wbkWriteHeaderCell(2, "Moment", 4)
    '        wbkReport.IncReportRow()

    '        Call wbkReport.wbkWriteHeaderCell(1, "m", 19)
    '        Call wbkReport.wbkWriteHeaderCell(2, "kNm", 19)


    '        wbkReport.IncReportRow()

    '        r = 7
    '        c = 1

    '        For global_i = baseIndex To nmb - 1
    '            seg = mlen(global_i) / n_segs
    '            Call wbkReport.wbkWritelnCellColoured(1, global_i + 1, 4)
    '            wbkReport.IncReportRow()
    '            r = r + 1
    '            For global_j = startZero To n_segs
    '                Call wbkReport.wbkWritelnCell(0, global_j)
    '                Call wbkReport.wbkWritelnCell(1, global_j * seg)
    '                Call wbkReport.wbkWritelnCell(2, mom_spn(global_i, global_j))
    '                r = r + 1
    '                wbkReport.IncReportRow()
    '            Next global_j

    '            wbkReport.IncReportRow()
    '            r = 7
    '            c = c + 3
    '        Next global_i

    'Exit_wbkSpanMoments:
    '        Exit Sub

    'ErrHandler_wbkSpanMoments:
    '        Close()
    '    console.writeLine( "... wbkSpanMoments: Exit Errors!"
    '    console.writeLine( Err.Number, Err.Description
    '        '    Resume Exit_wbkSpanMoments
    '        Stop

    '    End Sub  '...wbkSpanMoments


    '    Sub wbkReportAnalysisResults(ByVal reportBk As Workbook)
    '        Dim wbkReport As New clsWbkReport

    '        On Error GoTo ErrHandler_wbkReportAnalysisResults

    '  console.writeLine( "wbkReportAnalysisResults "

    '        Call wbkReport.SetReportWrkBk(False, "Report")

    '        '  Call ClearOutputSheet("b19:u35")
    '        Call wbkControls(wbkReport)
    '        Call wbkDeltas(wbkReport)
    '        Call wbkEndForces(wbkReport)
    '        Call wbkReactions(18, 16, wbkReport)
    '        Call wbkSection_Details(5, 6, wbkReport)

    '        Call wbkSpanMoments(wbkReport)

    'Exit_wbkReportAnalysisResults:
    '        Exit Sub

    'ErrHandler_wbkReportAnalysisResults:
    '        Close()
    '    console.writeLine( "... wbkReportAnalysisResults: Exit Errors!"
    '    console.writeLine( Err.Number, Err.Description
    '        '    Resume Exit_wbkReportAnalysisResults
    '        Stop

    '    End Sub   '..wbkReportAnalysisResults











    '------------------------------------------------------------------------------
    'REPORTS: Text Files
    '------------------------------------------------------------------------------

    '    <<< fprintDeltas >>>
    Sub fprintDeltas(ByVal fpRpt As Integer)
        Dim txt1, txt2, txt3, txt4
        Dim idx1, idx2, idx3

        Console.WriteLine("fprintDeltas ...")
        PrintLine(fpRpt, "fprintDeltas ...")
        For global_i = baseIndex + 1 To GModel.structParam.njt
            txt1 = StrLPad(Format(global_i, "0"), 4)

            idx1 = 3 * global_i - 3
            idx2 = 3 * global_i - 2
            idx3 = 3 * global_i - 1

            txt2 = StrLPad(Format(-dj(idx1), "0.0000"), 8)
            txt3 = StrLPad(Format(-dj(idx2), "0.0000"), 8)
            txt4 = StrLPad(Format(-dj(idx3), "0.0000"), 8)

            PrintLine(fpRpt, txt1 + " " + txt2 + " " + txt3 + " " + txt4)

        Next global_i

        PrintLine(fpRpt)
        Console.WriteLine("... fprintDeltas")
    End Sub '...fprintDeltas

    '   <<< fprintEndForces >>>
    Sub fprintEndForces(ByVal fpRpt As Integer)
        Dim txt0, txt1, txt2, txt3, txt4, txt5 As String
        Dim txt6, txt7, txt8, txt9, txt As String
        Dim i As Integer

        Console.WriteLine("fprintEndForces ...")
        PrintLine(fpRpt, "fprintEndForces ...")
        For i = baseIndex To GModel.structParam.nmb - 1
            txt0 = StrLPad(i.ToString(), 8)
            txt1 = StrLPad(Format(mlen(i), "0.000"), 8)

            txt2 = StrLPad(Format(GModel.con_grp(i).jj, "0"), 8)
            txt3 = StrLPad(Format(GModel.con_grp(i).jnt_jj.axial, "0.0000"), 15)
            txt4 = StrLPad(Format(GModel.con_grp(i).jnt_jj.shear, "0.0000"), 15)
            txt5 = StrLPad(Format(GModel.con_grp(i).jnt_jj.momnt, "0.0000"), 15)

            txt6 = StrLPad(Format(GModel.con_grp(i).jk, "0"), 8)
            txt7 = StrLPad(Format(GModel.con_grp(i).jnt_jk.axial, "0.0000"), 15)
            txt8 = StrLPad(Format(GModel.con_grp(i).jnt_jk.shear, "0.0000"), 15)
            txt9 = StrLPad(Format(GModel.con_grp(i).jnt_jk.momnt, "0.0000"), 15)

            txt = txt0 + " " + txt1 + " " + txt2 + " " + txt3 + " " + txt4 + " " + txt5
            txt = txt + " " + txt6 + " " + txt7 + " " + txt8 + " " + txt9
            PrintLine(fpRpt, txt)
        Next i

        PrintLine(fpRpt)
        Console.WriteLine("... fprintEndForces")
    End Sub '...fprintEndForces

    '    << fprint_Reaction_Sum >>
    Sub fprint_Reaction_Sum(ByVal fpRpt As Integer)
        Dim txt0, txt1

        PrintLine(fpRpt, "fprint_Reaction_Sum ...")
        txt0 = StrLPad(Format(sumx, "0.0000"), 15)
        txt1 = StrLPad(Format(sumy, "0.0000"), 15)
        PrintLine(fpRpt, txt0 + " " + txt1)
        PrintLine(fpRpt)

    End Sub '.. fprint_Reaction_Sum ..

    '    <<< fprintReactions >>>
    Sub fprintReactions(ByVal fpRpt As Integer)
        Dim i, k, k3, c, r
        Dim txt0, txt1, txt2

        Console.WriteLine("fprintReactions ...")
        PrintLine(fpRpt, "fprintReactions ...")

        For k = baseIndex To n3 - 1
            If (rjl(k) = 1) Then
                ar(k) = ar(k) - fc(Equiv_Ndx(k))
            End If
        Next k
        sumx = 0
        sumy = 0

        For i = baseIndex To GModel.structParam.nrj-1


            txt0 = GModel.sup_grp(i).js
            flag = 0
            k3 = 3 * GModel.sup_grp(i).js - 1
            For k = k3 - 2 To k3
                If ((k + 1) Mod 3 = 0) Then
                    txt1 = StrLPad(Format(ar(k), "0.0000"), 15)
                    Print(fpRpt, txt1)
                Else
                    txt2 = StrLPad(Format(ar(k), "0.0000"), 15)
                    Print(fpRpt, txt2)
                    If (flag = 0) Then
                        sumx = sumx + ar(k)
                    Else
                        sumy = sumy + ar(k)
                    End If
                    flag = flag + 1
                End If
            Next k
            flag = 0

            PrintLine(fpRpt)

        Next i

        fprint_Reaction_Sum(fpRpt)

        Print(fpRpt)
        Console.WriteLine("... fprintReactions")

    End Sub '...fprintReactions

    '    << fprint_Controls >>
    Sub fprint_Controls(ByVal fpRpt As Integer)
        Dim txt1, txt2, txt3, txt4, txt5 As String
        Dim txt6, txt7, txt8, txt9, txt As String

        PrintLine(fpRpt, "fprint_Controls ...")
        txt1 = GModel.structParam.njt
        txt2 = GModel.structParam.nmb
        txt3 = GModel.structParam.nmg
        txt4 = GModel.structParam.nsg
        txt5 = GModel.structParam.nrj
        txt6 = GModel.structParam.njl
        txt7 = GModel.structParam.nml
        txt8 = GModel.structParam.ngl
        txt9 = GModel.structParam.nr

        txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4 + " " + txt5
        txt = txt + " " + txt6 + " " + txt7 + " " + txt8 + " " + txt9
        PrintLine(fpRpt, txt)
        PrintLine(fpRpt)

    End Sub '.. fprint_Controls ..

    '    <<< fprint_Section_Details >>>
    Sub fprint_Section_Details(ByVal fpRpt As Integer)
        Dim txt1, txt2, txt3, txt4 As String
        Dim txt As String
        Dim i As Integer

        Console.WriteLine("fprint_Section_Details ...")
        PrintLine(fpRpt, "fprint_Section_Details ...")
        For i = baseIndex To GModel.structParam.nmg-1

            txt1 = StrLPad(i, 8)
            txt2 = StrLPad(Format(GModel.sec_grp(i).t_len, "0"), 8)
            txt3 = "<>"
            txt4 = StrLPad(GModel.sec_grp(i).Descr, 8)
            txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4
            PrintLine(fpRpt, txt)

        Next i

        PrintLine(fpRpt)
        Console.WriteLine("... fprint_Section_Details")
    End Sub '...fprint_Section_Details

    '   <<< fprintSpanMoments >>>
    Sub fprintSpanMoments(ByVal fpRpt As Integer)
        Dim seg As Double
        Dim tmp As Double

        Dim txt1, txt2, txt3, txt4 As String
        Dim txt As String
        Dim i As Integer, j As Integer

        Console.WriteLine("fprintSpanMoments ...")
        PrintLine(fpRpt, "fprintSpanMoments ...")
        '  MiWrkBk.Worksheets("MSpan").Activate
        '  Set Prnge = MiWrkBk.Worksheets("MSpan").Range("A1:A1")


        For i = baseIndex To GModel.structParam.nmb - 1
            seg = mlen(i) / n_segs
            txt1 = StrLPad(Format(i, "0"), 8)
            For j = 0 To n_segs
                txt2 = StrLPad(Format(j, "0"), 8)

                tmp = j * seg
                tmp = Format(tmp, "0.000")
                txt3 = StrLPad(tmp, 8)
                txt4 = StrLPad(Format(mom_spn(i, j), "0.0000"), 15)

                txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4
                PrintLine(fpRpt, txt)

            Next j
            PrintLine(fpRpt)
        Next i

        PrintLine(fpRpt)
        Console.WriteLine("... fprintSpanMoments")
    End Sub

    '<< Output Results to Table >>
    Sub fPrintResults(ByVal fpRpt As Integer)
        Console.WriteLine("PrintResults ...")
        fprint_Controls(fpRpt)
        fprintDeltas(fpRpt)
        fprintEndForces(fpRpt)
        fprintReactions(fpRpt)
        fprint_Section_Details(fpRpt)
        fprintSpanMoments(fpRpt)
        Console.WriteLine("... PrintResults")
    End Sub

End Class
