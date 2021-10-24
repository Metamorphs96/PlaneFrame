'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On
Public Class clsGeomModel

    Const MinBound = 1 'NB: Collections start item count at 1.
    Const MaxNodes = 5

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

    Const mega As Double = 1000000
    Const kilo As Double = 1000
    Const cent As Double = 100

    Const tolerance As Double = 0.0001
    Const infinity As Double = 2.0E+20
    Const neg_slope As Integer = 1
    Const pos_slope As Integer = -1

    'Public Nodes(MaxNodes) As clsPfCoordinate 'Not possible in vba but possible in vb.net
    Public Nodes As New Collection 'use collection instead of public array

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
    '------------------------------------------------------------------------------
    'Project & Parameters
    Public ProjectData As New clsProjectData
    Public structParam As New clsParameters

    'Materials & Sections
    Public mat_grp(max_mats) As clsPfMaterial        'material_rec
    Public sec_grp(max_grps) As clsPfSection         'section_rec

    'Dimension & Geometry
    Public nod_grp(max_grps) As clsPfCoordinate      'coord_rec
    Public con_grp(max_grps) As clsPfConnectivity    'connect_rec
    Public sup_grp(max_grps) As clsPfSupport         'support_rec

    'Design Actions
    Public jnt_lod(numloads) As clsPfJointLoad       'jnt_ld_rec
    Public mem_lod(numloads) As clsPfMemberLoad      'mem_ld_rec
    Public grv_lod As clsPfGravityLoad     'grv_ld_rec
    '------------------------------------------------------------------------------


    'INITIALISATION SUBROUTINES
    '------------------------------------------------------------------------------
    Sub initialiseMaterials()
        Dim i As Integer

        Console.WriteLine("Initialise: Materials")
        For i = baseIndex To max_mats
            mat_grp(i) = New clsPfMaterial
            With mat_grp(i)
                .initialise()
            End With
        Next i
    End Sub

    Sub initialiseSections()
        Dim i As Integer
        Console.WriteLine("Initialise: Sections")
        For i = baseIndex To max_grps
            sec_grp(i) = New clsPfSection
            With sec_grp(i)
                .initialise()
                .Descr = .Descr & Format(i, "#")
                '.cprint
            End With
        Next i
    End Sub

    Sub initialiseNodes()
        Dim i As Integer
        Console.WriteLine("Initialise: Nodes")
        For i = baseIndex To max_grps
            nod_grp(i) = New clsPfCoordinate
            With nod_grp(i)
                .initialise()
            End With
        Next i
    End Sub

    Sub initialiseConnectivity()
        Dim i As Integer
        Console.WriteLine("Initialise: Connectivity")
        For i = baseIndex To max_grps
            con_grp(i) = New clsPfConnectivity
            With con_grp(i)
                .initialise()
            End With
        Next i
    End Sub

    Sub initialiseSupports()
        Dim i As Integer
        Console.WriteLine("Initialise: Supports")
        For i = baseIndex To max_grps
            sup_grp(i) = New clsPfSupport
            With sup_grp(i)
                .initialise()
            End With
        Next i
    End Sub

    Sub initialiseJointLoads()
        Dim i As Integer

        Console.WriteLine("Initialise: Joint Loads")
        For i = baseIndex To numloads
            jnt_lod(i) = New clsPfJointLoad
            With jnt_lod(i)
                .initialise()
            End With
        Next i

    End Sub


    Sub initialiseMemberLoads()
        Dim i As Integer

        Console.WriteLine("Initialise: Member Loads")
        For i = baseIndex To numloads
            mem_lod(i) = New clsPfMemberLoad
            With mem_lod(i)
                .initialise()
            End With
        Next i

    End Sub

    Sub initialiseGravityLoads()
        Console.WriteLine("Initialise: Gravity Loads")
        grv_lod = New clsPfGravityLoad
        grv_lod.initialise()
    End Sub

    Sub initialise()

        ProjectData.initialise()
        structParam.initialise()

        initialiseMaterials()
        initialiseSections()
        initialiseNodes()
        initialiseConnectivity()
        initialiseSupports()
        initialiseJointLoads()
        initialiseMemberLoads()
        initialiseGravityLoads()
    End Sub

    'DATA COLLECTION SUBROUTINES
    '------------------------------------------------------------------------------
    Sub setNode(ByVal nodeKey As Integer, ByVal x1 As Double, ByVal y1 As Double)
        Dim nodePtr As clsPfCoordinate

        nodePtr = Nodes(nodeKey)
        Call nodePtr.setValues(nodeKey, x1, y1)
    End Sub

    Sub setNode2(ByVal nodeKey As Integer, ByVal x1 As Double, ByVal y1 As Double)
        Dim nodePtr As clsPfCoordinate

        nodePtr = nod_grp(nodeKey)
        Call nodePtr.setValues(nodeKey, x1, y1)
    End Sub

    Public Sub addNode(ByVal nodeKey As Integer, ByVal x As Double, ByVal y As Double)
        Dim nodePtr As clsPfCoordinate

        nodePtr = nod_grp(structParam.njt)
        Call nodePtr.setValues(nodeKey, x, y)
        structParam.njt = structParam.njt + 1

    End Sub

    Public Sub addMaterialGroup(ByVal materialKey As Integer, ByVal density As Double, ByVal ElasticModulus As Double, ByVal CoeffThermExpansion As Double)
        Call mat_grp(structParam.nmg).setValues(materialKey, density, ElasticModulus, CoeffThermExpansion)
        structParam.nmg = structParam.nmg + 1
    End Sub

    Public Sub addSectionGroup(ByVal sectionKey As Integer, ByVal SectionArea As Double, ByVal SecondMomentArea As Double, ByVal materialKey As Integer, ByVal Description As String)
        Call sec_grp(structParam.nsg).setValues(sectionKey, SectionArea, SecondMomentArea, materialKey, Description)
        structParam.nsg = structParam.nsg + 1
    End Sub

    Public Sub addMember(ByVal memberKey As Integer, ByVal NodeA As Integer, ByVal NodeB As Integer, ByVal sectionKey As Integer, ByVal ReleaseA As Integer, ByVal ReleaseB As Integer)
        Call con_grp(structParam.nmb).setValues(memberKey, NodeA, NodeB, sectionKey, ReleaseA, ReleaseB)
        structParam.nmb = structParam.nmb + 1
    End Sub

    Public Sub addSupport(ByVal supportKey As Integer, ByVal SupportNode As Integer, ByVal RestraintX As Byte, ByVal RestraintY As Byte, ByVal RestraintMoment As Byte)


        Call sup_grp(structParam.nrj).setValues(supportKey, SupportNode, RestraintX, RestraintY, RestraintMoment)

        With sup_grp(structParam.nrj)
            structParam.nr = structParam.nr + .rx + .ry + .rm
        End With
        structParam.nrj = structParam.nrj + 1

    End Sub

    Public Sub addJointLoad(ByVal LoadKey As Integer, ByVal Node As Integer, ByVal ForceX As Double, ByVal ForceY As Double, ByVal Moment As Double)
        Call jnt_lod(structParam.njl).setValues(LoadKey, Node, ForceX, ForceY, Moment)
        structParam.njl = structParam.njl + 1
    End Sub

    Public Sub addMemberLoad(ByVal LoadKey As Integer, ByVal memberKey As Integer, ByVal LoadType As Integer, ByVal ActionKey As Integer _
                             , ByVal LoadMag1 As Double, ByVal LoadMag2 As Double, ByVal LoadStart As Double, ByVal LoadCover As Double)


        Call mem_lod(structParam.nml).setValues(LoadKey, memberKey, LoadType, ActionKey, LoadMag1, LoadMag1, LoadStart, LoadCover)
        structParam.nml = structParam.nml + 1
    End Sub

    Public Sub addGravityLoad(ByVal ActionKey As Integer, ByVal LoadMag As Double)
        Call grv_lod.setValues(ActionKey, LoadMag)
    End Sub


    'REPORTING SUBROUTINES
    '------------------------------------------------------------------------------
    Sub cprintjobData()
        Console.WriteLine("cprintjobData ...")
        ProjectData.cprint()
    End Sub

    Sub cprintControlData()
        Console.WriteLine("cprintControlData ...")
        structParam.cprint()
    End Sub

    Sub cprintNodes()
        Dim nodePtr As clsPfCoordinate
        Dim n As Integer
        Dim i As Integer

        Console.WriteLine("cprintNodes ...")

        If structParam.njt = 0 Then n = max_grps Else n = structParam.njt

        For i = baseIndex To n - 1
            nodePtr = nod_grp(i)
            nodePtr.cprint()
        Next i

        Console.WriteLine("... cprintNodes")

    End Sub

    Sub cprintConnectivity()
        Dim i As Integer
        Dim n As Integer

        Console.WriteLine("cprint: Connectivity")
        If structParam.nmb = 0 Then n = max_grps Else n = structParam.nmb
        For i = baseIndex To n - 1
            With con_grp(i)
                .cprint()
            End With
        Next i

    End Sub

    Sub cprintMaterials()
        Dim i As Integer
        Dim n As Integer

        Console.WriteLine("cprint: Materials")
        If structParam.nmg = 0 Then n = max_mats Else n = structParam.nmg
        For i = baseIndex To n - 1
            With mat_grp(i)
                .cprint()
            End With
        Next i

    End Sub

    Sub cprintSections()
        Dim i As Integer
        Dim n As Integer

        Console.WriteLine("cprint: Sections")
        If structParam.nsg = 0 Then n = max_grps Else n = structParam.nsg
        For i = baseIndex To n - 1
            With sec_grp(i)
                .cprint()
            End With
        Next i
    End Sub


    Sub cprintSupports()
        Dim i As Integer
        Dim n As Integer

        Console.WriteLine("cprint: Supports")
        If structParam.nrj = 0 Then n = max_grps Else n = structParam.nrj
        For i = baseIndex To n - 1
            With sup_grp(i)
                .cprint()
            End With
        Next i
    End Sub

    Sub cprintJointLoads(ByVal isPrintRaw As Boolean)
        Dim i As Integer
        Dim n As Integer

        Console.WriteLine("cprint: Joint Loads")
        If isPrintRaw Then
            n = numloads
        Else
            n = structParam.njl
        End If

        For i = baseIndex To n - 1
            With jnt_lod(i)
                .cprint()
            End With
        Next i

    End Sub


    Sub cprintMemberLoads()
        Dim i As Integer
        Dim n As Integer

        Console.WriteLine("cprint: Member Loads")
        If structParam.nml = 0 Then n = numloads Else n = structParam.nml
        For i = baseIndex To n - 1
            With mem_lod(i)
                .cprint()
            End With
        Next i
    End Sub

    Sub cprintGravityLoads()

        Console.WriteLine("cprint: Gravity Loads")
        grv_lod.cprint()

    End Sub


    Sub cprint()
        Console.WriteLine("cprint ...")

        cprintjobData()
        cprintControlData()

        cprintMaterials()
        cprintSections()

        cprintNodes()
        cprintConnectivity()
        cprintSupports()

        Call cprintJointLoads(False)
        cprintMemberLoads()
        cprintGravityLoads()

        Console.WriteLine("... cprint")
    End Sub

    'FILE READING SUBROUTINES
    '------------------------------------------------------------------------------
    Function isDataBlockHeaderString(ByVal s As String) As Boolean
        Dim p As Integer

        p = InStr(1, s, dataBlockTag)
        If p <> 0 Then
            isDataBlockHeaderString = True
        Else
            isDataBlockHeaderString = False
        End If

    End Function

    Sub fgetNodeData(ByVal fp As Integer, ByRef lastTxtStr As String)
        Dim s As String
        Dim n As Integer
        Dim dataflds(4) As String

        Dim MachineState As Integer
        Dim quit As Boolean 'Switch Machine OFF and Quit
        Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
        Dim isDataBlockFound As Boolean

        quit = False
        MachineState = MachineON 'and is Scanning file
        done = False
        isDataBlockFound = False

        Console.WriteLine("fgetNodeData ...")

        done = False
        Do While Not (done) And Not (quit)
            Select Case MachineState
                Case MachineTurnOFF
                    quit = True
                    Console.WriteLine("Machine to be Turned OFF")
                Case MachineScanning
                    If Not (EOF(fp)) Then
                        s = Trim(Readln(fp))
                        isDataBlockFound = isDataBlockHeaderString(s)
                        If isDataBlockFound Then
                            MachineState = DataBlockFound
                        Else
                            Call parseDelimitedString(s, dataflds, n, " ")
                            Console.WriteLine("Node= " + dataflds(0))
                            Console.WriteLine("x= " + dataflds(1))
                            Console.WriteLine("y= " + dataflds(2))
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
        Console.WriteLine("... fgetNodeData")
    End Sub

    Sub fgetMemberData(ByVal fp As Integer, ByRef lastTxtStr As String)
        Dim s As String
        Dim n As Integer
        Dim dataflds(8) As String

        Dim MachineState As Integer
        Dim quit As Boolean 'Switch Machine OFF and Quit
        Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
        Dim isDataBlockFound As Boolean

        quit = False
        MachineState = MachineON 'and is Scanning file
        done = False
        isDataBlockFound = False

        Console.WriteLine("fgetMemberData ...")

        done = False
        Do While Not (done) And Not (quit)
            Select Case MachineState
                Case MachineTurnOFF
                    quit = True
                    Console.WriteLine("Machine to be Turned OFF")
                Case MachineScanning
                    If Not (EOF(fp)) Then
                        s = Trim(Readln(fp))
                        isDataBlockFound = isDataBlockHeaderString(s)
                        If isDataBlockFound Then
                            MachineState = DataBlockFound
                        Else
                            Call parseDelimitedString(s, dataflds, n, " ")
                            '            For i = 0 To n
                            '              console.writeLine( dataflds(i))
                            '            Next i
                            '            console.writeLine( "----")
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

        Console.WriteLine("... fgetMemberData")

    End Sub

    Sub fgetSupportData(ByVal fp As Integer, ByRef lastTxtStr As String)
        Dim s As String
        Dim n As Integer
        Dim dataflds(6) As String

        Dim MachineState As Integer
        Dim quit As Boolean 'Switch Machine OFF and Quit
        Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
        Dim isDataBlockFound As Boolean

        quit = False
        MachineState = MachineON 'and is Scanning file
        done = False
        isDataBlockFound = False

        Console.WriteLine("fgetSupportData ...")

        done = False
        Do While Not (done) And Not (quit)
            Select Case MachineState
                Case MachineTurnOFF
                    quit = True
                    Console.WriteLine("Machine to be Turned OFF")
                Case MachineScanning
                    If Not (EOF(fp)) Then
                        s = Trim(Readln(fp))
                        isDataBlockFound = isDataBlockHeaderString(s)
                        If isDataBlockFound Then
                            MachineState = DataBlockFound
                        Else
                            Call parseDelimitedString(s, dataflds, n, " ")
                            '            For i = 0 To n
                            '              console.writeLine( dataflds(i))
                            '            Next i
                            '            console.writeLine( "----")

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

        Console.WriteLine("... fgetSupportData")

    End Sub

    Sub fgetMaterialData(ByVal fp As Integer, ByRef lastTxtStr As String)
        Dim s As String
        Dim n As Integer
        Dim dataflds(8) As String

        Dim MachineState As Integer
        Dim quit As Boolean 'Switch Machine OFF and Quit
        Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
        Dim isDataBlockFound As Boolean

        quit = False
        MachineState = MachineON 'and is Scanning file
        done = False
        isDataBlockFound = False

        Console.WriteLine("fgetMaterialData ...")

        done = False
        Do While Not (done) And Not (quit)
            Select Case MachineState
                Case MachineTurnOFF
                    quit = True
                    Console.WriteLine("Machine to be Turned OFF")
                Case MachineScanning
                    If Not (EOF(fp)) Then
                        s = Trim(Readln(fp))
                        isDataBlockFound = isDataBlockHeaderString(s)
                        If isDataBlockFound Then
                            MachineState = DataBlockFound
                        Else
                            Call parseDelimitedString(s, dataflds, n, " ")
                            '            For i = 0 To n
                            '              console.writeLine( dataflds(i))
                            '            Next i
                            '            console.writeLine( "----"
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



        Console.WriteLine("... fgetMaterialData")

    End Sub

    Sub fgetSectionData(ByVal fp As Integer, ByRef lastTxtStr As String)
        Dim s As String
        Dim n As Integer
        Dim dataflds(8) As String

        Dim MachineState As Integer
        Dim quit As Boolean 'Switch Machine OFF and Quit
        Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
        Dim isDataBlockFound As Boolean

        quit = False
        MachineState = MachineON 'and is Scanning file
        done = False
        isDataBlockFound = False

        Console.WriteLine("fgetSectionData ...")

        done = False
        Do While Not (done) And Not (quit)
            Select Case MachineState
                Case MachineTurnOFF
                    quit = True
                    Console.WriteLine("Machine to be Turned OFF")
                Case MachineScanning
                    If Not (EOF(fp)) Then
                        s = Trim(Readln(fp))
                        isDataBlockFound = isDataBlockHeaderString(s)
                        If isDataBlockFound Then
                            MachineState = DataBlockFound
                        Else
                            Call parseDelimitedString(s, dataflds, n, " ")
                            '            For i = 0 To n
                            '              console.writeLine( dataflds(i))
                            '            Next i
                            '            console.writeLine( "----")
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



        Console.WriteLine("... fgetSectionData")

    End Sub

    Sub fgetJointLoadData(ByVal fp As Integer, ByRef lastTxtStr As String)
        Dim s As String
        Dim i As Integer, n As Integer
        Dim dataflds(8) As String

        Dim MachineState As Integer
        Dim quit As Boolean 'Switch Machine OFF and Quit
        Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
        Dim isDataBlockFound As Boolean

        quit = False
        MachineState = MachineON 'and is Scanning file
        done = False
        isDataBlockFound = False

        Console.WriteLine("fgetJointLoadData ...")

        done = False
        Do While Not (done) And Not (quit)
            Select Case MachineState
                Case MachineTurnOFF
                    quit = True
                    Console.WriteLine("Machine to be Turned OFF")
                Case MachineScanning
                    If Not (EOF(fp)) Then
                        s = Trim(Readln(fp))
                        isDataBlockFound = isDataBlockHeaderString(s)
                        If isDataBlockFound Then
                            MachineState = DataBlockFound
                        Else
                            Call parseDelimitedString(s, dataflds, n, " ")
                            '            For i = 0 To n
                            '              console.writeLine( dataflds(i))
                            '            Next i
                            '            console.writeLine( "----")
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


        Console.WriteLine("... fgetJointLoadData")

    End Sub

    Sub fgetMemberLoadData(ByVal fp As Integer, ByRef lastTxtStr As String)
        Dim s As String
        Dim i As Integer, n As Integer
        Dim dataflds(8) As String

        Dim MachineState As Integer
        Dim quit As Boolean 'Switch Machine OFF and Quit
        Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
        Dim isDataBlockFound As Boolean

        quit = False
        MachineState = MachineON 'and is Scanning file
        done = False
        isDataBlockFound = False

        Console.WriteLine("fgetMemberLoadData ...")

        done = False
        Do While Not (done) And Not (quit)
            Select Case MachineState
                Case MachineTurnOFF
                    quit = True
                    Console.WriteLine("Machine to be Turned OFF")
                Case MachineScanning
                    If Not (EOF(fp)) Then
                        s = Trim(Readln(fp))
                        isDataBlockFound = isDataBlockHeaderString(s)
                        If isDataBlockFound Then
                            MachineState = DataBlockFound
                        Else
                            Call parseDelimitedString(s, dataflds, n, " ")
                            '            For i = 0 To n
                            '              console.writeLine( dataflds(i))
                            '            Next i
                            '            console.writeLine( "----")

                            If isEarlyVersion Then
                                Call addMemberLoad(CInt(dataflds(0)), CInt(dataflds(1)), CDbl(dataflds(2)) _
                                                   , CDbl(dataflds(3)), CDbl(dataflds(4)), CDbl(dataflds(4)) _
                                                   , CDbl(dataflds(5)), CDbl(dataflds(6)))
                            Else
                                Call addMemberLoad(CInt(dataflds(0)), CInt(dataflds(1)), CDbl(dataflds(2)) _
                                       , CDbl(dataflds(3)), CDbl(dataflds(4)), CDbl(dataflds(5)) _
                                       , CDbl(dataflds(6)), CDbl(dataflds(7)))
                            End If



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


        Console.WriteLine("... fgetMemberLoadData")

    End Sub

    Sub fgetGravityLoadData(ByVal fp As Integer, ByRef lastTxtStr As String)
        Dim s As String
        Dim i As Integer, n As Integer
        Dim dataflds(8) As String

        Dim MachineState As Integer
        Dim quit As Boolean 'Switch Machine OFF and Quit
        Dim done As Boolean 'Finished Reading File but not processing data, prepare machine to switch off
        Dim isDataBlockFound As Boolean
        Dim isUseDefaultData As Boolean

        Console.WriteLine("fgetGravityLoadData ...")

        isDataBlockFound = False
        If Not (EOF(fp)) Then
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
                    Console.WriteLine("Limit State File Parser Machine to be Turned OFF")
                Case MachineScanning
                    If Not (EOF(fp)) Then
                        s = Trim(Readln(fp))
                        isDataBlockFound = isDataBlockHeaderString(s)
                        If isDataBlockFound Then
                            MachineState = DataBlockFound
                        Else
                            Call parseDelimitedString(s, dataflds, n, " ")
                            '            For i = 0 To n
                            '              console.writeLine( dataflds(i))
                            '            Next i
                            '            console.writeLine( "----")
                            Call addGravityLoad(CInt(dataflds(0)), CDbl(dataflds(1)))
                            MachineState = MachineScanning
                        End If
                    Else
                        Console.WriteLine("... End of File")
                        done = True
                        MachineState = MachineTurnOFF
                    End If
                Case DataBlockFound
                    'Signifies End of Current Data Block
                    done = True
                    MachineState = MachineTurnOFF
            End Select
        Loop

        If Not (EOF(fp)) Then
            lastTxtStr = s
        Else
            lastTxtStr = ""
        End If

        If isUseDefaultData Then
            Console.WriteLine("Using Default Data")
            Call addGravityLoad(2, -9.81)
        End If

        'File Data Ignored
        'Default Values Used Only

        Console.WriteLine("... fgetGravityLoadData")
    End Sub


    'Limit State Machine: File Parser
    'File format to match requirements for F_wrk.exe (With File Date Modified = Friday, 23 August 1996, 13:18:04)
    '
    Sub pframeReader00(ByVal fp As Integer)
        Const pwid = 20
        Dim i As Byte, tmp As Byte, p As Integer
        Dim s As String
        Dim dataCtrlBlk As String

        Dim MachineState As Integer
        Dim quit As Boolean
        Dim done As Boolean
        Dim isDataBlockFound As Boolean

        On Error GoTo ErrHandler_pframeReader00
        Console.WriteLine("pframeReader00 ...")

        quit = False
        MachineState = MachineON 'and is Scanning file
        done = False
        isDataBlockFound = False
        s = ""
        dataCtrlBlk = ""

        Do While Not (done) And Not (quit)

            Select Case MachineState
                Case MachineTurnOFF
                    quit = True
                    Console.WriteLine("Machine to be Turned OFF")
                Case MachineScanning
                    If Not (EOF(fp)) Then
                        s = Readln(fp)
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
                    Console.WriteLine("<" & dataCtrlBlk & ">")
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
                            If Not (EOF(fp)) Then
                                MachineState = DataBlockFound
                            Else
                                MachineState = MachineTurnOFF
                            End If

                        Case "GRAVITY LOADS"
                            Call fgetGravityLoadData(fp, s)
                            MachineState = MachineTurnOFF
                    End Select
                Case Else
                    If EOF(fp) Then
                        Console.WriteLine("DataBlockFound: End Of File")
                        done = True
                        MachineState = MachineTurnOFF
                    Else
                        MachineState = MachineScanning
                    End If
            End Select 'machine state

        Loop

        Console.WriteLine("... pframeReader00")

Exit_pframeReader00:
        Exit Sub

ErrHandler_pframeReader00:
        'On Error Close All open Files
        FileClose()
        Console.WriteLine("... pframeReader00: Exit Errors!")
        Console.WriteLine(Err.Number, Err.Description)
        Stop

    End Sub

    'DATA FILE STORE SUBROUTINES
    '------------------------------------------------------------------------------
    'Compatible file for F_wrk.exe (With File Date Modified = Friday, 23 August 1996, 13:18:04)
    Sub SaveDataToTextFile(ByVal fp As Integer)
        Dim i As Byte

        Console.WriteLine("SaveDataToTextFile ...")
        Print(fp, "JOB DATA" & dataBlockTag)
        Call ProjectData.fprint(fp)

        'NB: It some versions of original Pascal application require screen magnification factor
        'other versions don't. If needed and not present the program will crash. If not needed but
        'is present it is simply ignored. Therefore always write to the file.
        Print(fp, "CONTROL DATA" & dataBlockTag)
        Call structParam.fprint(fp)

        Print(fp, "NODES" & dataBlockTag)
        For i = 1 To structParam.njt
            Call nod_grp(i).fprint(fp)
        Next i

        Print(fp, "MEMBERS" & dataBlockTag)
        For i = 1 To structParam.nmb
            Call con_grp(i).fprint(fp)
        Next i

        Print(fp, "SUPPORTS" & dataBlockTag)
        For i = 1 To structParam.nrj
            Call sup_grp(i).fprint(fp)
        Next i

        Print(fp, "MATERIALS" & dataBlockTag)
        For i = 1 To structParam.nmg
            Call mat_grp(i).fprint(fp)
        Next i

        Print(fp, "SECTIONS" & dataBlockTag)
        For i = 1 To structParam.nsg
            Call sec_grp(i).fprint(fp)
        Next i

        Print(fp, "JOINT LOADS" & dataBlockTag)
        Console.WriteLine("njl= " + format(structParam.njl,"0"))
        For i = 1 To structParam.njl
            Call jnt_lod(i).fprint(fp)
        Next i

        Print(fp, "MEMBER LOADS" & dataBlockTag)
        For i = 1 To structParam.nml
            Call mem_lod(i).fprint(fp)
        Next i


        Print(fp, "GRAVITY LOADS" & dataBlockTag)

        FileClose(fp)

        Console.WriteLine("... SaveDataToTextFile")

    End Sub


    'EXCEL WORKBOOK STORE DATA SUBROUTINES
    '------------------------------------------------------------------------------
    'Sub wbkStoreNodes(ByVal dataBk As Workbook)
    '    Dim i As Integer
    '    Dim dataTable As Range
    '    Dim nodePtr As clsPfCoordinate

    '    dataTable = dataBk.Names("NODES").RefersToRange

    '    For i = baseIndex To structParam.njt
    '        nodePtr = nod_grp(i)
    '        Call nodePtr.wbkPrint(dataTable, i - 1)
    '    Next i

    'End Sub

    'Sub wbkStoreConnectivity(ByVal dataBk As Workbook)
    '    Dim i As Integer
    '    Dim dataTable As Range
    '    Dim connectivtyPtr As clsPfConnectivity

    '    dataTable = dataBk.Names("MEMBERS").RefersToRange

    '    For i = baseIndex To structParam.nmb
    '        connectivtyPtr = con_grp(i)
    '        Call connectivtyPtr.wbkPrint(dataTable, i - 1)
    '    Next i

    'End Sub


    'Sub wbkStoreMaterials(ByVal dataBk As Workbook)
    '    Dim i As Integer
    '    Dim dataTable As Range
    '    Dim materialPtr As clsPfMaterial

    '    dataTable = dataBk.Names("MATERIAL_ID").RefersToRange
    '    For i = baseIndex To structParam.nmg
    '        materialPtr = mat_grp(i)
    '        Call materialPtr.wbkPrint(dataTable, i - 1)
    '    Next i

    'End Sub

    'Sub wbkStoreSections(ByVal dataBk As Workbook)
    '    Dim i As Integer
    '    Dim dataTable As Range
    '    Dim sectionPtr As clsPfSection

    '    dataTable = dataBk.Names("SECTION_ID").RefersToRange

    '    For i = baseIndex To structParam.nsg
    '        sectionPtr = sec_grp(i)
    '        Call sectionPtr.wbkPrint(dataTable, i - 1)
    '    Next i

    'End Sub

    'Sub wbkStoreSupports(ByVal dataBk As Workbook)
    '    Dim i As Integer
    '    Dim dataTable As Range
    '    Dim supportPtr As clsPfSupport

    '    dataTable = dataBk.Names("SUPPORTS").RefersToRange
    '    For i = baseIndex To structParam.nrj
    '        supportPtr = sup_grp(i)
    '        Call supportPtr.wbkPrint(dataTable, i - 1)
    '    Next i
    'End Sub

    'Sub wbkStoreJointLoads(ByVal dataBk As Workbook)
    '    Dim i As Integer
    '    Dim dataTable As Range
    '    Dim jointLoadPtr As clsPfJointLoad

    '    dataTable = dataBk.Names("JLOADS").RefersToRange
    '    For i = baseIndex To structParam.njl
    '        jointLoadPtr = jnt_lod(i)
    '        Call jointLoadPtr.wbkPrint(dataTable, i - 1)
    '    Next i

    'End Sub

    'Sub wbkStoreMemberLoads(ByVal dataBk As Workbook)
    '    Dim i As Integer
    '    Dim dataTable As Range
    '    Dim memberLoadPtr As clsPfMemberLoad

    '    dataTable = dataBk.Names("MLOADS").RefersToRange
    '    For i = baseIndex To structParam.nml
    '        memberLoadPtr = mem_lod(i)
    '        Call memberLoadPtr.wbkPrint(dataTable, i - 1)
    '    Next i
    'End Sub

    'Sub wbkStoreGravityLoads(ByVal dataBk As Workbook)
    '    Dim dataTable As Range
    '    Dim gravityLoadPtr As clsPfGravityLoad

    '    dataTable = dataBk.Names("GLoads").RefersToRange

    '    gravityLoadPtr = grv_lod


    '    Call gravityLoadPtr.wbkPrint(dataTable, 0)

    'End Sub

    'Sub wbkClearData(ByVal dataBk As Workbook)
    '    Dim wrkSht As Worksheet

    '    Dim dataShts As Object
    '    Dim hdrs As Object
    '    Dim numRecs As Object

    '    Dim i As Integer, n As Integer

    '    dataShts = Array("Nodes", "Members", "Supports", "Materials", "FrameSections", "JointLoads", "MemberLoads", "GravityLoads")
    '    hdrs = Array(3, 2, 2, 3, 3, 3, 3, 3)
    '    numRecs = Array(max_grps, max_grps, max_grps, max_mats, max_grps, numloads, numloads, 1)


    '    n = UBound(dataShts)

    '    For i = 0 To n
    '        '    console.writeLine( dataShts(i), hdrs(i), numRecs(i)
    '        wrkSht = dataBk.Worksheets(dataShts(i))
    '        Call ClearDataBlock(wrkSht, CInt(hdrs(i)), CInt(numRecs(i)))
    '    Next i

    'End Sub

    'Sub wbkStoreData()
    '    Dim dataBk As Workbook
    '    Dim dataSht As Worksheet

    '    dataBk = ThisWorkbook


    '    Call wbkClearData(dataBk)

    '    dataSht = dataBk.Worksheets("ProjectData")
    '    Call ProjectData.wbkPrint(dataSht)

    '    dataSht = dataBk.Worksheets("Param")
    '    Call structParam.wbkPrint(dataSht)

    '    'Materials & Sections
    '    Call wbkStoreMaterials(dataBk)
    '    Call wbkStoreSections(dataBk)

    '    'Dimension & Geometry
    '    Call wbkStoreNodes(dataBk)
    '    Call wbkStoreConnectivity(dataBk)
    '    Call wbkStoreSupports(dataBk)

    '    'Design Actions
    '    Call wbkStoreJointLoads(dataBk)
    '    Call wbkStoreMemberLoads(dataBk)
    '    Call wbkStoreGravityLoads(dataBk)

    'End Sub

    'EXCEL WORKBOOK GET DATA SUBROUTINES
    '------------------------------------------------------------------------------

    'Sub wbkReadNodes(ByVal dataTable As Range)
    '    Dim r As Integer

    '    console.writeLine("Reading: Nodes...")
    '    r = 0
    '    Do While Not (IsEmpty(dataTable.Offset(r, 1)))
    '        structParam.njt = structParam.njt + 1
    '        Call nod_grp(structParam.njt).wbkRead(dataTable, r)
    '        r = r + 1
    '        console.writeLine(r, structParam.njt, nod_grp(structParam.njt).x, nod_grp(structParam.njt).y)
    '    Loop

    'End Sub

    'Sub wbkReadMaterials(ByVal dataTable As Range)
    '    Dim r As Byte

    '    console.writeLine("Reading: Materials...")
    '    r = 0
    '    Do While Not (IsEmpty(dataTable.Offset(r, 1)))
    '        structParam.nmg = structParam.nmg + 1
    '        Call mat_grp(structParam.nmg).wbkRead(dataTable, r)
    '        r = r + 1
    '        console.writeLine(r, structParam.nmg)
    '    Loop
    'End Sub

    'Sub wbkReadSections(ByVal dataTable As Range)
    '    Dim r As Byte

    '    console.writeLine("Reading: Sections...")
    '    r = 0
    '    Do While Not (IsEmpty(dataTable.Offset(r, 1)))
    '        structParam.nsg = structParam.nsg + 1
    '        Call sec_grp(structParam.nsg).wbkRead(dataTable, r)
    '        r = r + 1
    '        console.writeLine(r, structParam.nsg)
    '    Loop
    'End Sub

    'Sub wbkReadMembers(ByVal dataTable As Range)
    '    Dim r As Byte

    '    console.writeLine("Reading: Members...")
    '    r = 0
    '    Do While Not (IsEmpty(dataTable.Offset(r, 1)))
    '        structParam.nmb = structParam.nmb + 1
    '        Call con_grp(structParam.nmb).wbkRead(dataTable, r)
    '        r = r + 1
    '        console.writeLine(r, structParam.nmb)
    '    Loop

    'End Sub

    'Sub wbkReadSupports(ByVal dataTable As Range)
    '    Dim r As Byte

    '    console.writeLine("Reading: Supports...")
    '    r = 0
    '    Do While Not (IsEmpty(dataTable.Offset(r, 1)))
    '        structParam.nrj = structParam.nrj + 1
    '        Call sup_grp(structParam.nrj).wbkRead(dataTable, r)
    '        With sup_grp(structParam.nrj)
    '            structParam.nr = structParam.nr + .rx + .ry + .rm
    '        End With
    '        r = r + 1
    '        console.writeLine(r, structParam.nrj)
    '    Loop
    '    console.writeLine("No. Restrained nr .. ", structParam.nr)

    'End Sub

    'Sub wbkReadNodeLoads(ByVal dataTable As Range)
    '    Dim r As Byte

    '    console.writeLine("Reading: Node Loads...")
    '    r = 0
    '    Do While Not (IsEmpty(dataTable.Offset(r, 1)))

    '        structParam.njl = structParam.njl + 1
    '        Call jnt_lod(structParam.njl).wbkRead(dataTable, r)

    '        r = r + 1
    '        console.writeLine(r, structParam.njl)
    '    Loop

    'End Sub


    'Sub wbkReadMemberLoads(ByVal dataTable As Range)
    '    Dim r As Byte

    '    console.writeLine("Reading: Member Loads...")
    '    r = 0
    '    Do While Not (IsEmpty(dataTable.Offset(r, 1)))

    '        structParam.nml = structParam.nml + 1
    '        Call mem_lod(structParam.nml).wbkRead(dataTable, r)
    '        r = r + 1
    '        console.writeLine(r, structParam.nml)
    '    Loop
    'End Sub


    'Sub wbkReadGravityLoads(ByVal dataTable As Range)
    '    Dim r As Byte

    '    console.writeLine("Reading: Gravity Loads...")
    '    r = 0
    '    Call grv_lod.wbkRead(dataTable, r)

    'End Sub



    'Sub wbkGetData(ByVal dataBk As Workbook)
    '    Dim r As Byte '.. Input Row ..]
    '    Dim dataTable As Range
    '    Dim dataSht As Worksheet

    '    data_loaded = False
    '    structParam.nr = 0

    '    console.writeLine("wbkGetData ...")

    '    dataSht = dataBk.Worksheets("ProjectData")
    '    Call ProjectData.wbkRead(dataSht)

    '    dataSht = dataBk.Worksheets("Param")
    '    Call structParam.wbkRead(dataSht, True)

    '    dataTable = dataBk.Worksheets("Nodes").Range("Nodes")
    '    Call wbkReadNodes(dataTable)

    '    dataTable = dataBk.Worksheets("Materials").Range("MATERIAL_ID")
    '    Call wbkReadMaterials(dataTable)

    '    dataTable = dataBk.Worksheets("FrameSections").Range("SECTION_ID")
    '    Call wbkReadSections(dataTable)

    '    dataTable = dataBk.Worksheets("Members").Range("Members")
    '    Call wbkReadMembers(dataTable)

    '    dataTable = dataBk.Worksheets("Supports").Range("Supports")
    '    Call wbkReadSupports(dataTable)

    '    dataTable = dataBk.Worksheets("JointLoads").Range("JLOADS")
    '    Call wbkReadNodeLoads(dataTable)

    '    dataTable = dataBk.Worksheets("MemberLoads").Range("MLOADS")
    '    Call wbkReadMemberLoads(dataTable)

    '    dataTable = dataBk.Worksheets("GravityLoads").Range("GLoads")
    '    Call wbkReadGravityLoads(dataTable)

    '    data_loaded = True

    '    console.writeLine("... wbkGetData")

    'End Sub



End Class
