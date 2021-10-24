'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit
'Option Base 0 'Arrays are zero based in VBScript

Sub parseString(dataStr , FieldValues() , fieldCount )
  Dim c , s 
  Dim i 
  Dim n 
  Dim allDone 
  Dim charCount 
  
  Wscript.Echo  "parseString ..."

  allDone = False

  s = ""
  c = ""
  n = Len(dataStr)
  charCount = 1
  
  Wscript.Echo  n, dataStr
  Do
    If charCount <= n Then
      c = Mid(dataStr, charCount, 1)
      'Wscript.Echo  c
      If isPunct(c) Or charCount = n Then
        'Wscript.Echo  i, charCount, s
        If charCount = n And Not (isPunct(c)) Then s = s & c
        s = Trim(s)
        If s <> "" Then
            FieldValues(i) = Trim(s)
            s = ""
            i = i + 1
        End If
      Else
        s = s & c
        'Wscript.Echo  s
      End If
      
      charCount = charCount + 1
    Else
      allDone = True
    End If
    
  Loop Until allDone
  
  If FieldValues(i) = "" Then
    fieldCount = i - 1
  Else
    fieldCount = i
  End If
  
  Wscript.Echo  "... parseString"
End Sub

Sub parseDelimitedString(dataStr , FieldValues() , fieldCount , delimitChar )
  Dim c , s 
  Dim i 
  Dim n 
  Dim allDone 
  Dim charCount 
  
'  Wscript.Echo  "parseDelimitedString ..."

  allDone = False

  s = ""
  c = ""
  n = Len(dataStr)
  charCount = 1
  i = 0
  
  'Wscript.Echo  n, dataStr
  Do
    If charCount <= n Then
      c = Mid(dataStr, charCount, 1)
      'Wscript.Echo  c
      If c = delimitChar Or charCount = n Then
        'Wscript.Echo  i, charCount, s
        If charCount = n And Not (c = delimitChar) Then s = s & c
        s = Trim(s)
        If s <> "" Then
            FieldValues(i) = Trim(s)
            s = ""
            i = i + 1
        End If
      Else
        s = s & c
        'Wscript.Echo  s
      End If
      
      charCount = charCount + 1
    Else
      allDone = True
    End If
    
  Loop Until allDone
  
  If FieldValues(i) = "" Then
    fieldCount = i
  Else
    fieldCount = i + 1
  End If
  
'  Wscript.Echo  "... parseDelimitedString"
End Sub

Sub parseTagDelimitedString(dataStr , FieldValues() , fieldCount , TagStr )
  Dim c , s , s2 
  Dim i 
  Dim n 
  Dim allDone 
  Dim charCount 
  Dim p 
  Dim tagLength 
  
  Wscript.Echo  "parseTagDelimitedString ..."

  allDone = False

  s = dataStr
  c = ""
  n = Len(dataStr)
  tagLength = Len(TagStr)
  charCount = 1
  i = 0
  
  Wscript.Echo  n, dataStr
  Do
    p = InStr(1, s, TagStr)
    If p <> 0 Then
      FieldValues(i) = Trim(Mid(s, 1, p - 1))
      s = Mid(s, p + tagLength, Len(s) - p + tagLength)
      i = i + 1
    Else
      FieldValues(i) = Trim(s)
      allDone = True
    End If
  Loop Until allDone
  
  If FieldValues(i) = "" Then
    fieldCount = i
  Else
    fieldCount = i + 1
  End If
  
  Wscript.Echo  "... parseTagDelimitedString"
End Sub


Sub testparseString()
  Dim keyWordList(50) 
  Dim TitleStr 
  Dim i , wordCount 
  Dim Addr 

  'TitleStr = "DA Certification, Extensions for display area, ""The Old Fire Station""Sturt St, Mt Gambier."
  'TitleStr = "DA certification  Lot 41, Proposed Workshop & office Cnr Port Wakefield rds & Ryans Roads , Greenfields"
  
  'TitleStr = "Historic Railway Hotel;Historic Railway Hotel;PORT ADELAIDE;South Australia;AUSTRALIA;AUSTRALASIA"
  'TitleStr = "16 Northampton:: Crescent;ELIZABETH EAST;South Australia;AUSTRALIA;AUSTRALASIA::"

  TitleStr = "          1       0.00       0.00"
  
  'TitleStr = "?;?;?;?;?"
  
  Wscript.Echo  "Original String: ", TitleStr
  Call parseDelimitedString(TitleStr, keyWordList, wordCount, " ")
  'Call parseTagDelimitedString(TitleStr, keyWordList, wordCount, "::")
  
  
  Wscript.Echo  "WordCount: ", wordCount
  Addr = ""
  For i = 0 To wordCount - 1
'    If keyWordList(i) <> "" Then
      Wscript.Echo  i, "<" & keyWordList(i) & ">"
      Addr = Addr & vbCr & keyWordList(i)
'    End If
  Next ' i
  
  'MsgBox (addr)
  
  Wscript.Echo  "...testparseString"
End Sub

