'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On

Public Class clsPfMemberLoad



#Const isUsingExcel = 0

    Public key As Integer

    Public mem_no As Byte
    Public lcode As Byte
    Public f_action As Byte
    Public ld_mag1 As Double     '.. member load magnitude 1 ..
    Public ld_mag2 As Double     '.. member load magnitude 2 ..
    Public start As Double       '.. dist from end_1 to start/centroid of load ..
    Public cover As Double      '.. dist that a load covers ..

    Sub initialise()
        mem_no = 0
        lcode = 0
        f_action = 0
        ld_mag1 = 0
        ld_mag2 = 0
        start = 0
        cover = 0
    End Sub

    Sub setValues(ByVal LoadKey As Integer, ByVal memberKey As Integer, ByVal LoadType As Integer, ByVal ActionKey As Integer _
                             , ByVal LoadMag1 As Double, ByVal LoadMag2 As Double, ByVal LoadStart As Double, ByVal LoadCover As Double)

        key = LoadKey
        mem_no = memberKey
        lcode = LoadType
        f_action = ActionKey
        ld_mag1 = LoadMag1
        ld_mag2 = LoadMag2 'xla version only
        start = LoadStart
        cover = LoadCover
    End Sub

    Function sprint() As String
        sprint = StrLPad(Format(key, "##0"), 8) _
                   & StrLPad(Format(mem_no, "##0"), 6) _
                   & StrLPad(Format(lcode, "##0"), 6) _
                   & StrLPad(Format(f_action, "##0"), 6) _
                   & StrLPad(Format(ld_mag1, "0.000"), 15) _
                   & StrLPad(Format(start, "0.000"), 15) _
                   & StrLPad(Format(cover, "0.000"), 12)

    End Function

    Sub cprint()
        Console.WriteLine(sprint)
    End Sub

    Sub fprint(ByVal fp As Integer)
        Print(fp, sprint)
    End Sub


#If isUsingExcel = 1 Then

    Sub wbkPrint(ByVal dataRec As Range, ByVal RecNum As Byte)
        With dataRec
            .Offset(RecNum, 0).Value = key
            .Offset(RecNum, 1).Value = mem_no
            .Offset(RecNum, 2).Value = lcode
            .Offset(RecNum, 3).Value = f_action
            .Offset(RecNum, 4).Value = ld_mag1
            .Offset(RecNum, 5).Value = start
            .Offset(RecNum, 6).Value = cover
        End With
    End Sub

    Sub wbkRead(ByVal dataRec As Range, ByVal RecNum As Byte)
        With dataRec
            key = .Offset(RecNum, 0).Value
            mem_no = .Offset(RecNum, 1).Value
            lcode = .Offset(RecNum, 2).Value
            f_action = .Offset(RecNum, 3).Value
            ld_mag1 = .Offset(RecNum, 4).Value
            ld_mag2 = .Offset(RecNum, 5).Value
            start = .Offset(RecNum, 6).Value
            cover = .Offset(RecNum, 7).Value
        End With
    End Sub

#End If

End Class
