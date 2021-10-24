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

Type clsPfJointLoad
    Public: key As Integer
    
    Public: jt As Byte
    Public: fx As Double          '.. horizontal load @ a joint ..
    Public: fy As Double          '.. vertical   load @ a joint ..
    Public: mz As Double          '.. moment applied  @ a joint ..
    
    Declare Sub initialise()
    Declare Sub setValues(LoadKey As Integer, Node As Integer, ForceX As Double, ForceY As Double, Moment As Double)
    Declare Function sprint() As String
    Declare Sub cprint()
    Declare Sub fprint(fp as integer)
    
End Type

Sub clsPfJointLoad.initialise()
  key = 0
  jt = 0
  fx = 0
  fy = 0
  mz = 0
End Sub

Sub clsPfJointLoad.setValues(LoadKey As Integer, Node As Integer, ForceX As Double, ForceY As Double, Moment As Double)
  key = LoadKey
  jt = Node
  fx = ForceX
  fy = ForceY
  mz = Moment
End Sub

Function clsPfJointLoad.sprint() As String
      sprint = StrLPad(Format(key, "##0"), 8) _
               & StrLPad(Format(jt, "##0"), 6) _
               & StrLPad(Format(fx, "0.000"), 15) _
               & StrLPad(Format(fy, "0.000"), 15) _
               & StrLPad(Format(mz, "0.000"), 15)
End Function

Sub clsPfJointLoad.cprint()
  print sprint
End Sub

Sub clsPfJointLoad.fprint(fp as integer)
      Print #fp, sprint
End Sub

