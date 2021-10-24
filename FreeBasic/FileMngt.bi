'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'INTERFACE
'-------------------------------------------------------------------------------


Declare Function FileExists(SearchSpec As String) As Boolean
Declare Function FirstFileFound(SearchSpec As String, fattr As Integer, foundname As String) As Boolean
Declare Function NextFileFound(foundname As String) As Boolean
Declare Sub fopenTXT(fp As Integer, fname As String, fmode As String)
Declare Function fopen(fname As String, fmode As String) As Integer
Declare Function ReadLine(fp as Integer) as string
