<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class TgraphViewer
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing AndAlso components IsNot Nothing Then
            components.Dispose()
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.graphView = New System.Windows.Forms.PictureBox
        CType(Me.graphView, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'graphView
        '
        Me.graphView.BackColor = System.Drawing.Color.White
        Me.graphView.Dock = System.Windows.Forms.DockStyle.Fill
        Me.graphView.Location = New System.Drawing.Point(0, 0)
        Me.graphView.Name = "graphView"
        Me.graphView.Size = New System.Drawing.Size(292, 266)
        Me.graphView.TabIndex = 0
        Me.graphView.TabStop = False
        '
        'TgraphViewer
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(292, 266)
        Me.Controls.Add(Me.graphView)
        Me.Name = "TgraphViewer"
        Me.Text = "TgraphViewer"
        CType(Me.graphView, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)

    End Sub
    Friend WithEvents graphView As System.Windows.Forms.PictureBox
End Class
