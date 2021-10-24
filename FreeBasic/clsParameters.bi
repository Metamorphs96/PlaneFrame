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


#include once "w7cpframe00.bi"

Type clsParameters
    Public: njt As Integer        '.. No. of joints ..
    Public: nmb As Integer        '.. No. of members ..
    Public: nmg As Integer        '.. No. of material groups ..
    Public: nsg As Integer        '.. No. of member section groups ..
    Public: nrj As Integer        '.. No. of supported reaction joints ..
    Public: njl As Integer        '.. No. of loaded joints ..
    Public: nml As Integer        '.. No. of loaded members ..
    Public: ngl As Integer        '.. No. of gravity load cases .. Self weight
    Public: nr  As Integer        '.. No. of restraints @ the supports ..
    
    Public: mag As Integer     '.. Magnification Factor for graphics
    
    Declare Function getInitValue(baseIndx As Integer) as integer
    Declare Sub initialise()
    Declare Function sprint() As String
    Declare Sub cprint()
    Declare Sub fprint(fp as integer)
    Declare Sub fgetData(fp as integer, isIgnore As Boolean)
    
End Type


Function clsParameters.getInitValue(baseIndx As Integer) as integer
  If baseIndx = 0 Then
    getInitValue = 0 '-1
  ElseIf baseIndx = 1 Then
    getInitValue = 0
  End If
End Function

Sub clsParameters.initialise()
    print "clsParameters: initialise ..."
    print "baseIndex:", baseIndex
    njt = getInitValue(baseIndex)
    nmb = getInitValue(baseIndex)
    nmg = getInitValue(baseIndex)
    nsg = getInitValue(baseIndex)
    nrj = getInitValue(baseIndex)
    njl = getInitValue(baseIndex)
    nml = getInitValue(baseIndex)
    ngl = getInitValue(baseIndex)
    nr = getInitValue(baseIndex)
    print "... initialise"
End Sub

Function clsParameters.sprint() As String
  sprint = StrLPad(Format(njt, "0"), 6) & StrLPad(Format(nmb, "0"), 6) _
          & StrLPad(Format(nrj, "0"), 6) & StrLPad(Format(nmg, "0"), 6) _
          & StrLPad(Format(nsg, "0"), 6) & StrLPad(Format(njl, "0"), 6) _
          & StrLPad(Format(nml, "0"), 6) & StrLPad(Format(ngl, "0"), 6) _
          & StrLPad(Format(mag, "0"), 6)

End Function

Sub clsParameters.cprint()
  print sprint
End Sub

Sub clsParameters.fprint(fp as integer)
  Print #fp, sprint
End Sub

Sub clsParameters.fgetData(fp as integer, isIgnore As Boolean)
  Dim s As String
  Dim n As Integer
  Dim dataflds(0 To 9) As String

  print "fgetData ..."
  
   s = Trim(ReadLine(fp))
   print s

   parseDelimitedString(s, dataflds(), n, " ")

  'typically ignore as all counters are incremented as data read
  'isIgnore=False only used to test parser.
  If isIgnore Then
    'Clear the control data, and count records as read data from file
    initialise
  Else
    njt = CInt(dataflds(0))
    nmb = CInt(dataflds(1))
    nrj = CInt(dataflds(2))
    nmg = CInt(dataflds(3))
    nsg = CInt(dataflds(4))
    njl = CInt(dataflds(5))
    nml = CInt(dataflds(6))
    ngl = CInt(dataflds(7))
  End If
 
  
  If dataflds(8) <> "" Then
    mag = CInt(dataflds(8))
  Else
    mag = 1
  End If
  
  print "Dimension & Geometry"
  print "-------------------------------"
  print "Number of Joints       : ", njt
  print "Number of Members      : ", nmb
  print "Number of Supports     : ", nrj
  
  print "Materials & Sections"
  print "-------------------------------"
  print "Number of Materials    : ", nmg
  print "Number of Sections     : ", nsg
  
  print "Design Actions"
  print "-------------------------------"
  print "Number of Joint Loads  : ", njl
  print "Number of Member Loads : ", nml
  print "Number of Gravity Loads : ", ngl
  
  print "Screen Magnifier: ", mag
 
  print "... fgetData"
End Sub

