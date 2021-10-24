'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Class clsPfMaterial
	
	  Public key 
	  
	  Public density      '.. density ..
	  Public emod            '.. elastic Modulus ..
	  Public therm           '.. coeff of thermal expansion..}
	
	
	Sub initialise()
	  density = 0
	  emod = 0
	  therm = 0
	End Sub
	
	Sub setValues(materialKey , massDensity , ElasticModulus , CoeffThermExpansion )
	  key = materialKey
	  density = massDensity
	  emod = ElasticModulus
	  therm = CoeffThermExpansion
	End Sub
	
	Function sprint() 
	      sprint = StrLPad(FormatNumber(key, 0), 8) _
	               & StrLPad(FormatNumber(density, 2), 15) _
	               & StrLPad(FormatScientific(emod, 2), 15) _
	               & StrLPad(FormatScientific(therm, 4), 15)
	
	End Function
	
	Sub cprint()
	  Wscript.Echo  sprint
	End Sub
	
	Sub fprint(fp )
	  fp.WriteLine(sprint)
	End Sub
	

End Class
