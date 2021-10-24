'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'IMPLEMENTATION
'-------------------------------------------------------------------------------


'Option Explicit

#include once "fnXStrings.bi"

Sub fnsplit(fPath As String, drv As String, fdir As String, fname As String, fext As String)
  drv = fnDrv(fPath)
  fdir = fnDir(fPath)
  fname = fnName(fPath)
  fext = fnExt(fPath)
End Sub

Sub fnsplit2(fPath As String, drv As String, fdir As String, fname As String, fext As String)
  drv = fnDrv(fPath)
  fdir = fnDir(fPath)
  fname = fnName2(fPath)
  fext = fnExt(fPath)
End Sub

