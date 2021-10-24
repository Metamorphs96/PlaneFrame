'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'

Option Explicit On

Module StringParser


    Sub parseString(ByVal dataStr As String, ByRef FieldValues() As String, ByRef fieldCount As Integer)
        Dim c As String, s As String
        Dim i As Integer
        Dim n As Integer
        Dim allDone As Boolean
        Dim charCount As Integer

        Debug.Print("parseString ...")

        allDone = False

        s = ""
        c = ""
        n = Len(dataStr)
        charCount = 1

        Debug.Print(n, dataStr)
        Do
            If charCount <= n Then
                c = Mid(dataStr, charCount, 1)
                'Debug.Print c
                If isPunct(c) Or charCount = n Then
                    'Debug.Print i, charCount, s
                    If charCount = n And Not (isPunct(c)) Then s = s & c
                    s = Trim(s)
                    If s <> "" Then
                        FieldValues(i) = Trim(s)
                        s = ""
                        i = i + 1
                    End If
                Else
                    s = s & c
                    'Debug.Print s
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

        Debug.Print("... parseString")
    End Sub

    Sub parseDelimitedString(ByVal dataStr As String, ByRef FieldValues() As String, ByRef fieldCount As Integer, ByVal delimitChar As String)
        Dim c As String, s As String
        Dim i As Integer
        Dim n As Integer
        Dim allDone As Boolean
        Dim charCount As Integer

        '  Debug.Print "parseDelimitedString ..."

        allDone = False

        s = ""
        c = ""
        n = Len(dataStr)
        charCount = 1
        i = 0

        'Debug.Print n, dataStr
        Do
            If charCount <= n Then
                c = Mid(dataStr, charCount, 1)
                'Debug.Print c
                If c = delimitChar Or charCount = n Then
                    'Debug.Print i, charCount, s
                    If charCount = n And Not (c = delimitChar) Then s = s & c
                    s = Trim(s)
                    If s <> "" Then
                        FieldValues(i) = Trim(s)
                        s = ""
                        i = i + 1
                    End If
                Else
                    s = s & c
                    'Debug.Print s
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

        '  Debug.Print "... parseDelimitedString"
    End Sub

    Sub parseTagDelimitedString(ByVal dataStr As String, ByVal FieldValues() As String, ByVal fieldCount As Integer, ByVal TagStr As String)
        Dim c As String, s As String, s2 As String
        Dim i As Integer
        Dim n As Integer
        Dim allDone As Boolean
        Dim charCount As Integer
        Dim p As Integer
        Dim tagLength As Integer

        Debug.Print("parseTagDelimitedString ...")

        allDone = False

        s = dataStr
        c = ""
        n = Len(dataStr)
        tagLength = Len(TagStr)
        charCount = 1
        i = 0

        Debug.Print(n, dataStr)
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

        Debug.Print("... parseTagDelimitedString")
    End Sub


    Sub testparseString()
        Dim keyWordList(50) As String
        Dim TitleStr As String
        Dim i As Integer, wordCount As Integer
        Dim Addr As String

        'TitleStr = "DA Certification, Extensions for display area, ""The Old Fire Station""Sturt St, Mt Gambier."
        'TitleStr = "DA certification  Lot 41, Proposed Workshop & office Cnr Port Wakefield rds & Ryans Roads , Greenfields"

        'TitleStr = "Historic Railway Hotel;Historic Railway Hotel;PORT ADELAIDE;South Australia;AUSTRALIA;AUSTRALASIA"
        'TitleStr = "16 Northampton:: Crescent;ELIZABETH EAST;South Australia;AUSTRALIA;AUSTRALASIA::"

        TitleStr = "          1       0.00       0.00"

        'TitleStr = "?;?;?;?;?"

        Debug.Print("Original String: ", TitleStr)
        Call parseDelimitedString(TitleStr, keyWordList, wordCount, " ")
        'Call parseTagDelimitedString(TitleStr, keyWordList, wordCount, "::")


        Debug.Print("WordCount: ", wordCount)
        Addr = ""
        For i = 0 To wordCount - 1
            '    If keyWordList(i) <> "" Then
            Debug.Print(i, "<" & keyWordList(i) & ">")
            Addr = Addr & vbCr & keyWordList(i)
            '    End If
        Next i

        'MsgBox (addr)

        Debug.Print("...testparseString")
    End Sub


End Module
