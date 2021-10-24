'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Class clsPfSection
	
	
	
	  Public key 
	  
	  Public ax           '.. member's cross sectional area ..
	  Public iz           '.. member's second moment of area ..
	  
	  'Dependent on Material Properties
	  Public t_len        '.. TOTAL length of this section ..
	  Public t_mass       '.. TOTAL mass of this section ..
	  Public mat            '.. material of section ..
	  
	  Public Descr        '.. section description string ..
	
	Sub initialise()
	  ax = 0
	  iz = 0
	  t_len = 0
	  t_mass = 0
	  mat = 0
	  Descr = "<unknown>"
	End Sub
	
	Sub setValues(sectionKey , SectionArea , SecondMomentArea , materialKey , Description )
	  key = sectionKey
	  ax = SectionArea
	  iz = SecondMomentArea
	  mat = materialKey
	  Descr = Description
	End Sub
	
	Function sprint() 
	      sprint = StrLPad(FormatNumber(key, 0), 8) _
	               & StrLPad(FormatScientific(ax, 4), 15) _
	               & StrLPad(FormatScientific(iz, 4), 15) _
	               & StrLPad(FormatNumber(mat, 0), 6) _
	               & StrLPad(Descr, 28)
	End Function
	
	
	Sub cprint()
	  Wscript.Echo  sprint
	End Sub
	
	Sub fprint(fp )
	  fp.WriteLine(sprint)
	End Sub

End Class
