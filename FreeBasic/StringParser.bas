'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'IMPLEMENTATION
'-------------------------------------------------------------------------------


'Option Explicit
'Option Base 0

#include once "xStrLib.bi"
#include once "fnXStrings.bi"
#include once "XStrings.bi"
#include once "StringParser.bi"

Sub parseString(dataStr As String, FieldValues() As String, fieldCount As Integer)
  Dim c As String, s As String
  Dim i As Integer
  Dim n As Integer
  Dim allDone As Boolean
  Dim charCount As Integer
  Dim condition1 as Boolean
  
  print "parseString ..."

  allDone = False

  s = ""
  c = ""
  n = Len(dataStr)
  charCount = 1
  
  print n, dataStr
  Do
    If charCount <= n Then
      c = Mid(dataStr, charCount, 1)
      'print c
      condition1 = (charCount = n)
      If isPunct(c) Or condition1 Then
        'print i, charCount, s
        If condition1 And Not (isPunct(c)) Then s = s & c
        s = Trim(s)
        If s <> "" Then
            FieldValues(i) = Trim(s)
            s = ""
            i = i + 1
        End If
      Else
        s = s & c
        'print s
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
  
  print "... parseString"
End Sub

Sub parseDelimitedString(dataStr As String, FieldValues() As String, BYREF fieldCount As Integer, delimitChar As String)
  Dim c As String, s As String
  Dim i As Integer
  Dim n As Integer
  Dim allDone As Boolean
  Dim charCount As Integer
  
'  print "parseDelimitedString ..."

  allDone = False

  s = ""
  c = ""
  n = Len(dataStr)
  charCount = 1
  i = 0
  
  'print n, dataStr
  Do
    If charCount <= n Then
      c = Mid(dataStr, charCount, 1)
      'print c
      If c = delimitChar Or charCount = n Then
        'print i, charCount, s
        If charCount = n And Not (c = delimitChar) Then s = s & c
        s = Trim(s)
        If s <> "" Then
            FieldValues(i) = Trim(s)
            s = ""
            i = i + 1
        End If
      Else
        s = s & c
        'print s
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
  
'  print "... parseDelimitedString"
End Sub

Sub parseTagDelimitedString(dataStr As String, FieldValues() As String, fieldCount As Integer, TagStr As String)
  Dim c As String, s As String, s2 As String
  Dim i As Integer
  Dim n As Integer
  Dim allDone As Boolean
  Dim charCount As Integer
  Dim p As Integer
  Dim tagLength As Integer
  
  print "parseTagDelimitedString ..."

  allDone = False

  s = dataStr
  c = ""
  n = Len(dataStr)
  tagLength = Len(TagStr)
  charCount = 1
  i = 0
  
  print n, dataStr
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
  
  print "... parseTagDelimitedString"
End Sub


Sub testparseString()
  Dim keyWordList(50) As String
  Dim TitleStr As String
  Dim i As Integer, wordCount As Integer
  Dim Addr As String
  Dim vbCr as string
  
  vbCR = CHR(13)

  'TitleStr = "DA Certification, Extensions for display area, ""The Old Fire Station""Sturt St, Mt Gambier."
  'TitleStr = "DA certification  Lot 41, Proposed Workshop & office Cnr Port Wakefield rds & Ryans Roads , Greenfields"
  
  'TitleStr = "Historic Railway Hotel;Historic Railway Hotel;PORT ADELAIDE;South Australia;AUSTRALIA;AUSTRALASIA"
  'TitleStr = "16 Northampton:: Crescent;ELIZABETH EAST;South Australia;AUSTRALIA;AUSTRALASIA::"

  TitleStr = "          1       0.00       0.00"
  
  'TitleStr = "?;?;?;?;?"
  
  print "Original String: ", TitleStr
  parseDelimitedString(TitleStr, keyWordList(), wordCount, " ")
  'Call parseTagDelimitedString(TitleStr, keyWordList, wordCount, "::")
  
  
  print "WordCount: ", wordCount
  Addr = ""
  For i = 0 To wordCount - 1
'    If keyWordList(i) <> "" Then
      print i, "<" & keyWordList(i) & ">"
      Addr = Addr & vbCr & keyWordList(i)
'    End If
  Next i
  
  'MsgBox (addr)
  
  print "...testparseString"
End Sub

