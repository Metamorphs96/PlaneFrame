'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Class clsPfJointLoad
	
	Public key 
	
	Public jt 
	Public fx           '.. horizontal load @ a joint ..
	Public fy           '.. vertical   load @ a joint ..
	Public mz           '.. moment applied  @ a joint ..
	
	Sub initialise()
	  key = 0
	  jt = 0
	  fx = 0
	  fy = 0
	  mz = 0
	End Sub
	
	Sub setValues(LoadKey , Node , ForceX , ForceY , Moment )
	  key = LoadKey
	  jt = Node
	  fx = ForceX
	  fy = ForceY
	  mz = Moment
	End Sub
	
	Function sprint() 
	      sprint = StrLPad(FormatNumber(key, 0), 8) _
	               & StrLPad(FormatNumber(jt, 0), 6) _
	               & StrLPad(FormatNumber(fx, 3), 15) _
	               & StrLPad(FormatNumber(fy, 3), 15) _
	               & StrLPad(FormatNumber(mz, 3), 15)
	End Function
	
	Sub cprint()
	  Wscript.Echo  sprint
	End Sub
	
	Sub fprint(fp )
	      fp.WriteLine(sprint)
	End Sub


End Class
