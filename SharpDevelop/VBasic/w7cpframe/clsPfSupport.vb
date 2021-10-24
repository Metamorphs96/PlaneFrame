'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On

Public Class clsPfSupport

#Const isUsingExcel = 0

    Public key As Integer
    Public js As Byte
    Public rx As Byte            '.. joint X directional restraint ..
    Public ry As Byte            '.. joint Y directional restraint ..
    Public rm As Byte            '.. joint Z rotational restraint ..

    Sub initialise()
        js = 0
        rx = 0
        ry = 0
        rm = 0
    End Sub

    Sub setValues(ByVal supportKey As Integer, ByVal SupportNode As Integer, ByVal RestraintX As Byte, ByVal RestraintY As Byte, ByVal RestraintMoment As Byte)
        key = supportKey
        js = SupportNode
        rx = RestraintX
        ry = RestraintY
        rm = RestraintMoment
    End Sub


    Function sprint() As String
        sprint = StrLPad(Format(key, "##0"), 8) _
                 & StrLPad(Format(js, "##0"), 6) _
                 & StrLPad(Format(rx, "##0"), 6) _
                 & StrLPad(Format(ry, "##0"), 6) _
                 & StrLPad(Format(rm, "##0"), 6)
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
      .Offset(RecNum, 0).Value = key
      .Offset(RecNum, 1).Value = js
      .Offset(RecNum, 2).Value = rx
      .Offset(RecNum, 3).Value = ry
      .Offset(RecNum, 4).Value = rm
    End With
  End Sub

  Sub wbkRead(dataRec As Range, RecNum As Byte)
    With dataRec
      key = .Offset(RecNum, 0).Value
      js = .Offset(RecNum, 1).Value
      rx = .Offset(RecNum, 2).Value
      ry = .Offset(RecNum, 3).Value
      rm = .Offset(RecNum, 4).Value
    End With
  End Sub

#End If

End Class
