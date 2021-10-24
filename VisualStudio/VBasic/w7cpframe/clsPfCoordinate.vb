'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On

Public Class clsPfCoordinate

#Const isUsingExcel = 0

    Public key As Integer
    Public x As Double           '.. x-coord of a joint ..
    Public y As Double           '.. y-coord of a joint ..

    Sub initialise()
        key = 0
        x = 0
        y = 0
    End Sub

    Sub setValues(ByVal nodeKey As Integer, ByVal x1 As Double, ByVal y1 As Double)
        key = nodeKey
        x = x1
        y = y1
    End Sub

    Function sprint() As String
        sprint = StrLPad(Format(key, "###"), 8) & StrLPad(Format(x, "0.0000"), 12) & StrLPad(Format(y, "0.0000"), 12)
    End Function

    Sub cprint()
        Console.WriteLine(sprint)
    End Sub

    Sub fprint(ByVal fp As Integer)
        Print(fp, sprint)
    End Sub


#If isUsingExcel = 1 Then

    Sub wbkPrint(ByVal dataRec As Range, ByVal RecNum As Integer)
        With dataRec
            .Offset(RecNum, 0).Value = key
            .Offset(RecNum, 1).Value = x
            .Offset(RecNum, 2).Value = y
        End With
    End Sub

    Sub wbkRead(ByVal dataRec As Range, ByVal RecNum As Integer)
        With dataRec
            key = .Offset(RecNum, 0).Value
            x = .Offset(RecNum, 1).Value
            y = .Offset(RecNum, 2).Value
        End With
    End Sub

#End If

End Class
