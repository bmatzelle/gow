'------------------------------------------------
' Gow - The lightweight alternative to Cygwin
' Handles all tasks for the Gow project.  
' Author: Brent R. Matzelle
'------------------------------------------------
Option Explicit

' Adds a path to the environment variable.  
Sub ExecutablesList()
  Dim fileSys, folder, file, index, shell, line
  
  line = "  "
  Set fileSys = CreateObject("Scripting.FileSystemObject")

  Set folder = filesys.GetFolder(ScriptPath())

  Print "Available executables:"
  Print ""

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

' Main sub-routine
Sub Main()
  If Wscript.Arguments.Count < 1 Then
    PrintUsage
    Exit Sub
  End If

  Select Case Wscript.Arguments(0)
  Case "-l", "--list"
    Call ExecutablesList()
  Case "-V", "--version"
    Print("Gow " & Version())
  Case "-h", "--help"
    Call PrintUsage
  Case Else
    Print "UNKNOWN COMMAND: [" & WScript.Arguments(0) & "]"
    Print ""
    PrintUsage
  End Select
End Sub

' Prints out a message.  
Sub Print(message)
  Wscript.Echo message
End Sub

' Prints out the normal program usage parameters
Sub PrintUsage()
  Print "Gow " & Version() & " - The lightweight alternative to Cygwin"
  Print "Usage: gow OPTION"
  Print ""
  Print "Options:"
  Print "    -l, --list                       Lists all executables"
  Print "    -V, --version                    Prints the version"
  Print "    -h, --help                       Show this message"
End Sub

' Returns the path of the VBS script. 
Function ScriptPath
  ScriptPath = Replace(WScript.ScriptFullName, "\" & WScript.ScriptName, "")
End Function

' Prints out the version of Gow.  
Function Version()
  Version = "0.8.0"
End Function


'------------------------------------------------
' Start program here
Call Main()

