'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On

Public Class clsPfSection

#Const isUsingExcel = 0

    Public key As Integer

    Public ax As Double          '.. member's cross sectional area ..
    Public iz As Double         '.. member's second moment of area ..

    'Dependent on Material Properties
    Public t_len As Double       '.. TOTAL length of this section ..
    Public t_mass As Double      '.. TOTAL mass of this section ..
    Public mat As Byte           '.. material of section ..

    Public Descr As String       '.. section description string ..

    Sub initialise()
        ax = 0
        iz = 0
        t_len = 0
        t_mass = 0
        mat = 0
        Descr = "<unknown>"
    End Sub

    Sub setValues(ByVal sectionKey As Integer, ByVal SectionArea As Double, ByVal SecondMomentArea As Double, ByVal materialKey As Integer, ByVal Description As String)
        key = sectionKey
        ax = SectionArea
        iz = SecondMomentArea
        mat = materialKey
        Descr = Description
    End Sub

    Function sprint() As String
        sprint = StrLPad(Format(key, "##0"), 8) _
                 & StrLPad(Format(ax, "0.0000E+00"), 15) _
                 & StrLPad(Format(iz, "0.0000E+00"), 15) _
                 & StrLPad(Format(mat, "##0"), 6) _
                 & StrLPad(Descr, 28)

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
            .Offset(RecNum, 1).Value = ax
            .Offset(RecNum, 2).Value = iz
            .Offset(RecNum, 3).Value = mat
            .Offset(RecNum, 4).Value = Descr

            '      .Offset(RecNum, 3).value = t_len
            '      .Offset(RecNum, 4).value = t_mass

        End With
    End Sub

    Sub wbkRead(ByVal dataRec As Range, ByVal RecNum As Byte)
        With dataRec
            key = .Offset(RecNum, 0).Value
            ax = .Offset(RecNum, 1).Value
            iz = .Offset(RecNum, 2).Value
            mat = .Offset(RecNum, 3).Value
            Descr = .Offset(RecNum, 4).Value
            '      t_len = .Offset(RecNum, 3).value
            '      t_mass = .Offset(RecNum, 4).value

        End With
    End Sub

#End If

End Class
