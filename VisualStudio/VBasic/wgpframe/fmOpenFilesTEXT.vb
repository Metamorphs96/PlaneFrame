'
' Copyright (c)2016 S C Harrison
' Refer to License.txt for terms and conditions of use.
'
Module fmOpenFilesTEXT

    '---------------------------------------------------------------------
    ' Deletes TEXT file if it exists and wish to start from scratch
    ' Otherwise leaves existing file alone, allowing PRINT to append
    ' to the end of the file
    '---------------------------------------------------------------------
    Function fopenTXT(ByVal fp As Integer, ByVal fname As String, ByVal fmode As String, ByVal AllowOverWrite As Boolean) As Boolean
        Dim FileOK As Boolean, isFileExist As Boolean

        FileOK = False

        On Error GoTo Err_fopenTXT

        isFileExist = My.Computer.FileSystem.FileExists(fname)

        Select Case LCase(fmode)
            Case "wt" 'if fmode = "wt" => create and open text file for writing
                If isFileExist Then
                    If AllowOverWrite Then
                        FileOpen(fp, fname, OpenMode.Output)
                        fopenTXT = True
                    Else
                        'Debug.Print "File Exists:", fname, "[Cannot OverWrite]"
                        fopenTXT = False
                    End If
                Else
                    FileOpen(fp, fname, OpenMode.Output)
                    fopenTXT = True
                End If

            Case "at" 'if fmode = "at" then append to end of file
                If isFileExist Then
                    FileOpen(fp, fname, OpenMode.Append)
                    fopenTXT = True
                Else
                    'Debug.Print "File Does NOT Exist:", fname, "[Cannot Append]"
                    fopenTXT = False
                End If

            Case "rt" 'if fmode = "rt" then read text file
                If isFileExist Then
                    FileOpen(fp, fname, OpenMode.Input)
                    fopenTXT = True
                Else
                    Console.WriteLine("File Does NOT Exist: " + fname + " [Cannot Read]")
                    Console.WriteLine(My.Computer.FileSystem.CurrentDirectory)
                    fopenTXT = False
                End If

        End Select

Exit_fopenTXT:
        Exit Function

Err_fopenTXT:
        FileClose()
        Console.WriteLine("Errors! " + "(fopenTXT)" +  format(Err.Number,"0") + Err.Description)
        fopenTXT = False

    End Function

    Function fopen(ByVal fname As String, ByVal fmode As String, ByVal AllowOverWrite As Boolean) As Integer
        Dim fp As Integer

        On Error GoTo Err_fopen

        fp = FreeFile() '(1)

        If fp <> 0 Then
            If fopenTXT(fp, fname, fmode, AllowOverWrite) Then
                fopen = fp
            Else
                fopen = 0
            End If
        Else
            fopen = 0
        End If

Exit_fopen:
        Exit Function
Err_fopen:
        FileClose()
        frmTracer.txtTracer.Text = frmTracer.txtTracer.Text & vbCrLf & "Errors! " + "(fopen)" +  format(Err.Number,"0") + Err.Description
        Resume Exit_fopen
    End Function

End Module
