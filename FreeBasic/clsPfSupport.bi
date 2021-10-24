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


Type clsPfSupport
    Public: key As Integer
    Public: js  As Byte
    Public: rx As Byte            '.. joint X directional restraint ..
    Public: ry As Byte            '.. joint Y directional restraint ..
    Public: rm As Byte            '.. joint Z rotational restraint ..
    
    Declare Sub initialise()
    Declare Sub setValues(supportKey As Integer, SupportNode As Integer, RestraintX As Byte, RestraintY As Byte, RestraintMoment As Byte)
    Declare Function sprint() As String
    Declare Sub cprint()
    Declare Sub fprint(fp as Integer)
    
End Type

Sub clsPfSupport.initialise()
  js = 0
  rx = 0
  ry = 0
  rm = 0
End Sub

Sub clsPfSupport.setValues(supportKey As Integer, SupportNode As Integer, RestraintX As Byte, RestraintY As Byte, RestraintMoment As Byte)
  key = supportKey
  js = SupportNode
  rx = RestraintX
  ry = RestraintY
  rm = RestraintMoment
End Sub


Function clsPfSupport.sprint() As String
  sprint = StrLPad(Format(key, "##0"), 8) _
           & StrLPad(Format(js, "##0"), 6) _
           & StrLPad(Format(rx, "##0"), 6) _
           & StrLPad(Format(ry, "##0"), 6) _
           & StrLPad(Format(rm, "##0"), 6)
End Function

Sub clsPfSupport.cprint()
  print sprint
End Sub

Sub clsPfSupport.fprint(fp as integer)
  Print #fp, sprint
End Sub
