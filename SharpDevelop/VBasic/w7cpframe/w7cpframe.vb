'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On

Module w7cpframe

    Public Const isEarlyVersion As Boolean = True 'Modify to test variable at future date

    Public Const baseIndex As Integer = 0
    Dim fpText As Integer, fpRpt As Integer, fpTracer As Integer
    Dim GModel As New clsGeomModel
    Dim pfModel As New PlaneFrame


    Public Const dataBlockTag As String = "::"
    Public data_loaded As Boolean

    '... Constant declarations ...
    Public Const numloads As Integer = 80
    Public Const order As Integer = 50
    Public Const v_size As Integer = 50
    Public Const max_grps As Integer = 25
    Public Const max_mats As Integer = 10
    Public Const n_segs As Byte = 10


    Sub cpFrameMainApp(ByVal ifullName As String, ByVal ofullName As String, ByVal TraceFName As String)

        Dim isAllowOverWrite As Boolean
        isAllowOverWrite = True 'For result files only

        Console.WriteLine("cpframe ...")
        Console.WriteLine("2D/Plane Frame Analysis ... ")

        Console.WriteLine("Input Data File     : " + ifullName)
        fpText = fopen(ifullName, "rt", False)

        If (fpText <> 0) Then


            'Trace File
            Console.WriteLine("Trace Report File   : " + TraceFName)
            fpTracer = fopen(TraceFName, "wt", isAllowOverWrite)
            If fpTracer = 0 Then
                Console.WriteLine("OUTPUT: File NOT Opened: " + TraceFName)
            End If


            'With GModel
            '    .initialise()
            '    .pframeReader00(fpText)
            '    .cprint()
            'End With

            With pfModel
                .fpTracer = fpTracer
                .GModel.initialise()
                .GModel.pframeReader00(fpText)

                Console.WriteLine()
                Console.WriteLine("DATA PRINTOUT")
                .GModel.cprint()

                .data_loaded = True
                Console.WriteLine("--------------------------------------------------------------------------------")
                Console.WriteLine("Analysis ...")
                .Analyse_Frame()
                Console.WriteLine("... Analysis")

                '    FileClose(fpTracer)
                Console.WriteLine("Report Results ...")
                Console.WriteLine("Output Report File  : " + ofullName)
                fpRpt = fopen(ofullName, "wt", isAllowOverWrite)
                If (fpRpt <> 0) Then
                    'Output_Results()
                    .fPrintResults(fpRpt)
                    FileClose(fpRpt)
                Else
                    Console.WriteLine("Report file NOT created")
                End If

                Console.WriteLine("... Report Results")


                '.Read_Data(fpText)
            End With




        Else
            Console.WriteLine("INPUT: File NOT Opened: " + ifullName)
        End If

        Console.WriteLine("... 2D/Plane Frame Analysis")
        Console.WriteLine("... cpframe")
        Console.WriteLine("<< END >>")

    End Sub 'cpframe



    Sub Main(ByVal cmdArgs() As String)
        Dim fso, WshShell, objArgs
        Dim fldr1, objPath

        'General
        Dim doAction As Boolean
        Dim fpath1 As String
        Dim fDrv As String, fPath, fName, fExt
        Dim ifullName As String
        Dim ofullName As String
        Dim TraceFName As String
        Dim s As String
        Dim isOk As Boolean

        Console.WriteLine("Main ...")
        Console.WriteLine(My.Computer.FileSystem.CurrentDirectory)

        ' See if there are any arguments.
        If cmdArgs.Length = 1 Then
            fpath1 = cmdArgs(0)
            ifullName = fpath1

            fDrv = ""
            fPath = ""
            fName = ""
            fExt = ""
            fnsplit2(fpath1, fDrv, fPath, fName, fExt)

            ofullName = ""
            TraceFName = ""
            ofullName = fnmerge(ofullName, fDrv, fPath, fName, ".rpt")
            TraceFName = fnmerge(TraceFName, fDrv, fPath, fName, ".trc")

            Console.WriteLine("INPUT: Data File: <" & fpath1 & ">")
            Console.WriteLine("OUTPUT: Data File: <" & ofullName & ">")
            Console.WriteLine("OUTPUT: Data File: <" & TraceFName & ">")

            cpFrameMainApp(ifullName, ofullName, TraceFName)

        Else
            Console.WriteLine("Not enough parameters: provide data file name")
        End If

        Console.WriteLine("... Main")
        Console.WriteLine("Press Any Key to Continue ...")
        Console.ReadLine()
        Console.WriteLine("All Done!")

    End Sub

End Module
