'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'INTERFACE
'-------------------------------------------------------------------------------


'Option Explicit
'Option Base 

#include once "clsGeomModel.bi"
#include once "xarray.bi"


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
Const n_segs As Byte = 10 '7

Const mega As Double = 1000000
Const kilo As Double = 1000
Const cent As Double = 100

Const tolerance As Double = 0.0001
Const infinity As Double = 2.0E+20
Const neg_slope As Integer = 1
Const pos_slope As Integer = -1




'------------------------------------------------------------------------------
'INTERFACE
'------------------------------------------------------------------------------

'Structural Parameters
'Public njt As Integer        '.. No. of joints ..
'Public nmb As Integer        '.. No. of members ..
'Public nmg As Integer        '.. No. of material groups ..
'Public nsg As Integer        '.. No. of member section groups ..
'Public nrj As Integer        '.. No. of supported reaction joints ..
'Public njl As Integer        '.. No. of loaded joints ..
'Public nml As Integer        '.. No. of loaded members ..
'Public ngl As Integer        '.. No. of gravity load cases .. Self weight
'Public nr  As Integer        '.. No. of restraints @ the supports ..

'Variable declarations

'Dim mat_grp(max_mats) As material_rec
'Dim sec_grp(max_grps) As section_rec
'Dim nod_grp(max_grps) As coord_rec
'Dim con_grp(max_grps) As connect_rec
'Dim sup_grp(max_grps) As support_rec
'Dim jnt_lod(numloads) As jnt_ld_rec
'Dim mem_lod(numloads) As mem_ld_rec
'Dim grv_lod           As grv_ld_rec

Dim shared global_i As Integer
Dim shared global_j As Integer
Dim shared global_k As Integer



Type PlaneFrame
	Public: GModel As clsGeomModel
	Public: fpTracer As Integer
	Public: data_loaded As Boolean

	Public: sumx As Double
	Public: sumy As Double


    Public: poslope As Boolean

	'------------------------------------------------------------------------------
	'IMPLEMENTATION
	'------------------------------------------------------------------------------
	'Dim schTrace2 As New debugTracer
	'Dim schTrace3 As New debugTracer


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

	Dim maxM As Double
	Dim MinM As Double
	Dim MaxMJnt As Byte
	Dim maxMmemb As Byte
	Dim MinMJnt As Byte
	Dim MinMmemb As Byte
	Dim maxA As Double
	Dim MinA As Double
	Dim MaxAJnt As Byte
	Dim maxAmemb As Byte
	Dim MinAJnt As Byte
	Dim MinAmemb As Byte
	Dim maxQ As Double
	Dim MinQ As Double
	Dim MaxQJnt As Byte
	Dim maxQmemb As Byte
	Dim MinQJnt As Byte
	Dim MinQmemb As Byte

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

	'Dim mom_spn(max_grps, ndx0 To n_segs) As Double  '.. member span moments ..
    Dim mom_spn(max_grps, n_segs) As Double  '.. member span moments ..
	
	
	Declare  Sub Choleski_Decomposition(sj() As Double, ByVal ndof As Integer, ByVal hbw As Integer)
	Declare  Sub Solve_Displacements()
	Declare Function getArrayIndex(key as integer) As Integer
	Declare  Sub Fill_Restrained_Joints_Vector()
	Declare  Function End_J() As Boolean
	Declare  Function End_K() As Boolean
	Declare  Sub Calc_Bandwidth()
	Declare  Sub Get_Stiff_Elements(i As Integer)
	Declare  Sub Assemble_Stiff_Mat(i As Integer)
	Declare  Sub Assemble_Global_Stiff_Matrix(i As Integer)
	Declare  Sub Load_Sj(ByVal j As Byte, ByVal kk As Byte, ByVal stiffval As Double)
	Declare  Sub Process_DOF_J1()
	Declare  Sub Process_DOF_J2()
	Declare  Sub Process_DOF_J3()
	Declare  Sub Process_DOF_K1()
	Declare  Sub Process_DOF_K2()
	Declare  Sub Process_DOF_K3()
	Declare  Sub Assemble_Struct_Stiff_Matrix(i As Integer)
	Declare  Sub Calc_Member_Forces()
	Declare  Sub Calc_Joint_Displacements()
	Declare  Sub Get_Span_Moments()
	Declare  Function In_Cover(ByVal x1 As Double, ByVal x2 As Double, ByVal mlen As Double) As Boolean
	Declare  Sub Calc_Moments(ByVal mn As Byte, ByVal mlen As Double, ByVal wtot As Double, ByVal x1 As Double, ByVal la As Double, ByVal cv As Double, ByVal wty As Byte,ByVal lslope As Integer)
	Declare  Sub Combine_Joint_Loads(kMember As Byte)
	Declare  Sub Calc_FE_Forces(ByVal kMember As Byte, ByVal la As Double, ByVal lb As Double)
	Declare  Sub Accumulate_FE_Actions(ByVal kMemberNum As Byte)
	Declare  Sub Process_FE_Actions(ByVal kMemberNum As Byte, ByVal la As Double, ByVal lb As Double)
	Declare  Sub Do_Global_Load(ByVal mem As Byte, ByVal acd As Byte, ByVal w0 As Double, ByVal start As Double)
	Declare  Sub Do_Axial_Load(ByVal mno As Byte, ByVal wu As Double, ByVal x1 As Double)
	Declare  Sub Do_Self_Weight(mem As Integer)
	Declare  Function UDL_Slope(w0 As Double, v As Double, c As Double) As Double
	Declare  Sub Do_Part_UDL(ByVal mno As Double, ByVal wu As Double, ByVal x1 As Double, ByVal cv As Double, wact As Byte)
	Declare  Function PL_Slope(v As Double) As Double
	Declare  Sub Do_Point_load(ByVal mno As Double, ByVal wu As Double, ByVal x1 As Double, wact As Byte)
	Declare  Function Tri_Slope(ByVal v As Double, ByVal w_nrm As Double, ByVal cv As Double,ByVal sl_switch As Integer) As Double
	Declare  Sub Do_Triangle(ByVal mno As Double, ByVal w0 As Double, ByVal la As Double, ByVal x1 As Double, ByVal cv As Double, wact As Byte, ByVal slopedir As Integer)
	Declare  Sub Do_Distributed_load(ByVal mno As Byte, ByVal wm1 As Double, ByVal wm2 As Double, ByVal x1 As Double, ByVal cv As Double, lact As Byte)
	Declare  Sub Get_FE_Forces(ByVal kMemberNum As Byte, ByVal ldty As Byte, ByVal wm1 As Double,ByVal wm2 As Double, ByVal x1 As Double, ByVal cvr As Double, lact As Byte)
	Declare  Sub Process_Loadcases()
	Declare Sub Zero_Vars()
	Declare Sub initialise()
	Declare  Function Translate_Ndx(ByVal i As Byte) As Integer
	Declare  Function Equiv_Ndx(ByVal j As Byte) As Integer
	Declare  Sub Get_Joint_Indices(ByVal nd As Byte)
	Declare  Sub Get_Direction_Cosines()
	Declare  Sub Total_Section_Mass()
	Declare  Sub Total_Section_Length()
	Declare  Sub Get_Min_Max()
	Declare Sub Analyse_Frame()
	Declare Sub ClearOutputSheet(ByVal clrng As String)
	Declare Sub PrtSpanMoments()
	Declare Sub PrintResults()
	Declare Sub addNode(x As Double, y As Double)
	Declare Sub addMaterialGroup(density As Double, ElasticModulus As Double, CoeffThermExpansion As Double)
	Declare Sub addSectionGroup(SectionArea As Double, SecondMomentArea As Double, materialKey As Integer, Description As String)
	Declare Sub addMember(NodeA As Integer, NodeB As Integer, sectionKey As Integer, ReleaseA As Integer, ReleaseB As Integer)
	Declare Sub addSupport(SupportNode As Integer, RestraintX As Byte, RestraintY As Byte, RestraintMoment As Byte)
	Declare Sub addJointLoad(Node As Integer, ForceX As Double, ForceY As Double, Moment As Double)
	Declare Sub addMemberLoad(memberKey As Integer, LoadType As Integer, ActionKey As Integer, LoadMag1 As Double, LoadMag2 As Double, LoadStart As Double, LoadCover As Double)
	Declare Sub addGravityLoad(ActionKey As Integer, LoadMag As Double)
	Declare Sub GetData()
	Declare Sub Archive_Data(fp as integer)
	Declare Function isDataBlockHeaderString(s As String) As Boolean
	Declare Sub fgetJobData(fp as integer)
	Declare Sub fgetControlData(fp as integer)
	Declare Sub fgetNodeData(fp as integer, lastTxtStr As String)
	Declare Sub fgetMemberData(fp as integer, lastTxtStr As String)
	Declare Sub fgetSupportData(fp as integer, lastTxtStr As String)
	Declare Sub fgetMaterialData(fp as integer, lastTxtStr As String)
	Declare Sub fgetSectionData(fp as integer, lastTxtStr As String)
	Declare Sub fgetJointLoadData(fp as integer, lastTxtStr As String)
	Declare Sub fgetMemberLoadData(fp as integer, lastTxtStr As String)
	Declare Sub fgetGravityLoadData(fp as integer, lastTxtStr As String)

	'Printing
	Declare Sub Read_Data(fp As integer)
	Declare Sub fprintDeltas(fpRpt As integer)
	Declare Sub fprintEndForces(fpRpt As integer)
	Declare Sub fprint_Reaction_Sum(fpRpt As integer)
	Declare Sub fprintReactions(fpRpt As integer)
	Declare Sub fprint_Controls(fpRpt As integer)
	Declare Sub fprint_Section_Details(fpRpt As integer)
	Declare Sub fprintSpanMoments(fpRpt As integer)
	Declare Sub fPrintResults(fpRpt As integer)

End Type



'------------------------------------------------------------------------------
'CLASS: PROPERTIES
'------------------------------------------------------------------------------
'Property Get SectionGroup(item As Integer) As clsPfSection  'section_rec
'  Set SectionGroup = GModel.sec_grp(item)
'End Property
'
'Property Get MemberProp(item As Integer) As clsPfConnectivity  'connect_rec
'  Set MemberProp = GModel.con_grp(item)
'End Property
'
'Property Get SupportProp(item As Integer) As clsPfSupport  'support_rec
'  Set SupportProp = GModel.sup_grp(item)
'End Property



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
Sub PlaneFrame.Choleski_Decomposition(sj() As Double, ByVal ndof As Integer, ByVal hbw As Integer)
    Dim p As Integer, q As Integer
    Dim su As Double, te As Double

    Dim indx1 As Integer, indx2 As Integer, indx3 As Integer
    '    WrMat("Decompose IN sj ..", sj, ndof, hbw)
    '    PrintMat("Choleski_Decomposition  IN sj() ..", sj(), dd(), ndof, hbw)

    Dim r As Integer, c As Integer

    On Error GoTo ErrHandler_Choleski_Decomposition

    print "Choleski_Decomposition ..."
    print "ndof, hbw", ndof, hbw

    '     schTrace2.wbkWriteCell(0, 0, "p")
    '     schTrace2.wbkWriteCell(0, 1, "q")
    '     schTrace2.wbkWriteCell(0, 2, "i")
    '     schTrace2.wbkWriteCell(0, 3, "j")
    '     schTrace2.wbkWriteCell(0, 4, "k")
    '
    '     schTrace2.wbkWriteCell(0, 17, "indx1")
    '     schTrace2.wbkWriteCell(0, 18, "indx2")
    '     schTrace2.wbkWriteCell(0, 19, "indx3")


    r = 1
    c = 0


    For global_i = baseIndex To ndof - 1 'From first to last index of array: rows of matrix
        print "global_i=", global_i

        'Trace Change to Matrix
        '         schTrace2.wbkWriteln("SJ[]: " & Format(global_i, "#"))
        '         schTrace2.wbkWriteMatrix(sj)


        p = ndof - global_i - 1                            '+ 1 'convert index to compact form of banded matrix
        If p > hbw - 1 Then p = hbw - 1
        print "p=", p

        '         schTrace2.wbkWriteCell(r, 2, global_i)
        '         schTrace2.wbkWriteCell(r, 0, p)

        For global_j = baseIndex To p

            q = (hbw - 2) - global_j        'convert index to compact form of banded matrix
            If q > global_i - 1 Then q = global_i - 1
            print "q=", q

            '             schTrace2.wbkWriteCell(r, 3, global_j)
            '             schTrace2.wbkWriteCell(r, 1, q)


            su = sj(global_i, global_j)
            '             schTrace2.wbkWriteCell(r, 10, sj(global_i, global_j))
            print "su = ", su

            If q >= 0 Then 'valid array index and not first element of array
                '              print "Testing: Valid Array Index"
                For global_k = baseIndex To q
                    '                 schTrace2.wbkWriteCell(r, 4, global_k)
                    If global_i > global_k Then
                        'Calculate sum
                        '                  su = su - sj(global_i - global_k, global_k + 1) * sj(global_i - global_k, global_k + global_j)
                        '                   schTrace2.wbkWriteCell(r, 5, su)
                        '                   schTrace2.wbkWriteCellColoured(r, 6, sj(global_i - global_k, global_k + 1), 4)
                        '                   schTrace2.wbkWriteCellColoured(r, 7, sj(global_i - global_k, global_k + global_j), 4)

                        indx1 = global_i - global_k - 1
                        indx2 = global_k + 1
                        indx3 = global_k + global_j + 1
                        su = su - sj(indx1, indx2) * sj(indx1, indx3)
                        '                   schTrace2.wbkWriteCell(r, 5, su)
                        '                   schTrace2.wbkWriteCellColoured(r, 6, sj(indx1, indx2), 4)
                        '                   schTrace2.wbkWriteCellColoured(r, 7, sj(indx1, indx3), 4)
                        '                   schTrace2.wbkWriteCell(r, 17, indx1)
                        '                   schTrace2.wbkWriteCell(r, 18, indx2)
                        '                   schTrace2.wbkWriteCell(r, 19, indx3)
                    End If
                    r = r + 1
                Next global_k
            End If

            If global_j <> 0 Then 'Not First Element of array
                sj(global_i, global_j) = su * te
                '              sj(global_i, global_j) = 999 'testing
                '               schTrace2.wbkWriteCellColoured(r, 8, sj(global_i, global_j), 7)
            Else 'is first element
                If su <= 0 Then
                    'MsgBox ("Choleski_Decomposition: matrix -ve TERM Terminated ???")
                    print "Choleski_Decomposition: matrix -ve TERM Terminated ???"
                    print "Cannot find square root of negative number"
                    print "su = ", su
                    print "global_i, global_j : ", global_i, global_j

                    'Err.Clear()
                    'Err.Raise(vbObjectError + 1001, , "Attempt to pass Negative Number to Square Root Function")


                Else 'First Element
                    '                print "Testing Index: su>0"
                    te = 1 / Sqr(su)

                    '                te = 1 'testing
                    sj(global_i, global_j) = te                        'Over write original matrix
                    print "te = ", te
                    '                 schTrace2.wbkWriteCellColoured(r, 8, sj(global_i, global_j), 22)
                End If ' Check postive value for su

            End If 'Processing array items

            r = r + 1
        Next global_j


        Print #fpTracer, "SJ[]: " & Format(global_i, "0")
        fprintMatrix(fpTracer,sj())

        r = r + 1
    Next global_i

    '   PrintMat("Choleski_Decomposition  OUT sj() ..", sj(), dd(), ndof, hbw)

    print "... Choleski_Decomposition"

Exit_Choleski_Decomposition:
    Exit Sub

ErrHandler_Choleski_Decomposition:
    Close
    print "--------------------------------------------------------------"
    print "ERRORS: "
    print "--------------------------------------------------------------"
    print "... Choleski_Decomposition: Exit Errors!"
    'print Err.Number - vbObjectError, Err.Description)
    'Err.Clear()
    print "--------------------------------------------------------------"
    '    Resume Exit_Choleski_Decomposition
    Stop

End Sub  '.. Choleski_Decomposition ..


'<< Solve_Displacements >>
'.. perform forward and backward substitution to solve the system ..
Sub PlaneFrame.Solve_Displacements()
    Dim su As Double
    Dim i As Integer, j As Integer
    Dim idx1 As Integer, idx2 As Integer

    '     schTrace.wbkWriteln("Solve_Displacement:1 [" & Format(nn, "0") & "]")
    For i = baseIndex To nn - 1
        j = i + 1 - hbw
        If j < 0 Then j = 0
        su = fc(i)

        If j - i + 1 <= 0 Then
            For global_k = j To i - 1
                If i - global_k + 1 > 0 Then

                    idx1 = i - global_k '+ 1
                    su = su - sj(global_k, idx1) * dd(global_k)

                    '             schTrace.wbkWritelnCell(0, i)
                    '             schTrace.wbkWritelnCell(1, j)
                    '             schTrace.wbkWritelnCell(2, global_k)
                    '             schTrace.wbkWritelnCell(3, idx1)
                    '             schTrace.wbkWritelnCell(4, sj(global_k, idx1))
                    '             schTrace.wbkWritelnCell(5, su)

                End If
            Next global_k
        End If
        dd(i) = su * sj(i, 0)

        '       schTrace.wbkWritelnCell(6, dd(i))
        '       schTrace.wbkWritelnCell(7, sj(i, 0))
        '      schTrace.IncTracerRow
    Next i


    '    schTrace.wbkWriteln ("Solve_Displacement:1")
    For i = (nn - 1) To baseIndex Step -1
        j = i + hbw - 1
        If j > (nn - 1) Then j = nn - 1

        su = dd(i)
        If i + 1 <= j Then
            For global_k = i + 1 To j
                If global_k + 1 > i Then

                    idx2 = global_k - i
                    su = su - sj(i, idx2) * dd(global_k)

                    '             schTrace.wbkWritelnCell(0, i)
                    '             schTrace.wbkWritelnCell(1, j)
                    '             schTrace.wbkWritelnCell(2, global_k)
                    '             schTrace.wbkWritelnCell(3, idx2)
                    '             schTrace.wbkWritelnCell(4, sj(i, idx2))
                    '             schTrace.wbkWritelnCell(5, su)

                End If
            Next global_k
        End If

        dd(i) = su * sj(i, 0)

        '       schTrace.wbkWritelnCell(6, dd(i))
        '       schTrace.wbkWritelnCell(7, sj(i, 0))
        '      schTrace.IncTracerRow
    Next i


    '       WrFVector("Solve Displacements  dd..  ", dd(), nn)
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

Function PlaneFrame.getArrayIndex(key As Integer) As Integer
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
Sub PlaneFrame.Fill_Restrained_Joints_Vector()
    n3 = 3 * GModel.structParam.njt
    nn = n3 - GModel.structParam.nr

    For global_i = baseIndex To GModel.structParam.nrj - 1
        With GModel.sup_grp(global_i)
            j3 = (3 * .js) - 1
            rjl(j3 - 2) = .rx
            rjl(j3 - 1) = .ry
            rjl(j3) = .rm
            print "rjl.. ", rjl(j3 - 2), rjl(j3 - 1), rjl(j3)
        End With
    Next global_i
    crl(baseIndex) = rjl(baseIndex)

    For global_i = baseIndex + 1 To n3 - 1
        crl(global_i) = crl(global_i - 1) + rjl(global_i)
        print "crl.. ", crl(global_i)
    Next global_i

    print "Fill_Restrained_Joints_Vector n3, nn, nr .. ", n3, nn, GModel.structParam.nr

End Sub  '.. Fill_Restrained_Joints_Vector ..


'<< Check_J >>
Function PlaneFrame.End_J() As Boolean
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
Function PlaneFrame.End_K() As Boolean
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
Sub PlaneFrame.Calc_Bandwidth()
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

            If Not End_J Then
                If Not End_K Then
                    diff = Translate_Ndx(global_k) - Translate_Ndx(global_j) + 1
                End If
            End If

            If diff > hbw Then
                hbw = diff
            End If

        End With
    Next global_i

    print "Calc_Bandwidth hbw, nn .. ", hbw, nn

End Sub  '.. Calc_Bandwidth ..


'<< Get_Stiff_Elements >>
Sub PlaneFrame.Get_Stiff_Elements(i As Integer)
    Dim flag As Byte, msect As Integer, mnum As Integer
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
Sub PlaneFrame.Assemble_Stiff_Mat(i As Integer)

    print "Assemble_Stiff_Mat ..."

    Get_Stiff_Elements(i)

    print "eaol: ", eaol
    print "cosa: ", cosa
    print "sina: ", sina
    print "ccl: ", ccl
    print "ci: ", ci
    print "cj: ", cj
    print "ai: ", ai
    print "ao2: ", ao2
    print "aj: ", aj

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

    '  '   PrintMat("Assemble_Stiff_Mat   s () ..", s, dd(), 6, 6)

    print "... Assemble_Stiff_Mat"

End Sub  '.. Assemble_Stiff_Mat ..

'<< Assemble_Global_Stiff_Matrix >>
Sub PlaneFrame.Assemble_Global_Stiff_Matrix(i As Integer)

    print "Assemble_Global_Stiff_Matrix ..."

    Get_Stiff_Elements(i)

    c2 = cosa * cosa
    s2 = sina * sina
    cs = cosa * sina

    '  print "eaol :", eaol
    '  print "cosa :", cosa
    '  print "sina :", sina
    '
    '  print "c2 :", c2
    '  print "s2 :", s2
    '  print "cs :", cs
    '  print "ccl :", ccl
    '  print "ci :", ci
    '  print "cj :", cj
    '  print "ai :", ai
    '  print "ao2 :", ao2
    '  print "aj :", aj
    '  print "-----------------------"

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

    '  '   PrintMat("Assemble_Global_Stiff_Matrix   s () ..", s, dd(), 6, 6)

    print "... Assemble_Global_Stiff_Matrix"


End Sub  '.. Assemble_Global_Stiff_Matrix ..

'<< Load_Sj >>
Sub PlaneFrame.Load_Sj(ByVal j As Byte, ByVal kk As Byte, ByVal stiffval As Double)
    print "Load_Sj: ", j, kk, stiffval
    '     schTrace3.wbkWriteln("Load_Sj")
    global_k = Translate_Ndx(kk) - j '+ 1
    '     schTrace3.wbkWritelnCell(11, global_k)
    '
    '     schTrace3.wbkWritelnCell(13, sj(j, global_k))

    sj(j, global_k) = sj(j, global_k) + stiffval

    '     schTrace3.wbkWritelnCell(14, sj(j, global_k))
    '     schTrace3.wbkWritelnCell(15, stiffval)
    '
    '     schTrace3.wbkWritelnCell(18, j)
    '     schTrace3.wbkWritelnCell(19, global_k)

End Sub  '.. Load_Sj ..

'<< Process_DOF_J1 >>
Sub PlaneFrame.Process_DOF_J1()
    print "Process_DOF_J1 ..."
    '     schTrace3.wbkWriteln("Process_DOF_J1")
    global_j = Translate_Ndx(j1)
    '     schTrace3.wbkWritelnCell(10, global_j)
    '
    '     schTrace3.wbkWritelnCell(13, sj(global_j, df1))
    sj(global_j, df1) = sj(global_j, df1) + s(df1, df1)
    '     schTrace3.wbkWritelnCell(14, sj(global_j, df1))
    '     schTrace3.wbkWritelnCell(15, s(df1, df1))
    '
    '     schTrace3.wbkWritelnCell(18, global_j)
    '     schTrace3.wbkWritelnCell(19, df1)
    '    schTrace3.IncTracerRow

    If rjl(j2) = 0 Then
        '      schTrace3.IncTracerRow
        '       schTrace3.wbkWritelnCell(13, sj(global_j, df2))
        sj(global_j, df2) = sj(global_j, df2) + s(df1, df2)
        '       schTrace3.wbkWritelnCell(14, sj(global_j, df2))
        '       schTrace3.wbkWritelnCell(15, s(df1, df2))
    End If

    If rjl(j3) = 0 Then
         Load_Sj(global_j, j3, s(df1, df3))
    End If

    If rjl(k1) = 0 Then
         Load_Sj(global_j, k1, s(df1, df4))
    End If

    If rjl(k2) = 0 Then
         Load_Sj(global_j, k2, s(df1, df5))
    End If

    If rjl(k3) = 0 Then
         Load_Sj(global_j, k3, s(df1, df6))
    End If

End Sub  '.. Process_DOF_J1 ..

'<< Process_DOF_J2 >>
Sub PlaneFrame.Process_DOF_J2()
    print "Process_DOF_J2 ..."
    '     schTrace3.wbkWriteln("Process_DOF_J2")
    global_j = Translate_Ndx(j2)
    '     schTrace3.wbkWritelnCell(10, global_j)
    '
    '     schTrace3.wbkWritelnCell(13, sj(global_j, df1))
    sj(global_j, df1) = sj(global_j, df1) + s(df2, df2)
    '     schTrace3.wbkWritelnCell(14, sj(global_j, df1))
    '     schTrace3.wbkWritelnCell(15, s(df2, df2))
    '
    '     schTrace3.wbkWritelnCell(18, global_j)
    '     schTrace3.wbkWritelnCell(19, df1)
    '    schTrace3.IncTracerRow

    If rjl(j3) = 0 Then
        '      schTrace3.IncTracerRow
        '       schTrace3.wbkWritelnCell(13, sj(global_j, df2))
        sj(global_j, df2) = sj(global_j, df2) + s(df2, df3)
        '       schTrace3.wbkWritelnCell(14, sj(global_j, df2))
        '       schTrace3.wbkWritelnCell(15, s(df2, df3))
    End If

    If rjl(k1) = 0 Then
         Load_Sj(global_j, k1, s(df2, df4))
    End If

    If rjl(k2) = 0 Then
         Load_Sj(global_j, k2, s(df2, df5))
    End If

    If rjl(k3) = 0 Then
         Load_Sj(global_j, k3, s(df2, df6))
    End If

End Sub  '.. Process_DOF_J2 ..

'<< Process_DOF_J3 >>
Sub PlaneFrame.Process_DOF_J3()
    print "Process_DOF_J3 ..."
    '     schTrace3.wbkWriteln("Process_DOF_J3")
    global_j = Translate_Ndx(j3)
    '     schTrace3.wbkWritelnCell(10, global_j)
    '
    '     schTrace3.wbkWritelnCell(13, sj(global_j, df1))
    sj(global_j, df1) = sj(global_j, df1) + s(df3, df3)
    '     schTrace3.wbkWritelnCell(14, sj(global_j, df1))
    '     schTrace3.wbkWritelnCell(15, s(df3, df3))
    '
    '     schTrace3.wbkWritelnCell(18, global_j)
    '     schTrace3.wbkWritelnCell(19, df1)
    '    schTrace3.IncTracerRow

    If rjl(k1) = 0 Then
         Load_Sj(global_j, k1, s(df3, df4))
    End If

    If rjl(k2) = 0 Then
         Load_Sj(global_j, k2, s(df3, df5))
    End If

    If rjl(k3) = 0 Then
         Load_Sj(global_j, k3, s(df3, df6))
    End If

End Sub  '.. Process_DOF_J3 ..

'<< Process_DOF_K1 >>
Sub PlaneFrame.Process_DOF_K1()
    print "Process_DOF_K1 ..."
    '     schTrace3.wbkWriteln("Process_DOF_K1")
    global_j = Translate_Ndx(k1)
    '     schTrace3.wbkWritelnCell(10, global_j)
    '
    '     schTrace3.wbkWritelnCell(13, sj(global_j, df1))
    sj(global_j, df1) = sj(global_j, df1) + s(df4, df4)
    '     schTrace3.wbkWritelnCell(14, sj(global_j, df1))
    '     schTrace3.wbkWritelnCell(15, s(df4, df4))
    '
    '     schTrace3.wbkWritelnCell(18, global_j)
    '     schTrace3.wbkWritelnCell(19, df1)
    '    schTrace3.IncTracerRow

    If rjl(k2) = 0 Then
        '      schTrace3.IncTracerRow
        '       schTrace3.wbkWritelnCell(13, sj(global_j, df2))
        sj(global_j, df2) = sj(global_j, df2) + s(df4, df5)
        '       schTrace3.wbkWritelnCell(14, sj(global_j, df2))
        '       schTrace3.wbkWritelnCell(15, s(df4, df5))
    End If

    If rjl(k3) = 0 Then
         Load_Sj(global_j, k3, s(df4, df6))
    End If

End Sub  '.. Process_DOF_K1 ..

'<< Process_DOF_K2 >>
Sub PlaneFrame.Process_DOF_K2()
    print "Process_DOF_K2 ..."
    '     schTrace3.wbkWriteln("Process_DOF_K2")
    global_j = Translate_Ndx(k2)
    '     schTrace3.wbkWritelnCell(10, global_j)
    '
    '     schTrace3.wbkWritelnCell(13, sj(global_j, df1))
    sj(global_j, df1) = sj(global_j, df1) + s(df5, df5)
    '     schTrace3.wbkWritelnCell(14, sj(global_j, df1))
    '     schTrace3.wbkWritelnCell(15, s(df5, df5))
    '
    '     schTrace3.wbkWritelnCell(18, global_j)
    '     schTrace3.wbkWritelnCell(19, df1)
    '    schTrace3.IncTracerRow

    If rjl(k3) = 0 Then
        '      schTrace3.IncTracerRow
        '       schTrace3.wbkWritelnCell(13, sj(global_j, df2))
        sj(global_j, df2) = sj(global_j, df2) + s(df5, df6)
        '       schTrace3.wbkWritelnCell(14, sj(global_j, df2))
        '       schTrace3.wbkWritelnCell(15, s(df5, df6))
    End If

End Sub  '.. Process_DOF_K2 ..

'<< Process_DOF_K3 >>
Sub PlaneFrame.Process_DOF_K3()
    print "Process_DOF_K3 ..."
    '     schTrace3.wbkWriteln("Process_DOF_K3")
    global_j = Translate_Ndx(k3)
    '     schTrace3.wbkWritelnCell(10, global_j)
    '
    '     schTrace3.wbkWritelnCell(13, sj(global_j, df1))

    sj(global_j, df1) = sj(global_j, df1) + s(df6, df6)

    '     schTrace3.wbkWritelnCell(14, sj(global_j, df1))
    '     schTrace3.wbkWritelnCell(15, s(df6, df6))
    '
    '     schTrace3.wbkWritelnCell(18, global_j)
    '     schTrace3.wbkWritelnCell(19, df1)

End Sub  '.. Process_DOF_K3 ..

'<< Assemble_Struct_Stiff_Matrix >>
Sub PlaneFrame.Assemble_Struct_Stiff_Matrix(i As Integer)
    '        .. initialise temp variables ..

    print "Assemble_Struct_Stiff_Matrix ...", i
    'Get indexes into the restrained joints list

    'Index for Node on near End of Member
    j3 = (3 * GModel.con_grp(i).jj) - 1
    j2 = j3 - 1
    j1 = j2 - 1

    'Index for Node on far End of Member
    k3 = (3 * GModel.con_grp(i).jk) - 1
    k2 = k3 - 1
    k1 = k2 - 1

    print j3, j2, j1, k3, k2, k1

    '     schTrace3.wbkWritelnCell(1, GModel.con_grp(i).jj)
    '     schTrace3.wbkWritelnCell(2, GModel.con_grp(i).jk)
    '     schTrace3.wbkWritelnCell(3, j1)
    '     schTrace3.wbkWritelnCell(4, j2)
    '     schTrace3.wbkWritelnCell(5, j3)
    '     schTrace3.wbkWritelnCell(6, k1)
    '     schTrace3.wbkWritelnCell(7, k2)
    '     schTrace3.wbkWritelnCell(8, k3)
    '    schTrace3.IncTracerRow

    If rjl(j3) = 0 Then  Process_DOF_J3() '.. do j3 ..
    If rjl(j2) = 0 Then  Process_DOF_J2() '.. do j2 ..
    If rjl(j1) = 0 Then  Process_DOF_J1() '.. do j1 ..

    If rjl(k3) = 0 Then  Process_DOF_K3() '.. do k3 ..
    If rjl(k2) = 0 Then  Process_DOF_K2() '.. do k2 ..
    If rjl(k1) = 0 Then  Process_DOF_K1() '.. do k1 ..

    print "... Assemble_Struct_Stiff_Matrix"

End Sub  '.. Assemble_Struct_Stiff_Matrix ..


'------------------------------------------------------------------------------
'BEGIN:: ACTION-EFFECTS
'------------------------------------------------------------------------------

'<< Calc_Member_Forces >>
Sub PlaneFrame.Calc_Member_Forces()

    '     schTrace.wbkWriteln("Calc_Member_Forces ..." & Format(GModel.structParam.nmb, "0"))



    For global_i = baseIndex To GModel.structParam.nmb - 1
        With GModel.con_grp(global_i)

             Assemble_Stiff_Mat(global_i)

            '        .. initialise temporary end restraint indices ..
            j3 = 3 * .jj - 1
            j2 = j3 - 1
            j1 = j2 - 1

            k3 = 3 * .jk - 1
            k2 = k3 - 1
            k1 = k2 - 1

            '         schTrace.wbkWritelnCell(0, global_i)
            '
            '         schTrace.wbkWritelnCellColoured(1, .jj, 4)
            '         schTrace.wbkWritelnCell(2, j3)
            '         schTrace.wbkWritelnCell(3, j2)
            '         schTrace.wbkWritelnCell(4, j1)
            '
            '         schTrace.wbkWritelnCellColoured(5, .jk, 4)
            '         schTrace.wbkWritelnCell(6, k3)
            '         schTrace.wbkWritelnCell(7, k2)
            '         schTrace.wbkWritelnCell(8, k1)


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

            '         schTrace.wbkWritelnCell(9, .jnt_jj.axial)
            '         schTrace.wbkWritelnCell(10, .jnt_jj.shear)
            '         schTrace.wbkWritelnCell(11, .jnt_jj.momnt)
            '         schTrace.wbkWritelnCell(12, .jnt_jk.axial)
            '         schTrace.wbkWritelnCell(13, .jnt_jk.shear)
            '         schTrace.wbkWritelnCell(14, .jnt_jk.momnt)

            '.. Member Joint j End forces
            If rjl(j1) <> 0 Then ar(j1) = ar(j1) + ad(df1) * cosa - ad(df2) * sina '.. Fx
            If rjl(j2) <> 0 Then ar(j2) = ar(j2) + ad(df1) * sina + ad(df2) * cosa '.. Fy
            If rjl(j3) <> 0 Then ar(j3) = ar(j3) + ad(df3) '.. Mz

            '.. Member Joint k End forces
            If rjl(k1) <> 0 Then ar(k1) = ar(k1) + ad(df4) * cosa - ad(df5) * sina '.. Fx
            If rjl(k2) <> 0 Then ar(k2) = ar(k2) + ad(df4) * sina + ad(df5) * cosa '.. Fy
            If rjl(k3) <> 0 Then ar(k3) = ar(k3) + ad(df6) '.. Mz

        End With

        '      schTrace.IncTracerRow
    Next global_i

End Sub  '.. Calc_Member_Forces ..

'<< Calc_Joint_Displacements >>
Sub PlaneFrame.Calc_Joint_Displacements()
    For global_i = baseIndex To n3 - 1
        If rjl(global_i) = 0 Then dj(global_i) = dd(Translate_Ndx(global_i))
    Next global_i
End Sub '.. Calc_Joint_Displacements ..

'<< Get_Span_Moments >>
Sub PlaneFrame.Get_Span_Moments()
    Dim seg as Double
    Dim stn As Double
    Dim rx As Double
    Dim mx As Double
    Dim i As Integer, j As Integer

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
Function PlaneFrame.In_Cover(ByVal x1 As Double, ByVal x2 As Double, ByVal mlen As Double) As Boolean
    '     schTrace.wbkWriteln("In_Cover ...")

    If (x2 = mlen) Or (x2 > mlen) Then
        In_Cover = True
    Else
        In_Cover = ((stn >= x1) And (stn <= x2))
    End If
End Function '...In_Cover...


'<< Calc_Moments >>
'.. RGH   12/4/92
'.. calc moments ..
Sub PlaneFrame.Calc_Moments(ByVal mn As Byte, ByVal mlen As Double, ByVal wtot As Double, _
                   ByVal x1 As Double, ByVal la As Double, ByVal cv As Double, ByVal wty As Byte, _
                   ByVal lslope As Integer)
    Dim x As Double
    Dim x2 As Double
    Dim Lx As Double
    Dim idx1 As Integer

    On Error GoTo ErrHandler_Calc_Moments

    '   schTrace.wbkWritelnCell(0, "Calc_Moments ...")
    '   schTrace.wbkWritelnCell(2, mn)
    '  schTrace.IncTracerRow

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
    Close
    print "... Calc_Moments: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Calc_Moments
    Stop

End Sub     '.. Calc_Moments ..


'<< Combine_Joint_Loads >>
Sub PlaneFrame.Combine_Joint_Loads(kMember As Byte)
    Dim k As Integer

    On Error GoTo ErrHandler_Combine_Joint_Loads

    '     schTrace.wbkWritelnCell(0, "Combine_Joint_Loads ...")
    '     schTrace.wbkWritelnCell(2, kMember)
    '    schTrace.IncTracerRow

    k = kMember - 1

    print "STEP:1"
    cosa = rot_mat(k, ndx1)
    sina = rot_mat(k, ndx2)

    '     schTrace.wbkWritelnCell(0, "cosa")
    '     schTrace.wbkWritelnCell(1, cosa)
    '    schTrace.IncTracerRow
    '     schTrace.wbkWritelnCell(0, "sina")
    '     schTrace.wbkWritelnCell(1, sina)
    '    schTrace.IncTracerRow



    '   ... Process end A
    Get_Joint_Indices(GModel.con_grp(k).jj)

    '     schTrace.wbkWritelnCell(0, "fc[]")
    '     schTrace.wbkWritelnCell(1, fc(j1))
    '     schTrace.wbkWritelnCell(2, fc(j2))
    '     schTrace.wbkWritelnCell(3, fc(j3))
    '    schTrace.IncTracerRow

    fc(j1) = fc(j1) - a_i * cosa + ri * sina    '.. Fx
    fc(j2) = fc(j2) - a_i * sina - ri * cosa    '.. Fy
    fc(j3) = fc(j3) - fi                        '.. Mz

    '     schTrace.wbkWritelnCell(0, "fc[]")
    '     schTrace.wbkWritelnCell(1, fc(j1))
    '     schTrace.wbkWritelnCell(2, fc(j2))
    '     schTrace.wbkWritelnCell(3, fc(j3))
    '    schTrace.IncTracerRow

    '   ... Process end B
    Get_Joint_Indices(GModel.con_grp(k).jk)
    '     schTrace.wbkWritelnCell(0, "fc[]")
    '     schTrace.wbkWritelnCell(1, fc(j1))
    '     schTrace.wbkWritelnCell(2, fc(j2))
    '     schTrace.wbkWritelnCell(3, fc(j3))
    '    schTrace.IncTracerRow

    fc(j1) = fc(j1) - a_j * cosa + rj * sina    '.. Fx
    fc(j2) = fc(j2) - a_j * sina - rj * cosa    '.. Fy
    fc(j3) = fc(j3) - fj                        '.. Mz

    '     schTrace.wbkWritelnCell(0, "fc[]")
    '     schTrace.wbkWritelnCell(1, fc(j1))
    '     schTrace.wbkWritelnCell(2, fc(j2))
    '     schTrace.wbkWritelnCell(3, fc(j3))
    '    schTrace.IncTracerRow

Exit_Combine_Joint_Loads:
    Exit Sub

ErrHandler_Combine_Joint_Loads:
    Close
    print "... Combine_Joint_Loads: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Combine_Joint_Loads
    Stop

End Sub  '.. Combine_Joint_Loads ..

'  << Calc_FE_Forces >>
Sub PlaneFrame.Calc_FE_Forces(ByVal kMember As Byte, ByVal la As Double, ByVal lb As Double)
    Dim k As Integer

    On Error GoTo ErrHandler_Calc_FE_Forces

    k = kMember - 1

    '   schTrace.wbkWritelnCell(0, "Calc_FE_Forces ...")
    '   schTrace.wbkWritelnCell(2, kMember)
    '  schTrace.IncTracerRow
    '   schTrace.wbkWritelnCell(0, "trl:")
    '   schTrace.wbkWritelnCell(2, trl)
    '  schTrace.IncTracerRow
    '   schTrace.wbkWritelnCell(0, "djj:")
    '   schTrace.wbkWritelnCell(2, djj)
    '  schTrace.IncTracerRow
    '   schTrace.wbkWritelnCell(0, "dii:")
    '   schTrace.wbkWritelnCell(2, dii)
    '  schTrace.IncTracerRow

    '.. both ends fixed
    fi = (2 * djj - 4 * dii) / trl
    fj = (4 * djj - 2 * dii) / trl
    With GModel.con_grp(k)
        '       schTrace.wbkWritelnCell(0, "jj and jk: ")
        '       schTrace.wbkWritelnCell(2, GModel.con_grp(k).jj)
        '       schTrace.wbkWritelnCell(3, GModel.con_grp(k).jk)
        '      schTrace.IncTracerRow

        flag = .rel_i + .rel_j
        '       schTrace.wbkWritelnCell(0, "Flag:")
        '       schTrace.wbkWritelnCell(1, flag)
        '      schTrace.IncTracerRow

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
    Close
    print "... Calc_FE_Forces: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Calc_FE_Forces
    Stop

End Sub  '.. Calc_FE_Forces ..


'<< Accumulate_FE_Actions >>
Sub PlaneFrame.Accumulate_FE_Actions(ByVal kMemberNum As Byte)
    Dim k As Integer

    On Error GoTo ErrHandler_Accumulate_FE_Actions

    '   schTrace.wbkWritelnCell(0, "Accumulate_FE_Actions ...")
    '   schTrace.wbkWritelnCell(2, kMemberNum)
    '  schTrace.IncTracerRow

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
    Close
    print "... Accumulate_FE_Actions: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Accumulate_FE_Actions
    Stop

End Sub  '.. Accumulate_FE_Actions ..


'<< Process_FE_Actions >>
Sub PlaneFrame.Process_FE_Actions(ByVal kMemberNum As Byte, ByVal la As Double, ByVal lb As Double)

    On Error GoTo ErrHandler_Process_FE_Actions

    '   schTrace.wbkWritelnCell(0, "Process_FE_Actions ...")
    '   schTrace.wbkWritelnCell(2, kMemberNum)
    '  schTrace.IncTracerRow

     Accumulate_FE_Actions(kMemberNum)
     Combine_Joint_Loads(kMemberNum)

Exit_Process_FE_Actions:
    Exit Sub

ErrHandler_Process_FE_Actions:
    Close
    print "... Process_FE_Actions: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Process_FE_Actions
    Stop

End Sub  '.. Process_FE_Actions ..


'<< Do_Global_Load >>
Sub PlaneFrame.Do_Global_Load(ByVal mem As Byte, ByVal acd As Byte, ByVal w0 As Double, ByVal start As Double)

    '   schTrace.wbkWritelnCell(0, "Do_Global_Load ...")
    '  schTrace.IncTracerRow

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
Sub PlaneFrame.Do_Axial_Load(ByVal mno As Byte, ByVal wu As Double, ByVal x1 As Double)

    On Error GoTo ErrHandler_Do_Axial_Load

    '   schTrace.wbkWritelnCell(0, "Do_Axial_Load ...")
    '  schTrace.IncTracerRow

    w_nrm = wu
    la = x1
    lb = trl - la
    a_i = -wu * lb / trl
    a_j = -wu * la / trl
    fi = 0
    fj = 0
    ri = 0
    rj = 0
     Process_FE_Actions(mno, la, lb)


Exit_Do_Axial_Load:
    Exit Sub

ErrHandler_Do_Axial_Load:
    Close
    print "... Do_Axial_Load: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Do_Axial_Load
    Stop

End Sub  '.. Do_Axial_Load ..


'<< Do_Self_Weight >>
Sub PlaneFrame.Do_Self_Weight(mem As Integer)
    Dim msect As Byte, mat As Byte
    Dim idxMem As Integer, idxMsect As Integer, idxMat As Integer

    '   schTrace.wbkWritelnCell(0, "Do_Self_Weight ...")
    '  schTrace.IncTracerRow

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
Function PlaneFrame.UDL_Slope(w0 As Double, v As Double, c As Double) As Double

    On Error GoTo ErrHandler_UDL_Slope

    '   schTrace.wbkWriteln("UDL_Slope ...")

    UDL_Slope = w0 * v * (4 * (trl ^ 2 - v ^ 2) - c ^ 2) / (24 * trl)

Exit_UDL_Slope:
    Exit Function

ErrHandler_UDL_Slope:
    Close
    print "... UDL_Slope: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_UDL_Slope
    Stop

End Function '.. UDL_Slope ..


'<< Do_Part_UDL >>
'.. Load type = "u" => #1
Sub PlaneFrame.Do_Part_UDL(ByVal mno As Double, ByVal wu As Double, ByVal x1 As Double, _
                                    ByVal cv As Double, wact As Byte)

    Dim la As Double, lb As Double

    On Error GoTo ErrHandler_Do_Part_UDL

    '   schTrace.wbkWritelnCell(0, "Do_Part_UDL ...")
    '   schTrace.wbkWritelnCell(2, mno)
    '  schTrace.IncTracerRow


    la = x1 + cv / 2
    lb = trl - la

    If wact <> local_act Then
         Do_Global_Load(mno, wact, wu, x1)
        w_axi = axi_comp * cv
         Do_Axial_Load(mno, w_axi, la)
    Else
        nrm_comp = wu
        axi_comp = 0
    End If

    w_nrm = nrm_comp * cv
    dii = UDL_Slope(w_nrm, lb, cv)
    djj = UDL_Slope(w_nrm, la, cv)

     Calc_Moments(mno, trl, w_nrm, x1, la, cv, udl_ld, pos_slope) '.. Calculate the span moments
     Calc_FE_Forces(mno, la, lb)
     Process_FE_Actions(mno, la, lb)


    '   schTrace.wbkWritelnCell(0, "... Do_Part_UDL")
    '  schTrace.IncTracerRow


Exit_Do_Part_UDL:
    Exit Sub

ErrHandler_Do_Part_UDL:
    Close
    print "... Do_Part_UDL: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Do_Part_UDL
    Stop

End Sub      '.. Do_Part_UDL ..


'<< PL_Slope >>
Function PlaneFrame.PL_Slope(v As Double) As Double

    '   schTrace.wbkWritelnCell(0, "PL_Slope ...")
    '  schTrace.IncTracerRow

    PL_Slope = w_nrm * v * (trl ^ 2 - v ^ 2) / (6 * trl)
End Function '.. PL_Slope ..


'<< Do_Point_load >>
'.. Load type = "p" => #2
Sub PlaneFrame.Do_Point_load(ByVal mno As Double, ByVal wu As Double, ByVal x1 As Double, wact As Byte)

    On Error GoTo ErrHandler_Do_Point_load

    '   schTrace.wbkWritelnCell(0, "Do_Point_load ...")
    '  schTrace.IncTracerRow

    la = x1
    lb = trl - la

    If wact <> local_act Then
         Do_Global_Load(mno, wact, wu, x1)
        w_axi = axi_comp
         Do_Axial_Load(mno, w_axi, la)
    Else
        nrm_comp = wu
        axi_comp = 0
    End If

    w_nrm = nrm_comp

    dii = PL_Slope(lb)
    djj = PL_Slope(la)

     Calc_Moments(mno, trl, w_nrm, x1, la, 0, pnt_ld, pos_slope) '.. Calculate the span moments
     Calc_FE_Forces(mno, la, lb)
     Process_FE_Actions(mno, la, lb)

Exit_Do_Point_load:
    Exit Sub

ErrHandler_Do_Point_load:
    Close
    print "... Do_Point_load: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Do_Point_load
    Stop

End Sub '.. Do_Point_load ..


'<< Tri_Slope >>
Function PlaneFrame.Tri_Slope(ByVal v As Double, ByVal w_nrm As Double, ByVal cv As Double, _
                   ByVal sl_switch As Integer) As Double



    On Error GoTo ErrHandler_Tri_Slope

    '   schTrace.wbkWritelnCell(0, "Tri_Slope ...")
    '  schTrace.IncTracerRow

    gam = cv / trl
    v = v / trl
    Tri_Slope = w_nrm * _
                trl ^ 2 * (270 * (v - v ^ 3) - gam ^ 2 * (45 * v + sl_switch * 2 * gam)) / 1620


Exit_Tri_Slope:
    Exit Function

ErrHandler_Tri_Slope:
    Close
    print "... Tri_Slope: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Tri_Slope
    Stop

End Function '.. Tri_Slope ..

'<< Do_Triangle >>
'.. Load type =
Sub PlaneFrame.Do_Triangle(ByVal mno As Double, ByVal w0 As Double, ByVal la As Double, _
                 ByVal x1 As Double, ByVal cv As Double, wact As Byte, ByVal slopedir As Integer)
    Dim lb As Double


    On Error GoTo ErrHandler_Do_Triangle

    '   schTrace.wbkWritelnCell(0, "Do_Triangle ...")
    '  schTrace.IncTracerRow

    lb = trl - la

    If wact <> local_act Then
         Do_Global_Load(mno, wact, w0, x1)
        w_axi = axi_comp * cv / 2
         Do_Axial_Load(mno, w_axi, la)
    Else
        nrm_comp = w0
        axi_comp = 0
    End If

    w_nrm = nrm_comp * cv / 2

    dii = Tri_Slope(lb, w_nrm, cv, pos_slope * slopedir)     '.. /!  => +ve when +ve slope
    djj = Tri_Slope(la, w_nrm, cv, neg_slope * slopedir)     '.. !\  => +ve when -ve slope

     Calc_Moments(mno, trl, w_nrm, x1, la, cv, tri_ld, slopedir)  '.. Calculate the span moments
     Calc_FE_Forces(mno, la, lb)
     Process_FE_Actions(mno, la, lb)


Exit_Do_Triangle:
    Exit Sub

ErrHandler_Do_Triangle:
    Close
    print "... Do_Triangle: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Do_Triangle
    Stop


End Sub  '.. Do_Triangle ..

'<< Do_Distributed_load >>
'.. Load type = "v" => #1
Sub PlaneFrame.Do_Distributed_load(ByVal mno As Byte, ByVal wm1 As Double, ByVal wm2 As Double, _
                     ByVal x1 As Double, ByVal cv As Double, lact As Byte)

    Dim wudl As Double, wtri As Double, slope As Double, ltri As Double

    On Error GoTo ErrHandler_Do_Distributed_load

    '   schTrace.wbkWritelnCell(0, "Do_Distributed_load ...")
    '   schTrace.wbkWritelnCell(2, mno)
    '  schTrace.IncTracerRow


    If wm1 = wm2 Then                 '..  load is a UDL
         Do_Part_UDL(mno, wm1, x1, cv, lact)
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
             Do_Part_UDL(mno, wudl, x1, cv, lact)
        End If

        If wtri <> 0 Then
             Do_Triangle(mno, wtri, ltri, x1, cv, lact, slope)
        End If

    End If

    '   schTrace.wbkWritelnCell(0, "... Do_Distributed_load")
    '  schTrace.IncTracerRow

Exit_Do_Distributed_load:
    Exit Sub

ErrHandler_Do_Distributed_load:
    Close
    print "... Do_Distributed_load: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Do_Distributed_load
    Stop

End Sub  '.. Do_Distributed_load ..

'<< Get_FE_Forces >>
Sub PlaneFrame.Get_FE_Forces(ByVal kMemberNum As Byte, ByVal ldty As Byte, ByVal wm1 As Double, _
                      ByVal wm2 As Double, ByVal x1 As Double, ByVal cvr As Double, lact As Byte)

    On Error GoTo ErrHandler_Get_FE_Forces

    '      schTrace.IncTracerRow
    '       schTrace.wbkWritelnCell(0, "Get_FE_Forces ...")
    '       schTrace.wbkWritelnCell(2, kMemberNum)

    Select Case ldty                '.. Get_FE_Forces ..

        Case dst_ld                                             '..  "v" = #1
             Do_Distributed_load(kMemberNum, wm1, wm2, x1, cvr, lact)
        Case pnt_ld                                             '..  "p" = #2
             Do_Point_load(kMemberNum, wm1, x1, lact)
        Case axi_ld                                             '..  "a" = #3
             Do_Axial_Load(kMemberNum, wm1, x1)

    End Select

Exit_Get_FE_Forces:
    Exit Sub

ErrHandler_Get_FE_Forces:
    Close
    print "... Get_FE_Forces: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Get_FE_Forces
    Stop

End Sub  '.. Get_FE_Forces ..

'  << Process_Loadcases >>
Sub PlaneFrame.Process_Loadcases()

    Dim r As Integer
    Dim idxMem As Byte

    On Error GoTo ErrHandler_Process_Loadcases

    '     schTrace.wbkWriteln("Process_Loadcases ...")
    '    schTrace.IncTracerRow

    'Joint Loads
    If GModel.structParam.njl <> 0 Then 'Have Joint Loads
        '      schTrace.wbkWriteln ("FC[]:")
        For global_i = baseIndex To GModel.structParam.njl - 1
            With GModel.jnt_lod(global_i)
                Get_Joint_Indices(.jt)

                fc(j1) = .fx
                fc(j2) = .fy
                fc(j3) = .mz

                '           schTrace.wbkWriteCell(r, 0, fc(j1))
                '           schTrace.wbkWriteCell(r, 1, fc(j2))
                '           schTrace.wbkWriteCell(r, 2, fc(j3))
                r = r + 1
            End With
        Next global_i
    Else
        '      schTrace.wbkWriteln ("njl=0 : No Joint Loads")
    End If

    'Member Loads
    If GModel.structParam.nml <> 0 Then 'Have Member Loads
        '      schTrace.wbkWriteln ("nml = " & Format(GModel.structParam.nml, "0"))

        For global_i = baseIndex To GModel.structParam.nml - 1
            '         schTrace.wbkWriteln("global_i = " & Format(global_i, "0"))
            '         schTrace.wbkWritelnCell(0, global_i)

            With GModel.mem_lod(global_i)
                idxMem = .mem_no - 1 'Member Numbers start at 1, arrays indexed from 0
                '             schTrace.wbkWritelnCell(1, .mem_no)
                trl = mlen(idxMem)
                '             schTrace.wbkWritelnCell(2, trl)

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
                 Get_FE_Forces(.mem_no, ldc, wm1, wm2, .start, cvr, .f_action)

                '             schTrace.wbkWriteln("FC[]:" & Format(global_i, "0"))
                '             schTrace.wbkWriteVector(fc)


            End With

            '        schTrace.IncTracerRow
        Next global_i
    Else
        '      schTrace.wbkWriteln ("nml=0 : No Member Loads")
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
                 Do_Self_Weight(global_i)
                nrm_comp = udl
                If .f_action <> local_act Then
                     Do_Global_Load(global_i, .f_action, udl, 0)
                End If
                 Get_FE_Forces(global_i, dst_ld, nrm_comp, nrm_comp, x1, cvr, .f_action)
            End With
        Next global_i
    Else
        '      schTrace.wbkWriteln ("ngl=0 : No Gravity Loads")
    End If


    '     schTrace.wbkWriteln("... Process_Loadcases")

Exit_Process_Loadcases:
    Exit Sub

ErrHandler_Process_Loadcases:
    Close
    print "... Process_Loadcases: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Process_Loadcases
    Stop

End Sub  '.. Process_Loadcases ..


'<< Zero_Vars >>
Sub PlaneFrame.Zero_Vars()

    '     schTrace.wbkWritelnCell(0, "Zero_Vars ...")
    '    schTrace.IncTracerRow

    print "Zero_Vars ..."
    Erase mlen  ' Each element set to 0.
    Erase ad
    Erase fc
    Erase ar
    Erase dj
    Erase dd
    Erase rjl
    Erase crl
    Erase rot_mat
    Erase af
    Erase sj
    Erase s
    Erase mom_spn
    print "... Zero_Vars"
End Sub  '.. Zero_Vars ..

'<< Initialise >>
Sub PlaneFrame.initialise()

    '     schTrace.wbkWritelnCell(0, "initialise ...")
    '    schTrace.IncTracerRow

    print "Initialise ..."
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

    If Not (data_loaded) Then GModel.initialise()

     Zero_Vars()
    If data_loaded Then  Get_Direction_Cosines()
    print "... Initialise"

End Sub  '.. Initialise ..

'<< Translate_Ndx >>
'.. Restrained joint index
Function PlaneFrame.Translate_Ndx(ByVal i As Byte) As Integer

    '     schTrace.wbkWritelnCell(0, "Translate_Ndx ...")
    '    schTrace.IncTracerRow

    Translate_Ndx = i - crl(i)
End Function  '.. Translate_Ndx ..

'<< Equiv_Ndx >>
'..equivalent matrix configuration  joint index numbers
Function PlaneFrame.Equiv_Ndx(ByVal j As Byte) As Integer

    '     schTrace.wbkWritelnCell(0, "Equiv_Ndx ...")
    '    schTrace.IncTracerRow

    Equiv_Ndx = rjl(j) * (nn + crl(j)) + (1 - rjl(j)) * Translate_Ndx(j)
End Function '.. Equiv_Ndx ..

'<< Get_Joint_Indices >>
'..  get equivalent matrix index numbers
Sub PlaneFrame.Get_Joint_Indices(ByVal nd As Byte)

    '     schTrace.wbkWritelnCell(0, "Get_Joint_Indices ...")
    '     schTrace.wbkWritelnCell(2, nd)
    '    schTrace.IncTracerRow

    j0 = (3 * nd) - 1
    j3 = Equiv_Ndx(j0)
    j2 = j3 - 1
    j1 = j2 - 1

    '     schTrace.wbkWritelnCell(0, "j0")
    '     schTrace.wbkWritelnCell(1, j0)
    '    schTrace.IncTracerRow
    '     schTrace.wbkWritelnCell(0, "j1")
    '     schTrace.wbkWritelnCell(1, j1)
    '    schTrace.IncTracerRow
    '     schTrace.wbkWritelnCell(0, "j2")
    '     schTrace.wbkWritelnCell(1, j2)
    '    schTrace.IncTracerRow
    '     schTrace.wbkWritelnCell(0, "j3")
    '     schTrace.wbkWritelnCell(1, j3)
    '    schTrace.IncTracerRow

End Sub      '.. Get_Joint_Indices ..

'<< Get_Direction_Cosines >>
Sub PlaneFrame.Get_Direction_Cosines()
    Dim i As Integer, tmp As Byte, rel_tmp As Byte
    Dim xm As Double, ym As Double

    print "Get_Direction_Cosines ..."

    '     schTrace.wbkWriteln("Get_Direction_Cosines ...")

    For i = baseIndex To GModel.structParam.nmb - 1
        'print i, nmb
        With GModel.con_grp(i)
            If .jk < .jj Then  '.. swap end1 with end2 if smaller !! ..
                tmp = .jj
                .jj = .jk
                .jk = tmp

                rel_tmp = .rel_j
                .rel_j = .rel_i
                .rel_i = rel_tmp
            End If

            'print "STEP:1", i, .jk, getArrayIndex(.jk), .jj, getArrayIndex(.jj)
            xm = GModel.nod_grp(getArrayIndex(.jk)).x - GModel.nod_grp(getArrayIndex(.jj)).x
            ym = GModel.nod_grp(getArrayIndex(.jk)).y - GModel.nod_grp(getArrayIndex(.jj)).y
            mlen(i) = Sqr(xm * xm + ym * ym)

            '         schTrace.wbkWritelnCell(0, i)
            '         schTrace.wbkWritelnCell(1, mlen(i))


            print i, ": mlen[i]: ", mlen(i)

            rot_mat(i, ndx1) = xm / mlen(i)      '.. Cos
            rot_mat(i, ndx2) = ym / mlen(i)      '.. Sin

        End With

        '       schTrace.IncTracerRow
    Next i

    print "... Get_Direction_Cosines"

End Sub  '.. Get_Direction_Cosines ..



'<< Total_Section_Mass >>
Sub PlaneFrame.Total_Section_Mass()
    Dim i As Integer

    '     schTrace.wbkWritelnCell(0, "Total_Section_Mass ...")
    '    schTrace.IncTracerRow

    For i = baseIndex To GModel.structParam.nsg - 1
        '      With mat_grp(sec_grp(i).mat)
        '        sec_grp(i).t_mass = sec_grp(i).ax * .Density * sec_grp(i).t_len
        GModel.sec_grp(i).t_mass = GModel.sec_grp(i).ax * GModel.mat_grp(getArrayIndex(GModel.sec_grp(i).mat)).density * GModel.sec_grp(i).t_len
        '      End With
    Next i
End Sub '.. Total_Section_Mass ..



'<< Total_Section_Length >>
Sub PlaneFrame.Total_Section_Length()
    Dim ndx As Integer

    '     schTrace.wbkWritelnCell(0, "Total_Section_Length ...")
    '    schTrace.IncTracerRow

    For global_i = baseIndex To GModel.structParam.nmb - 1
        ndx = getArrayIndex(GModel.con_grp(global_i).sect)
        'With con_grp(global_i)
        'sec_grp(.sect).t_len = sec_grp(.sect).t_len + mlen(global_i)
        GModel.sec_grp(ndx).t_len = GModel.sec_grp(ndx).t_len + mlen(global_i)
        'End With
    Next global_i
     Total_Section_Mass()
End Sub '.. Total_Section_Length ..


'<< Get_Min_Max >>
'..find critical End forces ..
Sub PlaneFrame.Get_Min_Max()

    '       schTrace.wbkWritelnCell(0, "Get_Min_Max ...")
    '      schTrace.IncTracerRow

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
Sub PlaneFrame.Analyse_Frame()

    Dim i As Integer

    On Error GoTo ErrHandler_Analyse_Frame

    'Get definition of the Plane Frame to Analyse

    print "Analyse_Frame ..."
    print ">>> Design Frame Started <<<"

     initialise()

    'BEGIN PLANEFRAME ANALYSIS

     Fill_Restrained_Joints_Vector()

     Total_Section_Length()

     Calc_Bandwidth()


    For i = baseIndex To GModel.structParam.nmb - 1
        print "Analyse_Frame:  i = ", i
         Assemble_Global_Stiff_Matrix(i)
         Assemble_Struct_Stiff_Matrix(i)


    Next i
    print "End of Matrix Assembly"
     Choleski_Decomposition(sj(), nn, hbw)



    '------------------------------------------------------------------------------


    '     schTrace.wbkWriteln("Process_Loadcases")
     Process_Loadcases()
    '     schTrace.wbkWriteln("FC[]: Result: ")
    '     schTrace.wbkWriteVector(fc)
    '
    '     schTrace.wbkWriteln("AF[]: ")
    '     schTrace.wbkWriteMatrix(af)
    '
    '     schTrace.wbkWriteln("Solve_Displacements")
     Solve_Displacements()
    '     schTrace.wbkWriteln("DD[]: ")
    '     schTrace.wbkWriteVector(dd)
    '
    '     schTrace.wbkWriteln("Calc_Joint_Displacements")
     Calc_Joint_Displacements()
    '     schTrace.wbkWriteln("DJ[]: ")
    '     schTrace.wbkWriteVector(dj)
    '
    '     schTrace.wbkWriteln("Calc_Member_Forces")
     Calc_Member_Forces()
    '     schTrace.wbkWriteln("AD[]: ")
    '     schTrace.wbkWriteVector(ad)
    '
    '     schTrace.wbkWriteln("AR[]: ")
    '     schTrace.wbkWriteVector(ar)



    '     schTrace.wbkWriteln("Get_Span_Moments")
     Get_Span_Moments()
    '     schTrace.wbkWriteln("mom_spn: ")
    '     schTrace.wbkWriteMatrix(mom_spn)
    '
    '
    '     schTrace.wbkWriteln("Get_Min_Max")
     Get_Min_Max()


    '     schTrace.wbkWriteln("Analysis Complete!")
    'END OF PLANEFRAME ANALYSIS

    'Trace all Arrays for Reference
    '     schTrace.wbkWriteln("Trace all Arrays for Reference:")
    '     schTrace.wbkWriteln("mlen: ")
    '     schTrace.wbkWriteVector(mlen)
    '
    '     schTrace.wbkWriteln("ad: ")
    '     schTrace.wbkWriteVector(ad)
    '
    '     schTrace.wbkWriteln("fc: ")
    '     schTrace.wbkWriteVector(fc)
    '
    '     schTrace.wbkWriteln("ar: ")
    '     schTrace.wbkWriteVector(ar)
    '
    '     schTrace.wbkWriteln("dj: ")
    '     schTrace.wbkWriteVector(dj)

    '     schTrace.wbkWriteln("dd: ")
    '     schTrace.wbkWriteVector(dd)
    '
    '     schTrace.wbkWriteln("rot_mat: ")
    '     schTrace.wbkWriteMatrix(rot_mat)
    '
    '     schTrace.wbkWriteln("af: ")
    '     schTrace.wbkWriteMatrix(af)
    '
    '     schTrace.wbkWriteln("s: ")
    '     schTrace.wbkWriteMatrix(s)
    '
    '     schTrace.wbkWriteln("mom_spn: ")
    '     schTrace.wbkWriteMatrix(mom_spn)
    '
    '     schTrace.wbkWriteln("sj: ")
    '     schTrace.wbkWriteMatrix(sj)
    '
    '     schTrace.wbkWriteln("crl: ")
    '     schTrace.wbkWriteVector(crl)
    '
    '     schTrace.wbkWriteln("rjl: ")
    '     schTrace.wbkWriteVector(rjl)
    '     schTrace.wbkWriteln("End Trace of Arrays")
    'End Trace of Arrays


    'Do something with the results of the analysis
    'This can be done in the main calling application

    print "*** Analysis Completed *** "
    print "... Analyse_Frame"

Exit_Analyse_Frame:
    Exit Sub

ErrHandler_Analyse_Frame:
    Close
    print "... Analyse_Frame: Exit Errors!"
    'print Err.Number, Err.Description
    '    Resume Exit_Analyse_Frame
    Stop

End Sub '.. Analyse_Frame ..

'===========================================================================
'END    ''.. Main Module ..
'===========================================================================



'------------------------------------------------------------------------------
'DISPLAY RESULTS TO EXCEL WORKBOOK
'------------------------------------------------------------------------------
'###### Pf_Prt.PAS ######
' ... a module of Output routines for the Framework Program-
'     R G Harrison   --  Version 1.1  --  12/05/05  ...
'     Revision history as-
'        12/05/05 - implemented ..

'<<< START CODE >>>>}
'===========================================================================
'<<< ClearOutputSheet >>>
'<<< PrtDeltas >>>
'<<< PrtEndForces >>>
'<<< PrtReactions >>>
'<< Prt_Controls >>
'<<< Prt_Section_Details >>>
'<<< PrtSpanMoments >>>
'<< Output Results to Table >>




'------------------------------------------------------------------------------
'BEGIN:: ADDITIONAL INPUT ROUTINES
'------------------------------------------------------------------------------

Sub PlaneFrame.addNode(x As Double, y As Double)
    Dim aNode As clsPfCoordinate

    'aNode = New clsPfCoordinate
    aNode.initialise()
    aNode.x = x
    aNode.y = y
    '  GModel.nod_grp(njt).x = x
    '  GModel.nod_grp(njt).y = y
    GModel.nod_grp(GModel.structParam.njt) = aNode
    print "njt", GModel.structParam.njt
    GModel.structParam.njt = GModel.structParam.njt + 1
End Sub

Sub PlaneFrame.addMaterialGroup(density As Double, ElasticModulus As Double, CoeffThermExpansion As Double)

    With GModel.mat_grp(GModel.structParam.nmg)
        .density = density
        .emod = ElasticModulus
        .therm = CoeffThermExpansion
    End With
    GModel.structParam.nmg = GModel.structParam.nmg + 1
End Sub

Sub PlaneFrame.addSectionGroup(SectionArea As Double, SecondMomentArea As Double, materialKey As Integer, Description As String)

    With GModel.sec_grp(GModel.structParam.nsg)
        .ax = SectionArea
        .iz = SecondMomentArea
        .mat = materialKey
        .Descr = Description
    End With
    GModel.structParam.nsg = GModel.structParam.nsg + 1
End Sub


Sub PlaneFrame.addMember(NodeA As Integer, NodeB As Integer, sectionKey As Integer, ReleaseA As Integer, ReleaseB As Integer)

    With GModel.con_grp(GModel.structParam.nmb)
        .jj = NodeA
        .jk = NodeB
        .sect = sectionKey
        .rel_i = ReleaseA
        .rel_j = ReleaseB
    End With
    GModel.structParam.nmb = GModel.structParam.nmb + 1
End Sub

Sub PlaneFrame.addSupport(SupportNode As Integer, RestraintX As Byte, RestraintY As Byte, RestraintMoment As Byte)

    With GModel.sup_grp(GModel.structParam.nrj)
        .js = SupportNode
        .rx = RestraintX
        .ry = RestraintY
        .rm = RestraintMoment
        GModel.structParam.nr = GModel.structParam.nr + .rx + .ry + .rm
    End With
    GModel.structParam.nrj = GModel.structParam.nrj + 1
End Sub

Sub PlaneFrame.addJointLoad(Node As Integer, ForceX As Double, ForceY As Double, Moment As Double)

    With GModel.jnt_lod(GModel.structParam.njl)
        .jt = Node
        .fx = ForceX
        .fy = ForceY
        .mz = Moment
    End With
    GModel.structParam.njl = GModel.structParam.njl + 1
End Sub

Sub PlaneFrame.addMemberLoad(memberKey As Integer, LoadType As Integer, ActionKey As Integer _
                         , LoadMag1 As Double, LoadMag2 As Double, LoadStart As Double, LoadCover As Double)

    With GModel.mem_lod(GModel.structParam.nml)
        .mem_no = memberKey
        .lcode = LoadType
        .f_action = ActionKey
        .ld_mag1 = LoadMag1
        .ld_mag2 = LoadMag2
        .start = LoadStart
        .cover = LoadCover
    End With
    GModel.structParam.nml = GModel.structParam.nml + 1
End Sub

Sub PlaneFrame.addGravityLoad(ActionKey As Integer, LoadMag As Double)
    With GModel.grv_lod
        .f_action = ActionKey
        .load = LoadMag
    End With
End Sub



'###### Pf_Inp.PAS ######
' ... a module of Input routines for the Framework Program-
'     R G Harrison   --  Version 1.1  --  12/05/05  ...
'     Revision history as-
'        12/05/05 - implemented ..
'<<< START CODE >>>>}
'===========================================================================
'<<< GetData >>>
' ...   read in the data
' ...   RGH   24/4/05
'------------------------------------------------------------------------------
'SAVE TEXT FILE DATA FILE
'------------------------------------------------------------------------------

Sub PlaneFrame.Archive_Data(fp as integer)
    Const pwid = 40
    Dim i As Integer

    print "Archive_Data ..."
  Print #fp, "JOB DATA" & dataBlockTag
    '  For i = baseIndex To 5
    '    Print fp, jobData(i)
    '  Next i

  Print #fp, "CONTROL DATA" & dataBlockTag
  Print #fp, GModel.structParam.njt, GModel.structParam.nmb, GModel.structParam.nrj, GModel.structParam.nmg, GModel.structParam.nsg, GModel.structParam.njl, GModel.structParam.nml
    '    WRITELN(inf,no_jts:6, m:6, nrj:6, nmg:6, nsg:6, njl:6,nml:6);

  Print #fp, "NODES" & dataBlockTag
    For i = baseIndex To GModel.structParam.njt - 1
        With GModel.nod_grp(i)
        Print #fp, Format(i, "###"), Format(.x, "0.000"), Format(.y, "0.000")
        End With
    Next i

  Print #fp, "MEMBERS" & dataBlockTag
    For i = baseIndex To GModel.structParam.nmb - 1
        With GModel.con_grp(i)
      Print #fp, Format(i, "##0"), Format(.jj, "##0"), Format(.jk, "##0"), Format(.sect, "##0"), Format(.rel_i, "##0"), Format(.rel_j, "##0")
        End With
    Next i


    '    FOR i := baseIndex TO m DO
    '      WITH con_grp[i] DO   WRITELN(inf,jj:6,jk:6,sect:6,mat:6,fixity:12);


  Print #fp, "SUPPORTS" & dataBlockTag
    For i = baseIndex To GModel.structParam.nrj - 1
        With GModel.sup_grp(i)
      Print #fp, Format(i, "##0"), Format(.js, "##0"), Format(.rx, "##0"), Format(.ry, "##0"), Format(.rm, "##0")
        End With
    Next i


    '    FOR i := baseIndex TO nrj DO
    '      WITH sup_grp[i] DO   WRITELN(inf,js :6, rx:6, ry:6, rm:6);


  Print #fp, "MATERIALS" & dataBlockTag
    For i = baseIndex To GModel.structParam.nmg - 1
        With GModel.mat_grp(i)
      Print #fp, Format(i, "##0"), Format(.density, "0.0000E+"), Format(.emod, "0.0000E+"), Format(.therm, "0.0000E+")
        End With
    Next i



    '    FOR i := baseIndex TO nmg DO
    '      WITH mat_grp[i] DO   WRITELN(inf,density:10, emod:10, therm:10);


  Print #fp, "SECTIONS" & dataBlockTag
    For i = baseIndex To GModel.structParam.nsg - 1
        With GModel.sec_grp(i)
      Print #fp, Format(i, "##0"), Format(.ax, "0.0000E+"), Format(.iz, "0.0000E+"), Format(.mat, "##0"); StrLPad(.Descr, 10)
        End With
    Next i


    '    FOR i := baseIndex TO nsg DO
    '      WITH mem_grp[i] DO   WRITELN(inf,ax:10, iz:10 ,descr  : 20);


  Print #fp, "JOINT LOADS" & dataBlockTag
    print "njl= ", GModel.structParam.njl
    For i = baseIndex To GModel.structParam.njl - 1
        With GModel.jnt_lod(i)
      Print #fp, Format(i, "##0"), Format(.jt, "##0"), Format(.fx, "0.0000"), Format(.fy, "0.0000"), Format(.mz, "0.0000")
        End With
    Next i



    '    FOR i := baseIndex TO njl DO
    '      WITH jnt_lod[i] DO   WRITELN(inf,jt: 6, fx:15:7, fy:15:7, mz :15:7);


  Print #fp, "MEMBER LOADS" & dataBlockTag
    For i = baseIndex To GModel.structParam.nml - 1
        With GModel.mem_lod(i)
      Print #fp, Format(i, "##0"), Format(.mem_no, "##0"), Format(.lcode, "##0"), _
                 Format(.ld_mag1, "0.0000"), Format(.ld_mag2, "0.0000"), _
                 Format(.start, "0.0000"), Format(.cover, "0.0000")
        End With
    Next i

    '    FOR i := baseIndex TO nml DO
    '      WITH mem_lod[i] DO   WRITELN(inf,mem_no:6, lcode : 6, load:15:7, start:15:7, cover : 12:4);


  Print #fp, "GRAVITY LOADS" & dataBlockTag


    print "... Archive_Data"

End Sub

'------------------------------------------------------------------------------
'READ TEXT FILE DATA FILE
'------------------------------------------------------------------------------
Function PlaneFrame.isDataBlockHeaderString(s As String) As Boolean
    Dim p As Integer

    p = InStr(1, s, dataBlockTag)
    If p <> 0 Then
        isDataBlockHeaderString = True
    Else
        isDataBlockHeaderString = False
    End If

End Function

Sub PlaneFrame.fgetJobData(fp as integer)
    print "fgetJobData ..."
    For global_i = baseIndex To UBound(jobData)
        jobData(global_i) = ReadLine(fp)
        print global_i, jobData(global_i)
    Next global_i


    print "... fgetJobData"
End Sub


Sub PlaneFrame.fgetControlData(fp as integer)
    print "fgetControlData ..."
    '  GModel.structParam.njt = CByte(ReadField(fp))
    '  GModel.structParam.nmb = CByte(ReadField(fp))
    '  GModel.structParam.nrj = CByte(ReadField(fp))
    '  GModel.structParam.nmg = CByte(ReadField(fp))
    '  GModel.structParam.nsg = CByte(ReadField(fp))
    '  GModel.structParam.njl = CByte(ReadField(fp))
    '  GModel.structParam.nml = CByte(ReadField(fp))
    print "... fgetControlData"
End Sub


Sub PlaneFrame.fgetNodeData(fp as integer, lastTxtStr As String)
    Dim s As String
    Dim i As Integer, n As Integer
    Dim dataflds(0 To 4) As String

    Dim MachineState As Integer
    Dim quit As Boolean 'Switch Machine OFF and Quit
    Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
    Dim isDataBlockFound As Boolean

    quit = False
    MachineState = MachineON 'and is Scanning file
    done = False
    isDataBlockFound = False

    print "fgetNodeData ..."

    done = False
    Do While Not (done) And Not (quit)
        Select Case MachineState
            Case MachineTurnOFF
                quit = True
                print "Machine to be Turned OFF"
            Case MachineScanning
                If Not (Eof(fp)) Then
                    s = Trim(ReadLine(fp))
                    isDataBlockFound = isDataBlockHeaderString(s)
                    If isDataBlockFound Then
                        MachineState = DataBlockFound
                    Else
                         parseDelimitedString(s, dataflds(), n, " ")
                        '            print "Node=", dataflds(0)
                        '            print "x= ", dataflds(1)
                        '            print "y= ", dataflds(2)
                         addNode(CDbl(dataflds(1)), CDbl(dataflds(2)))
                        MachineState = MachineScanning
                    End If
                Else
                    done = True
                    MachineState = MachineTurnOFF
                End If
            Case DataBlockFound
                'Signifies End of Current Data Block
                done = True
                MachineState = MachineTurnOFF
        End Select
    Loop
    lastTxtStr = s
    print "... fgetNodeData"
End Sub

Sub PlaneFrame.fgetMemberData(fp as integer, lastTxtStr As String)
    Dim s As String
    Dim i As Integer, n As Integer
    Dim dataflds(0 To 8) As String

    Dim MachineState As Integer
    Dim quit As Boolean 'Switch Machine OFF and Quit
    Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
    Dim isDataBlockFound As Boolean

    quit = False
    MachineState = MachineON 'and is Scanning file
    done = False
    isDataBlockFound = False

    print "fgetMemberData ..."

    done = False
    Do While Not (done) And Not (quit)
        Select Case MachineState
            Case MachineTurnOFF
                quit = True
                print "Machine to be Turned OFF"
            Case MachineScanning
                If Not (Eof(fp)) Then
                    s = Trim(ReadLine(fp))
                    isDataBlockFound = isDataBlockHeaderString(s)
                    If isDataBlockFound Then
                        MachineState = DataBlockFound
                    Else
                         parseDelimitedString(s, dataflds(), n, " ")
                        '            For i = startZero To n
                        '              print dataflds(i)
                        '            Next i
                        '            print "----"
                         addMember(CInt(dataflds(1)), CInt(dataflds(2)), CInt(dataflds(3)), CInt(dataflds(4)), CInt(dataflds(5)))
                        MachineState = MachineScanning
                    End If
                Else
                    done = True
                    MachineState = MachineTurnOFF
                End If
            Case DataBlockFound
                'Signifies End of Current Data Block
                done = True
                MachineState = MachineTurnOFF
        End Select
    Loop

    lastTxtStr = s

    print "... fgetMemberData"

End Sub

Sub PlaneFrame.fgetSupportData(fp as integer, lastTxtStr As String)
    Dim s As String
    Dim i As Integer, n As Integer
    Dim dataflds(0 To 6) As String

    Dim MachineState As Integer
    Dim quit As Boolean 'Switch Machine OFF and Quit
    Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
    Dim isDataBlockFound As Boolean

    quit = False
    MachineState = MachineON 'and is Scanning file
    done = False
    isDataBlockFound = False

    print "fgetSupportData ..."

    done = False
    Do While Not (done) And Not (quit)
        Select Case MachineState
            Case MachineTurnOFF
                quit = True
                print "Machine to be Turned OFF"
            Case MachineScanning
                If Not (Eof(fp)) Then
                    s = Trim(ReadLine(fp))
                    isDataBlockFound = isDataBlockHeaderString(s)
                    If isDataBlockFound Then
                        MachineState = DataBlockFound
                    Else
                         parseDelimitedString(s, dataflds(), n, " ")
                        '            For i = startZero To n
                        '              print dataflds(i)
                        '            Next i
                        '            print "----"

                         addSupport(CInt(dataflds(1)), CByte(dataflds(2)), CByte(dataflds(3)), CByte(dataflds(4)))
                        MachineState = MachineScanning
                    End If
                Else
                    done = True
                    MachineState = MachineTurnOFF
                End If
            Case DataBlockFound
                'Signifies End of Current Data Block
                done = True
                MachineState = MachineTurnOFF
        End Select
    Loop

    lastTxtStr = s

    print "... fgetSupportData"

End Sub

Sub PlaneFrame.fgetMaterialData(fp as integer, lastTxtStr As String)
    Dim s As String
    Dim i As Integer, n As Integer
    Dim dataflds(0 To 8) As String

    Dim MachineState As Integer
    Dim quit As Boolean 'Switch Machine OFF and Quit
    Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
    Dim isDataBlockFound As Boolean

    quit = False
    MachineState = MachineON 'and is Scanning file
    done = False
    isDataBlockFound = False

    print "fgetMaterialData ..."

    done = False
    Do While Not (done) And Not (quit)
        Select Case MachineState
            Case MachineTurnOFF
                quit = True
                print "Machine to be Turned OFF"
            Case MachineScanning
                If Not (Eof(fp)) Then
                    s = Trim(ReadLine(fp))
                    isDataBlockFound = isDataBlockHeaderString(s)
                    If isDataBlockFound Then
                        MachineState = DataBlockFound
                    Else
                         parseDelimitedString(s, dataflds(), n, " ")
                        '            For i = startZero To n
                        '              print dataflds(i)
                        '            Next i
                        '            print "----"
                         addMaterialGroup(CDbl(dataflds(1)), CDbl(dataflds(2)), CDbl(dataflds(3)))
                        MachineState = MachineScanning
                    End If
                Else
                    done = True
                    MachineState = MachineTurnOFF
                End If
            Case DataBlockFound
                'Signifies End of Current Data Block
                done = True
                MachineState = MachineTurnOFF
        End Select
    Loop

    lastTxtStr = s



    print "... fgetMaterialData"

End Sub

Sub PlaneFrame.fgetSectionData(fp as integer, lastTxtStr As String)
    Dim s As String
    Dim i As Integer, n As Integer
    Dim dataflds(0 To 8) As String

    Dim MachineState As Integer
    Dim quit As Boolean 'Switch Machine OFF and Quit
    Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
    Dim isDataBlockFound As Boolean

    quit = False
    MachineState = MachineON 'and is Scanning file
    done = False
    isDataBlockFound = False

    print "fgetSectionData ..."

    done = False
    Do While Not (done) And Not (quit)
        Select Case MachineState
            Case MachineTurnOFF
                quit = True
                print "Machine to be Turned OFF"
            Case MachineScanning
                If Not (Eof(fp)) Then
                    s = Trim(ReadLine(fp))
                    isDataBlockFound = isDataBlockHeaderString(s)
                    If isDataBlockFound Then
                        MachineState = DataBlockFound
                    Else
                         parseDelimitedString(s, dataflds(), n, " ")
                        '            For i = startZero To n
                        '              print dataflds(i)
                        '            Next i
                        '            print "----"
                         addSectionGroup(CDbl(dataflds(1)), CDbl(dataflds(2)), CDbl(dataflds(3)), dataflds(4))
                        MachineState = MachineScanning
                    End If
                Else
                    done = True
                    MachineState = MachineTurnOFF
                End If
            Case DataBlockFound
                'Signifies End of Current Data Block
                done = True
                MachineState = MachineTurnOFF
        End Select
    Loop

    lastTxtStr = s



    print "... fgetSectionData"

End Sub

Sub PlaneFrame.fgetJointLoadData(fp as integer, lastTxtStr As String)
    Dim s As String
    Dim i As Integer, n As Integer
    Dim dataflds(0 To 8) As String

    Dim MachineState As Integer
    Dim quit As Boolean 'Switch Machine OFF and Quit
    Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
    Dim isDataBlockFound As Boolean

    quit = False
    MachineState = MachineON 'and is Scanning file
    done = False
    isDataBlockFound = False

    print "fgetJointLoadData ..."

    done = False
    Do While Not (done) And Not (quit)
        Select Case MachineState
            Case MachineTurnOFF
                quit = True
                print "Machine to be Turned OFF"
            Case MachineScanning
                If Not (Eof(fp)) Then
                    s = Trim(ReadLine(fp))
                    isDataBlockFound = isDataBlockHeaderString(s)
                    If isDataBlockFound Then
                        MachineState = DataBlockFound
                    Else
                         parseDelimitedString(s, dataflds(), n, " ")
                        '            For i = startZero To n
                        '              print dataflds(i)
                        '            Next i
                        '            print "----"
                         addJointLoad(CInt(dataflds(0)), CDbl(dataflds(1)), CDbl(dataflds(2)), CDbl(dataflds(3)))
                        MachineState = MachineScanning
                    End If
                Else
                    done = True
                    MachineState = MachineTurnOFF
                End If
            Case DataBlockFound
                'Signifies End of Current Data Block
                done = True
                MachineState = MachineTurnOFF
        End Select
    Loop

    lastTxtStr = s


    print "... fgetJointLoadData"

End Sub

Sub PlaneFrame.fgetMemberLoadData(fp as integer, lastTxtStr As String)
    Dim s As String
    Dim i As Integer, n As Integer
    Dim dataflds(0 To 8) As String

    Dim MachineState As Integer
    Dim quit As Boolean 'Switch Machine OFF and Quit
    Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
    Dim isDataBlockFound As Boolean

    quit = False
    MachineState = MachineON 'and is Scanning file
    done = False
    isDataBlockFound = False

    print "fgetMemberLoadData ..."

    done = False
    Do While Not (done) And Not (quit)
        Select Case MachineState
            Case MachineTurnOFF
                quit = True
                print "Machine to be Turned OFF"
            Case MachineScanning
                If Not (Eof(fp)) Then
                    s = Trim(ReadLine(fp))
                    isDataBlockFound = isDataBlockHeaderString(s)
                    If isDataBlockFound Then
                        MachineState = DataBlockFound
                    Else
                         parseDelimitedString(s, dataflds(), n, " ")
                        '            For i = startZero To n
                        '              print dataflds(i)
                        '            Next i
                        '            print "----"
                         addMemberLoad(CInt(dataflds(0)), CInt(dataflds(1)), CInt(dataflds(2)), CDbl(dataflds(3)) _
                                           , CDbl(dataflds(4)), CDbl(dataflds(5)), CDbl(dataflds(6)))
                        MachineState = MachineScanning
                    End If
                Else
                    done = True
                    MachineState = MachineTurnOFF
                End If
            Case DataBlockFound
                'Signifies End of Current Data Block
                done = True
                MachineState = MachineTurnOFF
        End Select
    Loop

    lastTxtStr = s


    print "... fgetMemberLoadData"

End Sub

Sub PlaneFrame.fgetGravityLoadData(fp as integer, lastTxtStr As String)
    Dim s As String
    Dim i As Integer, n As Integer
    Dim dataflds(0 To 8) As String

    Dim MachineState As Integer
    Dim quit As Boolean 'Switch Machine OFF and Quit
    Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
    Dim isDataBlockFound As Boolean
    Dim isUseDefaultData As Boolean

    print "fgetGravityLoadData ..."

    isDataBlockFound = False
    If Not (Eof(fp)) Then
        quit = False
        MachineState = MachineON 'and is Scanning file
        done = False
        isUseDefaultData = False
    Else
        done = True
        MachineState = MachineTurnOFF
        isUseDefaultData = True
    End If

    Do While Not (done) And Not (quit)
        Select Case MachineState
            Case MachineTurnOFF
                quit = True
                print "Limit State File Parser Machine to be Turned OFF"
            Case MachineScanning
                If Not (Eof(fp)) Then
                    s = Trim(ReadLine(fp))
                    isDataBlockFound = isDataBlockHeaderString(s)
                    If isDataBlockFound Then
                        MachineState = DataBlockFound
                    Else
                         parseDelimitedString(s, dataflds(), n, " ")
                        '            For i = startZero To n
                        '              print dataflds(i)
                        '            Next i
                        '            print "----"
                         addGravityLoad(CInt(dataflds(0)), CDbl(dataflds(1)))
                        MachineState = MachineScanning
                    End If
                Else
                    print "... End of File"
                    done = True
                    MachineState = MachineTurnOFF
                End If
            Case DataBlockFound
                'Signifies End of Current Data Block
                done = True
                MachineState = MachineTurnOFF
        End Select
    Loop

    If Not (Eof(fp)) Then
        lastTxtStr = s
    Else
        lastTxtStr = ""
    End If

    If isUseDefaultData Then
        print "Using Default Data"
         addGravityLoad(2, -9.81)
    End If

    'File Data Ignored
    'Default Values Used Only

    print "... fgetGravityLoadData"
End Sub


'Limit State Machine: File Parser
Sub PlaneFrame.Read_Data(fp As integer)
    Const pwid = 20
    Dim i As Byte, tmp As Byte, p As Integer
    Dim s As String
    Dim dataCtrlBlk As String

    Dim MachineState As Integer
    Dim quit As Boolean
    Dim done As Boolean
    Dim isDataBlockFound As Boolean

    On Error GoTo ErrHandler_Read_Data
    print "Read_Data ..."

    quit = False
    MachineState = MachineON 'and is Scanning file
    done = False
    isDataBlockFound = False

    Do While Not (done) And Not (quit)

        Select Case MachineState
            Case MachineTurnOFF
                quit = True
                print "Machine to be Turned OFF"
            Case MachineScanning
                If Not (Eof(fp)) Then
                    s = ReadLine(fp)
                    isDataBlockFound = isDataBlockHeaderString(s)
                    If isDataBlockFound Then
                        MachineState = DataBlockFound
                    Else
                        MachineState = MachineScanning
                    End If
                Else
                    done = True
                    MachineState = MachineTurnOFF
                End If
            Case DataBlockFound
                dataCtrlBlk = UCase(Trim(Left(s, Len(s) - 2)))
                print "<" & dataCtrlBlk & ">"
                MachineState = RecognisedSection
            Case RecognisedSection
                Select Case dataCtrlBlk
                    Case "JOB DETAILS"
                         fgetJobData(fp)
                        MachineState = MachineScanning
                    Case "CONTROL DATA"
                         fgetControlData(fp)
                        MachineState = MachineScanning
                    Case "NODES"
                         fgetNodeData(fp, s)
                        MachineState = DataBlockFound
                    Case "MEMBERS"
                         fgetMemberData(fp, s)
                        MachineState = DataBlockFound
                    Case "SUPPORTS"
                         fgetSupportData(fp, s)
                        MachineState = DataBlockFound
                    Case "MATERIALS"
                         fgetMaterialData(fp, s)
                        MachineState = DataBlockFound
                    Case "SECTIONS"
                         fgetSectionData(fp, s)
                        MachineState = DataBlockFound
                    Case "JOINT LOADS"
                         fgetJointLoadData(fp, s)
                        MachineState = DataBlockFound
                    Case "MEMBER LOADS"
                         fgetMemberLoadData(fp, s)
                        MachineState = DataBlockFound
                    Case "GRAVITY LOADS"
                         fgetGravityLoadData(fp, s)
                        MachineState = MachineTurnOFF
                End Select
            Case Else
                If Eof(fp) Then
                    print "DataBlockFound: End Of File"
                    done = True
                    MachineState = MachineTurnOFF
                Else
                    MachineState = MachineScanning
                End If
        End Select 'machine state

    Loop

    print "... Read_Data"

Exit_Read_Data:
    Exit Sub

ErrHandler_Read_Data:
    'On Error Close All open Files
    Close
    print "... Read_Data: Exit Errors!"
    'print Err.Number, Err.Description
    'Resume Exit_Read_Data

End Sub

'------------------------------------------------------------------------------
'REPORTS: Text Files
'------------------------------------------------------------------------------

'    <<< fprintDeltas >>>
Sub PlaneFrame.fprintDeltas(fpRpt As integer)
    Dim txt1 As String, txt2 As String, txt3 As String, txt4 As String
    Dim idx1 As Integer, idx2 As Integer, idx3 As Integer

    print "fprintDeltas ..."
    print #fpRpt,"fprintDeltas ..."
    For global_i = baseIndex + 1 To GModel.structParam.njt
        txt1 = StrLPad(Format(global_i, "0"), 4)

        idx1 = 3 * global_i - 3
        idx2 = 3 * global_i - 2
        idx3 = 3 * global_i - 1

        txt2 = StrLPad(Format(-dj(idx1), "0.0000"), 8)
        txt3 = StrLPad(Format(-dj(idx2), "0.0000"), 8)
        txt4 = StrLPad(Format(-dj(idx3), "0.0000"), 8)

        print #fpRpt,txt1 + " " + txt2 + " " + txt3 + " " + txt4

    Next global_i

     print #fpRpt,
    print "... fprintDeltas"
End Sub '...fprintDeltas

'   <<< fprintEndForces >>>
Sub PlaneFrame.fprintEndForces(fpRpt As integer)
    Dim txt0 As String, txt1 As String, txt2 As String, txt3 As String, txt4 As String, txt5 As String
    Dim txt6 As String, txt7 As String, txt8 As String, txt9 As String, txt As String
    Dim i As Integer

    print "fprintEndForces ..."
    print #fpRpt,"fprintEndForces ..."
    For i = baseIndex To GModel.structParam.nmb - 1
        txt0 = StrLPad(Str(i), 8)
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
        print #fpRpt,txt
    Next i

     print #fpRpt,
    print "... fprintEndForces"
End Sub '...fprintEndForces

'    << fprint_Reaction_Sum >>
Sub PlaneFrame.fprint_Reaction_Sum(fpRpt As integer)
    Dim txt0 As String, txt1 As String

    print #fpRpt,"fprint_Reaction_Sum ..."
    txt0 = StrLPad(Format(sumx, "0.0000"), 15)
    txt1 = StrLPad(Format(sumy, "0.0000"), 15)
    print #fpRpt,txt0 & " " & txt1
    print #fpRpt,

End Sub '.. fprint_Reaction_Sum ..

'    <<< fprintReactions >>>
Sub PlaneFrame.fprintReactions(fpRpt As integer)
    Dim i As Integer, k As Integer, k3 As Integer, c As Integer, r As Integer
    Dim txt0 As String, txt1 As String, txt2 As String

    print "fprintReactions ..."
    print #fpRpt,"fprintReactions ..."

    For k = baseIndex To n3 - 1
        If (rjl(k) = 1) Then
            ar(k) = ar(k) - fc(Equiv_Ndx(k))
        End If
    Next k
    sumx = 0
    sumy = 0

    For i = baseIndex To GModel.structParam.nrj - 1


        txt0 = Format(GModel.sup_grp(i).js,"0")
        flag = 0
        k3 = 3 * GModel.sup_grp(i).js - 1
        For k = k3 - 2 To k3
            If ((k + 1) Mod 3 = 0) Then
                txt1 = StrLPad(Format(ar(k), "0.0000"), 15)
                 print #fpRpt,txt1;
            Else
                txt2 = StrLPad(Format(ar(k), "0.0000"), 15)
                 print #fpRpt,txt2;
                If (flag = 0) Then
                    sumx = sumx + ar(k)
                Else
                    sumy = sumy + ar(k)
                End If
                flag = flag + 1
            End If
        Next k
        flag = 0

         print #fpRpt,

    Next i

     fprint_Reaction_Sum(fpRpt)

     print #fpRpt,
    print "... fprintReactions"

End Sub '...fprintReactions

'    << fprint_Controls >>
Sub PlaneFrame.fprint_Controls(fpRpt As integer)
    Dim txt1 As String, txt2 As String, txt3 As String, txt4 As String, txt5 As String
    Dim txt6 As String, txt7 As String, txt8 As String, txt9 As String, txt As String

    print #fpRpt,"fprint_Controls ..."
    txt1 = Format(GModel.structParam.njt,"0")
    txt2 = Format(GModel.structParam.nmb,"0")
    txt3 = Format(GModel.structParam.nmg,"0")
    txt4 = Format(GModel.structParam.nsg,"0")
    txt5 = Format(GModel.structParam.nrj,"0")
    txt6 = Format(GModel.structParam.njl,"0")
    txt7 = Format(GModel.structParam.nml,"0")
    txt8 = Format(GModel.structParam.ngl,"0")
    txt9 = Format(GModel.structParam.nr,"0")

    txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4 + " " + txt5
    txt = txt + " " + txt6 + " " + txt7 + " " + txt8 + " " + txt9
    print #fpRpt,txt
    print #fpRpt,

End Sub '.. fprint_Controls ..

'    <<< fprint_Section_Details >>>
Sub PlaneFrame.fprint_Section_Details(fpRpt As integer)
    Dim txt1 As String, txt2 As String, txt3 As String, txt4 As String
    Dim txt As String
    Dim i As Integer

    print "fprint_Section_Details ..."
    print #fpRpt,"fprint_Section_Details ..."
    For i = baseIndex To GModel.structParam.nmg - 1

        txt1 = StrLPad(Str(i), 8)
        txt2 = StrLPad(Format(GModel.sec_grp(i).t_len, "0.000"), 8)
        txt3 = "<>"
        txt4 = StrLPad(GModel.sec_grp(i).Descr, 8)
        txt = txt1 & " " & txt2 & " " & txt3 & " " & txt4
        print #fpRpt,txt

    Next i

     print #fpRpt,
    print "... fprint_Section_Details"
End Sub '...fprint_Section_Details

'   <<< fprintSpanMoments >>>
Sub PlaneFrame.fprintSpanMoments(fpRpt As integer)
    Dim seg As Double
    Dim tmp As Double

    Dim txt1 As String, txt2 As String, txt3 As String, txt4 As String
    Dim txt As String
    Dim i As Integer, j As Integer

    print "fprintSpanMoments ..."
    print #fpRpt,"fprintSpanMoments ..."


    For i = baseIndex To GModel.structParam.nmb - 1
        seg = mlen(i) / n_segs
        txt1 = StrLPad(Format(i, "0"), 8)
        For j = 0 To n_segs
            txt2 = StrLPad(Format(j, "0"), 8)

            tmp = j * seg
            txt3 = StrLPad(Format(tmp, "0.000"), 8)
            txt4 = StrLPad(Format(mom_spn(i, j), "0.0000"), 15)

            txt = txt1 & " " & txt2 & " " & txt3 & " " & txt4
            print #fpRpt,txt

        Next j
         print #fpRpt,
    Next i

     print #fpRpt,
    print "... fprintSpanMoments"
End Sub

'<< Output Results to Table >>
Sub PlaneFrame.fPrintResults(fpRpt As integer)
    print "PrintResults ..."
     fprint_Controls(fpRpt)
     fprintDeltas(fpRpt)
     fprintEndForces(fpRpt)
     fprintReactions(fpRpt)
     fprint_Section_Details(fpRpt)
     fprintSpanMoments(fpRpt)
    print "... PrintResults"
End Sub
