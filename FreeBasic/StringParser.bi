'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'-------------------------------------------------------------------------------
'INTERFACE
'-------------------------------------------------------------------------------


Declare Sub parseString(dataStr As String, FieldValues() As String, fieldCount As Integer)
Declare Sub parseDelimitedString(dataStr As String, FieldValues() As String, BYREF fieldCount As Integer, delimitChar As String)
Declare Sub parseTagDelimitedString(dataStr As String, FieldValues() As String, fieldCount As Integer, TagStr As String)
Declare Sub testparseString()
