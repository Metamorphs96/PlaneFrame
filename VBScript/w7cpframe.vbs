'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

'WINDOWS SCRIPT OBJECTS
'FILESYSTEM OBJECTS
Dim fso
Dim WshShell

'VBSCRIPT VARIABLES
Dim objArgs



Public Const isEarlyVersion = True 'Modify to test variable at future date

Public Const baseIndex  = 0
Dim fpText , fpRpt , fpTracer 
'Dim GModel 'As New clsGeomModel
Dim pfModel 'As New PlaneFrame


' Public Const dataBlockTag  = "::"
'Public data_loaded 

'... Constant declarations ...
' Public Const numloads  = 80
' Public Const order  = 50
' Public Const v_size  = 50
' Public Const max_grps  = 25
' Public Const max_mats  = 10
' Public Const n_segs  = 7


Sub cpFrameMainApp(ByVal ifullName , ByVal ofullName , ByVal TraceFName )
	Dim isPerformingAnalysis
	Dim isAllowOverWrite
	
	isAllowOverWrite = True 'For result files only
	isPerformingAnalysis = True
	
	WScript.Echo "cpframe ..."
	WScript.Echo "2D/Plane Frame Analysis ... "
	
	WScript.Echo "Input Data File     : " & ifullName
	Set fpText = fopenTXT(ifullName, "rt", False)
	
	If Not( fpText Is Nothing) Then
		
		
		'Trace File
		WScript.Echo "Trace Report File   : " & TraceFName
		Set fpTracer = fopenTXT(TraceFName, "wt", isAllowOverWrite)
		If fpTracer Is Nothing Then
			WScript.Echo "OUTPUT: File NOT Opened: " & TraceFName
		End If
		
		'Set GModel = New clsGeomModel
		Set pfModel = New PlaneFrame
		
		' With GModel
		' .initialise()
		' .pframeReader00(fpText)
		' .cprint()
		' End With
		
		With pfModel
			Set .fpTracer = fpTracer
			.data_loaded = False
			.initialise0
			
			.initialise
			.GModel.initialise()
			.GModel.pframeReader00(fpText)
			
			WScript.Echo
			WScript.Echo "DATA PRINTOUT"
			'.GModel.cprint()
			.data_loaded = True
			WScript.Echo "--------------------------------------------------------------------------------"
			
			If .data_loaded Then
				
				If isPerformingAnalysis Then
					WScript.Echo "Analysis ..."
					.Analyse_Frame()
					WScript.Echo "... Analysis"
					
					fpTracer.Close
					WScript.Echo "Report Results ..."
					WScript.Echo "Output Report File  : " & ofullName
					Set fpRpt = fopenTXT(ofullName, "wt", isAllowOverWrite)
					If not(fpRpt Is Nothing) Then
						.fPrintResults(fpRpt)
						fpRpt.Close
					Else
						WScript.Echo "Report file NOT created"
					End If
					WScript.Echo "... Report Results"
				End If 'perform analysis
			Else
				WScript.Echo "No Data"
			End If 'data loaded
			
			'.Read_Data(fpText)
		End With
		
	Else
		WScript.Echo "INPUT: File NOT Opened: " & ifullName
	End If
	
	WScript.Echo "... 2D/Plane Frame Analysis"
	WScript.Echo "... cpframe"
	WScript.Echo "<< END >>"
	
End Sub 'cpframe



Sub cMain '(ByVal cmdArgs() )
	Dim anykey
	Dim fso, WshShell, objArgs
	Dim fldr1, objPath
	
	'General
	Dim doAction 
	Dim fpath1 
	Dim fDrv , fPath, fName, fExt
	Dim ifullName 
	Dim ofullName 
	Dim TraceFName 
	Dim s 
	Dim isOk 
	
	WScript.Echo "Main ..."
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set WshShell = CreateObject("WScript.Shell")
	Set objArgs = WScript.Arguments
	
	
	' See if there are any arguments.
	If objArgs.Count = 1  Then
		fpath1 = objArgs(0)
		ifullName = fpath1
		
		fDrv = ""
		fPath = ""
		fName = ""
		fExt = ""
		Call fnsplit2(fpath1, fDrv, fPath, fName, fExt)
		
		ofullName = ""
		TraceFName = ""
		ofullName = fnmerge(ofullName, fDrv, fPath, fName, ".rpt")
		TraceFName = fnmerge(TraceFName, fDrv, fPath, fName, ".trc")
		
		WScript.Echo "INPUT: Data File: <" & fpath1 & ">"
		WScript.Echo "OUTPUT: Data File: <" & ofullName & ">"
		WScript.Echo "OUTPUT: Data File: <" & TraceFName & ">"
		
		Call cpFrameMainApp(ifullName, ofullName, TraceFName)
		
	Else
		WScript.Echo "Not enough parameters: provide data file name"
	End If
	
	WScript.Echo "... Main"
	'        Wscript.Echo "Press Any Key to Continue ..."
	'        anykey = WScript.StdIn.ReadLine
	WScript.Echo "All Done!"
	
End Sub

