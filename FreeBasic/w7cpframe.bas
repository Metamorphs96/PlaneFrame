'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'IMPLEMENTATION
'-------------------------------------------------------------------------------


'Main Program File

#include once "XStrings.bi"
#include once "fnXStrings.bi"
#include once "FileMngt.bi"
#include once "clsGeomModel.bi"
#include once "PlaneFrame.bi"


Function countCmdArgs as integer
    Dim isDone As Boolean
    Dim argc As Integer, argv As String
    
    isDone = False
    argc = 0
    Do
         argv = Command( argc )
         If( Len( argv ) = 0 ) Then
             isDone = True
         Else    
            argc += 1
         End If
    Loop Until isDone
    
    countCmdArgs = argc-1 'NB: argc is index into zero based array
End Function


 Sub cpFrameMainApp(ByVal ifullName As String, ByVal ofullName As String, ByVal TraceFName As String)

     Dim fpText as integer
     Dim fpTracer as integer
     Dim fpRpt as Integer
     
     Dim GModel as clsGeomModel
     Dim pfModel as PlaneFrame
     
     Dim isAllowOverWrite As Boolean
     isAllowOverWrite = True 'For result files only

     print "cpframe ..."
     print "2D/Plane Frame Analysis ... "

     print "Input Data File     : " + ifullName
     fpText = fopen(ifullName, "rt")

     If (fpText <> 0) Then


         'Trace File
         print "Trace Report File   : " + TraceFName
         fpTracer = fopen(TraceFName, "wt")
         If fpTracer = 0 Then
             print "OUTPUT: File NOT Opened: " + TraceFName
         End If


'         With GModel
'             .initialise
'             .pframeReader00(fpText)
'             .cprint
'         End With

         With pfModel
             .fpTracer = fpTracer
             .GModel.initialise()
             .GModel.pframeReader00(fpText)

             print 
             print "DATA PRINTOUT"
             .GModel.cprint 

             .data_loaded = True
             print "--------------------------------------------------------------------------------"
             print "Analysis ..."
             .Analyse_Frame()
             Close #fpTracer
             print "... Analysis"

             '    FileClose(fpTracer)
             print "Report Results ..."
             print "Output Report File  : " + ofullName
             fpRpt = fopen(ofullName, "wt")
             If (fpRpt <> 0) Then
                 'Output_Results()
                 .fPrintResults(fpRpt)
                 Close #fpRpt
             Else
                 print "Report file NOT created"
             End If

             print "... Report Results"


             '.Read_Data(fpText)
         End With




     Else
         print "INPUT: File NOT Opened: " + ifullName
     End If

     print "... 2D/Plane Frame Analysis"
     print "... cpframe"
     print "<< END >>"

 End Sub 'cpframe



Sub Main()
    Dim argc As Integer, argv As String
    'Dim fso as variant, WshShell as variant, objArgs as variant
    'Dim fldr1 as variant, objPath as variant

    'General
    Dim doAction As Boolean
    Dim fpath1 As String
    Dim fDrv As String, fPath as String, fName as string, fExt as string
    Dim ifullName As String
    Dim ofullName As String
    Dim TraceFName As String
    Dim s As String
    Dim isOk As Boolean
    Dim tmpResponse as string

    print "Main ..."

    ' See if there are any arguments.
    If (countCmdArgs() = 1) Then

        fpath1 = Command( 1 )
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

        print "INPUT: Data File: <" & fpath1 & ">"
        print "OUTPUT: Data File: <" & ofullName & ">"
        print "OUTPUT: Data File: <" & TraceFName & ">"

        cpFrameMainApp(ifullName, ofullName, TraceFName)

    Else
        print "Not enough parameters: provide data file name"
    End If

    print "... Main"
'        print "Press Any Key to Continue ..."
'        input tmpResponse
    print "All Done!"

End Sub

'------------------------------------------------------------------------------  
'MAIN
'------------------------------------------------------------------------------
    Main
'==============================================================================
'END MAIN
'==============================================================================


