Module uPfGraph

    'Geometry Plot
    Sub Display_Network(ByVal crv_no As Byte)
        Dim plot As TDiagramPlotter

        plot = New TDiagramPlotter
        plot.plotcase = crv_no

        If isDataLoaded Then
            If crv_no = geometry Then
                plot.Display_Graph()
            ElseIf isAnalysed Then
                plot.Display_Graph()
            Else
                MsgBox(">> Run Analysis First !!  <<") ', mtInformation, (mbOK), 0)
            End If
        End If

    End Sub

End Module
