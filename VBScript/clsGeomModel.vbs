'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit
'Option Base 0

Const MinBound = 1 'NB: Collections start item count at 1.
Const MaxNodes = 5

'.. enumeration constants ..

'... Load Actions
Const local_act    = 0
Const global_x     = 1
Const global_y     = 2

'... Load Types
Const dst_ld       = 1    '.. distributed loads udl, trap, triangular
Const pnt_ld       = 2    '.. point load
Const axi_ld       = 3    '.. axial load

Const udl_ld       = 4    '.. uniform load
Const tri_ld       = 5    '.. triangular load

Const mega        = 1000000
Const kilo        = 1000
Const cent        = 100

Const tolerance   = 0.0001
Const infinity    = 2E+20
Const neg_slope      = 1
Const pos_slope      = -1


Const MachineOFF  = 0
Const MachineTurnOFF  = 0

Const MachineON  = 1
Const MachineTurnON  = 1
Const MachineRunning  = 1
Const MachineScanning  = 1

Const RecognisedSection  = 2
Const DataBlockFound  = 3

Public Const numloads  = 80
Public Const order    = 50
Public Const v_size   = 50
Public Const max_grps  = 25
Public Const max_mats  = 10
Public Const n_segs   = 10 '7 '10



Class clsGeomModel
	
	'Public Nodes(MaxNodes)  'Not possible in vba but possible in vb.net
	Public Nodes 'As New Collection 'use collection instead of public array
	
	'File Parser: Limit State Machine
	
	'------------------------------------------------------------------------------
	'Need Public Access to this Data
	'As the whole point is to programmatically define and build a structural model
	'External to the Class
	'NB: Need to maintain the array names publicly to minimise changes to planeframe
	'------------------------------------------------------------------------------
	'Project & Parameters
	Public ProjectData 'As New clsProjectData
	Public structParam 'As New clsParameters
	
	'Materials & Sections
	Dim mat_grp1() '(max_mats)         'material_rec
	Dim sec_grp1() '(max_grps)          'section_rec
	
	'Dimension & Geometry
	Dim nod_grp1() '(max_grps)       'coord_rec
	Dim con_grp1() '(max_grps)     'connect_rec
	Dim sup_grp1() '(max_grps)          'support_rec
	
	'Design Actions
	Dim jnt_lod1() '(numloads)        'jnt_ld_rec
	Dim mem_lod1() '(numloads)       'mem_ld_rec
	Public grv_lod                'grv_ld_rec
	'------------------------------------------------------------------------------
	
	Public Property Get mat_grp(i ) 
	Set mat_grp = mat_grp1(i)
	End Property
	
	Property Set mat_grp(i , aMaterial )
	Set mat_grp1(i) = aMaterial
	End Property
	
	Public Property Get sec_grp(i ) 
	Set sec_grp = sec_grp1(i)
	End Property
	
	Property Set sec_grp(i , aSection )
	Set sec_grp1(i) = aSection
	End Property
	
	Public Property Get nod_grp(i ) 
	Set nod_grp = nod_grp1(i)
	End Property
	
	Property Set nod_grp(i , aNode )
	Set nod_grp1(i) = aNode
	End Property
	
	Public Property Get con_grp(i ) 
	'  Wscript.Echo  "Bounds: ", LBound(con_grp1), UBound(con_grp1)
	Set con_grp = con_grp1(i)
	End Property
	
	Property Set con_grp(i , aMemberConnection )
	Set con_grp1(i) = aMemberConnection
	End Property
	
	Public Property Get sup_grp(i ) 
	Set sup_grp = sup_grp1(i)
	End Property
	
	Property Set sup_grp(i , aSupport )
	Set sup_grp1(i) = aSupport
	End Property
	
	Public Property Get jnt_lod(i ) 
	Set jnt_lod = jnt_lod1(i)
	End Property
	
	Property Set jnt_lod(i , aJointLoad )
	Set jnt_lod1(i) = aJointLoad
	End Property
	
	Public Property Get mem_lod(i ) 
	Set mem_lod = mem_lod1(i)
	End Property
	
	Property Set mem_lod(i , aMemberLoad )
	Set mem_lod1(i) = aMemberLoad
	End Property
	
	
	
	
	'INITIALISATION SUBROUTINES
	'------------------------------------------------------------------------------
	Sub initialiseMaterials()
		Dim i 
		
		WScript.Echo  "Initialise: Materials"
		ReDim mat_grp1(max_mats)
		
		For i = baseIndex To max_mats
			Set mat_grp1(i) = New clsPfMaterial
			With mat_grp1(i)
				.initialise
			End With
		Next ' i
	End Sub
	
	Sub initialiseSections()
		Dim i 
		WScript.Echo  "Initialise: Sections"
		ReDim sec_grp1(max_grps)
		
		For i = baseIndex To max_grps
			Set sec_grp1(i) = New clsPfSection
			With sec_grp1(i)
				.initialise
				.Descr = .Descr & FormatNumber(i, 0)
				'.cprint
			End With
		Next ' i
	End Sub
	
	Sub initialiseNodes()
		Dim i 
		WScript.Echo  "Initialise: Nodes"
		ReDim nod_grp1(max_grps)
		
		For i = baseIndex To max_grps
			Set nod_grp1(i) = New clsPfCoordinate
			With nod_grp1(i)
				.initialise
			End With
		Next ' i
	End Sub
	
	Sub initialiseConnectivity()
		Dim i 
		WScript.Echo  "Initialise: Connectivity"
		ReDim con_grp1(max_grps)
		
		For i = baseIndex To max_grps
			Set con_grp1(i) = New clsPfConnectivity
			With con_grp1(i)
				.initialise
			End With
		Next ' i
	End Sub
	
	Sub initialiseSupports()
		Dim i 
		WScript.Echo  "Initialise: Supports"
		ReDim sup_grp1(max_grps)
		
		For i = baseIndex To max_grps
			Set sup_grp1(i) = New clsPfSupport
			With sup_grp1(i)
				.initialise
			End With
		Next ' i
	End Sub
	
	Sub initialiseJointLoads()
		Dim i 
		
		WScript.Echo  "Initialise: Joint Loads"
		ReDim jnt_lod1(numloads)
		
		For i = baseIndex To numloads
			Set jnt_lod1(i) = New clsPfJointLoad
			With jnt_lod1(i)
				.initialise
			End With
		Next ' i
		
	End Sub
	
	
	Sub initialiseMemberLoads()
		Dim i 
		
		WScript.Echo  "Initialise: Member Loads"
		ReDim mem_lod1(numloads)
		
		For i = baseIndex To numloads
			Set mem_lod1(i) = New clsPfMemberLoad
			With mem_lod1(i)
				.initialise
			End With
		Next ' i
		
	End Sub
	
	Sub initialiseGravityLoads()
		Dim i 
		
		WScript.Echo  "Initialise: Gravity Loads"
		Set grv_lod = New clsPfGravityLoad
		grv_lod.initialise
	End Sub
	
	Sub initialiseSkeleton()
		Dim i 
	End Sub
	
	Sub initialise()
		WScript.Echo  "initialise ..."
		Set ProjectData = New clsProjectData
		ProjectData.initialise
		Set structParam = New clsParameters
		structParam.initialise
		
		initialiseMaterials
		initialiseSections
		initialiseNodes
		initialiseConnectivity
		initialiseSupports
		initialiseJointLoads
		initialiseMemberLoads
		initialiseGravityLoads
		WScript.Echo  "... initialise"
	End Sub
	
	'DATA COLLECTION SUBROUTINES
	'------------------------------------------------------------------------------
	Sub setNode(ByVal nodeKey , ByVal x1 , ByVal y1 )
		Dim nodePtr 
		
		Set nodePtr = Nodes(nodeKey)
		Call nodePtr.setValues(nodeKey, x1, y1)
	End Sub
	
	Sub setNode2(ByVal nodeKey , ByVal x1 , ByVal y1 )
		Dim nodePtr 
		
		Set nodePtr = nod_grp(nodeKey)
		Call nodePtr.setValues(nodeKey, x1, y1)
	End Sub
	
	Public Sub addNode(ByVal nodeKey , x , y )
		Dim nodePtr 
		
		Set nodePtr = nod_grp(structParam.njt)
		Call nodePtr.setValues(nodeKey, x, y)
		structParam.njt = structParam.njt + 1
	End Sub
	
	Public Sub addMaterialGroup(materialKey , density , ElasticModulus , CoeffThermExpansion )
		Call mat_grp(structParam.nmg).setValues(materialKey, density, ElasticModulus, CoeffThermExpansion)
		structParam.nmg = structParam.nmg + 1
	End Sub
	
	Public Sub addSectionGroup(sectionKey , SectionArea , SecondMomentArea , materialKey , Description )
		Call sec_grp(structParam.nsg).setValues(sectionKey, SectionArea, SecondMomentArea, materialKey, Description)
		structParam.nsg = structParam.nsg + 1
	End Sub
	
	Public Sub addMember(memberKey , NodeA , NodeB , sectionKey , ReleaseA , ReleaseB )
		Call con_grp(structParam.nmb).setValues(memberKey, NodeA, NodeB, sectionKey, ReleaseA, ReleaseB)
		structParam.nmb = structParam.nmb + 1
	End Sub
	
	Public Sub addSupport(supportKey , SupportNode , RestraintX , RestraintY , RestraintMoment )
		
		Call sup_grp(structParam.nrj).setValues(supportKey, SupportNode, RestraintX, RestraintY, RestraintMoment)
		
		With sup_grp(structParam.nrj)
			structParam.nr = structParam.nr + .rx + .ry + .rm
		End With
		structParam.nrj = structParam.nrj + 1
	End Sub
	
	Public Sub addJointLoad(LoadKey , Node , ForceX , ForceY , Moment )
		Call jnt_lod(structParam.njl).setValues(LoadKey, Node, ForceX, ForceY, Moment)
		structParam.njl = structParam.njl + 1
	End Sub
	
	Public Sub addMemberLoad(LoadKey , memberKey , LoadType , ActionKey  _
		, LoadMag1 , LoadStart , LoadCover )
		
		Call mem_lod(structParam.nml).setValues(LoadKey, memberKey, LoadType, ActionKey, LoadMag1, LoadStart, LoadCover)
		structParam.nml = structParam.nml + 1
	End Sub
	
	Public Sub addGravityLoad(ActionKey , LoadMag )
		Call grv_lod.setValues(ActionKey, LoadMag)
	End Sub
	
	
	
	
	'REPORTING SUBROUTINES
	'------------------------------------------------------------------------------
	
	Sub cprintSkeleton()
		Dim i 
	End Sub
	
	Sub cprintjobData()
		Dim i 
		
		WScript.Echo  "cprintjobData ..."
		ProjectData.cprint
		
	End Sub
	
	Sub cprintControlData()
		WScript.Echo  "cprintControlData ..."
		'  Wscript.Echo  njt, nmb, nmg, nsg, nrj, njl, nml, ngl, mag
		structParam.cprint
	End Sub
	
	Sub cprintNodes()
		Dim nodePtr 
		Dim n 
		Dim i 
		
		WScript.Echo  "cprintNodes ..."
		
		If structParam.njt = 0 Then n = max_grps Else n = structParam.njt - 1
		
		For i = baseIndex To n
			Set nodePtr = nod_grp(i)
			nodePtr.cprint
		Next ' i
		
		WScript.Echo  "... cprintNodes"
		
	End Sub
	
	Sub cprintConnectivity()
		Dim i 
		Dim n 
		
		WScript.Echo  "cprint: Connectivity"
		If structParam.nmb = 0 Then n = max_grps Else n = structParam.nmb - 1
		For i = baseIndex To n
			With con_grp(i)
				.cprint
			End With
		Next ' i
		
	End Sub
	
	Sub cprintMaterials()
		Dim i 
		Dim n 
		
		WScript.Echo  "cprint: Materials"
		If structParam.nmg = 0 Then n = max_mats Else n = structParam.nmg - 1
		For i = baseIndex To n
			With mat_grp(i)
				.cprint
			End With
		Next ' i
		
	End Sub
	
	Sub cprintSections()
		Dim i 
		Dim n 
		
		WScript.Echo  "cprint: Sections"
		If structParam.nsg = 0 Then n = max_grps Else n = structParam.nsg - 1
		For i = baseIndex To n
			With sec_grp(i)
				.cprint
			End With
		Next ' i
	End Sub
	
	
	Sub cprintSupports()
		Dim i 
		Dim n 
		
		WScript.Echo  "cprint: Supports"
		If structParam.nrj = 0 Then n = max_grps Else n = structParam.nrj - 1
		For i = baseIndex To n
			With sup_grp(i)
				.cprint
			End With
		Next ' i
	End Sub
	
	Sub cprintJointLoads(isPrintRaw )
		Dim i 
		Dim n 
		
		WScript.Echo  "cprint: Joint Loads"
		If isPrintRaw Then
			n = numloads
		Else
			n = structParam.njl - 1
		End If
		
		For i = baseIndex To n
			With jnt_lod(i)
				.cprint
			End With
		Next ' i
		
	End Sub
	
	
	Sub cprintMemberLoads()
		Dim i 
		Dim n 
		
		WScript.Echo  "cprint: Member Loads"
		If structParam.nml = 0 Then n = numloads Else n = structParam.nml - 1
		For i = baseIndex To n
			With mem_lod(i)
				.cprint
			End With
		Next ' i
	End Sub
	
	Sub cprintGravityLoads()
		
		WScript.Echo  "cprint: Gravity Loads"
		grv_lod.cprint
		
	End Sub
	
	
	Sub cprint()
		WScript.Echo  "cprint ..."
		
		cprintjobData
		cprintControlData
		
		cprintMaterials
		cprintSections
		
		cprintNodes
		cprintConnectivity
		cprintSupports
		
		Call cprintJointLoads(False)
		cprintMemberLoads
		cprintGravityLoads
		
		WScript.Echo  "... cprint"
	End Sub
	
	'FILE READING SUBROUTINES
	'------------------------------------------------------------------------------
	Function isDataBlockHeaderString(s ) 
		Dim p 
		
		p = InStr(1, s, dataBlockTag)
		If p <> 0 Then
			isDataBlockHeaderString = True
		Else
			isDataBlockHeaderString = False
		End If
		
	End Function
	
	Sub fgetNodeData(fp , lastTxtStr )
		Dim s 
		Dim i , n 
		Dim dataflds(4) '(0 To 4)
		
		Dim MachineState 
		Dim quit  'Switch Machine OFF and Quit
		Dim done  'Finished Reading File but not processing data, prepare machine to switch off
		Dim isDataBlockFound 
		
		quit = False
		MachineState = MachineON 'and is Scanning file
		done = False
		isDataBlockFound = False
		
		WScript.Echo  "fgetNodeData ..."
		
		done = False
		Do While Not (done) And Not (quit)
			Select Case MachineState
				Case MachineTurnOFF
				quit = True
				WScript.Echo  "Machine to be Turned OFF"
				Case MachineScanning
				If fp.AtEndOfStream <> True Then
					s = Trim(fp.ReadLine)
					isDataBlockFound = isDataBlockHeaderString(s)
					If isDataBlockFound Then
						MachineState = DataBlockFound
					Else
						Call parseDelimitedString(s, dataflds, n, " ")
						'            Wscript.Echo  "Node=", dataflds(0)
						'            Wscript.Echo  "x= ", dataflds(1)
						'            Wscript.Echo  "y= ", dataflds(2)
						Call addNode(CInt(dataflds(0)), CDbl(dataflds(1)), CDbl(dataflds(2)))
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
		WScript.Echo  "... fgetNodeData"
	End Sub
	
	Sub fgetMemberData(fp , lastTxtStr )
		Dim s 
		Dim i , n 
		Dim dataflds(8) '(0 To 8) 
		
		Dim MachineState 
		Dim quit  'Switch Machine OFF and Quit
		Dim done  'Finished Reading File but not processing data, prepare machine to switch off
		Dim isDataBlockFound 
		
		quit = False
		MachineState = MachineON 'and is Scanning file
		done = False
		isDataBlockFound = False
		
		WScript.Echo  "fgetMemberData ..."
		
		done = False
		Do While Not (done) And Not (quit)
			Select Case MachineState
				Case MachineTurnOFF
				quit = True
				WScript.Echo  "Machine to be Turned OFF"
				Case MachineScanning
				If fp.AtEndOfStream <> True Then
					s = Trim(fp.ReadLine)
					isDataBlockFound = isDataBlockHeaderString(s)
					If isDataBlockFound Then
						MachineState = DataBlockFound
					Else
						Call parseDelimitedString(s, dataflds, n, " ")
						'            For i = 0 To n
						'              Wscript.Echo  dataflds(i)
						'            Next ' i
						'            Wscript.Echo  "----"
						Call addMember(CInt(dataflds(0)), CInt(dataflds(1)), CInt(dataflds(2)), CInt(dataflds(3)), CInt(dataflds(4)), CInt(dataflds(5)))
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
		
		WScript.Echo  "... fgetMemberData"
		
	End Sub
	
	Sub fgetSupportData(fp , lastTxtStr )
		Dim s 
		Dim i , n 
		Dim dataflds(6) '(0 To 6) 
		
		Dim MachineState 
		Dim quit  'Switch Machine OFF and Quit
		Dim done  'Finished Reading File but not processing data, prepare machine to switch off
		Dim isDataBlockFound 
		
		quit = False
		MachineState = MachineON 'and is Scanning file
		done = False
		isDataBlockFound = False
		
		WScript.Echo  "fgetSupportData ..."
		
		done = False
		Do While Not (done) And Not (quit)
			Select Case MachineState
				Case MachineTurnOFF
				quit = True
				WScript.Echo  "Machine to be Turned OFF"
				Case MachineScanning
				If fp.AtEndOfStream <> True Then
					s = Trim(fp.ReadLine)
					isDataBlockFound = isDataBlockHeaderString(s)
					If isDataBlockFound Then
						MachineState = DataBlockFound
					Else
						Call parseDelimitedString(s, dataflds, n, " ")
						'            For i = 0 To n
						'              Wscript.Echo  dataflds(i)
						'            Next ' i
						'            Wscript.Echo  "----"
						
						Call addSupport(CInt(dataflds(0)), CInt(dataflds(1)), CByte(dataflds(2)), CByte(dataflds(3)), CByte(dataflds(4)))
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
		
		WScript.Echo  "... fgetSupportData"
		
	End Sub
	
	Sub fgetMaterialData(fp , lastTxtStr )
		Dim s 
		Dim i , n 
		Dim dataflds(8) '(0 To 8) 
		
		Dim MachineState 
		Dim quit  'Switch Machine OFF and Quit
		Dim done  'Finished Reading File but not processing data, prepare machine to switch off
		Dim isDataBlockFound 
		
		quit = False
		MachineState = MachineON 'and is Scanning file
		done = False
		isDataBlockFound = False
		
		WScript.Echo  "fgetMaterialData ..."
		
		done = False
		Do While Not (done) And Not (quit)
			Select Case MachineState
				Case MachineTurnOFF
				quit = True
				WScript.Echo  "Machine to be Turned OFF"
				Case MachineScanning
				If fp.AtEndOfStream <> True Then
					s = Trim(fp.ReadLine)
					isDataBlockFound = isDataBlockHeaderString(s)
					If isDataBlockFound Then
						MachineState = DataBlockFound
					Else
						Call parseDelimitedString(s, dataflds, n, " ")
						'            For i = 0 To n
						'              Wscript.Echo  dataflds(i)
						'            Next ' i
						'            Wscript.Echo  "----"
						Call addMaterialGroup(CInt(dataflds(0)), CDbl(dataflds(1)), CDbl(dataflds(2)), CDbl(dataflds(3)))
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
		
		
		
		WScript.Echo  "... fgetMaterialData"
		
	End Sub
	
	Sub fgetSectionData(fp , lastTxtStr )
		Dim s 
		Dim i , n 
		Dim dataflds(8) '(0 To 8) 
		
		Dim MachineState 
		Dim quit  'Switch Machine OFF and Quit
		Dim done  'Finished Reading File but not processing data, prepare machine to switch off
		Dim isDataBlockFound 
		
		quit = False
		MachineState = MachineON 'and is Scanning file
		done = False
		isDataBlockFound = False
		
		WScript.Echo  "fgetSectionData ..."
		
		done = False
		Do While Not (done) And Not (quit)
			Select Case MachineState
				Case MachineTurnOFF
				quit = True
				WScript.Echo  "Machine to be Turned OFF"
				Case MachineScanning
				If fp.AtEndOfStream <> True Then
					s = Trim(fp.ReadLine)
					isDataBlockFound = isDataBlockHeaderString(s)
					If isDataBlockFound Then
						MachineState = DataBlockFound
					Else
						Call parseDelimitedString(s, dataflds, n, " ")
						'            For i = 0 To n
						'              Wscript.Echo  dataflds(i)
						'            Next ' i
						'            Wscript.Echo  "----"
						Call addSectionGroup(CInt(dataflds(0)), CDbl(dataflds(1)), CDbl(dataflds(2)), CDbl(dataflds(3)), dataflds(4))
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
		
		
		
		WScript.Echo  "... fgetSectionData"
		
	End Sub
	
	Sub fgetJointLoadData(fp , lastTxtStr )
		Dim s 
		Dim i , n 
		Dim dataflds(8) '(0 To 8) 
		
		Dim MachineState 
		Dim quit  'Switch Machine OFF and Quit
		Dim done  'Finished Reading File but not processing data, prepare machine to switch off
		Dim isDataBlockFound 
		
		quit = False
		MachineState = MachineON 'and is Scanning file
		done = False
		isDataBlockFound = False
		
		WScript.Echo  "fgetJointLoadData ..."
		
		done = False
		Do While Not (done) And Not (quit)
			Select Case MachineState
				Case MachineTurnOFF
				quit = True
				WScript.Echo  "Machine to be Turned OFF"
				Case MachineScanning
				If fp.AtEndOfStream <> True Then
					s = Trim(fp.ReadLine)
					isDataBlockFound = isDataBlockHeaderString(s)
					If isDataBlockFound Then
						MachineState = DataBlockFound
					Else
						Call parseDelimitedString(s, dataflds, n, " ")
						'            For i = 0 To n
						'              Wscript.Echo  dataflds(i)
						'            Next ' i
						'            Wscript.Echo  "----"
						Call addJointLoad(CInt(dataflds(0)), CDbl(dataflds(1)), CDbl(dataflds(2)), CDbl(dataflds(3)), CDbl(dataflds(4)))
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
		
		
		WScript.Echo  "... fgetJointLoadData"
		
	End Sub
	
	Sub fgetMemberLoadData(fp , lastTxtStr )
		Dim s 
		Dim i , n 
		Dim dataflds(8) '(0 To 8) 
		
		Dim MachineState 
		Dim quit  'Switch Machine OFF and Quit
		Dim done  'Finished Reading File but not processing data, prepare machine to switch off
		Dim isDataBlockFound 
		
		quit = False
		MachineState = MachineON 'and is Scanning file
		done = False
		isDataBlockFound = False
		
		WScript.Echo  "fgetMemberLoadData ..."
		
		done = False
		Do While Not (done) And Not (quit)
			Select Case MachineState
				Case MachineTurnOFF
				quit = True
				WScript.Echo  "Machine to be Turned OFF"
				Case MachineScanning
				If fp.AtEndOfStream <> True Then
					s = Trim(fp.ReadLine)
					isDataBlockFound = isDataBlockHeaderString(s)
					If isDataBlockFound Then
						MachineState = DataBlockFound
					Else
						Call parseDelimitedString(s, dataflds, n, " ")
						'            For i = 0 To n
						'              Wscript.Echo  dataflds(i)
						'            Next ' i
						'            Wscript.Echo  "----"
						
						Call addMemberLoad(CInt(dataflds(0)), CInt(dataflds(1)), CDbl(dataflds(2)) _
						, CDbl(dataflds(3)), CDbl(dataflds(4)) _
						, CDbl(dataflds(5)), CDbl(dataflds(6)))
						
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
		
		
		WScript.Echo  "... fgetMemberLoadData"
		
	End Sub
	
	Sub fgetGravityLoadData(fp , lastTxtStr )
		Dim s 
		Dim i , n 
		Dim dataflds(8) '(0 To 8) 
		
		Dim MachineState 
		Dim quit  'Switch Machine OFF and Quit
		Dim done  'Finished Reading File but not processing data, prepare machine to switch off
		Dim isDataBlockFound 
		Dim isUseDefaultData 
		
		WScript.Echo  "fgetGravityLoadData ..."
		
		isDataBlockFound = False
		If fp.AtEndOfStream <> True Then
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
				WScript.Echo  "Limit State File Parser Machine to be Turned OFF"
				Case MachineScanning
				If fp.AtEndOfStream <> True Then
					s = Trim(fp.ReadLine)
					isDataBlockFound = isDataBlockHeaderString(s)
					If isDataBlockFound Then
						MachineState = DataBlockFound
					Else
						Call parseDelimitedString(s, dataflds, n, " ")
						'            For i = 0 To n
						'              Wscript.Echo  dataflds(i)
						'            Next ' i
						'            Wscript.Echo  "----"
						Call addGravityLoad(CInt(dataflds(0)), CDbl(dataflds(1)))
						MachineState = MachineScanning
					End If
				Else
					WScript.Echo  "... End of File"
					done = True
					MachineState = MachineTurnOFF
				End If
				Case DataBlockFound
				'Signifies End of Current Data Block
				done = True
				MachineState = MachineTurnOFF
			End Select
		Loop
		
		If fp.AtEndOfStream <> True Then
			lastTxtStr = s
		Else
			lastTxtStr = ""
		End If
		
		If isUseDefaultData Then
			WScript.Echo  "Using Default Data"
			Call addGravityLoad(2, -9.81)
		End If
		
		'File Data Ignored
		'Default Values Used Only
		
		WScript.Echo  "... fgetGravityLoadData"
	End Sub
	
	
	'Limit State Machine: File Parser
	'File format to match requirements for F_wrk.exe (With File Date Modified = Friday, 23 August 1996, 13:18:04)
	'
	Sub pframeReader00(fp )
		Const pwid = 20
		Dim i , tmp , p 
		Dim s 
		Dim dataCtrlBlk 
		
		Dim MachineState 
		Dim quit 
		Dim done 
		Dim isDataBlockFound 
		
		'On Error GoTo ErrHandler_pframeReader00
		WScript.Echo  "pframeReader00 ..."
		
		quit = False
		MachineState = MachineON 'and is Scanning file
		done = False
		isDataBlockFound = False
		
		Do While Not (done) And Not (quit)
			
			Select Case MachineState
				Case MachineTurnOFF
				quit = True
				WScript.Echo  "Machine to be Turned OFF"
				Case MachineScanning
				If fp.AtEndOfStream <> True Then
					s = fp.ReadLine
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
				WScript.Echo  "<" & dataCtrlBlk & ">"
				MachineState = RecognisedSection
				Case RecognisedSection
				Select Case dataCtrlBlk
					Case "JOB DETAILS"  'Alternative to Job Data
					Call ProjectData.fgetData(fp)
					MachineState = MachineScanning
					Case "JOB DATA" 'Alternative to Job Details
					Call ProjectData.fgetData(fp)
					MachineState = MachineScanning
					Case "CONTROL DATA"
					Call structParam.fgetData(fp, True)
					MachineState = MachineScanning
					Case "NODES"
					Call fgetNodeData(fp, s)
					MachineState = DataBlockFound
					Case "MEMBERS"
					Call fgetMemberData(fp, s)
					MachineState = DataBlockFound
					Case "SUPPORTS"
					Call fgetSupportData(fp, s)
					MachineState = DataBlockFound
					Case "MATERIALS"
					Call fgetMaterialData(fp, s)
					MachineState = DataBlockFound
					Case "SECTIONS"
					Call fgetSectionData(fp, s)
					MachineState = DataBlockFound
					Case "JOINT LOADS"
					Call fgetJointLoadData(fp, s)
					MachineState = DataBlockFound
					Case "MEMBER LOADS"
					Call fgetMemberLoadData(fp, s)
					If fp.AtEndOfStream <> True Then
						MachineState = DataBlockFound
					Else
						MachineState = MachineTurnOFF
					End If
					
					Case "GRAVITY LOADS"
					Call fgetGravityLoadData(fp, s)
					MachineState = MachineTurnOFF
				End Select
				Case Else
				If fp.AtEndOfStream = True Then
					WScript.Echo  "DataBlockFound: End Of File"
					done = True
					MachineState = MachineTurnOFF
				Else
					MachineState = MachineScanning
				End If
			End Select 'machine state
			
		Loop
		
		WScript.Echo  "... pframeReader00"
		
		'	Exit_pframeReader00:
		'	    Exit Sub
		
		'	ErrHandler_pframeReader00:
		'On Error Close All open Files
		'	    Close
		'	    Wscript.Echo  "... pframeReader00: Exit Errors!"
		'	    Wscript.Echo  Err.Number, Err.Description
		'Resume Exit_pframeReader00
		'	    Stop
		
	End Sub
	
	'DATA FILE STORE SUBROUTINES
	'------------------------------------------------------------------------------
	'Compatible file for F_wrk.exe (With File Date Modified = Friday, 23 August 1996, 13:18:04)
	'
	'NB: xlFrame.xls has changed some of the data structures to accommodate trapezoidal loads.
	'Therefore introduce new section header for new data structure.
	'The original Pascal program doesn't have a file parser, it assumes the file is correctly formatted
	'with each section in the correct order. It simply reads the section headers into a dummy variable and discards.
	'The original application will therefore crash when reading new files.
	'Which is what happened when I created data files based on the data in the spreadsheet.
	'And the original reason for back tracking to the original Pascal Application.
	'The idea is when xlFrame.xla gets integrated into some larger application and
	'disappears from view, working behind the scenes, then should be able to export data files
	'which are compatible with stand alone tools to check the validity of the results produced by
	'the larger integrated application. Also so that can check whether have a problem with the structures engine or
	'have a problem with its integration with the larger system.
	'It should be modular.
	
	Sub SaveDataToTextFile(fp )
		Const pwid = 40
		Dim i 
		
		WScript.Echo  "SaveDataToTextFile ..."
		fp.WriteLine("JOB DATA" & dataBlockTag)
		Call ProjectData.fprint(fp)
		
		'NB: It some versions of original Pascal application require screen magnification factor
		'other versions don't. If needed and not present the program will crash. If not needed but
		'is present it is simply ignored. Therefore always write to the file.
		fp.WriteLine("CONTROL DATA" & dataBlockTag)
		Call structParam.fprint(fp)
		
		fp.WriteLine("NODES" & dataBlockTag)
		For i = 1 To structParam.njt
			Call nod_grp1(i).fprint(fp)
		Next ' i
		
		fp.WriteLine("MEMBERS" & dataBlockTag)
		For i = 1 To structParam.nmb
			Call con_grp1(i).fprint(fp)
		Next ' i
		
		fp.WriteLine("SUPPORTS" & dataBlockTag)
		For i = 1 To structParam.nrj
			Call sup_grp1(i).fprint(fp)
		Next ' i
		
		fp.WriteLine("MATERIALS" & dataBlockTag)
		For i = 1 To structParam.nmg
			Call mat_grp1(i).fprint(fp)
		Next ' i
		
		fp.WriteLine("SECTIONS" & dataBlockTag)
		For i = 1 To structParam.nsg
			Call sec_grp1(i).fprint(fp)
		Next ' i
		
		fp.WriteLine("JOINT LOADS" & dataBlockTag)
		WScript.Echo  "njl= ", structParam.njl
		For i = 1 To structParam.njl
			Call jnt_lod1(i).fprint(fp)
		Next ' i
		
		fp.WriteLine("MEMBER LOADS" & dataBlockTag)
		For i = 1 To structParam.nml
			Call mem_lod1(i).fprint(fp)
		Next ' i
		
		
		fp.WriteLine("GRAVITY LOADS" & dataBlockTag)
		
		Close
		
		WScript.Echo  "... SaveDataToTextFile"
		
	End Sub
	
End Class
