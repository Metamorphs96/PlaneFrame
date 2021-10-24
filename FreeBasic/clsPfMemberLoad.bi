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

Type clsPfMemberLoad
    Public: key As Integer
    
    Public: mem_no As Byte
    Public: lcode As Byte
    Public: f_action As Byte
    Public: ld_mag1 As Double     '.. member load magnitude 1 ..
    Public: ld_mag2 As Double     '.. member load magnitude 2 ..
    Public: start As Double       '.. dist from end_1 to start/centroid of load ..
    Public: cover  As Double      '.. dist that a load covers ..
    
    Declare Sub initialise()
    Declare Sub setValues(LoadKey As Integer, memberKey As Integer, LoadType As Integer, ActionKey As Integer, LoadMag1 As Double, LoadStart As Double, LoadCover As Double)
    Declare Function sprint() As String
    Declare Sub cprint()
    Declare Sub fprint(fp as integer)
    
End Type


Sub clsPfMemberLoad.initialise()
  mem_no = 0
  lcode = 0
  f_action = 0
  ld_mag1 = 0
  ld_mag2 = 0
  start = 0
  cover = 0
End Sub

Sub clsPfMemberLoad.setValues(LoadKey As Integer, memberKey As Integer, LoadType As Integer, ActionKey As Integer _
                         , LoadMag1 As Double, LoadStart As Double, LoadCover As Double)
                         
  key = LoadKey
  mem_no = memberKey
  lcode = LoadType
  f_action = ActionKey
  ld_mag1 = LoadMag1
  ld_mag2 = LoadMag1
  'ld_mag2 = LoadMag2 'xla version only
  start = LoadStart
  cover = LoadCover
End Sub

Function clsPfMemberLoad.sprint() As String
  sprint = StrLPad(Format(key, "##0"), 8) _
             & StrLPad(Format(mem_no, "##0"), 6) _
             & StrLPad(Format(lcode, "##0"), 6) _
             & StrLPad(Format(f_action, "##0"), 6) _
             & StrLPad(Format(ld_mag1, "0.000"), 15) _
             & StrLPad(Format(start, "0.000"), 15) _
             & StrLPad(Format(cover, "0.000"), 12)

End Function

Sub clsPfMemberLoad.cprint()
  print sprint
End Sub

Sub clsPfMemberLoad.fprint(fp as integer)
  Print #fp, sprint

End Sub
