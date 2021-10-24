'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Class clsPfGravityLoad
	
	
	Public f_action 
	Public load         '.. mass per unit length of a member load ..
	
	Sub initialise()
	  f_action = 0
	  load = 0
	End Sub
	
	Sub setValues(ActionKey , LoadMag )
	  f_action = ActionKey
	  load = LoadMag
	End Sub
	
	Function sprint() 
	  sprint = StrLPad(FormatNumber(f_action, 0), 6) & StrLPad(FormatNumber(load, 3), 15)
	End Function
	
	Sub cprint()
	  Wscript.Echo sprint
	End Sub
	
	Sub fprint(fp )
	  fp.WriteLine(sprint)
	End Sub

End Class
