'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Option Explicit On

Public Class clsProjectData


#Const isUsingExcel = 0

    Public ProjectKey As Integer

    Public HdrTitle1 As String
    Public LoadCase As String
    Public ProjectID As String
    Public Author As String
    Public runNumber As Integer

    Sub initialise()
        ProjectKey = 0

        HdrTitle1 = ""
        LoadCase = ""
        ProjectID = ""
        Author = ""
        runNumber = 0

    End Sub

    Sub cprint()
        Console.WriteLine(HdrTitle1)
        Console.WriteLine(LoadCase)
        Console.WriteLine(ProjectID)
        Console.WriteLine(Author)
        Console.WriteLine(runNumber)
    End Sub

    Sub fprint(ByVal fp As Integer)
        Print(fp, HdrTitle1)
        Print(fp, LoadCase)
        Print(fp, ProjectID)
        Print(fp, Author)
        Print(fp, runNumber)
    End Sub

    Sub fgetData(ByVal fp As Integer)

        Console.WriteLine("fgetData ...")

        HdrTitle1 = Readln(fp)
        LoadCase = Readln(fp)
        ProjectID = Readln(fp)
        Author = Readln(fp)
        runNumber = Readln(fp)

        cprint()
        Console.WriteLine("... fgetData")
    End Sub

#If isUsingExcel = 1 Then

    Sub wbkPrint(ByVal dataSht As Worksheet)
        With dataSht
            .Range("HdrTitle1").Value = HdrTitle1
            .Range("LoadCase").Value = LoadCase
            .Range("project_id").Value = ProjectID
            .Range("Author").Value = Author
            .Range("RunNumber").Value = runNumber
        End With
    End Sub

    Sub wbkRead(ByVal dataSht As Worksheet)
        With dataSht
            HdrTitle1 = .Range("HdrTitle1").Value
            LoadCase = .Range("LoadCase").Value
            ProjectID = .Range("project_id").Value
            Author = .Range("Author").Value
            runNumber = .Range("RunNumber").Value
        End With
    End Sub

#End If


End Class
