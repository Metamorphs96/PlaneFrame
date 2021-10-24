'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'

Module xarray

    Sub fprintVector(ByVal fp As Integer, ByVal v() As Double)
        Dim j As Integer, c As Integer, n As Integer, startNdx as integer

        startNdx = LBound(v)
        n = UBound(v)
        For j = startNdx To n
            Print(fp, StrLPad(Format(v(j), "0.0000"), 15))
        Next j

        PrintLine(fp)

    End Sub


    Sub fprintMatrix(ByVal fp As Integer, ByVal v(,) As Double)
        Dim j As Integer, n1 As Integer, startNdx1 as integer
        Dim i As Integer, n2 As Integer, startNdx2 as integer

        startNdx1 = LBound(v, 1)
        n1 = UBound(v, 1)

        startNdx2 = LBound(v, 2)
        n2 = UBound(v, 2)


        For i = startNdx1 To n1
            For j = startNdx2 To n2
                Print(fp, StrLPad(Format(v(i, j), "0.0000"), 15))
            Next j
            PrintLine(fp)
        Next i

        PrintLine(fp)

    End Sub

End Module
