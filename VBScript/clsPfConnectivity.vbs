'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Class clsPfConnectivity
	
	  Public key 
	  
	  Public jj             '.. joint No. @ end "j" of a member ..  [na]
	  Public jk             '.. joint No. @ end "k" of a member ..  [nb]
	  Public sect           '.. section group of member ..          [ns]
	  Public rel_i          '.. end i release of member ..          [mra]
	  Public rel_j          '.. end j release of member ..          [mrb]
	  Public jnt_jj 'As clsPfForce
	  Public jnt_jk 'As clsPfForce
	
	Sub initialise()
	  jj = 0
	  jk = 0
	  sect = 0
	  rel_i = 0
	  rel_j = 0
	  
	  Set jnt_jj = New clsPfForce
	  jnt_jj.initialise
	  
	  Set jnt_jk = New clsPfForce
	  jnt_jk.initialise
	    
	End Sub
	
	Sub setValues(memberKey , NodeA , NodeB , sectionKey , ReleaseA , ReleaseB )
	  key = memberKey
	  jj = NodeA
	  jk = NodeB
	  sect = sectionKey
	  rel_i = ReleaseA
	  rel_j = ReleaseB
	End Sub
	
	Function sprint() 
	     sprint = StrLPad(FormatNumber(key, 0), 8) _
	              & StrLPad(FormatNumber(jj, 0), 6) _
	              & StrLPad(FormatNumber(jk, 0), 6) _
	              & StrLPad(FormatNumber(sect, 0), 6) _
	              & StrLPad(FormatNumber(rel_i, 0), 6) _
	              & StrLPad(FormatNumber(rel_j,0), 2)
	
	End Function
	
	
	Sub cprint()
	
	  Wscript.Echo  sprint
	'  jnt_jj.cprint
	'  jnt_jk.cprint
	
	End Sub
	
	Sub fprint(fp )
	  fp.WriteLine(sprint)
	End Sub


End Class
