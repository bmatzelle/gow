'------------------------------------------------
' PathSetup
' Configures the path environment variable. 
' Author: Brent R. Matzelle
'------------------------------------------------
Option Explicit

'------------------------------------------------
' Main sub-routine
Sub Main()
  If Wscript.Arguments.Count < 1 Then
    Call PrintUsage("Incorrect parameters")
    Exit Sub
  End If

  Select Case Wscript.Arguments(0)
    Case "--path-add", "-a" 
      Call PathAdd(Wscript.Arguments(1))
    Case "--path-remove", "-r" 
      Call PathRemove(Wscript.Arguments(1))
    Case "--help", "-h"
      Call PrintUsage("")
    Case Else
      Call PrintUsage("That command is unknown")
  End Select
End Sub

'------------------------------------------------
' Adds a path to the environment variable.  
Sub PathAdd(path)
  If PathIsPresent(path) Then
    Exit Sub
  End If

  ' Get the value of the PATH environment variable
  Dim script, shell, newPath, oldPath
  Set script = Wscript.CreateObject("Wscript.Shell")
  Set shell = script.Environment("SYSTEM")
  
  oldPath = shell("Path")
  newPath = oldPath & ";" & path
  
  shell("Path") = newPath
End Sub

'------------------------------------------------
' Checks if the path is already present. 
Function PathIsPresent(path)
  Dim script, shell, currentPath
  Set script = Wscript.CreateObject("Wscript.Shell")
  Set shell = script.Environment("SYSTEM")
  
  currentPath = shell("Path")
  
  PathIsPresent = (InStr(LCase(currentPath), LCase(path)) <> 0)
End Function

'------------------------------------------------
' Removes a path from the environment variable. 
Sub PathRemove(path)
  If Not PathIsPresent(path) Then
    Exit Sub
  End If

  ' Get the value of the PATH environment variable
  Dim script, shell, newPath, oldPath
  Set script = Wscript.CreateObject("Wscript.Shell")
  Set shell = script.Environment("SYSTEM")
  
  oldPath = shell("Path")
  newPath = Replace(oldPath, ";" & path, "")
  
  If Len(newPath) < 5 Then
    PrintError("Could not remove that path variable")
  End If
  
  shell("Path") = newPath
End Sub

'------------------------------------------------
' Exits the script with an error. 
Sub PrintError(message)
  Wscript.Echo "An error occurred:" & Chr(10) & message
  WScript.Quit(1)
End Sub

'------------------------------------------------
' Prints out the normal program usage parameters
Sub PrintUsage(message)
  Dim usage
  
  If Len(message) > 0 Then
    usage = message & Chr(10)
  End If

  usage = "Path Setup" & Chr(10) & usage & Chr(10) & "Usage: " & _
          "cscript.exe PathSetup.vbs [OPTIONS]" & Chr(10) & Chr(10) & _
          "Options:" & Chr(10) & _
          "  --path-add [PATH]" & Chr(10) & _
          "  --path-remove [PATH]" & Chr(10) & _
          "  --help" & Chr(10)
  Wscript.Echo usage
End Sub

' Start program here
Call Main()
