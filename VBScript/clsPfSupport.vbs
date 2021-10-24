'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Class clsPfSupport

	Public key 
	Public js  
	Public rx             '.. joint X directional restraint ..
	Public ry             '.. joint Y directional restraint ..
	Public rm             '.. joint Z rotational restraint ..
	
	Sub initialise()
	  js = 0
	  rx = 0
	  ry = 0
	  rm = 0
	End Sub
	
	Sub setValues(supportKey , SupportNode , RestraintX , RestraintY , RestraintMoment )
	  key = supportKey
	  js = SupportNode
	  rx = RestraintX
	  ry = RestraintY
	  rm = RestraintMoment
	End Sub
	
	
	Function sprint() 
	  sprint = StrLPad(FormatNumber(key, 0), 8) _
	           & StrLPad(FormatNumber(js, 0), 6) _
	           & StrLPad(FormatNumber(rx, 0), 6) _
	           & StrLPad(FormatNumber(ry, 0), 6) _
	           & StrLPad(FormatNumber(rm, 0), 6)
	End Function
	
	Sub cprint()
	  Wscript.Echo  sprint
	End Sub
	
	Sub fprint(fp )
	  fp.WriteLine(sprint)
	End Sub


End Class
