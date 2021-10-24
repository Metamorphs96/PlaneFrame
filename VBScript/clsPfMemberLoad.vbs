'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Class clsPfMemberLoad

	
	
	Public key 
	
	Public mem_no 
	Public lcode 
	Public f_action 
	Public ld_mag1      '.. member load magnitude 1 ..
	Public ld_mag2      '.. member load magnitude 2 ..
	Public start        '.. dist from end_1 to start/centroid of load ..
	Public cover        '.. dist that a load covers ..
	
	Sub initialise()
	  mem_no = 0
	  lcode = 0
	  f_action = 0
	  ld_mag1 = 0
	  ld_mag2 = 0
	  start = 0
	  cover = 0
	End Sub
	
	Sub setValues(LoadKey , memberKey , LoadType , ActionKey  _
	                         , LoadMag1 , LoadStart , LoadCover )
	                         
	  key = LoadKey
	  mem_no = memberKey
	  lcode = LoadType
	  f_action = ActionKey
	  ld_mag1 = LoadMag1
	  ld_mag2 = LoadMag1
	  'ld_mag2 = LoadMag2 'xla version only
	  start = LoadStart
	  cover = LoadCover
	End Sub
	
	Function sprint() 
	  sprint = StrLPad(FormatNumber(key, 0), 8) _
	             & StrLPad(FormatNumber(mem_no, 0), 6) _
	             & StrLPad(FormatNumber(lcode, 0), 6) _
	             & StrLPad(FormatNumber(f_action,0), 6) _
	             & StrLPad(FormatNumber(ld_mag1, 3), 15) _
	             & StrLPad(FormatNumber(start, 3), 15) _
	             & StrLPad(FormatNumber(cover, 3), 12)
	
	End Function
	
	Sub cprint()
	  Wscript.Echo  sprint
	End Sub
	
	Sub fprint(fp )
	  fp.WriteLine(sprint)
	
	End Sub
	

End Class
