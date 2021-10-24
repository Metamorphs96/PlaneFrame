'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'INTERFACE
'-------------------------------------------------------------------------------


Const isEarlyVersion As Boolean = True 'Modify to test variable at future date

Const baseIndex As Integer = 0
' Dim fpText As Integer, fpRpt As Integer, fpTracer As Integer
' Dim GModel As New clsGeomModel
' Dim pfModel As New PlaneFrame


Const dataBlockTag As String = "::"
Dim data_loaded As Boolean

'... Constant declarations ...
Const numloads As Integer = 80
Const order As Integer = 50
Const v_size As Integer = 50
Const max_grps As Integer = 25
Const max_mats As Integer = 10
Const n_segs As Byte = 10
