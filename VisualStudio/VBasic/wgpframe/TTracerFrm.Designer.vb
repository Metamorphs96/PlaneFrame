<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class TTracerFrm
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
        Me.txtTracer = New System.Windows.Forms.TextBox
        Me.SuspendLayout()
        '
        'txtTracer
        '
        Me.txtTracer.Dock = System.Windows.Forms.DockStyle.Fill
        Me.txtTracer.Location = New System.Drawing.Point(0, 0)
        Me.txtTracer.Multiline = True
        Me.txtTracer.Name = "txtTracer"
        Me.txtTracer.ScrollBars = System.Windows.Forms.ScrollBars.Vertical
        Me.txtTracer.Size = New System.Drawing.Size(292, 266)
        Me.txtTracer.TabIndex = 0
        '
        'TTracerFrm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(292, 266)
        Me.Controls.Add(Me.txtTracer)
        Me.Name = "TTracerFrm"
        Me.Text = "Tracer"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents txtTracer As System.Windows.Forms.TextBox
End Class
