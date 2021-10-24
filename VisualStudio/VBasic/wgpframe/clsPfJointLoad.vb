'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On

Public Class clsPfJointLoad

#Const isUsingExcel = 0

    Public key As Integer

    Public jt As Byte
    Public fx As Double          '.. horizontal load @ a joint ..
    Public fy As Double          '.. vertical   load @ a joint ..
    Public mz As Double          '.. moment applied  @ a joint ..

    Sub initialise()
        key = 0
        jt = 0
        fx = 0
        fy = 0
        mz = 0
    End Sub

    Sub setValues(ByVal LoadKey As Integer, ByVal Node As Integer, ByVal ForceX As Double, ByVal ForceY As Double, ByVal Moment As Double)
        key = LoadKey
        jt = Node
        fx = ForceX
        fy = ForceY
        mz = Moment
    End Sub

    Function sprint() As String
        sprint = StrLPad(Format(key, "##0"), 8) _
                 & StrLPad(Format(jt, "##0"), 6) _
                 & StrLPad(Format(fx, "0.000"), 15) _
                 & StrLPad(Format(fy, "0.000"), 15) _
                 & StrLPad(Format(mz, "0.000"), 15)
    End Function

    Sub cprint()
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & sprint
    End Sub

    Sub fprint(ByVal fp As Integer)
        Print(fp, sprint)
    End Sub


#If isUsingExcel = 1 Then

    Sub wbkPrint(ByVal dataRec As Range, ByVal RecNum As Byte)
        With dataRec
            .Offset(RecNum, 0).Value = key
            .Offset(RecNum, 1).Value = jt
            .Offset(RecNum, 2).Value = fx
            .Offset(RecNum, 3).Value = fy
            .Offset(RecNum, 4).Value = mz
        End With
    End Sub

    Sub wbkRead(ByVal dataRec As Range, ByVal RecNum As Byte)
        With dataRec
            key = .Offset(RecNum, 0).Value
            jt = .Offset(RecNum, 1).Value
            fx = .Offset(RecNum, 2).Value
            fy = .Offset(RecNum, 3).Value
            mz = .Offset(RecNum, 4).Value
        End With
    End Sub

#End If

End Class
