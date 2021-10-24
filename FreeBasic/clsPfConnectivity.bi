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
#include once "StringParser.bi"
#include once "FileMngt.bi"
#include once "clsPfForce.bi"

Type clsPfConnectivity
    Public: key As Integer
    
    Public: jj As Byte            '.. joint No. @ end "j" of a member ..  [na]
    Public: jk As Byte            '.. joint No. @ end "k" of a member ..  [nb]
    Public: sect As Byte          '.. section group of member ..          [ns]
    Public: rel_i As Byte         '.. end i release of member ..          [mra]
    Public: rel_j As Byte         '.. end j release of member ..          [mrb]
    Public: jnt_jj As clsPfForce
    Public: jnt_jk As clsPfForce
  
    Declare Sub initialise()
    Declare Sub setValues(memberKey As Integer, NodeA As Integer, NodeB As Integer, sectionKey As Integer, ReleaseA As Integer, ReleaseB As Integer)
    Declare Function sprint() As String
    Declare Sub cprint()
    Declare Sub fprint(fp as integer)
  
End Type

Sub clsPfConnectivity.initialise()
  jj = 0
  jk = 0
  sect = 0
  rel_i = 0
  rel_j = 0
  
  'jnt_jj = New clsPfForce
  jnt_jj.initialise
  
  'jnt_jk = New clsPfForce
  jnt_jk.initialise
    
End Sub

Sub clsPfConnectivity.setValues(memberKey As Integer, NodeA As Integer, NodeB As Integer, sectionKey As Integer, ReleaseA As Integer, ReleaseB As Integer)
  key = memberKey
  jj = NodeA
  jk = NodeB
  sect = sectionKey
  rel_i = ReleaseA
  rel_j = ReleaseB
End Sub

Function clsPfConnectivity.sprint() As String
     sprint = StrLPad(Format(key, "##0"), 8) _
              & StrLPad(Format(jj, "##0"), 6) _
              & StrLPad(Format(jk, "##0"), 6) _
              & StrLPad(Format(sect, "##0"), 6) _
              & StrLPad(Format(rel_i, "##0"), 6) _
              & StrLPad(Format(rel_j, "##0"), 2)

End Function


Sub clsPfConnectivity.cprint()

  print sprint
'  jnt_jj.cprint
'  jnt_jk.cprint

End Sub

Sub clsPfConnectivity.fprint(fp as integer)
  Print #fp, sprint
End Sub

