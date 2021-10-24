Module uwgpframe
    Public Const isEarlyVersion As Boolean = True 'Modify to test variable at future date
    Public Const baseIndex As Integer = 0

    Public Const dataBlockTag As String = "::"
    Public data_loaded As Boolean

    '... Constant declarations ...
    Public Const numloads As Integer = 80
    Public Const order As Integer = 50
    Public Const v_size As Integer = 50
    Public Const max_grps As Integer = 25
    Public Const max_mats As Integer = 10
    Public Const n_segs As Byte = 7

    Public dataFileName As String
    Public ifullName As String
    Public ofullName As String
    Public TraceFName As String

    Dim fpText As Integer
    Dim fpRpt As Integer
    Dim fpTracer As Integer


    'Dim GModel As clsGeomModel
    Public pfModel As PlaneFrame


    Public isDataLoaded As Boolean
    Public isAnalysed As Boolean

    'Dim edModel As TModelEditor

    Public frmTracer As TTracerFrm
    Public ResultViewer As TTracerFrm
    Public graphViewer As TgraphViewer



    Sub cpFramefgetData()

        Dim isAllowOverWrite As Boolean
        Dim isOK, isFileOk as boolean
        Dim isFileClosed as boolean
        
        isOK = False
        isAllowOverWrite = True 'For result files only

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "cpFramefgetData ..."

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Input Data File     : " + ifullName
        fpText = fopen(ifullName, "rt", False)
        

        If (fpText <> 0) Then

            'GModel = New clsGeomModel
            'With GModel
            '    .initialise()
            '    .pframeReader00(fpText)
            '    .cprint()
            'End With   
            
            'Trace File
            frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Trace Report File   : " + TraceFName
            fpTracer = fopen(TraceFName, "wt", isAllowOverWrite)
            If fpTracer = 0 Then
                frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "OUTPUT: File NOT Opened: " + TraceFName
            else
                pfModel = New PlaneFrame
                With pfModel
                    .fpTracer = fpTracer
                    .GModel.initialise()
                    .GModel.pframeReader00(fpText)
                    FileClose(fpText)
                    isDataLoaded = True
                    .data_loaded = isDataLoaded
                End With
            End If

        Else
            Console.WriteLine("INPUT: File NOT Opened: " + ifullName)
        End If
        
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "... cpFramefgetData"
        
    End Sub

    Sub cpFrameRunAnalysis

        Dim isAllowOverWrite As Boolean
        isAllowOverWrite = True 'For result files only

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "cpframe ..."
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "2D/Plane Frame Analysis ... "
        pfModel.data_loaded = isDataLoaded
        If isDataLoaded Then

            With pfModel

                frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf
                frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "DATA PRINTOUT"
                .GModel.cprint()

                frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "--------------------------------------------------------------------------------"
                frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Analysis ..."
                .Analyse_Frame()
                frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "... Analysis"
                FileClose(fpTracer)

                frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Report Results ..."
                frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Output Report File  : " + ofullName
                fpRpt = fopen(ofullName, "wt", isAllowOverWrite)
                If (fpRpt <> 0) Then
                    .fPrintResults(fpRpt)
                    FileClose(fpRpt)
                Else
                    frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Report file NOT created"
                End If

                frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "... Report Results"

            End With



        End If

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "... 2D/Plane Frame Analysis"
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "... cpframe"
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "<< END >>"

    End Sub 'cpframe
  
    
   
    Sub MainApplication(ByVal dataFileName As String)
        'General
        Dim fpath1 As String
        Dim fDrv As String, fPath, fName, fExt

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Main ..."
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & My.Computer.FileSystem.CurrentDirectory

        'See if there are any arguments.
        fpath1 = dataFileName
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

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "INPUT: Data File: <" & fpath1 & ">"
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "OUTPUT: Data File: <" & ofullName & ">"
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "OUTPUT: Data File: <" & TraceFName & ">"

    End Sub

End Module
