'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Function fopenTXT(fname, fmode, isAllowOverWrite)
  Const ForReading = 1
  Const ForWriting = 2
  Const ForAppending = 8
  Const TristateUseDefault = -2
  Const TristateTrue = -1
  Const TristateFalse = 0
  
  Dim FSO, isCreate, fp
  
  isCreate = True
  
  Set fp = Nothing

  Set FSO = CreateObject("Scripting.FileSystemObject")
  
  'if fmode = "wt" => create and open text file for writing
  If LCase(fmode) = "wt" Then 'ASCII file
    If not(FSO.FileExists(fname)) Then
      Set fp = FSO.OpenTextFile(fname, ForWriting, isCreate, TristateFalse)
    ElseIf isAllowOverWrite = True Then
      Set fp = FSO.OpenTextFile(fname, ForWriting, isCreate, TristateFalse)
    End If
    
  ElseIf LCase(fmode) = "uwt" Then 'unicode
    If not(FSO.FileExists(fname)) Then
      Set fp = FSO.OpenTextFile(fname, ForWriting, isCreate, TristateTrue)
    ElseIf isAllowOverWrite = True Then
      Set fp = FSO.OpenTextFile(fname, ForWriting, isCreate, TristateTrue)
    End If 
  
  'if fmode = "at" then append to end of file
  ElseIf LCase(fmode) = "at" Then 'ASCII file
    If FSO.FileExists(fname) Then
      Set fp = FSO.OpenTextFile(fname, ForAppending, False, TristateFalse)
    End If
    
  ElseIf LCase(fmode) = "uat" Then 'unicode
    If FSO.FileExists(fname) Then
      Set fp = FSO.OpenTextFile(fname, ForAppending, False, TristateTrue)
    End If
    
  'if fmode = "rt" then read text file
  ElseIf LCase(fmode) = "rt" Then 'ASCII file
    If FSO.FileExists(fname) Then
      Set fp = FSO.OpenTextFile(fname, ForReading, False, TristateFalse)
    End If
    
  ElseIf LCase(fmode) = "urt" Then 'unicode
    If FSO.FileExists(fname) Then
      Set fp = FSO.OpenTextFile(fname, ForReading, False, TristateTrue)
    End If
    
  End If
  
  Set fopenTXT = fp
  
End Function

