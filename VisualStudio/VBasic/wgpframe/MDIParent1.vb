'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'

Imports System.Windows.Forms

Public Class MDIParent1

    Private Sub ShowNewForm(ByVal sender As Object, ByVal e As EventArgs) Handles NewToolStripMenuItem.Click, NewToolStripButton.Click, NewWindowToolStripMenuItem.Click
        ' Create a new instance of the child form.
        Dim ChildForm As New System.Windows.Forms.Form
        ' Make it a child of this MDI form before showing it.
        ChildForm.MdiParent = Me

        m_ChildFormNumber += 1
        ChildForm.Text = "Window " & m_ChildFormNumber

        ChildForm.Show()
    End Sub

    Private Sub OpenFile(ByVal sender As Object, ByVal e As EventArgs) Handles OpenToolStripMenuItem.Click, OpenToolStripButton.Click

        frmTracer = New TTracerFrm
        frmTracer.MdiParent = Me
        frmTracer.Show()

        Dim OpenFileDialog As New OpenFileDialog
        'OpenFileDialog.InitialDirectory = My.Computer.FileSystem.SpecialDirectories.MyDocuments

        OpenFileDialog.Filter = "Data Files (*.dat)|*.dat|All Files (*.*)|*.*"
        If (OpenFileDialog.ShowDialog(Me) = System.Windows.Forms.DialogResult.OK) Then
            'Dim FileName As String = OpenFileDialog.FileName
            ' TODO: Add code here to open the file.
            dataFileName = OpenFileDialog.FileName
            frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & dataFileName
            MainApplication(dataFileName)
            cpFramefgetData()

        End If
    End Sub

    Private Sub SaveAsToolStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles SaveAsToolStripMenuItem.Click
        Dim SaveFileDialog As New SaveFileDialog
        SaveFileDialog.InitialDirectory = My.Computer.FileSystem.SpecialDirectories.MyDocuments
        SaveFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"

        If (SaveFileDialog.ShowDialog(Me) = System.Windows.Forms.DialogResult.OK) Then
            Dim FileName As String = SaveFileDialog.FileName
            ' TODO: Add code here to save the current contents of the form to a file.
        End If
    End Sub


    Private Sub ExitToolsStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles ExitToolStripMenuItem.Click
        Global.System.Windows.Forms.Application.Exit()
    End Sub

    Private Sub CutToolStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles CutToolStripMenuItem.Click
        ' Use My.Computer.Clipboard to insert the selected text or images into the clipboard
    End Sub

    Private Sub CopyToolStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles CopyToolStripMenuItem.Click
        ' Use My.Computer.Clipboard to insert the selected text or images into the clipboard
    End Sub

    Private Sub PasteToolStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles PasteToolStripMenuItem.Click
        'Use My.Computer.Clipboard.GetText() or My.Computer.Clipboard.GetData to retrieve information from the clipboard.
    End Sub

    Private Sub ToolBarToolStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles ToolBarToolStripMenuItem.Click
        Me.ToolStrip.Visible = Me.ToolBarToolStripMenuItem.Checked
    End Sub

    Private Sub StatusBarToolStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles StatusBarToolStripMenuItem.Click
        Me.StatusStrip.Visible = Me.StatusBarToolStripMenuItem.Checked
    End Sub

    Private Sub CascadeToolStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles CascadeToolStripMenuItem.Click
        Me.LayoutMdi(MdiLayout.Cascade)
    End Sub

    Private Sub TileVerticleToolStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles TileVerticalToolStripMenuItem.Click
        Me.LayoutMdi(MdiLayout.TileVertical)
    End Sub

    Private Sub TileHorizontalToolStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles TileHorizontalToolStripMenuItem.Click
        Me.LayoutMdi(MdiLayout.TileHorizontal)
    End Sub

    Private Sub ArrangeIconsToolStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles ArrangeIconsToolStripMenuItem.Click
        Me.LayoutMdi(MdiLayout.ArrangeIcons)
    End Sub

    Private Sub CloseAllToolStripMenuItem_Click(ByVal sender As Object, ByVal e As EventArgs) Handles CloseAllToolStripMenuItem.Click
        ' Close all child forms of the parent.
        For Each ChildForm As Form In Me.MdiChildren
            ChildForm.Close()
        Next
    End Sub

    Private m_ChildFormNumber As Integer = 0

    Private Sub LinearAnalysis2DToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles LinearAnalysis2DToolStripMenuItem.Click

        If isDataLoaded Then
            cpFrameRunAnalysis()
            isAnalysed = True

            ResultViewer = New TTracerFrm
            ResultViewer.MdiParent = Me
            ResultViewer.Show()

            ResultViewer.Text = ofullName
            ResultViewer.txtTracer.Text = My.Computer.FileSystem.ReadAllText(ofullName)
        Else
            frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "No Data Loaded!!"
        End If

    End Sub

    Private Sub MDIParent1_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        'MsgBox("Form Loaded")
        'For Each s As String In My.Application.CommandLineArgs
        '    MsgBox(s)
        'Next
        'If My.Application.CommandLineArgs.Count > 0 Then
        '    MsgBox("Have Command Line Arguments")
        'End If
    End Sub

    Private Sub GeometryToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles GeometryToolStripMenuItem.Click
        'Dim objbmp As Bitmap
        'Dim objGraph As Graphics
        'Dim objPen As Pen

        'graphViewer = New TgraphViewer
        'graphViewer.MdiParent = Me
        'graphViewer.Show()
        'objbmp = New Bitmap(graphViewer.graphView.Width, graphViewer.graphView.Height)
        'objGraph = Graphics.FromImage(objbmp)
        'objPen = New Pen(Color.Blue, 1)
        'objGraph.DrawLine(objPen, 0, 0, 50, 50)
        'graphViewer.graphView.Image = objbmp

        'graphViewer.graphView.CreateGraphics()

        Display_Network(geometry)


    End Sub

    Private Sub LoadsToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles LoadsToolStripMenuItem.Click
        Display_Network(loads)
    End Sub

    Private Sub MomentsToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MomentsToolStripMenuItem.Click
        Display_Network(moments)
    End Sub

    Private Sub ShearToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ShearToolStripMenuItem.Click
        Display_Network(shears)
    End Sub

    Private Sub AxialToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles AxialToolStripMenuItem.Click
        Display_Network(axial)
    End Sub

    Private Sub DeflectionToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles DeflectionToolStripMenuItem.Click
        Display_Network(delta)
    End Sub

    Private Sub AboutToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles AboutToolStripMenuItem.Click
        AboutBox1.Show()
    End Sub
End Class
