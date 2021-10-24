'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'

Option Explicit On

Module xStrLib

    Const Letter_uA As Integer = 65
    Const Letter_uZ As Integer = 90
    Const Letter_lA As Integer = 97
    Const Letter_lZ As Integer = 122
    Const Digit_0 As Integer = 48
    Const Digit_9 As Integer = 57
    Const Htab As Integer = 9
    Const SpaceChar As Integer = 32
    '
    '


    Function isAlpha(ByVal ch As String) As Boolean
        Dim c As Integer

        c = Asc(ch)

        If (Letter_uA <= c And c <= Letter_uZ) Or (Letter_lA <= c And c <= Letter_lZ) Then
            isAlpha = True
        Else
            isAlpha = False
        End If
    End Function

    Function isUpper(ByVal ch As String) As Boolean
        Dim c As Integer

        c = Asc(ch)

        If (Letter_uA <= c And c <= Letter_uZ) Then
            isUpper = True
        Else
            isUpper = False
        End If
    End Function

    Function isLower(ByVal ch As String) As Boolean
        Dim c As Integer

        c = Asc(ch)

        If (Letter_lA <= c And c <= Letter_lZ) Then
            isLower = True
        Else
            isLower = False
        End If
    End Function

    'Newline character not considered
    Function isSpace(ByVal ch As String) As Boolean
        Dim c As Integer

        c = Asc(ch)

        If (c = SpaceChar) Or (c = Htab) Then
            isSpace = True
        Else
            isSpace = False
        End If
    End Function

    Function isPrint(ByVal ch As String) As Boolean
        Dim c As Integer

        c = Asc(ch)

        If (32 <= c And c <= 126) Then
            isPrint = True
        Else
            isPrint = False
        End If
    End Function

    Function isPunct(ByVal ch As String) As Boolean
        If Not (isAlnum(ch)) And isPrint(ch) Then
            isPunct = True
        Else
            isPunct = False
        End If
    End Function

    Function isCntrl(ByVal ch As String) As Boolean
        Dim c As Integer

        c = Asc(ch)

        If (c < 32) Or (c = 127) Then
            isCntrl = True
        Else
            isCntrl = False
        End If
    End Function


    Function isDigit(ByVal ch As String) As Boolean
        Dim c As Integer

        c = Asc(ch)

        If (Digit_0 <= c And c <= Digit_9) Then
            isDigit = True
        Else
            isDigit = False
        End If
    End Function

    Function isAlnum(ByVal ch As String) As Boolean

        If isDigit(ch) Or isAlpha(ch) Then
            isAlnum = True
        Else
            isAlnum = False
        End If

    End Function


End Module
