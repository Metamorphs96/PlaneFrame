'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On

Public Class clsPfMaterial

#Const isUsingExcel = 0

    Public key As Integer

    Public density As Double     '.. density ..
    Public emod As Double           '.. elastic Modulus ..
    Public therm As Double          '.. coeff of thermal expansion..}


    Sub initialise()
        density = 0
        emod = 0
        therm = 0
    End Sub

    Sub setValues(ByVal materialKey As Integer, ByVal massDensity As Double, ByVal ElasticModulus As Double, ByVal CoeffThermExpansion As Double)
        key = materialKey
        density = massDensity
        emod = ElasticModulus
        therm = CoeffThermExpansion
    End Sub

    Function sprint() As String
        sprint = StrLPad(Format(key, "##0"), 8) _
                 & StrLPad(Format(density, "0.00"), 15) _
                 & StrLPad(Format(emod, "0.00E+00"), 15) _
                 & StrLPad(Format(therm, "0.0000E+00"), 15)

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
            .Offset(RecNum, 1).Value = density
            .Offset(RecNum, 2).Value = emod
            .Offset(RecNum, 3).Value = therm
        End With
    End Sub

    Sub wbkRead(ByVal dataRec As Range, ByVal RecNum As Byte)
        With dataRec
            key = .Offset(RecNum, 0).Value
            density = .Offset(RecNum, 1).Value
            emod = .Offset(RecNum, 2).Value
            therm = .Offset(RecNum, 3).Value
        End With
    End Sub

#End If

End Class
