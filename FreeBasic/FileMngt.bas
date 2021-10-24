'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'IMPLEMENTATION
'-------------------------------------------------------------------------------


'Option Explicit
# Include once "dir.bi"


Function FileExists(SearchSpec As String) As Boolean
  Dim foundname As String
  'SearchSpec = Path and filename for file search
  
  foundname = Dir(UCase(SearchSpec), fbNormal)
  If foundname <> "" Then
    FileExists = True
  Else
    FileExists = False
  End If
  
End Function

Function FirstFileFound(SearchSpec As String, fattr As Integer, foundname As String) As Boolean
  'SearchSpec = Path ONLY for directory search
  'SearchSpec = Path and filename for file search
  'foundname = filename ONLY path information not included.
  
  foundname = Dir(UCase(SearchSpec), fattr)
  
  If foundname <> "" Then
    FirstFileFound = True
  Else
    FirstFileFound = False
  End If
  
End Function

Function NextFileFound(foundname As String) As Boolean

  'check that previous foundname <> ""
  If foundname <> "" Then
    foundname = Dir
  End If
  
  If foundname <> "" Then
    NextFileFound = True
  Else
    NextFileFound = False
  End If
  
End Function

'---------------------------------------------------------------------
' Deletes TEXT file if it exists and wish to start from scratch
' Otherwise leaves existing file alone, allowing PRINT to append
' to the end of the file
'---------------------------------------------------------------------
Sub fopenTXT(fp As Integer, fname As String, fmode As String)
  'if fmode = "wt" => create and open text file for writing
  If LCase(fmode) = "wt" Then
    Open fname For Output As #fp
    
  'if fmode = "at" then append to end of file
  ElseIf LCase(fmode) = "at" Then
    Open fname For Append As #fp
    
  'if fmode = "rt" then read text file
  ElseIf LCase(fmode) = "rt" Then
    Open fname For Input As #fp
    
  End If
End Sub

Function fopen(fname As String, fmode As String) As Integer
  Dim fp As Integer
  
  fp = FreeFile '(1)
  fopenTXT(fp, fname, fmode)
  fopen = fp
  
End Function

Function ReadLine(fp as Integer) as string
    Dim tmpTxt as string
    
    If not(Eof(fp)) Then
        Line Input #fp, tmpTxt
        ReadLine = tmpTxt    
    Else
        ReadLine = ""
    End If

End Function
