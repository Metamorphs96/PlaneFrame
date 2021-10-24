'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On

Public Class clsPfGravityLoad

#Const isUsingExcel = 0

    Public f_action As Byte
    Public load As Double        '.. mass per unit length of a member load ..

    Sub initialise()
        f_action = 0
        load = 0
    End Sub

    Sub setValues(ByVal ActionKey As Integer, ByVal LoadMag As Double)
        f_action = ActionKey
        load = LoadMag
    End Sub

    Function sprint() As String
        sprint = StrLPad(Format(f_action, "##0"), 6) & StrLPad(Format(load, "0.000"), 15)
    End Function

    Sub cprint()
        Console.WriteLine(sprint)
    End Sub

    Sub fprint(ByVal fp As Integer)
        Print(fp, sprint)
    End Sub

#If isUsingExcel = 1 Then

  Sub wbkPrint(dataRec As Range, RecNum As Byte)
    With dataRec
      .Offset(RecNum, 0).Value = f_action
      .Offset(RecNum, 1).Value = load
    End With
  End Sub

  Sub wbkRead(dataRec As Range, RecNum As Byte)
    With dataRec
      f_action = .Offset(RecNum, 1).Value
      load = .Offset(RecNum, 2).Value
    End With
  End Sub

#End If

End Class
