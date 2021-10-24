'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On

Public Class clsPfForce

#Const isUsingExcel = 0

    Public axial As Double       '.. axial force ..
    Public shear As Double       '.. shear force ..
    Public momnt As Double      '.. end moment ..


    Sub initialise()
        axial = 0
        shear = 0
        momnt = 0
    End Sub

    Sub cprint()
        Console.WriteLine(format(axial,"0.00") + " : " + format(shear,"0.00") +  " : " + format( momnt,"0.00"))
    End Sub

#If isUsingExcel = 1 Then

    Sub wbkPrint(ByVal dataRec As Range, ByVal RecNum As Byte)
        With dataRec
            .Offset(RecNum, 1).Value = axial
            .Offset(RecNum, 2).Value = shear
            .Offset(RecNum, 3).Value = momnt
        End With
    End Sub

    Sub wbkRead(ByVal dataRec As Range, ByVal RecNum As Byte)
        With dataRec
            axial = .Offset(RecNum, 1).Value
            shear = .Offset(RecNum, 2).Value
            momnt = .Offset(RecNum, 3).Value
        End With
    End Sub

#End If

End Class
