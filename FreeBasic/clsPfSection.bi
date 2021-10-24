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

Type clsPFSection
  Public: key As Integer
  
  Public: ax As Double          '.. member's cross sectional area ..
  Public: iz  As Double         '.. member's second moment of area ..
  
  'Dependent on Material Properties
  Public: t_len As Double       '.. TOTAL length of this section ..
  Public: t_mass As Double      '.. TOTAL mass of this section ..
  Public: mat As Byte           '.. material of section ..
  
  Public: Descr As String       '.. section description string ..
  
    Declare Sub initialise()
    Declare Sub setValues(sectionKey As Integer, SectionArea As Double, SecondMomentArea As Double, materialKey As Integer, Description As String)
    Declare Function sprint() As String
    Declare Sub cprint()
    Declare Sub fprint(fp as integer)
  

End Type


Sub clsPFSection.initialise()
  ax = 0
  iz = 0
  t_len = 0
  t_mass = 0
  mat = 0
  Descr = "<unknown>"
End Sub

Sub clsPFSection.setValues(sectionKey As Integer, SectionArea As Double, SecondMomentArea As Double, materialKey As Integer, Description As String)
  key = sectionKey
  ax = SectionArea
  iz = SecondMomentArea
  mat = materialKey
  Descr = Description
End Sub

Function clsPFSection.sprint() As String
      sprint = StrLPad(Format(key, "##0"), 8) _
               & StrLPad(Format(ax, "0.0000E+00"), 15) _
               & StrLPad(Format(iz, "0.0000E+00"), 15) _
               & StrLPad(Format(mat, "##0"), 6) _
               & StrLPad(Descr, 28)

End Function


Sub clsPFSection.cprint()
  print sprint
End Sub

Sub clsPFSection.fprint(fp as integer)
  Print #fp, sprint
End Sub
