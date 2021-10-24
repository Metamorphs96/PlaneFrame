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



Type clsPfMaterial
  Public: key As Integer
  
  Public: density As Double     '.. density ..
  Public: emod As Double           '.. elastic Modulus ..
  Public: therm As Double          '.. coeff of thermal expansion..}
  
    Declare Sub initialise()
    Declare Sub setValues(materialKey As Integer, massDensity As Double, ElasticModulus As Double, CoeffThermExpansion As Double)
    Declare Function sprint() As String
    Declare Sub cprint()
    Declare Sub fprint(fp as integer)
  
End Type


Sub clsPfMaterial.initialise()
  density = 0
  emod = 0
  therm = 0
End Sub

Sub clsPfMaterial.setValues(materialKey As Integer, massDensity As Double, ElasticModulus As Double, CoeffThermExpansion As Double)
  key = materialKey
  density = massDensity
  emod = ElasticModulus
  therm = CoeffThermExpansion
End Sub

Function clsPfMaterial.sprint() As String
      sprint = StrLPad(Format(key, "##0"), 8) _
               & StrLPad(Format(density, "0.00"), 15) _
               & StrLPad(Format(emod, "0.00E+00"), 15) _
               & StrLPad(Format(therm, "0.0000E+00"), 15)

End Function

Sub clsPfMaterial.cprint()
  print sprint
End Sub

Sub clsPfMaterial.fprint(fp as integer)
  Print #fp, sprint
End Sub

