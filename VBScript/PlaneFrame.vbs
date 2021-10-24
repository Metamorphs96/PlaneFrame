'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit
'Option Base 0 'Base Zero by Default and cannot change

'------------------------------------------------------------------------------
'Purpose:
'------------------------------------------------------------------------------
'  The program analyses structural frameworks based upon the matrix stiffness
'  method of structural analysis.
'  .. References:-
'    1. W.H.Mosley & W.J.Spencer (1984), "Microcomputer Applications 
'       in Structural Engineering", Macmillan Press
'       [pgs 109-132]
'       [Sample programs are in interpretted dialetic of BASIC, and 
'        preface indicates programs listed in book are available
'        on disk for Apple Microcomputer. ]
'------------------------------------------------------------------------------
'Revisions:
'------------------------------------------------------------------------------
'R G Harrison ( 17 Feb 91): Implemented Turbo Pascal
'R G Harrison (2005)      : Converted to VBA
'S C Harrison (July 2010) : Plane Frame Analysis Modified to Class Object (VBA)
'S C Harrison (2014)      : Modified to zero based array indexing (VBA)
'S C Harrison (2016)      : Converted to VBScript running under WSH
'------------------------------------------------------------------------------

'File Parser: Limit State Machine

' Const MachineOFF = 0
' Const MachineTurnOFF = 0

' Const MachineON = 1
' Const MachineTurnON = 1
' Const MachineRunning = 1
' Const MachineScanning = 1

' Const RecognisedSection = 2
' Const DataBlockFound = 3

Const startIndex = 1
Const startZero = 0
Const StartCounter = 1 'Counting starting at 1

' Public Const baseIndex = 0 'Counting starting at base index of array
Const ndx0 = 0 'Index Zero

Const ndx1 = 0
Const ndx2 = 1

Const df1 = 0 'degree of freedom 1
Const df2 = 1
Const df3 = 2
Const df4 = 3
Const df5 = 4
Const df6 = 5

Const dataBlockTag = "::"

'.. enumeration constants ..
'... Load Actions
' Const local_act  = 0
' Const global_x   = 1
' Const global_y   = 2

'... Load Types
' Const dst_ld    = 1  '.. distributed loads udl, trap, triangular
' Const pnt_ld    = 2  '.. point load
' Const axi_ld    = 3  '.. axial load

' Const udl_ld    = 4  '.. uniform load
' Const tri_ld    = 5  '.. triangular load

'... Constant declarations ...
' Public Const numloads  = 80
' Const order    = 50
' Public Const v_size   = 50
' Public Const max_grps  = 25
' Public Const max_mats  = 10
' Public Const n_segs   = 7 '10

' Const mega    = 1000000
' Const kilo    = 1000
' Const cent    = 100

' Const tolerance  = 0.0001
' Const infinity  = 2E+20
' Const neg_slope   = 1
' Const pos_slope   = -1


'Define Class
Class PlaneFrame
	
	'------------------------------------------------------------------------------
	'INTERFACE
	'------------------------------------------------------------------------------
	
	'Variable declarations
	Public GModel 'As New clsGeomModel
	Public fpTracer
	
	Public data_loaded
	
	Public sumx
	Public sumy
	
	'	Public jotterbk
	'	Public MiWrkBk
	'	Public wrkSht
	'	Public TblRange
	
	Public poslope
	
	'------------------------------------------------------------------------------
	'IMPLEMENTATION
	'------------------------------------------------------------------------------
	Dim tmpPrintStr
	' Dim schTrace2 'As New debugTracer
	' Dim startCell2
	
	' Dim schTrace3 'As New debugTracer
	' Dim startCell3
	
	Dim jobData(5)
	
	
	Dim cosa        '  .. member's direction cosines ..
	Dim sina        '  .. member's direction cosines ..
	Dim c2         '  .. Cos^2
	Dim s2         '  .. Sin^2
	Dim cs         '  .. Cos x Sin
	Dim fi         '  .. fixed end moment @ end "i" of a member ..
	Dim fj         '  .. fixed end moment @ end "j" of a member ..
	Dim a_i         '  .. fixed end axial force @ end "i" ..
	Dim a_j         '  .. fixed end axial force @ end "j" ..
	Dim ri         '  .. fixed end shear @ end "i" ..
	Dim rj         '  .. fixed end shear @ end "j" ..
	Dim dii         '  .. slope function @ end "i" ..
	Dim djj         '  .. slope function @ end "j" ..
	Dim ao2
	Dim ldc        '  .. load type
	Dim x1         '  .. start position ..
	Dim la         '  .. dist from end "i" to centroid of load ..
	Dim lb         '  .. dist from end "j" to centroid of load ..
	Dim udl         '  .. uniform load
	Dim wm1         '  .. load magnitude 1
	Dim wm2         '  .. load magnitude 2
	Dim cvr         '  .. length covered by load
	Dim w1
	Dim ra         '  .. reaction @ end A
	Dim rb         '  .. reaction @ end B
	Dim w_nrm        '  .. total load normal to member ..
	Dim w_axi        '  .. total load axial to member ..
	Dim wchk        '  .. check reaction sum on span
	Dim nrm_comp      '  .. load normal to member
	Dim axi_comp      '  .. load axial to member
	Dim poa         '  .. point of application ..
	Dim stn
	Dim seg
	
	'.. Analysis module
	'...Variable declarations...
	
	Dim hbw        '  .. upper band width of the joint stiffness matrix ..
	Dim nn         '  .. No. of degrees of freedom @ the joints ..
	Dim n3         '  .. No. of joints x 3 ..
	Dim eaol        '  .. elements of the member stiffness matrix ..
	Dim trl         '  .. true length of a member ..
	Dim gam         '  .. gamma = cover/length
	
	Dim ci
	Dim cj
	Dim ccl
	Dim ai
	Dim aj
	
	Dim global_i
	Dim global_j
	Dim global_k
	
	
	'Index Variables
	Dim j0
	Dim j1
	Dim j2
	Dim j3
	
	'Index Variables
	Dim k0
	Dim k1
	Dim k2
	Dim k3
	
	Dim diff
	Dim flag
	Dim sect
	Dim rel
	
	Dim maxM , MinM
	Dim MaxMJnt , maxMmemb , MinMJnt , MinMmemb
	Dim maxA , MinA
	Dim MaxAJnt , maxAmemb , MinAJnt , MinAmemb
	Dim maxQ , MinQ
	Dim MaxQJnt , maxQmemb , MinQJnt , MinQmemb
	
	'------------------
	'Array Variables
	'------------------
	'NB: VBScript does not support using declared constants.
	'Have to to use literal constants in array declarations
	'The exception is when using redim, then can use declared constant or variables
	'However cannot redim in the body of a class definition, needs to be inside procedure
	
	'Vectors
	Dim mlen() '(v_size)       '.. member length ..
	
	Dim rjl() '(v_size)            '.. restrained joint list ..
	Dim crl() '(v_size)            '.. cumulative joint restraint list ..
	
	Dim fc() '(v_size)             '.. combined joint loads ..
	
	Dim dd() '(v_size)             '.. joint displacements @ free nodes ..
	Dim dj() '(v_size)             '.. joint displacements @ ALL the nodes ..
	Dim ad() '(v_size)             '.. member end forces not including fixed end forces ..
	Dim ar() '(v_size)             '.. support reactions ..
	
	'Matrices
	Dim rot_mat() '(v_size, ndx2)        '.. member rotation matrix ..
	Dim s() '(order, v_size)          '.. member stiffness matrix ..
	Dim sj() '(order, v_size)          '.. joint stiffness matrix ..
	
	Dim af() '(order, v_size)          '.. member fixed end forces ..
	Dim mom_spn() '(max_grps, ndx0 To n_segs)  '.. member span moments ..
	
	
	'------------------------------------------------------------------------------
	'CLASS: PROPERTIES
	'------------------------------------------------------------------------------
	Property Get SectionGroup(item )  'section_rec
	Set SectionGroup = GModel.sec_grp(item)
	End Property
	
	Property Get MemberProp(item )  'connect_rec
	Set MemberProp = GModel.con_grp(item)
	End Property
	
	Property Get SupportProp(item )  'support_rec
	Set SupportProp = GModel.sup_grp(item)
	End Property
	
	
	
	'==============================================================================
	'CLASS: INTERNAL/EXTERNAL PROCEDURES
	'==============================================================================
	
	
	'------------------------------------------------------------------------------
	'BEGIN:: SOLVER
	'------------------------------------------------------------------------------
	
	'###### Pf_Solve.PAS ######
	' ... a module of Bandsolver routines for the Framework Program-
	'   R G Harrison  -- Version 1.1 -- 12/05/05 ...
	'   Revision history as-
	'    12/05/05 - implemented ..
	
	'<<< START CODE >>>>}
	'===========================================================================
	
	
	'<< Choleski_Decomposition >>
	'... matrix decomposition by the Choleski method..
	'A=L.U
	'Matrix used is the reduced storage form of a banded matrix.
	'
	Private Sub Choleski_Decomposition(ByRef sj() , ByVal ndof , ByVal hbw )
		Dim p , q
		Dim su , te
		Dim indx1 , indx2 , indx3
		Dim r , c
		
		
		
		WScript.Echo "Choleski_Decomposition ..."
		WScript.Echo "ndof, hbw", ndof, hbw
		r = 1
		c = 0
		
		
		For global_i = baseIndex To ndof - 1 'From first to last index of array: rows of matrix
			fpTracer.WriteLine( "global_i= " & CStr( global_i))
			
			p = ndof - global_i - 1              '+ 1 'convert index to compact form of banded matrix
			If p > hbw - 1 Then p = hbw - 1
			fpTracer.WriteLine( "p=" & CStr( p))
			
			For global_j = baseIndex To p
				
				q = (hbw - 2) - global_j    'convert index to compact form of banded matrix
				If q > global_i - 1 Then q = global_i - 1
				fpTracer.WriteLine(  "q=" & CStr( q))
				
				
				su = sj(global_i, global_j)
				fpTracer.WriteLine( "su = " & CStr( su))
				
				If q >= 0 Then 'valid array index and not first element of array
					'       Wscript.Echo "Testing: Valid Array Index"
					For global_k = baseIndex To q
						If global_i > global_k Then
							'Calculate sum
							indx1 = global_i - global_k - 1
							indx2 = global_k + 1
							indx3 = global_k + global_j + 1
							su = su - sj(indx1, indx2) * sj(indx1, indx3)
						End If
						r = r + 1
					Next ' global_k
				End If
				
				If global_j <> 0 Then 'Not First Element of array
					sj(global_i, global_j) = su * te
					
				Else 'is first element
					If su <= 0 Then
						WScript.Echo "Choleski_Decomposition: matrix -ve TERM Terminated ???"
						WScript.Echo "Cannot find square root of negative number"
						WScript.Echo "su = ", su
						WScript.Echo "global_i, global_j : ", global_i, global_j
						Err.Clear
						Call Err.Raise(vbObjectError + 1001, , "Attempt to pass Negative Number to Square Root Function")
						
						
					Else 'First Element
						'        Wscript.Echo "Testing Index: su>0"
						te = 1 / Sqr(su)
						
						'        te = 1 'testing
						sj(global_i, global_j) = te            'Over write original matrix
						fpTracer.WriteLine(  "te = " & CStr( te))
					End If ' Check postive value for su
					
				End If 'Processing array items
				
				r = r + 1
			Next ' global_j
			r = r + 1
		Next ' global_i
		
		WScript.Echo "... Choleski_Decomposition"
		
	End Sub '.. Choleski_Decomposition ..
	
	
	'<< Solve_Displacements >>
	'.. perform forward and backward substitution to solve the system ..
	Private Sub Solve_Displacements()
		Dim su
		Dim i , j
		Dim idx1 , idx2
		
		fpTracer.WriteLine(  "Solve_Displacement:1 [" & CStr(nn) & "]" )
		For i = baseIndex To nn - 1
			j = i + 1 - hbw
			If j < 0 Then j = 0
			su = fc(i)
			
			If j - i + 1 <= 0 Then
				For global_k = j To i - 1
					If i - global_k + 1 > 0 Then
						
						idx1 = i - global_k '+ 1
						su = su - sj(global_k, idx1) * dd(global_k)
						
						fpTracer.WriteLine(CStr( i))
						fpTracer.WriteLine(CStr( j))
						fpTracer.WriteLine(CStr( global_k))
						fpTracer.WriteLine(CStr( idx1))
						fpTracer.WriteLine(CStr( sj(global_k, idx1)))
						fpTracer.WriteLine(CStr( su))
					End If
				Next ' global_k
			End If
			dd(i) = su * sj(i, 0)
			
			fpTracer.WriteLine(dd(i))
			fpTracer.WriteLine( sj(i, 0))
			fpTracer.WriteLine
		Next ' i
		
		
		WScript.Echo "Solve_Displacement:1"
		For i = (nn - 1) To baseIndex Step -1
			j = i + hbw - 1
			If j > (nn - 1) Then j = nn - 1
			
			su = dd(i)
			If i + 1 <= j Then
				For global_k = i + 1 To j
					If global_k + 1 > i Then
						
						idx2 = global_k - i
						su = su - sj(i, idx2) * dd(global_k)
						fpTracer.WriteLine( i)
						fpTracer.WriteLine( j)
						fpTracer.WriteLine( global_k)
						fpTracer.WriteLine( idx2)
						fpTracer.WriteLine(sj(i, idx2))
						fpTracer.WriteLine( su)
					End If
				Next ' global_k
			End If
			
			dd(i) = su * sj(i, 0)
			
			fpTracer.WriteLine( dd(i))
			fpTracer.WriteLine( sj(i, 0))
			fpTracer.WriteLine
		Next ' i
		
		
		'   Call WrFVector("Solve Displacements dd.. ", dd(), nn)
	End Sub '.. Solve_Displacements ..
	
	'End  ''.. CholeskiDecomp Module ..
	'===========================================================================
	
	
	'------------------------------------------------------------------------------
	'BEGIN:: ANALYSIS
	'------------------------------------------------------------------------------
	'###### Pf_Anal.PAS ######
	' ... a module of Analysis Routines for the Framework Program -
	'   R G Harrison  -- Version 1.1 -- 12/05/05 ...
	'   Revision history as-
	'    12/05/05 - implemented ..
	
	'<<< START CODE >>>>}
	'===========================================================================
	
	Function getArrayIndex(ByVal key)
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
				WScript.Echo "j3.. ",j3
				WScript.Echo "ubound(rjl): ",UBound(rjl)
				rjl(j3 - 2) = .rx
				rjl(j3 - 1) = .ry
				rjl(j3) = .rm
				WScript.Echo "rjl.. ", rjl(j3 - 2), rjl(j3 - 1), rjl(j3)
			End With
		Next ' global_i
		crl(baseIndex) = rjl(baseIndex)
		
		For global_i = baseIndex + 1 To n3 - 1
			crl(global_i) = crl(global_i - 1) + rjl(global_i)
			WScript.Echo "crl.. ", crl(global_i)
		Next ' global_i
		
		WScript.Echo "Fill_Restrained_Joints_Vector n3, nn, nr .. ", n3, nn, GModel.structParam.nr
		
	End Sub '.. Fill_Restrained_Joints_Vector ..
	
	
	'<< Check_J >>
	Private Function End_J
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
	End Function '.. End_J ..
	
	
	'<< End_K >>
	Private Function End_K
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
	End Function '.. End_K ..
	
	
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
				
				If Not End_J Then
					If Not End_K Then
						diff = Translate_Ndx(global_k) - Translate_Ndx(global_j) + 1
					End If
				End If
				
				If diff > hbw Then
					hbw = diff
				End If
				
			End With
		Next ' global_i
		
		WScript.Echo "Calc_Bandwidth hbw, nn .. ", hbw, nn
		
	End Sub '.. Calc_Bandwidth ..
	
	
	'<< Get_Stiff_Elements >>
	Private Sub Get_Stiff_Elements(i )
		Dim flag , msect , mnum
		Dim eiol
		
		With GModel.con_grp(i)
			msect = getArrayIndex(.sect)
			mnum = getArrayIndex(GModel.sec_grp(msect).mat)
			flag = .rel_i + .rel_j
			eiol = GModel.mat_grp(mnum).emod * GModel.sec_grp(msect).iz / mlen(i)
			
			'    .. initialise temp variables ..
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
	End Sub '.. Get_Stiff_Elements ..
	
	'<< Assemble_Stiff_Mat >>
	Private Sub Assemble_Stiff_Mat(i )
		
		WScript.Echo "Assemble_Stiff_Mat ..."
		
		Call Get_Stiff_Elements(i)
		
		WScript.Echo "eaol: ", eaol
		WScript.Echo "cosa: ", cosa
		WScript.Echo "sina: ", sina
		WScript.Echo "ccl: ", ccl
		WScript.Echo "ci: ", ci
		WScript.Echo "cj: ", cj
		WScript.Echo "ai: ", ai
		WScript.Echo "ao2: ", ao2
		WScript.Echo "aj: ", aj
		
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
		
		'		fpTracer.WriteLine( "S[]:")
		'		Call fprintMatrix(fpTracer, s)
		
		WScript.Echo "... Assemble_Stiff_Mat"
		
	End Sub '.. Assemble_Stiff_Mat ..
	
	'<< Assemble_Global_Stiff_Matrix >>
	Private Sub Assemble_Global_Stiff_Matrix(i )
		
		WScript.Echo "Assemble_Global_Stiff_Matrix ..."
		
		Call Get_Stiff_Elements(i)
		
		c2 = cosa * cosa
		s2 = sina * sina
		cs = cosa * sina
		
		' Wscript.Echo "eaol :", eaol
		' Wscript.Echo "cosa :", cosa
		' Wscript.Echo "sina :", sina
		'
		' Wscript.Echo "c2 :", c2
		' Wscript.Echo "s2 :", s2
		' Wscript.Echo "cs :", cs
		' Wscript.Echo "ccl :", ccl
		' Wscript.Echo "ci :", ci
		' Wscript.Echo "cj :", cj
		' Wscript.Echo "ai :", ai
		' Wscript.Echo "ao2 :", ao2
		' Wscript.Echo "aj :", aj
		' Wscript.Echo "-----------------------"
		
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
		
		'		fpTracer.WriteLine( "S[]: " & CStr(i))
		'		Call fprintMatrix(fpTracer, s)
		
		
		WScript.Echo "... Assemble_Global_Stiff_Matrix"
		
		
	End Sub '.. Assemble_Global_Stiff_Matrix ..
	
	'<< Load_Sj >>
	Private Sub Load_Sj(ByVal j , ByVal kk , ByVal stiffval )
		WScript.Echo "Load_Sj: ", j, kk, stiffval
		fpTracer.WriteLine("Load_Sj")
		global_k = Translate_Ndx(kk) - j '+ 1
		fpTracer.WriteLine( global_k)
		fpTracer.WriteLine( sj(j, global_k))
		sj(j, global_k) = sj(j, global_k) + stiffval
		fpTracer.WriteLine( sj(j, global_k))
		fpTracer.WriteLine( stiffval)
		
		fpTracer.WriteLine( j)
		fpTracer.WriteLine( global_k)
	End Sub '.. Load_Sj ..
	
	'<< Process_DOF_J1 >>
	Private Sub Process_DOF_J1()
		WScript.Echo "Process_DOF_J1 ..."
		fpTracer.WriteLine("Process_DOF_J1")
		global_j = Translate_Ndx(j1)
		
		sj(global_j, df1) = sj(global_j, df1) + s(df1, df1)
		
		
		If rjl(j2) = 0 Then
			sj(global_j, df2) = sj(global_j, df2) + s(df1, df2)
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
		
	End Sub '.. Process_DOF_J1 ..
	
	'<< Process_DOF_J2 >>
	Private Sub Process_DOF_J2()
		WScript.Echo "Process_DOF_J2 ..."
		global_j = Translate_Ndx(j2)
		
		sj(global_j, df1) = sj(global_j, df1) + s(df2, df2)
		
		If rjl(j3) = 0 Then
			sj(global_j, df2) = sj(global_j, df2) + s(df2, df3)
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
		
	End Sub '.. Process_DOF_J2 ..
	
	'<< Process_DOF_J3 >>
	Private Sub Process_DOF_J3()
		WScript.Echo "Process_DOF_J3 ..."
		global_j = Translate_Ndx(j3)
		
		sj(global_j, df1) = sj(global_j, df1) + s(df3, df3)
		
		If rjl(k1) = 0 Then
			Call Load_Sj(global_j, k1, s(df3, df4))
		End If
		
		If rjl(k2) = 0 Then
			Call Load_Sj(global_j, k2, s(df3, df5))
		End If
		
		If rjl(k3) = 0 Then
			Call Load_Sj(global_j, k3, s(df3, df6))
		End If
		
	End Sub '.. Process_DOF_J3 ..
	
	'<< Process_DOF_K1 >>
	Private Sub Process_DOF_K1()
		WScript.Echo "Process_DOF_K1 ..."
		global_j = Translate_Ndx(k1)
		sj(global_j, df1) = sj(global_j, df1) + s(df4, df4)
		
		If rjl(k2) = 0 Then
			sj(global_j, df2) = sj(global_j, df2) + s(df4, df5)
		End If
		
		If rjl(k3) = 0 Then
			Call Load_Sj(global_j, k3, s(df4, df6))
		End If
		
	End Sub '.. Process_DOF_K1 ..
	
	'<< Process_DOF_K2 >>
	Private Sub Process_DOF_K2()
		WScript.Echo "Process_DOF_K2 ..."
		global_j = Translate_Ndx(k2)
		
		sj(global_j, df1) = sj(global_j, df1) + s(df5, df5)
		
		If rjl(k3) = 0 Then
			sj(global_j, df2) = sj(global_j, df2) + s(df5, df6)
		End If
		
	End Sub '.. Process_DOF_K2 ..
	
	'<< Process_DOF_K3 >>
	Private Sub Process_DOF_K3()
		WScript.Echo "Process_DOF_K3 ..."
		global_j = Translate_Ndx(k3)
		
		
		sj(global_j, df1) = sj(global_j, df1) + s(df6, df6)
		
		
	End Sub '.. Process_DOF_K3 ..
	
	'<< Assemble_Struct_Stiff_Matrix >>
	Private Sub Assemble_Struct_Stiff_Matrix(i )
		'    .. initialise temp variables ..
		
		WScript.Echo "Assemble_Struct_Stiff_Matrix ...", i
		'Get indexes into the restrained joints list
		
		'Index for Node on near End of Member
		j3 = (3 * GModel.con_grp(i).jj) - 1
		j2 = j3 - 1
		j1 = j2 - 1
		
		'Index for Node on far End of Member
		k3 = (3 * GModel.con_grp(i).jk) - 1
		k2 = k3 - 1
		k1 = k2 - 1
		
		'Wscript.Echo j3, j2, j1, k3, k2, k1
		
		
		If rjl(j3) = 0 Then Call Process_DOF_J3   '.. do j3 ..
		If rjl(j2) = 0 Then Call Process_DOF_J2   '.. do j2 ..
		If rjl(j1) = 0 Then Call Process_DOF_J1   '.. do j1 ..
		
		If rjl(k3) = 0 Then Call Process_DOF_K3   '.. do k3 ..
		If rjl(k2) = 0 Then Call Process_DOF_K2   '.. do k2 ..
		If rjl(k1) = 0 Then Call Process_DOF_K1   '.. do k1 ..
		
		WScript.Echo "... Assemble_Struct_Stiff_Matrix"
		
	End Sub '.. Assemble_Struct_Stiff_Matrix ..
	
	
	'------------------------------------------------------------------------------
	'BEGIN:: ACTION-EFFECTS
	'------------------------------------------------------------------------------
	
	'<< Calc_Member_Forces >>
	Private Sub Calc_Member_Forces()
		
    		fpTracer.WriteLine("Calc_Member_Forces ..." & CStr(GModel.structParam.nmb))
		For global_i = baseIndex To GModel.structParam.nmb - 1
			With GModel.con_grp(global_i)
				
				Call Assemble_Stiff_Mat(global_i)
				
				'    .. initialise temporary end restraint indices ..
				j3 = 3 * .jj - 1
				j2 = j3 - 1
				j1 = j2 - 1
				
				k3 = 3 * .jk - 1
				k2 = k3 - 1
				k1 = k2 - 1
				
        			fpTracer.WriteLine(global_i)
        
       				fpTracer.WriteLine( .jj)
        			fpTracer.WriteLine( j3)
        			fpTracer.WriteLine( j2)
        			fpTracer.WriteLine( j1)
        
        			fpTracer.WriteLine(.jk)
        			fpTracer.WriteLine( k3)
        			fpTracer.WriteLine( k2)
        			fpTracer.WriteLine( k1)
				
				For global_j = baseIndex To df6
					ad(global_j) = s(global_j, df1) * dj(j1) + s(global_j, df2) * dj(j2) + s(global_j, df3) * dj(j3)
					ad(global_j) = ad(global_j) + s(global_j, df4) * dj(k1) + s(global_j, df5) * dj(k2) + s(global_j, df6) * dj(k3)
				Next ' global_j
				
				'.. Store End forces ..
				.jnt_jj.axial = -(af(global_i, df1) + ad(df1))
				.jnt_jj.shear = -(af(global_i, df2) + ad(df2))
				.jnt_jj.momnt = -(af(global_i, df3) + ad(df3))
				
				.jnt_jk.axial = af(global_i, df4) + ad(df4)
				.jnt_jk.shear = af(global_i, df5) + ad(df5)
				.jnt_jk.momnt = af(global_i, df6) + ad(df6)
				
			        fpTracer.WriteLine(.jnt_jj.axial)
			        fpTracer.WriteLine(.jnt_jj.shear)
			        fpTracer.WriteLine(.jnt_jj.momnt)
			        fpTracer.WriteLine(.jnt_jk.axial)
			        fpTracer.WriteLine(.jnt_jk.shear)
			        fpTracer.WriteLine(.jnt_jk.momnt)
				'.. Member Joint j End forces
				If rjl(j1) <> 0 Then ar(j1) = ar(j1) + ad(df1) * cosa - ad(df2) * sina  '.. Fx
				If rjl(j2) <> 0 Then ar(j2) = ar(j2) + ad(df1) * sina + ad(df2) * cosa  '.. Fy
				If rjl(j3) <> 0 Then ar(j3) = ar(j3) + ad(df3)              '.. Mz
				
				'.. Member Joint k End forces
				If rjl(k1) <> 0 Then ar(k1) = ar(k1) + ad(df4) * cosa - ad(df5) * sina  '.. Fx
				If rjl(k2) <> 0 Then ar(k2) = ar(k2) + ad(df4) * sina + ad(df5) * cosa  '.. Fy
				If rjl(k3) <> 0 Then ar(k3) = ar(k3) + ad(df6)              '.. Mz
				
			End With
			
			fpTracer.WriteLine
		Next ' global_i
		
	End Sub '.. Calc_Member_Forces ..
	
	'<< Calc_Joint_Displacements >>
	Private Sub Calc_Joint_Displacements()
		For global_i = baseIndex To n3 - 1
			If rjl(global_i) = 0 Then dj(global_i) = dd(Translate_Ndx(global_i))
		Next ' global_i
	End Sub '.. Calc_Joint_Displacements ..
	
	'<< Get_Span_Moments >>
	Private Sub Get_Span_Moments()
		Dim seg, stn
		Dim rx
		Dim mx
		Dim i , j
		
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
					'     With mem_lod(i)
					''      If (.lcode = 2) _
					''       And (stn >= .start) _
					''       And (stn - .start < seg) Then
					''        stn = .start
					''      End If
					If poslope Then
						mom_spn(i, j) = mom_spn(i, j) + rx * stn - mx
					Else
						mom_spn(i, j) = mom_spn(i, j) + rx * (stn - mlen(i)) - mx
					End If
					
					'     End With
				Next ' j
			End With
			
		Next ' i
	End Sub '.. Get_Span_Moments ..
	
	
	'===========================================================================
	'###### Pf_Load.PAS ######
	' ... a unit file of load analysis routines for the Framework Program-
	'   R G Harrison  -- Version 5.2 -- 30/ 3/96 ...
	'   Revision history as-
	'    29/7/90 - implemented ..
	'===========================================================================
	
	'<<< In_Cover >>>
	Private Function In_Cover(ByVal x1 , ByVal x2 , ByVal mlen )
		'  Call schTrace.wbkWriteln("In_Cover ...")
		
		If (x2 = mlen) Or (x2 > mlen) Then
			In_Cover = True
		Else
			In_Cover = ((stn >= x1) And (stn <= x2))
		End If
	End Function '...In_Cover...
	
	
	'<< Calc_Moments >>
	'.. RGH  12/4/92
	'.. calc moments ..
	Private Sub Calc_Moments(ByVal mn , ByVal mlen , ByVal wtot , _
		ByVal x1 , ByVal la , ByVal cv , ByVal wty , _
		ByVal lslope )
		Dim x
		Dim x2
		Dim Lx
		Dim idx1
		
		fpTracer.WriteLine("Calc_Moments ...")
		fpTracer.WriteLine(mn)
		fpTracer.WriteLine
		
		idx1 = mn - 1
		
		x2 = x1 + cv
		
		seg = mlen / n_segs
		
		If cv <> 0 Then w1 = wtot / cv
		
		For global_j = startZero To n_segs
			stn = global_j * seg
			
			If poslope Then
				x = stn - x1           '.. dist to sect from stn X-X..
				Lx = stn - la
			Else
				x = x2 - stn
				Lx = la - stn
			End If
			
			If In_Cover(x1, x2, mlen) Then
				Select Case wty         '.. calc moments if inside load cover..
					Case udl_ld          '  Uniform Load
					mom_spn(idx1, global_j) = mom_spn(idx1, global_j) - w1 * x ^ 2 / 2
					
					Case tri_ld          '  Triangular Loads
					mom_spn(idx1, global_j) = mom_spn(idx1, global_j) - (w1 * x ^ 2 / cv) * x / 3
				End Select
			Else
				If x <= 0 Then
					Lx = 0
				End If
				
				mom_spn(idx1, global_j) = mom_spn(idx1, global_j) - wtot * Lx
				
			End If
			
		Next ' global_j
		
		
	End Sub   '.. Calc_Moments ..
	
	
	'<< Combine_Joint_Loads >>
	Private Sub Combine_Joint_Loads(kMember )
		Dim k
		
		WScript.Echo "Combine_Joint_Loads ..."
		fpTracer.WriteLine("Combine_Joint_Loads ...")
    		fpTracer.WriteLine(kMember)
		fpTracer.WriteLine
		k = kMember - 1
		cosa = rot_mat(k, ndx1)
		sina = rot_mat(k, ndx2)
    		fpTracer.WriteLine("cosa")
    		fpTracer.WriteLine(cosa)
    		fpTracer.WriteLine
    		fpTracer.WriteLine("sina")
    		fpTracer.WriteLine(sina)
    		fpTracer.WriteLine
		
		'  ... Process end A
		Get_Joint_Indices (GModel.con_grp(k).jj)
		
    		fpTracer.WriteLine("fc[]")
    		fpTracer.WriteLine(fc(j1))
    		fpTracer.WriteLine(fc(j2))
    		fpTracer.WriteLine(fc(j3))
    		fpTracer.WriteLine
		
		fc(j1) = fc(j1) - a_i * cosa + ri * sina  '.. Fx
		fc(j2) = fc(j2) - a_i * sina - ri * cosa  '.. Fy
		fc(j3) = fc(j3) - fi                      '.. Mz
		
    		fpTracer.WriteLine("fc[]")
    		fpTracer.WriteLine(fc(j1))
    		fpTracer.WriteLine(fc(j2))
    		fpTracer.WriteLine(fc(j3))
    		fpTracer.WriteLine
		'  ... Process end B
		Get_Joint_Indices (GModel.con_grp(k).jk)
    		fpTracer.WriteLine("fc[]")
    		fpTracer.WriteLine(fc(j1))
    		fpTracer.WriteLine(fc(j2))
    		fpTracer.WriteLine(fc(j3))
    		fpTracer.WriteLine
		
		fc(j1) = fc(j1) - a_j * cosa + rj * sina  '.. Fx
		fc(j2) = fc(j2) - a_j * sina - rj * cosa  '.. Fy
		fc(j3) = fc(j3) - fj                      '.. Mz
    		fpTracer.WriteLine("fc[]")
    		fpTracer.WriteLine(fc(j1))
    		fpTracer.WriteLine(fc(j2))
    		fpTracer.WriteLine(fc(j3))
    		fpTracer.WriteLine
		WScript.Echo "... Combine_Joint_Loads"
	End Sub '.. Combine_Joint_Loads ..
	
	' << Calc_FE_Forces >>
	Private Sub Calc_FE_Forces(ByVal kMember , ByVal la , ByVal lb )
		Dim k
		
		WScript.Echo "Calc_FE_Forces ..."
		k = kMember - 1
		
  		fpTracer.WriteLine("Calc_FE_Forces ...")
  		fpTracer.WriteLine(kMember)
  		fpTracer.WriteLine
  		fpTracer.WriteLine("trl:")
  		fpTracer.WriteLine(trl)
  		fpTracer.WriteLine
  		fpTracer.WriteLine("djj:")
 		fpTracer.WriteLine(djj)
  		fpTracer.WriteLine
  		fpTracer.WriteLine("dii:")
  		fpTracer.WriteLine(dii)
  		fpTracer.WriteLine
		'.. both ends fixed
		fi = (2 * djj - 4 * dii) / trl
		fj = (4 * djj - 2 * dii) / trl
		With GModel.con_grp(k)
      			fpTracer.WriteLine("jj and jk: ")
      			fpTracer.WriteLine(GModel.con_grp(k).jj)
      			fpTracer.WriteLine(GModel.con_grp(k).jk)
     			fpTracer.WriteLine
			
			flag = .rel_i + .rel_j
      			fpTracer.WriteLine("Flag:")
     			fpTracer.WriteLine(flag)
      			fpTracer.WriteLine
			
			If flag = 2 Then       '.. both ends pinned
				fi = 0
				fj = 0
			End If
			
			If flag = 1 Then       '.. propped cantilever
				If (.rel_i = 0) Then    '.. end i pinned
					fi = fi - fj / 2
					fj = 0
				Else            '.. end j pinned
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
		
		WScript.Echo "... Calc_FE_Forces"
	End Sub '.. Calc_FE_Forces ..
	
	
	'<< Accumulate_FE_Actions >>
	Private Sub Accumulate_FE_Actions(ByVal kMemberNum )
		Dim k
		
		WScript.Echo "Accumulate_FE_Actions ..."
		fpTracer.WriteLine("Accumulate_FE_Actions ...")
  		fpTracer.WriteLine(kMemberNum)
  		fpTracer.WriteLine
		k = kMemberNum - 1
		
		af(k, df1) = af(k, df1) + a_i
		af(k, df2) = af(k, df2) + ri
		af(k, df3) = af(k, df3) + fi
		af(k, df4) = af(k, df4) + a_j
		af(k, df5) = af(k, df5) + rj
		af(k, df6) = af(k, df6) + fj
		
		WScript.Echo "... Accumulate_FE_Actions"
	End Sub '.. Accumulate_FE_Actions ..
	
	
	'<< Process_FE_Actions >>
	Private Sub Process_FE_Actions(ByVal kMemberNum , ByVal la , ByVal lb )
		WScript.Echo "Process_FE_Actions ..."
		fpTracer.WriteLine("Process_FE_Actions ...")
  		fpTracer.WriteLine(kMemberNum)
  		fpTracer.WriteLine
		Call Accumulate_FE_Actions(kMemberNum)
		Call Combine_Joint_Loads(kMemberNum)
		
		WScript.Echo "... Process_FE_Actions"
	End Sub '.. Process_FE_Actions ..
	
	
	'<< Do_Global_Load >>
	Private Sub Do_Global_Load(ByVal mem , ByVal acd , ByVal w0 , ByVal start )
		WScript.Echo "Do_Global_Load ..."
		fpTracer.WriteLine("Do_Global_Load ...")
		Select Case acd
			Case global_x      ' .. global X components
			nrm_comp = w0 * sina
			axi_comp = w0 * cosa
			
			Case global_y      ' .. global Y components
			nrm_comp = w0 * cosa
			axi_comp = w0 * sina
		End Select
		WScript.Echo "... Do_Global_Load"
	End Sub '.. Do_Global_Load ..
	
	
	'<< Do_Axial_Load >>
	'.. Load type = "v" => #3
	Private Sub Do_Axial_Load(ByVal mno , ByVal wu , ByVal x1 )
		WScript.Echo "Do_Axial_Load ..."
		fpTracer.WriteLine("Do_Axial_Load ...")
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
		
		WScript.Echo "... Do_Axial_Load"
	End Sub '.. Do_Axial_Load ..
	
	
	'<< Do_Self_Weight >>
	Private Sub Do_Self_Weight(ByVal mem )
		Dim msect , mat
		Dim idxMem , idxMsect , idxMat
		
		WScript.Echo "Do_Self_Weight ..."
		fpTracer.WriteLine("Do_Self_Weight ...")
		
		'Convert Member Number to Array Index
		idxMem = mem - 1
		
		'Convert Section Number to Array Index
		msect = GModel.con_grp(idxMem).sect
		idxMsect = msect - 1
		
		'Convert Material Number to Array Index
		mat = GModel.sec_grp(idxMsect).mat
		idxMat = mat - 1
		
		udl = udl * GModel.mat_grp(idxMat).density * GModel.sec_grp(idxMsect).ax / kilo
		
		WScript.Echo "... Do_Self_Weight"
	End Sub '.. Do_Self_Weight ..
	
	
	'<< UDL_Slope >>
	Private Function UDL_Slope(w0 , v , c )
		'WScript.Echo "UDL_Slope"
		fpTracer.WriteLine("UDL_Slope ...")
		UDL_Slope = w0 * v * (4 * (trl ^ 2 - v ^ 2) - c ^ 2) / (24 * trl)
	End Function '.. UDL_Slope ..
	
	
	'<< Do_Part_UDL >>
	'.. Load type = "u" => #1
	Private Sub Do_Part_UDL(ByVal mno , ByVal wu , ByVal x1 , _
		ByVal cv , ByVal wact )
		Dim la , lb
		
		WScript.Echo "Do_Part_UDL ..."
		fpTracer.WriteLine("Do_Part_UDL ...")
		
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
		
		WScript.Echo "... Do_Part_UDL"
	End Sub   '.. Do_Part_UDL ..
	
	
	'<< PL_Slope >>
	Private Function PL_Slope(v )
		PL_Slope = w_nrm * v * (trl ^ 2 - v ^ 2) / (6 * trl)
	End Function '.. PL_Slope ..
	
	
	'<< Do_Point_load >>
	'.. Load type = "p" => #2
	Private Sub Do_Point_load(ByVal mno , ByVal wu , ByVal x1 , wact )
		WScript.Echo "Do_Point_load ..."
		fpTracer.WriteLine("Do_Point_load ...")
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
		WScript.Echo "... Do_Point_load"
	End Sub '.. Do_Point_load ..
	
	
	'<< Tri_Slope >>
	Private Function Tri_Slope(ByVal v , ByVal w_nrm , ByVal cv , _
		ByVal sl_switch )
		
		gam = cv / trl
		v = v / trl
		Tri_Slope = w_nrm * _
		trl ^ 2 * (270 * (v - v ^ 3) - gam ^ 2 * (45 * v + sl_switch * 2 * gam)) / 1620
		
	End Function '.. Tri_Slope ..
	
	'<< Do_Triangle >>
	'.. Load type =
	Private Sub Do_Triangle(ByVal mno , ByVal w0 , ByVal la , _
		ByVal x1 , ByVal cv , wact , ByVal slopedir )
		
		Dim lb
		
		WScript.Echo "Do_Triangle ..."
		fpTracer.WriteLine("Do_Triangle ...")
		
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
		
		dii = Tri_Slope(lb, w_nrm, cv, pos_slope * slopedir)   '.. /! => +ve when +ve slope
		djj = Tri_Slope(la, w_nrm, cv, neg_slope * slopedir)   '.. !\ => +ve when -ve slope
		
		Call Calc_Moments(mno, trl, w_nrm, x1, la, cv, tri_ld, slopedir) '.. Calculate the span moments
		Call Calc_FE_Forces(mno, la, lb)
		Call Process_FE_Actions(mno, la, lb)
		
		WScript.Echo "... Do_Triangle"
	End Sub '.. Do_Triangle ..
	
	'<< Do_Distributed_load >>
	'.. Load type = "v" => #1
	Private Sub Do_Distributed_load(ByVal mno , ByVal wm1 , ByVal wm2 , _
		ByVal x1 , ByVal cv , ByVal lact )
		
		Dim wudl , wtri , slope , ltri
		
		WScript.Echo "Do_Distributed_load ..."
		fpTracer.WriteLine("Do_Distributed_load ...")
 		fpTracer.WriteLine(mno)
 		fpTracer.WriteLine("wm1: " & CStr(wm1))
 		fpTracer.WriteLine("wm2: " & CStr(wm2))
		If wm1 = wm2 Then         '.. load is a UDL
			fpTracer.WriteLine("Load is UDL ...")
			Call Do_Part_UDL(mno, wm1, x1, cv, lact)
		Else
			If Abs(wm1) < Abs(wm2) Then   '.. positive slope ie sloping upwards / left to right
				wudl = wm1
				wtri = wm2 - wudl
				slope = pos_slope
				ltri = x1 + 2 * cv / 3
			Else              '.. negative slope ie sloping upwards \ right to left
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
		
		WScript.Echo "... Do_Distributed_load"
	End Sub '.. Do_Distributed_load ..
	
	'<< Get_FE_Forces >>
	Private Sub Get_FE_Forces(ByVal kMemberNum , ByVal ldty , ByVal wm1 , _
		ByVal wm2 , ByVal x1 , ByVal cvr , ByVal lact )
		
		WScript.Echo "Get_FE_Forces ..."
		fpTracer.WriteLine("Get_FE_Forces ...")
      		fpTracer.WriteLine(kMemberNum)
		Select Case ldty        '.. Get_FE_Forces ..
			
			Case dst_ld                       '.. "v" = #1
			Call Do_Distributed_load(kMemberNum, wm1, wm2, x1, cvr, lact)
			Case pnt_ld                       '.. "p" = #2
			Call Do_Point_load(kMemberNum, wm1, x1, lact)
			Case axi_ld                       '.. "a" = #3
			Call Do_Axial_Load(kMemberNum, wm1, x1)
			
		End Select
		WScript.Echo "... Get_FE_Forces"
		
	End Sub '.. Get_FE_Forces ..
	
	' << Process_Loadcases >>
	Private Sub Process_Loadcases()
		
		Dim r
		Dim idxMem
		
		WScript.Echo "Process_Loadcases ..."
		
		'Joint Loads
		WScript.Echo "Joint Loads:"
		fpTracer.WriteLine("Joint Loads:" & CStr(GModel.structParam.njl))
		If GModel.structParam.njl <> 0 Then 'Have Joint Loads
      		fpTracer.WriteLine ("FC[]:")
			For global_i = baseIndex To GModel.structParam.njl - 1
				With GModel.jnt_lod(global_i)
					Get_Joint_Indices (.jt)
					
					fc(j1) = .fx
					fc(j2) = .fy
					fc(j3) = .mz
					
          				fpTracer.WriteLine(fc(j1))
          				fpTracer.WriteLine(fc(j2))
          				fpTracer.WriteLine(fc(j3))
					r = r + 1
				End With
			Next ' global_i
		Else
			WScript.Echo "njl=0 : No Joint Loads"
		End If
		fpTracer.WriteLine( "FC[]: Joint Loads: ")
		Call fprintVector(fpTracer, fc)
		
		
		
		'Member Loads
		WScript.Echo "Member Loads:"
		fpTracer.WriteLine("Member Loads:" & CStr(GModel.structParam.nml))
		If GModel.structParam.nml <> 0 Then 'Have Member Loads
			
			For global_i = baseIndex To GModel.structParam.nml - 1
				WScript.Echo "Member Load: " & CStr(global_i)
				With GModel.mem_lod(global_i)
					idxMem = .mem_no - 1 'Member Numbers start at 1, arrays indexed from 0
					fpTracer.WriteLine(CStr(.mem_no))
					trl = mlen(idxMem)
					fpTracer.WriteLine(CStr(trl))
					cosa = rot_mat(idxMem, ndx1)  '.. Cos
					sina = rot_mat(idxMem, ndx2)  '.. Sin
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
					fpTracer.WriteLine( "FC[]: Member Loads: " & FormatNumber(global_i,0))
					Call fprintVector(fpTracer, fc)
				End With

				WScript.Echo "----------"
			Next ' global_i
		Else
			WScript.Echo "nml=0 : No Member Loads"
		End If
		
		
		
		'Gravity Loads
		WScript.Echo "Gravity Loads:"
		fpTracer.WriteLine("Gravity Loads:" & CStr(GModel.structParam.ngl))
		If GModel.structParam.ngl <> 0 Then 'Have Gravity Loads
			For global_i = baseIndex To GModel.structParam.nmb - 1
				With GModel.grv_lod
					x1 = 0
					trl = mlen(global_i)
					cvr = trl
					cosa = rot_mat(global_i, ndx1)
					sina = rot_mat(global_i, ndx2)
					udl = .load
					ldc = dst_ld    ' ud_ld    '.. 1
					Call Do_Self_Weight(global_i)
					nrm_comp = udl
					If .f_action <> local_act Then
						Call Do_Global_Load(global_i, .f_action, udl, 0)
					End If
					Call Get_FE_Forces(global_i, dst_ld, nrm_comp, nrm_comp, x1, cvr, .f_action)
				End With
			Next ' global_i
		Else
			WScript.Echo "ngl=0 : No Gravity Loads"
		End If
		fpTracer.WriteLine( "FC[]: Gravity Loads: ")
		Call fprintVector(fpTracer, fc)
		
    		fpTracer.WriteLine("... Process_Loadcases")
		
		WScript.Echo "... Process_Loadcases"
	End Sub '.. Process_Loadcases ..
	
	
	'<< Zero_Vars >>
	Public Sub Zero_Vars()
		Dim i,j
		
		WScript.Echo "Zero_Vars ..."
		'NB: Erase deallocates dynamic-array storage space.
		'		Erase mlen ' Each element set to 0.
		'		Erase ad
		'		Erase fc
		'		Erase ar
		'		Erase dj
		'		Erase dd
		'		Erase rjl
		'		Erase crl
		'		Erase rot_mat
		'		Erase af
		'		Erase sj
		'		Erase s
		'		Erase mom_spn
		For i=0 To v_size
			mlen(i) = 0.00
		Next 'i
		
		For i=0 To v_size
			ad(i) = 0.00
		Next 'i
		
		For i=0 To v_size
			fc(i) = 0.00
		Next 'i
		
		For i=0 To v_size
			ar(i) = 0.00
		Next 'i
		
		For i=0 To v_size
			dj(i) = 0.00
		Next 'i
		
		For i=0 To v_size
			dd(i) = 0.00
		Next 'i
		
		For i=0 To v_size
			rjl(i) = 0 'integer
		Next 'i
		
		For i=0 To v_size
			crl(i) = 0 'integer
		Next 'i
		
		For i=0 To v_size
			For j=0 To ndx2
				rot_mat(i,j) = 0.00
			Next 'j
		Next 'i
		
		For i=0 To order
			For j=0 To v_size
				af(i,j) = 0.00
			Next 'j
		Next 'i
		
		For i=0 To order
			For j=0 To v_size
				sj(i,j) = 0.00
			Next 'j
		Next 'i
		
		For i=0 To order
			For j=0 To v_size
				s(i,j) = 0.00
			Next 'j
		Next 'i
		
		
		For i=0 To max_grps
			For j=0 To n_segs
				mom_spn(i,j) = 0.00
			Next 'j
		Next 'i
		
		WScript.Echo "... Zero_Vars"
	End Sub '.. Zero_Vars ..
	
	Public Sub initialise0
		Set  GModel = New clsGeomModel
		
		ReDim mlen(v_size)                 '.. member length ..
		
		ReDim rjl(v_size)                  '.. restrained joint list ..
		ReDim crl(v_size)                  '.. cumulative joint restraint list ..
		
		ReDim fc(v_size)                   '.. combined joint loads ..
		
		ReDim dd(v_size)                   '.. joint displacements @ free nodes ..
		ReDim dj(v_size)                   '.. joint displacements @ ALL the nodes ..
		ReDim ad(v_size)                   '.. member end forces not including fixed end forces ..
		ReDim ar(v_size)                   '.. support reactions ..
		
		'Matrices
		ReDim rot_mat(v_size, ndx2)        '.. member rotation matrix ..
		ReDim s(order, v_size)             '.. member stiffness matrix ..
		ReDim sj(order, v_size)            '.. joint stiffness matrix ..
		
		ReDim af(order, v_size)            '.. member fixed end forces ..
		ReDim mom_spn(max_grps,n_segs)     '.. member span moments ..
	End Sub
	
	
	'<< Initialise >>
	Public Sub initialise()
		WScript.Echo "PlaneFrame: Initialise ..."
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
		
		If Not (data_loaded) Then GModel.initialise
		
		Call Zero_Vars
		
		If data_loaded Then
			WScript.Echo "Data Loaded: Get Direction Cosines"
			Call Get_Direction_Cosines
		Else
			WScript.Echo "<<<< Data Not Loaded >>>>"
		End If
		WScript.Echo "... PlaneFrame : Initialise"
	End Sub '.. Initialise ..
	
	'<< Translate_Ndx >>
	'.. Restrained joint index
	Private Function Translate_Ndx(ByVal i )
		Translate_Ndx = i - crl(i)
	End Function '.. Translate_Ndx ..
	
	'<< Equiv_Ndx >>
	'..equivalent matrix configuration joint index numbers
	Private Function Equiv_Ndx(ByVal j )
		
		Equiv_Ndx = rjl(j) * (nn + crl(j)) + (1 - rjl(j)) * Translate_Ndx(j)
	End Function '.. Equiv_Ndx ..
	
	'<< Get_Joint_Indices >>
	'.. get equivalent matrix index numbers
	Private Sub Get_Joint_Indices(ByVal nd )
		
		j0 = (3 * nd) - 1
		j3 = Equiv_Ndx(j0)
		j2 = j3 - 1
		j1 = j2 - 1
		
		
	End Sub   '.. Get_Joint_Indices ..
	
	'<< Get_Direction_Cosines >>
	Private Sub Get_Direction_Cosines
		Dim i , tmp , rel_tmp
		Dim xm , ym
		
		WScript.Echo "Get_Direction_Cosines ..."
		
		' Call schTrace.wbkWriteln("Get_Direction_Cosines ...")
		
		For i = baseIndex To GModel.structParam.nmb - 1
			'Wscript.Echo i, nmb
			With GModel.con_grp(i)
				If .jk < .jj Then '.. swap end1 with end2 if smaller !! ..
					tmp = .jj
					.jj = .jk
					.jk = tmp
					
					rel_tmp = .rel_j
					.rel_j = .rel_i
					.rel_i = rel_tmp
				End If
				
				'Wscript.Echo "STEP:1", i, .jk, getArrayIndex(.jk), .jj, getArrayIndex(.jj)
				xm = GModel.nod_grp(getArrayIndex(.jk)).x - GModel.nod_grp(getArrayIndex(.jj)).x
				ym = GModel.nod_grp(getArrayIndex(.jk)).y - GModel.nod_grp(getArrayIndex(.jj)).y
				mlen(i) = Sqr(xm * xm + ym * ym)
				
				
				WScript.Echo i, ": mlen[i]: ", mlen(i)
				
				rot_mat(i, ndx1) = xm / mlen(i)   '.. Cos
				rot_mat(i, ndx2) = ym / mlen(i)   '.. Sin
				
			End With
			
		Next ' i
		
		WScript.Echo "... Get_Direction_Cosines"
		
	End Sub '.. Get_Direction_Cosines ..
	
	
	
	'<< Total_Section_Mass >>
	Private Sub Total_Section_Mass()
		Dim i
		
		
		For i = baseIndex To GModel.structParam.nsg - 1
			'   With mat_grp(sec_grp(i).mat)
			'    sec_grp(i).t_mass = sec_grp(i).ax * .Density * sec_grp(i).t_len
			GModel.sec_grp(i).t_mass = GModel.sec_grp(i).ax * GModel.mat_grp(getArrayIndex(GModel.sec_grp(i).mat)).density * GModel.sec_grp(i).t_len
			'   End With
		Next ' i
	End Sub '.. Total_Section_Mass ..
	
	
	
	'<< Total_Section_Length >>
	Private Sub Total_Section_Length()
		Dim ndx
		
		
		For global_i = baseIndex To GModel.structParam.nmb - 1
			ndx = getArrayIndex(GModel.con_grp(global_i).sect)
			'With con_grp(global_i)
			'sec_grp(.sect).t_len = sec_grp(.sect).t_len + mlen(global_i)
			GModel.sec_grp(ndx).t_len = GModel.sec_grp(ndx).t_len + mlen(global_i)
			'End With
		Next ' global_i
		Call Total_Section_Mass
	End Sub '.. Total_Section_Length ..
	
	
	'<< Get_Min_Max >>
	'..find critical End forces ..
	Private Sub Get_Min_Max()
		
		
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
				
				'     .. End moments ..
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
				
				'     .. End axials ..
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
				
				'     .. End shears..
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
		Next ' global_i
	End Sub   '.. Get_Min_Max ..
	
	'<<---------------------------------------------------------------------->>
	'<< Analyse_Frame                                                        >>
	'<<---------------------------------------------------------------------->>
	Sub Analyse_Frame()
		
		Dim i
		
		
		'Get definition of the Plane Frame to Analyse
		
		WScript.Echo "Analyse_Frame ..."
		WScript.Echo ">>> Design Frame Started <<<"
		initialise
		
		'BEGIN PLANEFRAME ANALYSIS
		fpTracer.WriteLine("mlen: ")
		Call fprintVector(fpTracer,mlen)
		
		Call Fill_Restrained_Joints_Vector
		fpTracer.WriteLine("rjl: ")
		Call fprintVector(fpTracer,rjl)
		fpTracer.WriteLine("crl: ")
		Call fprintVector(fpTracer,crl)
		
		fpTracer.WriteLine("Calculate Total Section Length")
		Call Total_Section_Length
		fpTracer.WriteLine("Calculate Band Width")
		Call Calc_Bandwidth
		fpTracer.WriteLine("hbw: " & CStr(hbw))
		fpTracer.WriteLine("nn: " & CStr(nn))
		
		
		For i = baseIndex To GModel.structParam.nmb - 1
			WScript.Echo "Analyse_Frame: i = ", i
			Call Assemble_Global_Stiff_Matrix(i)
			fpTracer.WriteLine( "S[]: " & CStr(i))
			Call fprintMatrix(fpTracer, s)
			
			Call Assemble_Struct_Stiff_Matrix(i)
			fpTracer.WriteLine( "SJ[]: " & CStr(i))
			Call fprintMatrix(fpTracer, sj)
			
		Next ' i
		WScript.Echo "End of Matrix Assembly"
		WScript.Echo "======================"
		
		fpTracer.WriteLine("Choleski Decomposition")
		Call Choleski_Decomposition(sj, nn, hbw)
		fpTracer.WriteLine( "SJ[]: Result")
		Call fprintMatrix(fpTracer, sj)
		WScript.Echo "======================"
		
		'------------------------------------------------------------------------------
		fpTracer.WriteLine("rot_mat: ")
		Call fprintMatrix(fpTracer,rot_mat)
		
		fpTracer.WriteLine( "Process_Loadcases")
		Call Process_Loadcases
		
		fpTracer.WriteLine( "FC[]: Result: ")
		Call fprintVector(fpTracer, fc)
		
		fpTracer.WriteLine( "AF[]: ")
		Call fprintMatrix(fpTracer, af)
		WScript.Echo "======================"
		
		
		WScript.Echo "Solve_Displacements"
		fpTracer.WriteLine( "Solve_Displacements")
		Call Solve_Displacements
		fpTracer.WriteLine( "DD[]: ")
		Call fprintVector(fpTracer, dd)
		
		WScript.Echo "Calc_Joint_Displacements"
		fpTracer.WriteLine("Calc_Joint_Displacements")
		Call Calc_Joint_Displacements
		fpTracer.WriteLine( "DJ[]: ")
		Call fprintVector(fpTracer, dj)
		
		WScript.Echo "Calc_Member_Forces"
		fpTracer.WriteLine( "Calc_Member_Forces")
		Call Calc_Member_Forces
		
		fpTracer.WriteLine( "AD[]: ")
		Call fprintVector(fpTracer, ad)
		fpTracer.WriteLine( "AR[]: ")
		Call fprintVector(fpTracer, ar)
		
		WScript.Echo "Get_Span_Moments"
		fpTracer.WriteLine( "Get_Span_Moments:")
		Call Get_Span_Moments
		fpTracer.WriteLine( "mom_spn:")
		Call fprintMatrix(fpTracer, mom_spn)
		
		WScript.Echo "Get_Min_Max"
		fpTracer.WriteLine( "Get_Min_Max:")
		Call Get_Min_Max
		
		fpTracer.WriteLine( "Analysis Complete!")
		'END OF PLANEFRAME ANALYSIS
		
		'Trace all Arrays for Reference
		'-------------------------------
				fpTracer.WriteLine("crl: ")
				Call fprintVector(fpTracer,crl)
		
				fpTracer.WriteLine("rjl: ")
				Call fprintVector(fpTracer,rjl)
		
				fpTracer.WriteLine("mlen: ")
				Call fprintVector(fpTracer,mlen)
		
				fpTracer.WriteLine("ad: ")
				Call fprintVector(fpTracer,ad)
		
				fpTracer.WriteLine("fc: ")
				Call fprintVector(fpTracer,fc)
		
				fpTracer.WriteLine("ar: ")
				Call fprintVector(fpTracer,ar)
		
				fpTracer.WriteLine("dj: ")
				Call fprintVector(fpTracer,dj)
		
				fpTracer.WriteLine("dd: ")
				Call fprintVector(fpTracer,dd)
		
				fpTracer.WriteLine("rot_mat: ")
				Call fprintMatrix(fpTracer,rot_mat)
		
				fpTracer.WriteLine("af: ")
				Call fprintMatrix(fpTracer,af)
		
				fpTracer.WriteLine("s: ")
				Call fprintMatrix(fpTracer,s)
		
				fpTracer.WriteLine("mom_spn: ")
				Call fprintMatrix(fpTracer,mom_spn)
		
				fpTracer.WriteLine("sj: ")
				Call fprintMatrix(fpTracer,sj)
		
		
		'End Trace of Arrays
		'============================================================================
		
		
		'Do something with the results of the analysis
		'This can be done in the main calling application
		
		WScript.Echo "*** Analysis Completed *** "
		WScript.Echo "... Analyse_Frame"
		WScript.Echo "==============================================================================="
	End Sub '.. Analyse_Frame ..
	
	'==========================================================================
	'END  ''.. Main Module ..
	'==========================================================================
	
	'--------------------------------------------------------------------------
	'BEGIN:: ADDITIONAL INPUT ROUTINES
	'--------------------------------------------------------------------------
	
	Public Sub addNode(x , y )
		Dim aNode
		
		Set aNode = New clsPfCoordinate
		aNode.initialise
		aNode.x = x
		aNode.y = y
		' GModel.nod_grp(njt).x = x
		' GModel.nod_grp(njt).y = y
		Set GModel.nod_grp(GModel.structParam.njt) = aNode
		WScript.Echo "njt", GModel.structParam.njt
		GModel.structParam.njt = GModel.structParam.njt + 1
	End Sub
	
	Public Sub addMaterialGroup(density , ElasticModulus , CoeffThermExpansion )
		
		With GModel.mat_grp(GModel.structParam.nmg)
			.density = density
			.emod = ElasticModulus
			.therm = CoeffThermExpansion
		End With
		GModel.structParam.nmg = GModel.structParam.nmg + 1
	End Sub
	
	Public Sub addSectionGroup(SectionArea , SecondMomentArea , materialKey , Description )
		
		With GModel.sec_grp(GModel.structParam.nsg)
			.ax = SectionArea
			.iz = SecondMomentArea
			.mat = materialKey
			.Descr = Description
		End With
		GModel.structParam.nsg = GModel.structParam.nsg + 1
	End Sub
	
	
	Public Sub addMember(NodeA , NodeB , sectionKey , ReleaseA , ReleaseB )
		
		With GModel.con_grp(GModel.structParam.nmb)
			.jj = NodeA
			.jk = NodeB
			.sect = sectionKey
			.rel_i = ReleaseA
			.rel_j = ReleaseB
		End With
		GModel.structParam.nmb = GModel.structParam.nmb + 1
	End Sub
	
	Public Sub addSupport(SupportNode , RestraintX , RestraintY , RestraintMoment )
		
		With GModel.sup_grp(GModel.structParam.nrj)
			.js = SupportNode
			.rx = RestraintX
			.ry = RestraintY
			.rm = RestraintMoment
			GModel.structParam.nr = GModel.structParam.nr + .rx + .ry + .rm
		End With
		GModel.structParam.nrj = GModel.structParam.nrj + 1
	End Sub
	
	Public Sub addJointLoad(Node , ForceX , ForceY , Moment )
		
		With GModel.jnt_lod(GModel.structParam.njl)
			.jt = Node
			.fx = ForceX
			.fy = ForceY
			.mz = Moment
		End With
		GModel.structParam.njl = GModel.structParam.njl + 1
	End Sub
	
	Public Sub addMemberLoad(memberKey , LoadType , ActionKey _
		, LoadMag1 , LoadMag2 , LoadStart , LoadCover )
		
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
	
	Public Sub addGravityLoad(ActionKey , LoadMag )
		With GModel.grv_lod
			.f_action = ActionKey
			.load = LoadMag
		End With
	End Sub
	
	
	
	
	'------------------------------------------------------------------------------
	'REPORTS: Text Files
	'------------------------------------------------------------------------------
	
	'    <<< fprintDeltas >>>
	Sub fprintDeltas(ByVal fpRpt)
		Dim txt1, txt2, txt3, txt4
		Dim idx1, idx2, idx3
		
		WScript.Echo "fprintDeltas ..."
		fpRpt.WriteLine( "fprintDeltas ...")
		For global_i = baseIndex + 1 To GModel.structParam.njt
			txt1 = StrLPad(FormatNumber(global_i, 0), 4)
			
			idx1 = 3 * global_i - 3
			idx2 = 3 * global_i - 2
			idx3 = 3 * global_i - 1
			
			txt2 = StrLPad(FormatNumber(-dj(idx1), 4), 8)
			txt3 = StrLPad(FormatNumber(-dj(idx2), 4), 8)
			txt4 = StrLPad(FormatNumber(-dj(idx3), 4), 8)
			
			fpRpt.WriteLine( txt1 & " " & txt2 & " " & txt3 & " " & txt4)
			
		Next 'global_i
		
		fpRpt.WriteLine
		WScript.Echo "... fprintDeltas"
	End Sub '...fprintDeltas
	
	'   <<< fprintEndForces >>>
	Sub fprintEndForces(ByVal fpRpt)
		Dim txt0, txt1, txt2, txt3, txt4, txt5 
		Dim txt6, txt7, txt8, txt9, txt
		Dim i 
		
		WScript.Echo "fprintEndForces ..."
		fpRpt.WriteLine( "fprintEndForces ...")
		For i = baseIndex To GModel.structParam.nmb - 1
			txt0 = StrLPad(CStr(i), 8)
			txt1 = StrLPad(FormatNumber(mlen(i), 3), 8)
			
			txt2 = StrLPad(FormatNumber(GModel.con_grp(i).jj, 0), 8)
			txt3 = StrLPad(FormatNumber(GModel.con_grp(i).jnt_jj.axial, 4), 15)
			txt4 = StrLPad(FormatNumber(GModel.con_grp(i).jnt_jj.shear, 4), 15)
			txt5 = StrLPad(FormatNumber(GModel.con_grp(i).jnt_jj.momnt, 4), 15)
			
			txt6 = StrLPad(FormatNumber(GModel.con_grp(i).jk, 0), 8)
			txt7 = StrLPad(FormatNumber(GModel.con_grp(i).jnt_jk.axial, 4), 15)
			txt8 = StrLPad(FormatNumber(GModel.con_grp(i).jnt_jk.shear, 4), 15)
			txt9 = StrLPad(FormatNumber(GModel.con_grp(i).jnt_jk.momnt, 4), 15)
			
			txt = txt0 & " " & txt1 & " " & txt2 & " " & txt3 & " " & txt4 & " " & txt5
			txt = txt & " " & txt6 & " " & txt7 & " " & txt8 & " " & txt9
			fpRpt.WriteLine(txt)
		Next 'i
		
		fpRpt.WriteLine
		WScript.Echo "... fprintEndForces"
	End Sub '...fprintEndForces
	
	'    << fprint_Reaction_Sum >>
	Sub fprint_Reaction_Sum(ByVal fpRpt)
		Dim txt0, txt1
		
		fpRpt.WriteLine( "fprint_Reaction_Sum ...")
		txt0 = StrLPad(FormatNumber(sumx, 4), 15)
		txt1 = StrLPad(FormatNumber(sumy, 4), 15)
		fpRpt.WriteLine( txt0 & " " & txt1)
		fpRpt.WriteLine
		
	End Sub '.. fprint_Reaction_Sum ..
	
	'    <<< fprintReactions >>>
	Sub fprintReactions(ByVal fpRpt)
		Dim i, k, k3, c, r
		Dim txt0, txt1, txt2
		
		WScript.Echo "fprintReactions ..."
		fpRpt.WriteLine( "fprintReactions ...")
		
		For k = baseIndex To n3 - 1
			If (rjl(k) = 1) Then
				ar(k) = ar(k) - fc(Equiv_Ndx(k))
			End If
		Next 'k
		sumx = 0
		sumy = 0
		
		For i = baseIndex To GModel.structParam.nrj-1
			
			
			txt0 = GModel.sup_grp(i).js
			flag = 0
			k3 = 3 * GModel.sup_grp(i).js - 1
			For k = k3 - 2 To k3
				If ((k + 1) Mod 3 = 0) Then
					txt1 = StrLPad(FormatNumber(ar(k), 4), 15)
					fpRpt.Write( txt1)
				Else
					txt2 = StrLPad(FormatNumber(ar(k), 4), 15)
					fpRpt.Write( txt2)
					If (flag = 0) Then
						sumx = sumx + ar(k)
					Else
						sumy = sumy + ar(k)
					End If
					flag = flag + 1
				End If
			Next 'k
			flag = 0
			
			fpRpt.WriteLine
			
		Next 'i
		
		fprint_Reaction_Sum(fpRpt)
		
		fpRpt.WriteLine
		WScript.Echo "... fprintReactions"
		
	End Sub '...fprintReactions
	
	'    << fprint_Controls >>
	Sub fprint_Controls(ByVal fpRpt)
		Dim txt1, txt2, txt3, txt4, txt5
		Dim txt6, txt7, txt8, txt9, txt
		
		fpRpt.WriteLine( "fprint_Controls ...")
		txt1 = FormatNumber(GModel.structParam.njt,0)
		txt2 = FormatNumber(GModel.structParam.nmb,0)
		txt3 = FormatNumber(GModel.structParam.nmg,0)
		txt4 = FormatNumber(GModel.structParam.nsg,0)
		txt5 = FormatNumber(GModel.structParam.nrj,0)
		txt6 = FormatNumber(GModel.structParam.njl,0)
		txt7 = FormatNumber(GModel.structParam.nml,0)
		txt8 = FormatNumber(GModel.structParam.ngl,0)
		txt9 = FormatNumber(GModel.structParam.nr,0)
		
		txt = txt1 & " " & txt2 & " " & txt3 & " " & txt4 & " " & txt5
		txt = txt & " " & txt6 & " " & txt7 + " " & txt8 + " " & txt9
		fpRpt.WriteLine( txt)
		fpRpt.WriteLine
		
	End Sub '.. fprint_Controls ..
	
	'    <<< fprint_Section_Details >>>
	Sub fprint_Section_Details(ByVal fpRpt)
		Dim txt1, txt2, txt3, txt4
		Dim txt
		Dim i
		
		WScript.Echo "fprint_Section_Details ..."
		fpRpt.WriteLine( "fprint_Section_Details ...")
		For i = baseIndex To GModel.structParam.nmg-1
			
			txt1 = StrLPad(CStr(i), 8)
			txt2 = StrLPad(FormatNumber(GModel.sec_grp(i).t_len, 3), 8)
			txt3 = "<>"
			txt4 = StrLPad(GModel.sec_grp(i).Descr, 8)
			txt = txt1 & " " & txt2 & " " & txt3 & " " & txt4
			fpRpt.WriteLine( txt)
			
		Next 'i
		
		fpRpt.WriteLine
		WScript.Echo "... fprint_Section_Details"
	End Sub '...fprint_Section_Details
	
	'   <<< fprintSpanMoments >>>
	Sub fprintSpanMoments(ByVal fpRpt)
		Dim seg
		Dim tmp
		Dim txt1, txt2, txt3, txt4
		Dim txt
		Dim i, j
		
		WScript.Echo "fprintSpanMoments ..."
		fpRpt.WriteLine( "fprintSpanMoments ...")
		'  MiWrkBk.Worksheets("MSpan").Activate
		'  Set Prnge = MiWrkBk.Worksheets("MSpan").Range("A1:A1")
		
		
		For i = baseIndex To GModel.structParam.nmb - 1
			seg = mlen(i) / n_segs
			txt1 = StrLPad(FormatNumber(i, 0), 8)
			For j = 0 To n_segs
				txt2 = StrLPad(FormatNumber(j, 0), 8)
				
				tmp = j * seg
				tmp = FormatNumber(tmp, 3)
				txt3 = StrLPad(tmp, 8)
				txt4 = StrLPad(FormatNumber(mom_spn(i, j), 4), 15)
				
				txt = txt1 & " " & txt2 & " " & txt3 & " " & txt4
				fpRpt.WriteLine( txt)
				
			Next 'j
			fpRpt.WriteLine
		Next 'i
		
		fpRpt.WriteLine
		WScript.Echo "... fprintSpanMoments"
	End Sub
	
	'<< Output Results to Table >>
	Sub fPrintResults(ByVal fpRpt)
		WScript.Echo "PrintResults ..."
		fprint_Controls(fpRpt)
		fprintDeltas(fpRpt)
		fprintEndForces(fpRpt)
		fprintReactions(fpRpt)
		fprint_Section_Details(fpRpt)
		fprintSpanMoments(fpRpt)
		WScript.Echo "... PrintResults"
	End Sub
	
	
	
End Class
