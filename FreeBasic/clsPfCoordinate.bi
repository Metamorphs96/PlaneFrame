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

Type clsPfCoordinate
    Public: key As Integer
    Public: x As Double           '.. x-coord of a joint ..
    Public: y As Double           '.. y-coord of a joint ..
    
    Declare Sub initialise()
    Declare Sub setValues(ByVal nodeKey As Integer, ByVal x1 As Double, ByVal y1 As Double)
    Declare Function sprint() As String
    Declare Sub cprint()
    Declare Sub fprint(fp as integer)

End Type  

Sub clsPfCoordinate.initialise()
  key = 0
  x = 0
  y = 0
End Sub

Sub clsPfCoordinate.setValues(ByVal nodeKey As Integer, ByVal x1 As Double, ByVal y1 As Double)
    key = nodeKey
    x = x1
    y = y1
End Sub

Function clsPfCoordinate.sprint() As String
  sprint = StrLPad(Format(key, "###"), 8) & StrLPad(Format(x, "0.0000"), 12) & StrLPad(Format(y, "0.0000"), 12)
End Function

Sub clsPfCoordinate.cprint()
  print sprint
End Sub

Sub clsPfCoordinate.fprint(fp as integer)
  Print #fp, sprint
End Sub

