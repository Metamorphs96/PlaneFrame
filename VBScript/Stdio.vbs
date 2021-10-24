Option Explicit

Public Const CR  = 13
Public Const LF  = 10
Public Const SpaceChar  = 32
Public Const Htab  = 9
Public Const ESC  = 27
Public Const NulChar  = 0

Public Const QuoteCode  = 34
Public Const QuoteChar  = """"


Function isCarriageReturn(c ) 
  If Asc(c) = CR Then
    isCarriageReturn = True
  Else
    isCarriageReturn = False
  End If
End Function

Function isLineFeed(c ) 
  If Asc(c) = LF Then
    isLineFeed = True
  Else
    isLineFeed = False
  End If
End Function

Function isEoLN(c ) 
  If isCarriageReturn(c) Or isLineFeed(c) Then
    isEoLN = True
  Else
    isEoLN = False
  End If
End Function


Function Eoln(fp , c ) 
  Dim c2 
  
  If Not (EOF(fp)) Then
    If Asc(c) = CR Or Asc(c) = LF Then
      'c2 = Input(1, fp) 'get 2nd part of LF/CR pair
      Eoln = True
    Else
      Eoln = False
    End If
  Else 'if eof
     Eoln = False
     'EOF can exist at the end of a line without CR/LF markers
     'such as the last line of text in a file without a blank line after it
  End If
  
End Function

 
'read characters until end of line and carriage return
Function Readln(fp ) 
  Dim s 
  Dim c 
  Dim prevc 
  Dim isDone 
  
  isDone = False
  s = ""
  c = NulChar
  prevc = c
  
  Do While Not (isDone) And Not (EOF(fp))
    c = Input(1, fp)
    
    If isPrint(c) Then s = s & c
    'Wscript.Echo  s
    
    If Not (EOF(fp)) Then
      If isCarriageReturn(c) And isLineFeed(prevc) Then
        isDone = True
      ElseIf isCarriageReturn(prevc) And isLineFeed(c) Then
        isDone = True
      End If
    End If
    prevc = c
  Loop
  
  Readln = s
   
End Function

'read characters until space character or (end of line and carriage return)
Function ReadField(fp ) 
  Dim s 
  Dim c 
 
  s = ""
  c = NulChar
  
  Do While Asc(c) <> SpaceChar And Not (EOF(fp)) And Not (isEoLN(c))
    c = Input(1, fp)
    If Asc(c) <> SpaceChar And Not (EOF(fp)) And Not (isEoLN(c)) Then s = s & c
  Loop
  ReadField = s
   
End Function

'read characters until delimiter character or (end of line and carriage return)
Function ReadDelimited(fp , ch ) 
  Dim s 
  Dim c 
 
  s = ""
  c = NulChar
  
  Do While Asc(c) <> Asc(ch) And Not (EOF(fp))
    c = Input(1, fp)
    If Asc(c) <> Asc(ch) And Not (EOF(fp)) Then s = s & c
  Loop
  ReadDelimited = s
   
End Function

Sub SplitFields(s )
  Dim i , EoStr 
  Dim s2 
  Dim c 
  
  EoStr = StrLen(s)
  i = 0
  s2 = ""
  
  Do
    Do
      i = i + 1
      c = Mid(s, i, 1)
      If c <> "," Then
        s2 = s2 & c
      End If
    Loop Until c = "," Or i = EoStr
    Wscript.Echo  s2
    s2 = ""
  Loop Until i = EoStr

End Sub

Sub readCDF()
  Dim fdrive , fpath 
  Dim fname , fext , Descr 
  Dim fp 
  Dim s 
  
  fname = "test"
  fext = ".txt"
  Descr = "Test Data"
  s = ""
  
  fp = SelectOpenFileExt(fname, fext, Descr)
  If fp <> 0 Then
     Do
       s = Readln(fp)
       If Not (EOF(fp)) Then
          Call SplitFields(s)
          'Wscript.Echo  s
       End If
     Loop Until EOF(fp)
     Close (fp)
  End If
End Sub


Sub TestRead()
  Dim fdrive , fpath 
  Dim fname , fext , Descr 
  Dim fp 
  Dim s 
  
  fname = "test"
  fext = ".scr"
  Descr = "Test Data"
  
  fp = SelectOpenFileExt(fname, fext, Descr)
  'fp = GUI_fopen_wrt(fdrive, fpath, fname, fext, Descr)
  If fp <> 0 Then
'     s = ReadDelimited(fp, ",")
'     Wscript.Echo  s
'     s = Readln(fp)
'     Wscript.Echo  s
'     s = ReadDelimited(fp, ",")
'     Wscript.Echo  s
     s = Readln(fp)
     Wscript.Echo  s
  Else
     Wscript.Echo  "Failed to Open File", fname
  End If
  
End Sub

Sub TestRead2()
  Dim fdrive , fpath 
  Dim fname , fext , Descr 
  Dim fp 
  Dim s 
  
  fname = "test"
  fext = ".scr"
  Descr = "Test Data"
  
  fp = SelectOpenFileExt(fname, fext, Descr)
  If fp <> 0 Then
     Do
       s = Readln(fp)
       Wscript.Echo  s
     Loop Until EOF(fp)
  Else
     Wscript.Echo  "Failed to Open File", fname
  End If
  
End Sub

Sub TestRead3()
  Dim fdrive , fpath 
  Dim fname , fext , Descr 
  Dim fp 
  Dim s 
  Dim WrkRng , r 
  
  fname = "test"
  fext = ".scr"
  Descr = "Test Data"
  
  Set WrkRng = ActiveWorkbook.Worksheets("Tracer").Range("A1:A1")
  ActiveWorkbook.Worksheets("Tracer").UsedRange.Select ' .Range("A1:IV1000").Clear
  Application.Selection.Clear
  ActiveWorkbook.Worksheets("Tracer").Range("A1:A1").Select
  
  fp = SelectOpenFileExt(fname, fext, Descr)
  If fp <> 0 Then
     r = 0
     Do
       s = Readln(fp)
       'Wscript.Echo  s
       WrkRng.Offset(r, 0).Value = s
       r = r + 1
     Loop Until EOF(fp)
  Else
     Wscript.Echo  "Failed to Open File", fname
  End If
  
  Wscript.Echo  "All Done !"
End Sub




