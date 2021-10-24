'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

    Sub fprintVector(ByVal fp , ByVal v )
        Dim j , c, n , startNdx

        startNdx = LBound(v)
        n = UBound(v)
        For j = startNdx To n
            fp.Write(StrLPad(FormatNumber(v(j), 4,-1,0,0), 15))
        Next 'j

        fp.WriteLine

    End Sub


    Sub fprintMatrix(ByVal fp, ByVal v() )
        Dim j , n1, startNdx1
        Dim i , n2 , startNdx2

        startNdx1 = LBound(v, 1)
        n1 = UBound(v, 1)

        startNdx2 = LBound(v, 2)
        n2 = UBound(v, 2)


        For i = startNdx1 To n1
            For j = startNdx2 To n2
                fp.Write(StrLPad(FormatNumber(v(i, j), 4,-1,0,0), 15))
            Next 'j
            fp.WriteLine
        Next 'i

        fp.WriteLine

    End Sub


