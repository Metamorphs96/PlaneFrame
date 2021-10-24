'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On
Public Class clsPfConnectivity

#Const isUsingExcel = 0

    Public key As Integer

    Public jj As Byte            '.. joint No. @ end "j" of a member ..  [na]
    Public jk As Byte            '.. joint No. @ end "k" of a member ..  [nb]
    Public sect As Byte          '.. section group of member ..          [ns]
    Public rel_i As Byte         '.. end i release of member ..          [mra]
    Public rel_j As Byte         '.. end j release of member ..          [mrb]
    Public jnt_jj As clsPfForce
    Public jnt_jk As clsPfForce

    Sub initialise()
        jj = 0
        jk = 0
        sect = 0
        rel_i = 0
        rel_j = 0

        jnt_jj = New clsPfForce
        jnt_jj.initialise()

        jnt_jk = New clsPfForce
        jnt_jk.initialise()

    End Sub

    Sub setValues(ByVal memberKey As Integer, ByVal NodeA As Integer, ByVal NodeB As Integer, ByVal sectionKey As Integer, ByVal ReleaseA As Integer, ByVal ReleaseB As Integer)
        key = memberKey
        jj = NodeA
        jk = NodeB
        sect = sectionKey
        rel_i = ReleaseA
        rel_j = ReleaseB
    End Sub

    Function sprint() As String
        sprint = StrLPad(Format(key, "##0"), 8) _
                 & StrLPad(Format(jj, "##0"), 6) _
                 & StrLPad(Format(jk, "##0"), 6) _
                 & StrLPad(Format(sect, "##0"), 6) _
                 & StrLPad(Format(rel_i, "##0"), 6) _
                 & StrLPad(Format(rel_j, "##0"), 2)

    End Function


    Sub cprint()

        Console.WriteLine(sprint)
        '  jnt_jj.cprint
        '  jnt_jk.cprint

    End Sub

    Sub fprint(ByVal fp As Integer)
        Print(fp, sprint)
    End Sub


#If isUsingExcel = 1 Then

    Sub wbkPrint(ByVal dataRec As Range, ByVal RecNum As Byte)
        With dataRec
            .Offset(RecNum, 0).Value = key
            .Offset(RecNum, 1).Value = jj
            .Offset(RecNum, 2).Value = jk
            .Offset(RecNum, 3).Value = sect
            .Offset(RecNum, 4).Value = rel_i
            .Offset(RecNum, 5).Value = rel_j
        End With
    End Sub

    Sub wbkRead(ByVal dataRec As Range, ByVal RecNum As Byte)
        With dataRec
            key = .Offset(RecNum, 0).Value
            jj = .Offset(RecNum, 1).Value
            jk = .Offset(RecNum, 2).Value
            sect = .Offset(RecNum, 3).Value
            rel_i = .Offset(RecNum, 4).Value
            rel_j = .Offset(RecNum, 5).Value
        End With
    End Sub

#End If

End Class
