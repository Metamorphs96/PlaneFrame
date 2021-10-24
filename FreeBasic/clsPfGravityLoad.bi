'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'INTERFACE
'-------------------------------------------------------------------------------


'Option Explicit
'#Const isUsingExcel = 1

'System libraries
#include once "string.bi"

'User libraries
#include once "fnXStrings.bi"

Type clsPfGravityLoad
    Public: f_action As Byte
    Public: load As Double        '.. mass per unit length of a member load ..
        
    Declare Sub initialise()
    Declare Sub setValues(ActionKey As Integer, LoadMag As Double)
    Declare Function sprint() As String
    Declare Sub cprint()
    Declare Sub fprint(fp as integer)
    
End Type

Sub clsPfGravityLoad.initialise()
  f_action = 0
  load = 0
End Sub

Sub clsPfGravityLoad.setValues(ActionKey As Integer, LoadMag As Double)
  f_action = ActionKey
  load = LoadMag
End Sub

Function clsPfGravityLoad.sprint() As String
  sprint = StrLPad(Format(f_action, "##0"), 6) & StrLPad(Format(load, "0.000"), 15)
End Function

Sub clsPfGravityLoad.cprint()
  print sprint
End Sub

Sub clsPfGravityLoad.fprint(fp as integer)
  Print #fp, sprint
End Sub

