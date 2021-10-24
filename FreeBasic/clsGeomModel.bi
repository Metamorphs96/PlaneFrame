'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'INTERFACE
'-------------------------------------------------------------------------------


'Option Explicit
'Option Base 0

#include once "clsParameters.bi"
#include once "clsPfConnectivity.bi"
#include once "clsPfCoordinate.bi"
#include once "clsPfGravityLoad.bi"
#include once "clsPfJointLoad.bi"
#include once "clsPfMaterial.bi"
#include once "clsPfMemberLoad.bi"
#include once "clsPfSection.bi"
#include once "clsPfSupport.bi"
#include once "clsProjectData.bi"


Const MinBound as integer = 1 'NB: Collections start item count at 1.
Const MaxNodes as integer = 5

'.. enumeration constants ..

'... Load Actions
Const local_act   As Byte = 0
Const global_x    As Byte = 1
Const global_y    As Byte = 2

'... Load Types
Const dst_ld      As Byte = 1    '.. distributed loads udl, trap, triangular
Const pnt_ld      As Byte = 2    '.. point load
Const axi_ld      As Byte = 3    '.. axial load

Const udl_ld      As Byte = 4    '.. uniform load
Const tri_ld      As Byte = 5    '.. triangular load

Const mega       As Double = 1000000
Const kilo       As Double = 1000
Const cent       As Double = 100

Const tolerance  As Double = 0.0001
Const infinity   As Double = 2E+20
Const neg_slope     As Integer = 1
Const pos_slope     As Integer = -1



'File Parser: Limit State Machine
Const MachineOFF As Integer = 0
Const MachineTurnOFF As Integer = 0

Const MachineON As Integer = 1
Const MachineTurnON As Integer = 1
Const MachineRunning As Integer = 1
Const MachineScanning As Integer = 1

Const RecognisedSection As Integer = 2
Const DataBlockFound As Integer = 3

'------------------------------------------------------------------------------
'Need Public Access to this Data
'As the whole point is to programmatically define and build a structural model
'External to the Class
'NB: Need to maintain the array names publicly to minimise changes to planeframe
'------------------------------------------------------------------------------

Type clsGeomModel
    
    Public: Nodes(MaxNodes) As clsPfCoordinate 'Not possible in vba but possible in vb.net
    'Public: Nodes As New Collection 'use collection instead of public array
    
    'Project & Parameters
    Public: ProjectData As clsProjectData
    Public: structParam As clsParameters
    
    'Materials & Sections
    Dim mat_grp(max_mats) As clsPfMaterial        'material_rec
    Dim sec_grp(max_grps) As clsPfSection         'section_rec
    
    'Dimension & Geometry
    Dim nod_grp(max_grps) As clsPfCoordinate      'coord_rec
    Dim con_grp(max_grps) As clsPfConnectivity    'connect_rec
    Dim sup_grp(max_grps) As clsPfSupport         'support_rec
    
    'Design Actions
    Dim jnt_lod(numloads) As clsPfJointLoad       'jnt_ld_rec
    Dim mem_lod(numloads) As clsPfMemberLoad      'mem_ld_rec
    Public: grv_lod           As clsPfGravityLoad   'grv_ld_rec

    Declare Sub initialiseMaterials()
    Declare Sub initialiseSections()
    Declare Sub initialiseNodes()
    Declare Sub initialiseConnectivity()
    Declare Sub initialiseSupports()
    Declare Sub initialiseJointLoads()
    Declare Sub initialiseMemberLoads()
    Declare Sub initialiseGravityLoads()
    Declare Sub initialiseSkeleton()
    Declare Sub initialise()
    Declare Sub setNode(ByVal nodeKey As Integer, ByVal x1 As Double, ByVal y1 As Double)
    Declare Sub setNode2(ByVal nodeKey As Integer, ByVal x1 As Double, ByVal y1 As Double)
    Declare Sub addNode(ByVal nodeKey As Integer, x As Double, y As Double)
    Declare Sub addMaterialGroup(materialKey As Integer, density As Double, ElasticModulus As Double, CoeffThermExpansion As Double)
    Declare Sub addSectionGroup(sectionKey As Integer, SectionArea As Double, SecondMomentArea As Double, materialKey As Integer, Description As String)
    Declare Sub addMember(memberKey As Integer, NodeA As Integer, NodeB As Integer, sectionKey As Integer, ReleaseA As Integer, ReleaseB As Integer)
    Declare Sub addSupport(supportKey As Integer, SupportNode As Integer, RestraintX As Byte, RestraintY As Byte, RestraintMoment As Byte)
    Declare Sub addJointLoad(LoadKey As Integer, Node As Integer, ForceX As Double, ForceY As Double, Moment As Double)
    Declare Sub addMemberLoad(LoadKey As Integer, memberKey As Integer, LoadType As Integer, ActionKey As Integer, LoadMag1 As Double, LoadStart As Double, LoadCover As Double)
    Declare Sub addGravityLoad(ActionKey As Integer, LoadMag As Double)
    Declare Sub cprintSkeleton()
    Declare Sub cprintjobData()
    Declare Sub cprintControlData()
    Declare Sub cprintNodes()
    Declare Sub cprintConnectivity()
    Declare Sub cprintMaterials()
    Declare Sub cprintSections()
    Declare Sub cprintSupports()
    Declare Sub cprintJointLoads(isPrintRaw As Boolean)
    Declare Sub cprintMemberLoads()
    Declare Sub cprintGravityLoads()
    Declare Sub cprint()
    Declare Function isDataBlockHeaderString(s As String) As Boolean
    Declare Sub fgetNodeData(fp as integer, lastTxtStr As String)
    Declare Sub fgetMemberData(fp as integer, lastTxtStr As String)
    Declare Sub fgetSupportData(fp as integer, lastTxtStr As String)
    Declare Sub fgetMaterialData(fp as integer, lastTxtStr As String)
    Declare Sub fgetSectionData(fp as integer, lastTxtStr As String)
    Declare Sub fgetJointLoadData(fp as integer, lastTxtStr As String)
    Declare Sub fgetMemberLoadData(fp as integer, lastTxtStr As String)
    Declare Sub fgetGravityLoadData(fp as integer, lastTxtStr As String)
    Declare Sub pframeReader00(fp as integer)
    Declare Sub SaveDataToTextFile(fp as integer)

End Type

'------------------------------------------------------------------------------

'Public Property Get mat_grp(i As Integer) As clsPfMaterial
'  Set mat_grp = mat_grp1(i)
'End Property
'
'Property Set mat_grp(i As Integer, aMaterial As clsPfMaterial)
'  Set mat_grp1(i) = aMaterial
'End Property
'
'Public Property Get sec_grp(i As Integer) As clsPfSection
'  Set sec_grp = sec_grp1(i)
'End Property
'
'Property Set sec_grp(i As Integer, aSection As clsPfSection)
'  Set sec_grp1(i) = aSection
'End Property
'
'Public Property Get nod_grp(i As Integer) As clsPfCoordinate
'  Set nod_grp = nod_grp1(i)
'End Property
'
'Property Set nod_grp(i As Integer, aNode As clsPfCoordinate)
'  Set nod_grp1(i) = aNode
'End Property
'
'Public Property Get con_grp(i As Integer) As clsPfConnectivity
''  print "Bounds: ", LBound(con_grp1), UBound(con_grp1)
'  Set con_grp = con_grp1(i)
'End Property
'
'Property Set con_grp(i As Integer, aMemberConnection As clsPfConnectivity)
'  Set con_grp1(i) = aMemberConnection
'End Property
'
'Public Property Get sup_grp(i As Integer) As clsPfSupport
'  Set sup_grp = sup_grp1(i)
'End Property
'
'Property Set sup_grp(i As Integer, aSupport As clsPfSupport)
'  Set sup_grp1(i) = aSupport
'End Property
'
'Public Property Get jnt_lod(i As Integer) As clsPfJointLoad
'  Set jnt_lod = jnt_lod1(i)
'End Property
'
'Property Set jnt_lod(i As Integer, aJointLoad As clsPfJointLoad)
'  Set jnt_lod1(i) = aJointLoad
'End Property
'
'Public Property Get mem_lod(i As Integer) As clsPfMemberLoad
'  Set mem_lod = mem_lod1(i)
'End Property
'
'Property Set mem_lod(i As Integer, aMemberLoad As clsPfMemberLoad)
'  Set mem_lod1(i) = aMemberLoad
'End Property




'INITIALISATION SUBROUTINES
'------------------------------------------------------------------------------
Sub clsGeomModel.initialiseMaterials()
  Dim i As Integer
  
  print "Initialise: Materials"
  For i = baseIndex To max_mats
    'Set mat_grp(i) = New clsPfMaterial
    With mat_grp(i)
      .initialise
    End With
  Next i
End Sub

Sub clsGeomModel.initialiseSections()
  Dim i As Integer
  print "Initialise: Sections"
  For i = baseIndex To max_grps
    'Set sec_grp(i) = New clsPfSection
    With sec_grp(i)
      .initialise
      .Descr = .Descr & Format(i, "#")
      '.cprint
    End With
  Next i
End Sub

Sub clsGeomModel.initialiseNodes()
  Dim i As Integer
  print "Initialise: Nodes"
  For i = baseIndex To max_grps
    'Set nod_grp(i) = New clsPfCoordinate
    With nod_grp(i)
      .initialise
    End With
  Next i
End Sub

Sub clsGeomModel.initialiseConnectivity()
  Dim i As Integer
  print "Initialise: Connectivity"
  For i = baseIndex To max_grps
    'Set con_grp(i) = New clsPfConnectivity
    With con_grp(i)
      .initialise
    End With
  Next i
End Sub

Sub clsGeomModel.initialiseSupports()
  Dim i As Integer
  print "Initialise: Supports"
  For i = baseIndex To max_grps
    'Set sup_grp(i) = New clsPfSupport
    With sup_grp(i)
      .initialise
    End With
  Next i
End Sub

Sub clsGeomModel.initialiseJointLoads()
  Dim i As Integer
  
  print "Initialise: Joint Loads"
  For i = baseIndex To numloads
    'Set jnt_lod(i) = New clsPfJointLoad
    With jnt_lod(i)
      .initialise
    End With
  Next i
  
End Sub


Sub clsGeomModel.initialiseMemberLoads()
  Dim i As Integer
  
  print "Initialise: Member Loads"
  For i = baseIndex To numloads
    'Set mem_lod1(i) = New clsPfMemberLoad
    With mem_lod(i)
      .initialise
    End With
  Next i
  
End Sub

Sub clsGeomModel.initialiseGravityLoads()
  Dim i As Integer
  
  print "Initialise: Gravity Loads"
  'Set grv_lod = New clsPfGravityLoad
  grv_lod.initialise
End Sub

Sub clsGeomModel.initialiseSkeleton()
  Dim i As Integer
End Sub

Sub clsGeomModel.initialise()
  print "initialise ..."
  ProjectData.initialise
  structParam.initialise
    
  initialiseMaterials
  initialiseSections
  initialiseNodes
  initialiseConnectivity
  initialiseSupports
  initialiseJointLoads
  initialiseMemberLoads
  initialiseGravityLoads
  print "... initialise"
End Sub

'DATA COLLECTION SUBROUTINES
'------------------------------------------------------------------------------
Sub clsGeomModel.setNode(ByVal nodeKey As Integer, ByVal x1 As Double, ByVal y1 As Double)
  Dim nodePtr As clsPfCoordinate

  nodePtr = Nodes(nodeKey)
  nodePtr.setValues(nodeKey, x1, y1)
End Sub

Sub clsGeomModel.setNode2(ByVal nodeKey As Integer, ByVal x1 As Double, ByVal y1 As Double)
  Dim nodePtr As clsPfCoordinate

  nodePtr = nod_grp(nodeKey)
  nodePtr.setValues(nodeKey, x1, y1)
End Sub

Public Sub clsGeomModel.addNode(ByVal nodeKey As Integer, x As Double, y As Double)
  Dim nodePtr As clsPfCoordinate
  
  'nodePtr = nod_grp(structParam.njt)
  nod_grp(structParam.njt).setValues(nodeKey, x, y)
  structParam.njt = structParam.njt + 1
End Sub

Public Sub clsGeomModel.addMaterialGroup(materialKey As Integer, density As Double, ElasticModulus As Double, CoeffThermExpansion As Double)
  mat_grp(structParam.nmg).setValues(materialKey, density, ElasticModulus, CoeffThermExpansion)
  structParam.nmg = structParam.nmg + 1
End Sub

Public Sub clsGeomModel.addSectionGroup(sectionKey As Integer, SectionArea As Double, SecondMomentArea As Double, materialKey As Integer, Description As String)
  sec_grp(structParam.nsg).setValues(sectionKey, SectionArea, SecondMomentArea, materialKey, Description)
  structParam.nsg = structParam.nsg + 1
End Sub

Public Sub clsGeomModel.addMember(memberKey As Integer, NodeA As Integer, NodeB As Integer, sectionKey As Integer, ReleaseA As Integer, ReleaseB As Integer)
  con_grp(structParam.nmb).setValues(memberKey, NodeA, NodeB, sectionKey, ReleaseA, ReleaseB)
  structParam.nmb = structParam.nmb + 1
End Sub

Public Sub clsGeomModel.addSupport(supportKey As Integer, SupportNode As Integer, RestraintX As Byte, RestraintY As Byte, RestraintMoment As Byte)

  sup_grp(structParam.nrj).setValues(supportKey, SupportNode, RestraintX, RestraintY, RestraintMoment)

  With sup_grp(structParam.nrj)
    structParam.nr = structParam.nr + .rx + .ry + .rm
  End With
  structParam.nrj = structParam.nrj + 1
End Sub

Public Sub clsGeomModel.addJointLoad(LoadKey As Integer, Node As Integer, ForceX As Double, ForceY As Double, Moment As Double)
  

  jnt_lod(structParam.njl).setValues(LoadKey, Node, ForceX, ForceY, Moment)
  structParam.njl = structParam.njl + 1
End Sub

Public Sub clsGeomModel.addMemberLoad(LoadKey As Integer, memberKey As Integer, LoadType As Integer, ActionKey As Integer _
                         , LoadMag1 As Double, LoadStart As Double, LoadCover As Double)
  
  mem_lod(structParam.nml).setValues(LoadKey, memberKey, LoadType, ActionKey, LoadMag1, LoadStart, LoadCover)
  structParam.nml = structParam.nml + 1
End Sub

Public Sub clsGeomModel.addGravityLoad(ActionKey As Integer, LoadMag As Double)
  grv_lod.setValues(ActionKey, LoadMag)
End Sub




'REPORTING SUBROUTINES
'------------------------------------------------------------------------------

Sub clsGeomModel.cprintSkeleton()
  Dim i As Integer
End Sub

Sub clsGeomModel.cprintjobData()
  Dim i As Integer

  print "cprintjobData ..."
  ProjectData.cprint

End Sub

Sub clsGeomModel.cprintControlData()
  print "cprintControlData ..."
'  print njt, nmb, nmg, nsg, nrj, njl, nml, ngl, mag
  structParam.cprint
End Sub

Sub clsGeomModel.cprintNodes()
  Dim nodePtr As clsPfCoordinate
  Dim n As Integer
  Dim i As Integer

  print "cprintNodes ..."
  
  If structParam.njt = 0 Then n = max_grps Else n = structParam.njt - 1
  
  For i = baseIndex To n
    nodePtr = nod_grp(i)
    nodePtr.cprint
  Next i
  
  print "... cprintNodes"

End Sub

Sub clsGeomModel.cprintConnectivity()
  Dim i As Integer
  Dim n As Integer

  print "cprint: Connectivity"
  If structParam.nmb = 0 Then n = max_grps Else n = structParam.nmb - 1
  For i = baseIndex To n
    With con_grp(i)
      .cprint
    End With
  Next i

End Sub

Sub clsGeomModel.cprintMaterials()
  Dim i As Integer
  Dim n As Integer

  print "cprint: Materials"
  If structParam.nmg = 0 Then n = max_mats Else n = structParam.nmg - 1
  For i = baseIndex To n
    With mat_grp(i)
      .cprint
    End With
  Next i

End Sub

Sub clsGeomModel.cprintSections()
  Dim i As Integer
  Dim n As Integer
  
  print "cprint: Sections"
  If structParam.nsg = 0 Then n = max_grps Else n = structParam.nsg - 1
  For i = baseIndex To n
    With sec_grp(i)
      .cprint
    End With
  Next i
End Sub


Sub clsGeomModel.cprintSupports()
  Dim i As Integer
  Dim n As Integer
  
  print "cprint: Supports"
  If structParam.nrj = 0 Then n = max_grps Else n = structParam.nrj - 1
  For i = baseIndex To n
    With sup_grp(i)
      .cprint
    End With
  Next i
End Sub

Sub clsGeomModel.cprintJointLoads(isPrintRaw As Boolean)
  Dim i As Integer
  Dim n As Integer
  
  print "cprint: Joint Loads"
  If isPrintRaw Then
    n = numloads
  Else
    n = structParam.njl - 1
  End If
  
  For i = baseIndex To n
    With jnt_lod(i)
      .cprint
    End With
  Next i
  
End Sub


Sub clsGeomModel.cprintMemberLoads()
  Dim i As Integer
  Dim n As Integer
  
  print "cprint: Member Loads"
  If structParam.nml = 0 Then n = numloads Else n = structParam.nml - 1
  For i = baseIndex To n
    With mem_lod(i)
      .cprint
    End With
  Next i
End Sub

Sub clsGeomModel.cprintGravityLoads()
  
  print "cprint: Gravity Loads"
  grv_lod.cprint

End Sub


Sub clsGeomModel.cprint()
  print "cprint ..."
  
  cprintjobData
  cprintControlData
  
  cprintMaterials
  cprintSections
  
  cprintNodes
  cprintConnectivity
  cprintSupports
  
  cprintJointLoads(False)
  cprintMemberLoads
  cprintGravityLoads
  
  print "... cprint"
End Sub

'FILE READING SUBROUTINES
'------------------------------------------------------------------------------
Function clsGeomModel.isDataBlockHeaderString(s As String) As Boolean
  Dim p As Integer
  
  p = InStr(1, s, dataBlockTag)
  If p <> 0 Then
    isDataBlockHeaderString = True
  Else
    isDataBlockHeaderString = False
  End If
  
End Function

Sub clsGeomModel.fgetNodeData(fp as integer, lastTxtStr As String)
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
            ' print "Node=", dataflds(0)
            ' print "x= ", dataflds(1)
            ' print "y= ", dataflds(2)
            addNode(CInt(dataflds(0)), CDbl(dataflds(1)), CDbl(dataflds(2)))
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

Sub clsGeomModel.fgetMemberData(fp as integer, lastTxtStr As String)
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
'            For i = 0 To n
'              print dataflds(i)
'            Next i
'            print "----"
            addMember(CInt(dataflds(0)), CInt(dataflds(1)), CInt(dataflds(2)), CInt(dataflds(3)), CInt(dataflds(4)), CInt(dataflds(5)))
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

Sub clsGeomModel.fgetSupportData(fp as integer, lastTxtStr As String)
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
'            For i = 0 To n
'              print dataflds(i)
'            Next i
'            print "----"

             addSupport(CInt(dataflds(0)), CInt(dataflds(1)), CByte(dataflds(2)), CByte(dataflds(3)), CByte(dataflds(4)))
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

Sub clsGeomModel.fgetMaterialData(fp as integer, lastTxtStr As String)
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
'            For i = 0 To n
'              print dataflds(i)
'            Next i
'            print "----"
             addMaterialGroup(CInt(dataflds(0)), CDbl(dataflds(1)), CDbl(dataflds(2)), CDbl(dataflds(3)))
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

Sub clsGeomModel.fgetSectionData(fp as integer, lastTxtStr As String)
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
'            For i = 0 To n
'              print dataflds(i)
'            Next i
'            print "----"
             addSectionGroup(CInt(dataflds(0)), CDbl(dataflds(1)), CDbl(dataflds(2)), CDbl(dataflds(3)), dataflds(4))
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

Sub clsGeomModel.fgetJointLoadData(fp as integer, lastTxtStr As String)
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
'            For i = 0 To n
'              print dataflds(i)
'            Next i
'            print "----"
             addJointLoad(CInt(dataflds(0)), CDbl(dataflds(1)), CDbl(dataflds(2)), CDbl(dataflds(3)), CDbl(dataflds(4)))
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

Sub clsGeomModel.fgetMemberLoadData(fp as integer, lastTxtStr As String)
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
'            For i = 0 To n
'              print dataflds(i)
'            Next i
'            print "----"

             addMemberLoad(CInt(dataflds(0)), CInt(dataflds(1)), CDbl(dataflds(2)) _
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
  
  
  print "... fgetMemberLoadData"
  
End Sub

Sub clsGeomModel.fgetGravityLoadData(fp as integer, lastTxtStr As String)
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
'            For i = 0 To n
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
'File format to match requirements for F_wrk.exe (With File Date Modified = Friday, 23 August 1996, 13:18:04)
'
Sub clsGeomModel.pframeReader00(fp as integer)
  Const pwid = 20
  Dim i As Byte, tmp As Byte, p As Integer
  Dim s As String
  Dim dataCtrlBlk As String
  
  Dim MachineState As Integer
  Dim quit As Boolean
  Dim done As Boolean
  Dim isDataBlockFound As Boolean
  
  On Error GoTo ErrHandler_pframeReader00
  print "pframeReader00 ..."
  
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
          Case "JOB DETAILS"  'Alternative to Job Data
             ProjectData.fgetData(fp)
            MachineState = MachineScanning
          Case "JOB DATA" 'Alternative to Job Details
             ProjectData.fgetData(fp)
            MachineState = MachineScanning
          Case "CONTROL DATA"
             structParam.fgetData(fp, True)
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
            If Not (Eof(fp)) Then
              MachineState = DataBlockFound
            Else
              MachineState = MachineTurnOFF
            End If
            
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
  
  print "... pframeReader00"
  
Exit_pframeReader00:
    Exit Sub
  
ErrHandler_pframeReader00:
    'On Error Close All open Files
    Close
    print "... pframeReader00: Exit Errors!"
    'print Err.Number, Err.Description
    'Resume Exit_pframeReader00
    Stop
    
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

Sub clsGeomModel.SaveDataToTextFile(fp as integer)
  Const pwid = 40
  Dim i As Byte
  
  print "SaveDataToTextFile ..."
  Print #fp, "JOB DATA" & dataBlockTag
   ProjectData.fprint(fp)
  
  'NB: It some versions of original Pascal application require screen magnification factor
  'other versions don't. If needed and not present the program will crash. If not needed but
  'is present it is simply ignored. Therefore always write to the file.
  Print #fp, "CONTROL DATA" & dataBlockTag
   structParam.fprint(fp)
             
  Print #fp, "NODES" & dataBlockTag
    For i = 1 To structParam.njt
       nod_grp(i).fprint(fp)
    Next i

  Print #fp, "MEMBERS" & dataBlockTag
  For i = 1 To structParam.nmb
     con_grp(i).fprint(fp)
  Next i
  
  Print #fp, "SUPPORTS" & dataBlockTag
  For i = 1 To structParam.nrj
     sup_grp(i).fprint(fp)
  Next i
 
  Print #fp, "MATERIALS" & dataBlockTag
  For i = 1 To structParam.nmg
     mat_grp(i).fprint(fp)
  Next i
  
  Print #fp, "SECTIONS" & dataBlockTag
  For i = 1 To structParam.nsg
     sec_grp(i).fprint(fp)
  Next i
  
  Print #fp, "JOINT LOADS" & dataBlockTag
  print "njl= ", structParam.njl
  For i = 1 To structParam.njl
     jnt_lod(i).fprint(fp)
  Next i
  
  Print #fp, "MEMBER LOADS" & dataBlockTag
  For i = 1 To structParam.nml
     mem_lod(i).fprint(fp)
  Next i
  

  Print #fp, "GRAVITY LOADS" & dataBlockTag

  Close
  
  print "... SaveDataToTextFile"
      
End Sub

