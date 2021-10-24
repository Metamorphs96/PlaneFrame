'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'IMPLEMENTATION
'-------------------------------------------------------------------------------


'Option Explicit

#include once "string.bi" 'required for format function
#include once "fnXStrings.bi"

Sub fprintVector(fp as integer, v() As double)
    Dim j As Integer, c As Integer, n As Integer, startNdx as integer

    startNdx = LBound(v)
    n = UBound(v)
    For j = startNdx To n
        print #fp, (StrLPad(Format(v(j), "0.0000"), 15))
    Next j

    print #fp, 

End Sub


Sub fprintMatrix(fp as integer, v() As double)
    Dim j As Integer, n1 As Integer, startNdx1 as integer
    Dim i As Integer, n2 As Integer, startNdx2 as integer

    startNdx1 = LBound(v, 1)
    n1 = UBound(v, 1)

    startNdx2 = LBound(v, 2)
    n2 = UBound(v, 2)

    print #fp, "Matrix::"

    For i = startNdx1 To n1
        For j = startNdx2 To n2
            print #fp, (StrLPad(Format(v(i, j), "0.0000"), 15));
        Next j
        print #fp,
    Next i

    print #fp,

End Sub
