'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Class clsParameters

	Public njt         '.. No. of joints ..
	Public nmb         '.. No. of members ..
	Public nmg         '.. No. of material groups ..
	Public nsg         '.. No. of member section groups ..
	Public nrj         '.. No. of supported reaction joints ..
	Public njl         '.. No. of loaded joints ..
	Public nml         '.. No. of loaded members ..
	Public ngl         '.. No. of gravity load cases .. Self weight
	Public nr          '.. No. of restraints @ the supports ..
	
	Public mag      '.. Magnification Factor for graphics
	
	Function getInitValue(baseIndx )
	  If baseIndx = 0 Then
	    getInitValue = -1
	  ElseIf baseIndx = 1 Then
	    getInitValue = 0
	  End If
	End Function
	
	Sub initialise()
	    Wscript.Echo  "clsParameters: initialise ..."
	    Wscript.Echo  "baseIndex:", baseIndex
	        'njt = getInitValue(baseIndex)
	        'nmb = getInitValue(baseIndex)
	        'nmg = getInitValue(baseIndex)
	        'nsg = getInitValue(baseIndex)
	        'nrj = getInitValue(baseIndex)
	        'njl = getInitValue(baseIndex)
	        'nml = getInitValue(baseIndex)
	        'ngl = getInitValue(baseIndex)
	        'nr = getInitValue(baseIndex)
	        'Total Count NOT indices
	        'But used as array index during reading
	        njt = 0
	        nmb = 0
	        nmg = 0
	        nsg = 0
	        nrj = 0
	        njl = 0
	        nml = 0
	        ngl = 0
	        nr = 0
	    Wscript.Echo  "... initialise"
	End Sub
	
	Function sprint() 
	  sprint = StrLPad(FormatNumber(njt, 0), 6) & StrLPad(FormatNumber(nmb, 0), 6) _
	          & StrLPad(FormatNumber(nrj, 0), 6) & StrLPad(FormatNumber(nmg, 0), 6) _
	          & StrLPad(FormatNumber(nsg, 0), 6) & StrLPad(FormatNumber(njl, 0), 6) _
	          & StrLPad(FormatNumber(nml, 0), 6) & StrLPad(FormatNumber(ngl, 0), 6) _
	          & StrLPad(FormatNumber(mag, 0), 6)
	
	End Function
	
	Sub cprint()
	  Wscript.Echo  sprint
	End Sub
	
	Sub fprint(fp )
	  fp.WriteLine(sprint)
	End Sub
	
	Sub fgetData(fp , isIgnore )
	  Dim s 
	  Dim n 
	  Dim dataflds(9) '(0 To 9) 
	
	  Wscript.Echo  "fgetData ..."
	  
	   s = Trim(fp.ReadLine)
	   Wscript.Echo  s
	
	   Call parseDelimitedString(s, dataflds, n, " ")
	
	  'typically ignore as all counters are incremented as data read
	  'isIgnore=False only used to test parser.
	  If isIgnore Then
	    'Clear the control data, and count records as read data from file
	    initialise
	  Else
	            njt = CInt(dataflds(0))
	            nmb = CInt(dataflds(1))
	            nrj = CInt(dataflds(2))
	            nmg = CInt(dataflds(3))
	            nsg = CInt(dataflds(4))
	            njl = CInt(dataflds(5))
	            nml = CInt(dataflds(6))
	            ngl = CInt(dataflds(7))
	  End If
	 
	  
	  If dataflds(8) <> "" Then
	    mag = CInt(dataflds(8))
	  Else
	    mag = 1
	  End If
	  
	  Wscript.Echo  "Dimension & Geometry"
	  Wscript.Echo  "-------------------------------"
	  Wscript.Echo  "Number of Joints       : ", njt
	  Wscript.Echo  "Number of Members      : ", nmb
	  Wscript.Echo  "Number of Supports     : ", nrj
	  
	  Wscript.Echo  "Materials & Sections"
	  Wscript.Echo  "-------------------------------"
	  Wscript.Echo  "Number of Materials    : ", nmg
	  Wscript.Echo  "Number of Sections     : ", nsg
	  
	  Wscript.Echo  "Design Actions"
	  Wscript.Echo  "-------------------------------"
	  Wscript.Echo  "Number of Joint Loads  : ", njl
	  Wscript.Echo  "Number of Member Loads : ", nml
	  Wscript.Echo  "Number of Gravity Loads : ", ngl
	  
	  Wscript.Echo  "Screen Magnifier: ", mag
	 
	  Wscript.Echo  "... fgetData"
	End Sub

End Class
