'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On
Module stdio

    Public Const CR As Integer = 13
    Public Const LF As Integer = 10
    Public Const SpaceChar As Integer = 32
    Public Const Htab As Integer = 9
    Public Const ESC As Integer = 27
    Public Const NulChar As Integer = 0

    Public Const QuoteCode As Integer = 34
    Public Const QuoteChar As String = """"


    Function isCarriageReturn(ByVal c As String) As Boolean
        If Asc(c) = CR Then
            isCarriageReturn = True
        Else
            isCarriageReturn = False
        End If
    End Function

    Function isLineFeed(ByVal c As String) As Boolean
        If Asc(c) = LF Then
            isLineFeed = True
        Else
            isLineFeed = False
        End If
    End Function

    Function isEoLN(ByVal c As String) As Boolean
        If isCarriageReturn(c) Or isLineFeed(c) Then
            isEoLN = True
        Else
            isEoLN = False
        End If
    End Function


    Function Eoln(ByVal fp As Integer, ByVal c As String) As Boolean

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
    Function Readln(ByVal fp As Integer) As String
        Dim s As String
        Dim c As String
        Dim prevc As String
        Dim isDone As Boolean

        isDone = False
        s = ""
        c = NulChar
        prevc = c

        Do While Not (isDone) And Not (EOF(fp))
            c = InputString(fp, 1)

            If isPrint(c) Then s = s & c
            'Debug.Print s

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
    Function ReadField(ByVal fp As Integer) As String
        Dim s As String
        Dim c As String

        s = ""
        c = NulChar

        Do While Asc(c) <> SpaceChar And Not (EOF(fp)) And Not (isEoLN(c))
            c = InputString(fp, 1)
            If Asc(c) <> SpaceChar And Not (EOF(fp)) And Not (isEoLN(c)) Then s = s & c
        Loop
        ReadField = s

    End Function

End Module
