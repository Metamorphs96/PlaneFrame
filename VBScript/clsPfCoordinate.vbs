'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Class clsPfCoordinate
	  Public key 
	  Public x            '.. x-coord of a joint ..
	  Public y            '.. y-coord of a joint ..
	
	Sub initialise()
	  key = 0
	  x = 0
	  y = 0
	End Sub
	
	Sub setValues(ByVal nodeKey , ByVal x1 , ByVal y1 )
	    key = nodeKey
	    x = x1
	    y = y1
	End Sub
	
	Function sprint() 
	  sprint = StrLPad(FormatNumber(key, 0), 8) & StrLPad(FormatNumber(x, 4), 12) & StrLPad(FormatNumber(y, 4), 12)
	End Function
	
	Sub cprint()
	  Wscript.Echo  sprint
	End Sub
	
	Sub fprint(fp )
	  fp.WriteLine(sprint)
	End Sub


End Class
