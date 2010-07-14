'------------------------------------------------
' Gow
' Prints out all of the executables. 
' Author: Brent R. Matzelle
'------------------------------------------------
Option Explicit

'------------------------------------------------
' Adds a path to the environment variable.  
Sub ExecutablesList(path)
  Dim fileSys, folder, file, index, line
  
  line = "  "
  Set fileSys = CreateObject("Scripting.FileSystemObject")
  Set folder = filesys.GetFolder(path)

  For Each file In folder.Files
    If IsExecutable(file) Then
      If (Len(line) + Len(file.Name)) >= 78 Then
        WScript.Echo line
        line = "  "
      End If
      line = line & Left(file.Name, Len(file.Name) - 4) & ", "
    End If
  Next
  
  WScript.Echo Left(line, Len(line) - 2)
End Sub

'------------------------------------------------
' Returns true if the file is an executable. 
Function IsExecutable(file)
  Dim result
  result = false

  If Len(file) > 4 Then
    result = (Right(file, 4) = ".exe")
    
    If result = False Then
      result = (Right(file, 4) = ".bat")
    End If
  End If
  
  IsExecutable = result
End Function

'------------------------------------------------
' Main sub-routine
Sub Main()
  If Wscript.Arguments.Count < 1 Then
    Call PrintUsage("")
    Exit Sub
  End If
  
  WScript.Echo "Available executables:"
  WScript.Echo ""
  ExecutablesList(Wscript.Arguments(0))
End Sub

'------------------------------------------------
' Prints out the normal program usage parameters
Sub PrintUsage(message)
  Dim usage
  
  If Len(message) > 0 Then
    usage = message & Chr(10)
  End If

  Wscript.Echo usage
End Sub

' Start program here
Call Main()
