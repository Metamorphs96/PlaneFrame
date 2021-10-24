'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'INTERFACE
'-------------------------------------------------------------------------------


'Option Explicit
'#Const isUsingExcel = 1

#include once "FileMngt.bi"

Type clsProjectData
    Public: ProjectKey As Integer
    
    Public: HdrTitle1 As String
    Public: LoadCase As String
    Public: ProjectID As String
    Public: Author As String
    Public: runNumber As Integer
    
    Declare Sub initialise()
    Declare Sub cprint()
    Declare Sub fprint(fp as integer)
    Declare Sub fgetData(fp as integer)
End Type

Sub clsProjectData.initialise()
 print "Project:initialise"
 ProjectKey = 0

 HdrTitle1 = ""
 LoadCase = ""
 ProjectID = ""
 Author = ""
 runNumber = 0

End Sub

Sub clsProjectData.cprint()
  print HdrTitle1
  print LoadCase
  print ProjectID
  print Author
  print runNumber
End Sub

Sub clsProjectData.fprint(fp as integer)
  Print #fp, HdrTitle1
  Print #fp, LoadCase
  Print #fp, ProjectID
  Print #fp, Author
  Print #fp, runNumber
End Sub

Sub clsProjectData.fgetData(fp as integer)
  Dim i As Integer

  print "fgetData ..."
  
  HdrTitle1 = ReadLine(fp)
  LoadCase = ReadLine(fp)
  ProjectID = ReadLine(fp)
  Author = ReadLine(fp)
  runNumber = CInt(ReadLine(fp))
  
  print "... fgetData"
End Sub
