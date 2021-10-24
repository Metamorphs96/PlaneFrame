'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Class clsPfForce


	  Public axial        '.. axial force ..
	  Public shear        '.. shear force ..
	  Public momnt        '.. end moment ..
	
	
	Sub initialise()
	  axial = 0
	  shear = 0
	  momnt = 0
	End Sub
	
	Sub cprint()
	  Wscript.Echo  axial, shear, momnt
	End Sub

End Class
