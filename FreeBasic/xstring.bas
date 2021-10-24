'Option Explicit

    'Created to simplify conversion of programs from other languages
    '(ie. C, AutoLISP)
    Function StrLen(ByVal s As String) As Integer
        StrLen = Len(s)
    End Function

    'Created to simplify conversion of programs from other languages
    '(ie. C, AutoLISP)
    Function strupr(ByVal s As String) As String
        strupr = UCase(s)
    End Function

    'Created to simplify conversion of programs from other languages
    '(ie. C, AutoLISP)
    Function strlwr(ByVal s As String) As String
        strlwr = LCase(s)
    End Function

    'Created to simplify conversion of programs from other languages
    '(ie. C, AutoLISP)
    Function substr(ByVal s As String, ByVal sp As Integer, ByVal l As Integer) As String
        substr = Mid(s, sp, l)
    End Function


    'Forward Search for 1st occurence of character in string
    'Created to simplify conversion of programs from other languages
    '(ie. C, AutoLISP)
    'InStr is available
    Function strchr(ByVal s As String, ByVal c As String) As Integer
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
    Function StrLPad(ByVal s As String, ByVal lStr As Integer) As String
        Dim ss As String
        ss = Space(lStr - Len(s))
        StrLPad = ss & s
    End Function '{...PStrLPad}

    'Set 1st N characters of string to given character
    Function StrNset(ByRef s As String, ByVal ch As String, ByVal n As Integer) As String
        Dim ss As String, i As Integer
        ss = ""
        For i = 1 To n
            ss = ss & ch
        Next i
        s = ss
        StrNset = s
    End Function

    'left pad a string with given character
    Function StrLPadc(ByVal s As String, ByVal lStr As Integer, ByVal c As String) As String
        Dim ss As String
        ss = ""
        ss = StrNset(ss, c, (lStr - Len(s)))
        StrLPadc = ss & s
    End Function '{...PStrLPadc}

    'Right pad a string with spaces
    Function StrRPad(ByVal s As String, ByVal lStr As Integer) As String
        Dim ss As String
        ss = Space(lStr - Len(s))
        StrRPad = s & ss
    End Function '{...PStrRPad}

    'Right pad a string with given character
    Function StrRPadc(ByVal s As String, ByVal lStr As Integer, ByVal c As String) As String
        Dim ss As String
        ss = ""
        ss = StrNset(ss, c, (lStr - Len(s)))
        StrRPadc = s & ss
    End Function '{...PStrRPadc}


    'find last occurrence of character
    'InStrRev is now available
    Function StrRChr(ByVal s As String, ByVal c As String) As Integer
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

    Function fnDrv(ByVal fPath As String) As String
        Dim p1 As Integer
        p1 = InStr(1, fPath, ":") ', vbTextCompare)
        If p1 = 0 Then
            fnDrv = ""
        Else
            fnDrv = Left(fPath, p1)
        End If
    End Function

    Function fnDir(ByVal fPath As String) As String

        Dim p1 As Integer, p2 As Integer

        'find last occurrence of directory delimiter
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
    Function fnName(ByVal fPath As String) As String
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
    Function fnName2(ByVal fPath As String) As String
        Dim p1 As Integer, p2 As Integer, l As Integer

        'find last occurrence of directory delimiter
        p1 = StrRChr(fPath, "\")
        p2 = StrRChr(fPath, ".") 'Can be part of folder name
        l = Len(fPath)
        If p1 = 0 And p2 = 0 Then
            fnName2 = fPath
        ElseIf p1 = 0 Then 'No path statement
            fnName2 = Mid(fPath, 1, p2 - 1)
        ElseIf p2 = 0 Then 'No file extension
            fnName2 = Mid(fPath, p1 + 1, Len(fPath) - p1)
        ElseIf p2 < p1 And l = p1 Then 'folder name includes '.' and no filename given
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
    Function fnExt(ByVal fPath As String) As String
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

    Sub fnsplit(ByVal fPath As String, ByRef drv As String, ByRef fdir As String, ByRef fname As String, ByRef fext As String)
        drv = fnDrv(fPath)
        fdir = fnDir(fPath)
        fname = fnName(fPath)
        fext = fnExt(fPath)
    End Sub

    Sub fnsplit2(ByVal fPath As String, ByRef drv As String, ByRef fdir As String, ByRef fname As String, ByRef fext As String)
        drv = fnDrv(fPath)
        fdir = fnDir(fPath)
        fname = fnName2(fPath)
        fext = fnExt(fPath)
    End Sub


    Function fnmerge(ByVal fPath As String, ByVal drv As String, ByVal fdir As String, ByVal fname As String, ByVal fext As String) As String
        fPath = drv & fdir & fname & fext
        fnmerge = fPath
    End Function
	
    Function FmtAcadPath(ByVal fPath As String) As String
        Dim i As Integer, n As Integer

        n = Len(fPath)
        For i = 1 To n
            If Mid(fPath, i, 1) = "\" Then
                Mid(fPath, i, 1) = "/"
            End If
        Next i

        FmtAcadPath = fPath
    End Function
