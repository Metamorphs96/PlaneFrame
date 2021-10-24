'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

  'Punctuation and Other Characters = "!""#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
  'Const legalChars = "!""#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
  
  
Const Letter_uA  = 65
Const Letter_uZ  = 90
Const Letter_lA  = 97
Const Letter_lZ  = 122
Const Digit_0 = 48
Const Digit_9  = 57
Const Htab   = 9
Const SpaceChar  = 32
'
'


Function isAlpha(ch ) 
  Dim c 
  
  c = Asc(ch)
  
  If (Letter_uA <= c And c <= Letter_uZ) Or (Letter_lA <= c And c <= Letter_lZ) Then
    isAlpha = True
  Else
    isAlpha = False
  End If
End Function

Function isUpper(ch)
  Dim c 
  
  c = Asc(ch)
  
  If (Letter_uA <= c And c <= Letter_uZ) Then
    isUpper = True
  Else
    isUpper = False
  End If
End Function

Function isLower(ch)
  Dim c 
  
  c = Asc(ch)
  
  If (Letter_lA <= c And c <= Letter_lZ) Then
    isLower = True
  Else
    isLower = False
  End If
End Function

'Newline character not considered
Function isSpace(ch)
  Dim c 
  
  c = Asc(ch)
  
  If (c = SpaceChar) Or (c = Htab) Then
    isSpace = True
  Else
    isSpace = False
  End If
End Function

Function isPrint(ch)
  Dim c 
  
  c = Asc(ch)
  
  If (32 <= c And c <= 126) Then
    isPrint = True
  Else
    isPrint = False
  End If
End Function

Function isPunct(ch)
  If Not (isAlnum(ch)) And isPrint(ch) Then
    isPunct = True
  Else
    isPunct = False
  End If
End Function

Function isCntrl(ch)
  Dim c 
  
  c = Asc(ch)

  If (c < 32) Or (c = 127) Then
    isCntrl = True
  Else
    isCntrl = False
  End If
End Function


Function isDigit(ch)
  Dim c 
  
  c = Asc(ch)
  
  If (Digit_0 <= c And c <= Digit_9) Then
    isDigit = True
  Else
    isDigit = False
  End If
End Function

Function isAlnum(ch)
  
  If isDigit(ch) Or isAlpha(ch) Then
    isAlnum = True
  Else
    isAlnum = False
  End If
  
End Function

Function isNumber(s )
  Dim c 
  Dim i 
  Dim Finished 
  Dim ok 
  Dim PeriodCount
  
  i = 1
  Finished = False
  PeriodCount = 0
  Do
    c = UCase(Mid(s, i, 1))
    If isDigit(c) Or c = "." Then
      ok = True
      If c = "." Then
        PeriodCount = PeriodCount + 1
        If PeriodCount > 1 Then
          ok = False
          Finished = True
        End If
      End If
      If i = Len(s) Then Finished = True
    Else
      ok = False
      Finished = True
    End If
    i = i + 1
  Loop Until Finished
  
  If ok Then isNumber = True Else isNumber = False
  
End Function




