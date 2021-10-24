'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit

Function HigherPrefixes(x,NumberDecimals,TensExponent)
	Dim PowerTen,TensBase
	Dim N
	Dim i
	
	TensBase = 10^TensExponent
	PowerTen = TensBase
	i = 0
	Do
		i = i + 1
		N = x / PowerTen
		PowerTen = PowerTen * TensBase
	Loop Until (Abs(N)<TensBase)
	HigherPrefixes = FormatNumber(N,NumberDecimals) & "E" & FormatNumber(TensExponent*i,0)
	
End Function

Function LowerPrefixes(x,NumberDecimals,TensExponent)
	Dim PowerTen,TensBase
	Dim N
	Dim i
	
	TensBase = 10^TensExponent
	PowerTen = TensBase
	i = 0
	Do
		i = i + 1
		N = x * PowerTen
		PowerTen = PowerTen * TensBase
	Loop Until (Abs(N)>=1)
	LowerPrefixes = FormatNumber(N,NumberDecimals) & "E" & FormatNumber(-TensExponent*i,0)
End Function

Function FormatEngineeringNotation(x,NumberDecimals)
	If Abs(x) > 1000 Then
		'Higher Prefixes
		FormatEngineeringNotation = HigherPrefixes(x,NumberDecimals,3)
	ElseIf Abs(x) < 1 Then
		'Lower Prefixes
		FormatEngineeringNotation = LowerPrefixes(x,NumberDecimals,3)
	Else
		'No Prefix
		FormatEngineeringNotation =FormatNumber(x,NumberDecimals) 
	End If
End Function

Function FormatScientific(x,NumberDecimals)
	If Abs(x) > 10 Then
		'Higher Prefixes
		FormatScientific = HigherPrefixes(x,NumberDecimals,1)
	ElseIf Abs(x) < 1 Then
		'Lower Prefixes
		FormatScientific = LowerPrefixes(x,NumberDecimals,1)
	Else
		'No Prefix
		FormatScientific =FormatNumber(x,NumberDecimals) 
	End If
End Function
