'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit


Class clsProjectData

	Public ProjectKey 
	
	Public HdrTitle1 
	Public LoadCase 
	Public ProjectID 
	Public Author 
	Public runNumber 
	
	Sub initialise()
	 Wscript.Echo  "Project:initialise"
	 ProjectKey = 0
	
	 HdrTitle1 = ""
	 LoadCase = ""
	 ProjectID = ""
	 Author = ""
	 runNumber = 0
	
	End Sub
	
	Sub cprint()
	  Wscript.Echo  HdrTitle1
	  Wscript.Echo  LoadCase
	  Wscript.Echo  ProjectID
	  Wscript.Echo  Author
	  Wscript.Echo  runNumber
	End Sub
	
	Sub fprint(fp )
	  call fpText.WriteLine( HdrTitle1)
	  call fpText.WriteLine( LoadCase)
	  call fpText.WriteLine( ProjectID)
	  call fpText.WriteLine( Author)
	  call fpText.WriteLine( runNumber)
	End Sub
	
	Sub fgetData(fp )
		Dim i 
	
	  Wscript.Echo  "fgetData ..."
	  
	  HdrTitle1 = fp.ReadLine
	  LoadCase = fp.ReadLine
	  ProjectID = fp.ReadLine
	  Author = fp.ReadLine
	  runNumber = fp.ReadLine
	  
	  Wscript.Echo  "... fgetData"
	End Sub

End Class
