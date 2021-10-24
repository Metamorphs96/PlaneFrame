'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'IMPLEMENTATION
'-------------------------------------------------------------------------------


'Option Explicit

'Created to simplify conversion of programs from other languages
'(ie. C, AutoLISP)
Function StrLen(s As String) As Integer
  StrLen = Len(s)
End Function

'Created to simplify conversion of programs from other languages
'(ie. C, AutoLISP)
Function strupr(s As String) As String
   strupr = UCase(s)
End Function

'Created to simplify conversion of programs from other languages
'(ie. C, AutoLISP)
Function strlwr(s As String) As String
   strlwr = LCase(s)
End Function

'Created to simplify conversion of programs from other languages
'(ie. C, AutoLISP)
Function substr(s As String, sp As Integer, L As Integer) As String
   substr = Mid(s, sp, L)
End Function

'Forward Search for 1st occurence of character in string
'Created to simplify conversion of programs from other languages
'(ie. C, AutoLISP)
'InStr is available
Function strchr(s As String, c As String) As Integer
  Dim i As Integer, n As Integer
   
  n = Len(s)
  i = 1
  
  If n > 0 Then
    Do While i <= n And Mid(s, i, 1) <> c
      i = i + 1
    Loop
    If Mid(s, i, 1) = c Then
      strchr = i '- 1
    Else
      strchr = 0
    End If
  Else
    strchr = 0
  End If
  
End Function

'left pad a string with spaces
Function StrLPad(s As String, lStr As Integer) As String
Dim ss As String, i As Integer
  ss = Space(lStr - Len(s))
  StrLPad = ss & s
End Function '{...PStrLPad}

'left pad a string with given character
Function StrLPadc(s As String, lStr As Integer, c As String) As String
Dim ss As String, i As Integer
  ss = String(lStr - Len(s), c)
  StrLPadc = ss & s
End Function '{...PStrLPadc}

'Right pad a string with spaces
Function StrRPad(s As String, lStr As Integer) As String
Dim ss As String, i As Integer
  ss = Space(lStr - Len(s))
  StrRPad = s & ss
End Function '{...PStrRPad}

'Right pad a string with given character
Function StrRPadc(s As String, lStr As Integer, c As String) As String
Dim ss As String, i As Integer
  ss = String(lStr - Len(s), c)
  StrRPadc = s & ss
End Function '{...PStrRPadc}

'Set 1st N characters of string to given character
Function StrNset(s As String, ch As String, n As Integer) As String
   s = String(n, ch)
   StrNset = s
End Function

'find last occurence of character
'InStrRev is now available
Function StrRChr(s As String, c As String) As Integer
Dim n As Integer

  n = Len(s)
  If n > 0 Then
    Do While n > 1 And Mid(s, n, 1) <> c
      n = n - 1
    Loop
    If Mid(s, n, 1) = c Then
      StrRChr = n
    Else
      StrRChr = 0
    End If
  Else
    StrRChr = 0
  End If
  
End Function

Function fnDrv(fPath As String) As String
Dim p1 As Integer
  p1 = InStr(1, fPath, ":") ', vbTextCompare)
  If p1 = 0 Then
    fnDrv = ""
  Else
    fnDrv = Left(fPath, p1)
  End If
End Function

Function fnDir(fPath As String) As String
Dim s As String
Dim p1 As Integer, p2 As Integer

  'find last occurence of directory delimiter
  p1 = InStr(1, fPath, ":") ', vbTextCompare)
  p2 = StrRChr(fPath, "\")
  
  If p1 = 0 And p2 = 0 Then
    fnDir = ""
  ElseIf p1 = 0 Then
    fnDir = Mid(fPath, 1, p2)
  Else
    fnDir = Mid(fPath, p1 + 1, p2 - p1)
  End If
End Function

'Allowing for long filenames
'filename assumed to exist between, last path separator character '\'
'and first extension separator character '.'
Function fnName(fPath As String) As String
Dim s As String
Dim p1 As Integer, p2 As Integer

  'find last occurence of directory delimiter
  p1 = StrRChr(fPath, "\")
  p2 = InStr(1, fPath, ".") ', vbTextCompare)
  If p1 = 0 And p2 = 0 Then
    fnName = fPath
  ElseIf p1 = 0 Then
    fnName = Mid(fPath, 1, p2 - 1)
  ElseIf p2 = 0 Then
    fnName = Mid(fPath, p1 + 1, Len(fPath) - p1 - 1)
  Else
    fnName = Mid(fPath, p1 + 1, p2 - p1 - 1)
  End If
End Function

'Allowing for long filenames
'filename assumed to exist between, last path separator character '\'
'and last extension separator character '.'
Function fnName2(fPath As String) As String
Dim s As String
Dim p1 As Integer, p2 As Integer, L As Integer

  'find last occurence of directory delimiter
  p1 = StrRChr(fPath, "\")
  p2 = StrRChr(fPath, ".") 'Can be part of folder name
  L = Len(fPath)
  If p1 = 0 And p2 = 0 Then
    fnName2 = fPath
  ElseIf p1 = 0 Then 'No path statement
    fnName2 = Mid(fPath, 1, p2 - 1)
  ElseIf p2 = 0 Then 'No file extension
    fnName2 = Mid(fPath, p1 + 1, Len(fPath) - p1)
  ElseIf p2 < p1 And L = p1 Then 'folder name includes '.' and no filename given
    fnName2 = ""
  Else
    fnName2 = Mid(fPath, p1 + 1, p2 - p1 - 1)
  End If
End Function

'Allowing for long filenames
'file extension assumed to lie between the end of the string
'and the last extension separator character '.'
'thus filename can have more than 1 '.' in its name such as 'fn.txt.bak'
'But '.' also permitted in folder paths
Function fnExt(fPath As String) As String
Dim s As String
Dim p1 As Integer, p2 As Integer

  'First extension separator character
'  p1 = InStr(1, fPath, ".", vbTextCompare)
'  If p1 = 0 Then
'    fnExt = ""
'  Else
'    fnExt = Mid(fPath, p1, Len(fPath))
'  End If
  p1 = StrRChr(fPath, "\")
  p2 = StrRChr(fPath, ".")
  If p2 = 0 Then
    fnExt = ""
  ElseIf p2 > p1 Then
    fnExt = Mid(fPath, p2, Len(fPath))
  Else
    fnExt = ""
  End If
  
End Function

Function fnmerge(fPath As String, drv As String, fdir As String, fname As String, fext As String) As String
  fPath = drv & fdir & fname & fext
  fnmerge = fPath
End Function

Function FmtAcadPath(fPath As String) As String
  Dim i As Integer, n As Integer
  
  n = Len(fPath)
  For i = 1 To n
    If Mid(fPath, i, 1) = "\" Then
       Mid(fPath, i, 1) = "/"
    End If
  Next i
  
  FmtAcadPath = fPath
End Function

