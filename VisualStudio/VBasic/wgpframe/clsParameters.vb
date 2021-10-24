'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Public Class clsParameters

    Public njt As Integer        '.. No. of joints ..
    Public nmb As Integer        '.. No. of members ..
    Public nmg As Integer        '.. No. of material groups ..
    Public nsg As Integer        '.. No. of member section groups ..
    Public nrj As Integer        '.. No. of supported reaction joints ..
    Public njl As Integer        '.. No. of loaded joints ..
    Public nml As Integer        '.. No. of loaded members ..
    Public ngl As Integer        '.. No. of gravity load cases .. Self weight
    Public nr As Integer        '.. No. of restraints @ the supports ..

    Public mag As Integer     '.. Magnification Factor for graphics

Function getInitValue(baseIndx As Integer)
  If baseIndx = 0 Then
    getInitValue = -1
  ElseIf baseIndx = 1 Then
    getInitValue = 0
  End If
End Function

Sub initialise()
        Console.WriteLine("initialise ...")
        'njt = getInitValue(baseIndex)
        'nmb = getInitValue(baseIndex)
        'nmg = getInitValue(baseIndex)
        'nsg = getInitValue(baseIndex)
        'nrj = getInitValue(baseIndex)
        'njl = getInitValue(baseIndex)
        'nml = getInitValue(baseIndex)
        'ngl = getInitValue(baseIndex)
        'nr = getInitValue(baseIndex)

        'Total Count NOT indices
        'But used as array index during reading
        njt = 0
        nmb = 0
        nmg = 0
        nsg = 0
        nrj = 0
        njl = 0
        nml = 0
        ngl = 0
        nr = 0


        Console.WriteLine("... initialise")
End Sub

Function sprint() As String
  sprint = StrLPad(Format(njt, "0"), 6) & StrLPad(Format(nmb, "0"), 6) _
          & StrLPad(Format(nrj, "0"), 6) & StrLPad(Format(nmg, "0"), 6) _
          & StrLPad(Format(nsg, "0"), 6) & StrLPad(Format(njl, "0"), 6) _
          & StrLPad(Format(nml, "0"), 6) & StrLPad(Format(ngl, "0"), 6) _
          & StrLPad(Format(mag, "0"), 6)

End Function

Sub cprint()
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & sprint
End Sub

Sub fprint(fp As Integer)
        Print(fp, sprint)
End Sub

    Sub fgetData(ByVal fp As Integer, ByVal isIgnore As Boolean)

        Dim s As String
        Dim n As Integer
        Dim dataflds(10) As String
        'Dim i As Integer

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "clsParameters.fgetData ..."

        s = Trim(Readln(fp))
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "<" + s + ">"

        Call parseDelimitedString(s, dataflds, n, " ")

        'typically ignore as all counters are incremented as data read
        'isIgnore=False only used to test parser.
        If isIgnore Then
            'Clear the control data, and count records as read data from file
            frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Ignore Control Variable: Count as read data"
            initialise()
        Else
            frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Reading Control Variables from File"

            'For i = 0 To n
            '    frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & dataflds(i)
            'Next

            njt = CInt(dataflds(0))
            nmb = CInt(dataflds(1))
            nrj = CInt(dataflds(2))
            nmg = CInt(dataflds(3))
            nsg = CInt(dataflds(4))
            njl = CInt(dataflds(5))
            nml = CInt(dataflds(6))
            ngl = CInt(dataflds(7))
        End If


        If dataflds(8) <> "" Then
            mag = CInt(dataflds(8))
        Else
            mag = 1
        End If

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Dimension & Geometry"
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "-------------------------------"
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Number of Joints       : " + Format(njt, "0")
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Number of Members      : " + Format(nmb, "0")
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Number of Supports     : " + Format(nrj, "0")

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Materials & Sections"
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "-------------------------------"
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Number of Materials    : " + Format(nmg, "0")
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Number of Sections     : " + Format(nsg, "0")

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Design Actions"
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "-------------------------------"
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Number of Joint Loads  : " + Format(njl, "0")
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Number of Member Loads : " + Format(nml, "0")
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Number of Gravity Loads : " + Format(ngl, "0")

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Screen Magnifier: " + Format(mag, "0")

        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "... clsParameters.fgetData"
    End Sub

    '#If isUsingExcel = 1 Then

    '  Sub wbkPrint(dataSht As Worksheet)

    '    With dataSht
    '      .Range("Njoints").Value = njt
    '      .Range("Nmembers").Value = nmb
    '      .Range("Nmaterials").Value = nmg
    '      .Range("Nsections").Value = nsg

    '      .Range("Nsupports").Value = nrj


    '      .Range("Njloads").Value = njl
    '      .Range("Nmloads").Value = nml
    '      .Range("Ngloads").Value = ngl

    '      .Range("Mag").Value = mag
    '    End With

    '  End Sub

    '  Sub wbkRead(dataSht As Worksheet, isIgnore As Boolean)

    '    If isIgnore Then
    '      'Clear the control data, and count records as read data from file
    '      initialise
    '    Else
    '      With dataSht
    '        njt = .Range("Njoints").Value
    '        nmb = .Range("Nmembers").Value
    '        nmg = .Range("Nmaterials").Value
    '        nsg = .Range("Nsections").Value
    '        nrj = .Range("Nsupports").Value
    '        njl = .Range("Njloads").Value
    '        nml = .Range("Nmloads").Value
    '        ngl = .Range("Ngloads").Value
    '      End With
    '    End If

    '    mag = dataSht.Range("Mag").Value

    '  End Sub

    '#End If


End Class
