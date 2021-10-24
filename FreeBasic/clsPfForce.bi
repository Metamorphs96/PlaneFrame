'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'INTERFACE
'-------------------------------------------------------------------------------


'Option Explicit
'#Const isUsingExcel = 1

Type clsPfForce
    Public: axial As Double       '.. axial force ..
    Public: shear As Double       '.. shear force ..
    Public: momnt  As Double      '.. end moment ..
    
    Declare Sub initialise()
    Declare Sub cprint()
End Type


Sub clsPfForce.initialise()
  axial = 0
  shear = 0
  momnt = 0
End Sub

Sub clsPfForce.cprint()
  print axial, shear, momnt
End Sub

