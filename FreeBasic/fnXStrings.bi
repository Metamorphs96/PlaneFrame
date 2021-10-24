'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'INTERFACE
'-------------------------------------------------------------------------------


Declare Function StrLen(s As String) As Integer
Declare Function strupr(s As String) As String
Declare Function strlwr(s As String) As String
Declare Function substr(s As String, sp As Integer, L As Integer) As String
Declare Function strchr(s As String, c As String) As Integer
Declare Function StrLPad(s As String, lStr As Integer) As String
Declare Function StrLPadc(s As String, lStr As Integer, c As String) As String
Declare Function StrRPad(s As String, lStr As Integer) As String
Declare Function StrRPadc(s As String, lStr As Integer, c As String) As String
Declare Function StrNset(s As String, ch As String, n As Integer) As String
Declare Function StrRChr(s As String, c As String) As Integer
Declare Function fnDrv(fPath As String) As String
Declare Function fnDir(fPath As String) As String
Declare Function fnName(fPath As String) As String
Declare Function fnName2(fPath As String) As String
Declare Function fnExt(fPath As String) As String
Declare Function fnmerge(fPath As String, drv As String, fdir As String, fname As String, fext As String) As String
Declare Function FmtAcadPath(fPath As String) As String
