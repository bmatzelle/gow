;--------------------------------
; Gow installer
; Web Site: http://gow.sourceforge.net/
; Author: Brent R. Matzelle
; Copyright 2006 Brent R. Matzelle
;--------------------------------


;--------------------------------
; Constants

  !define PRODUCT "Gow"
  !define VERSION "0.2.0"
  !define SRC_DIR ".."

  Name "${PRODUCT}"
  SetCompressor zlib
  BrandingText "${PRODUCT} Installer - powered by NSIS"

  !include "MUI.nsh" ; Include Modern UI

;--------------------------------
; Variables

  Var MUI_TEMP
  Var STARTMENU_FOLDER

;--------------------------------
; Pages

  !insertmacro MUI_PAGE_LICENSE "${SRC_DIR}\GPL-License.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY

  ; Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU"
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Modern UI Test"
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
  !insertmacro MUI_PAGE_STARTMENU Application $STARTMENU_FOLDER

  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
; Language

  !insertmacro MUI_LANGUAGE "English"

  OutFile "${PRODUCT}-${VERSION}.exe" ; Installer file name
  ShowInstDetails nevershow
  ShowUninstDetails nevershow

;--------------------------------
; Descriptions

  LangString DESC_Core ${LANG_ENGLISH} "Installs the core components"
  LangString DESC_CommandPrompt ${LANG_ENGLISH} "Installs Command Prompt Here"

  InstallDir "$PROGRAMFILES\${PRODUCT}"
  InstType "Default installation"
  InstType "Minimal installation"

;--------------------------------
; Installer Sections

; Core components
Section "Core Components" SecCore
  SectionIn 1 2 RO
  AddSize 10240

  Call Install
SectionEnd

; Command Prompt here
Section "Command Prompt Here" DESC_CommandPrompt
  SectionIn 1
  AddSize 0

  Call RegistryCommandPrompt
SectionEnd

;--------------------------------
; Install Functions

; Configures the installation
Function Configure
  StrCpy $R0 "cscript //NoLogo"
  nsExec::Exec '$R0 "$INSTDIR\setup\PathSetup.vbs" --path-add "$INSTDIR\bin"'

  IfErrors done
  FileOpen $R1 "$INSTDIR\bin\gow.bat" w
  FileWrite $R1 "@echo off $\r$\n"
  FileWrite $R1 '$R0 "$INSTDIR\bin\gow.vbs" "C:\Program Files\Gow\bin" %1'
  FileClose $R1

  done:
FunctionEnd

; Installs all files
Function Files
  ; License, changelog, and readme files
  SetOutPath "$INSTDIR"
  File "${SRC_DIR}\*.txt"

  ; Executables
  SetOutPath "$INSTDIR\bin"
  File "${SRC_DIR}\bin\*.exe"
  File "${SRC_DIR}\bin\*.bat"
  File "${SRC_DIR}\bin\*.vbs"

  ; Documentation directory
  SetOutPath "$INSTDIR"
  File /r "${SRC_DIR}\docs"

  ; Setup files
  SetOutPath "$INSTDIR\setup"
  File /r "${SRC_DIR}\setup\*.vbs"
FunctionEnd

; Starts the installation
Function Install
  Call Files
  Call Registry
  Call Configure
  Call Shortcuts
FunctionEnd

; Create the necessary registry entries
Function Registry
  ; Write Registry settings for Add/Remove
  WriteRegStr HKLM "SOFTWARE\${PRODUCT}" "" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" \
                   "DisplayName" "${PRODUCT}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" \
                   "UninstallString" '"$INSTDIR\Uninstall.exe"'
FunctionEnd

; Add the Command Prompt Here entry
Function RegistryCommandPrompt
  StrCpy $R0 'Folder\shell\Command Prompt Here ${PRODUCT}'
  WriteRegStr HKCR $R0 "" "Command Prompt &Here"
  WriteRegExpandStr HKCR "$R0\command" "" '"%SystemRoot%\system32\cmd.exe" /k cd /d "%1"'
FunctionEnd

; Set the shortcuts
Function Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application

  ; License shortcuts
  SetOutPath "$SMPROGRAMS\$STARTMENU_FOLDER\Licenses"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Licenses\GPL.lnk" \
                 "$INSTDIR\GPL-License.txt"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Licenses\NcFTP.lnk" \
                 "$INSTDIR\NcFTP-License.txt"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Licenses\Putty.lnk" \
                 "$INSTDIR\Putty-License.txt"

  ; General shortcuts
  SetOutPath "$SMPROGRAMS\$STARTMENU_FOLDER"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\ChangeLog.lnk" \
                 "$INSTDIR\ChangeLog.txt"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\ReadMe.lnk" \
                 "$INSTDIR\ReadMe.txt"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Uninstall ${PRODUCT}.lnk" \
                 "$INSTDIR\Uninstall.exe"

  !insertmacro MUI_STARTMENU_WRITE_END

FunctionEnd

;--------------------------------
; Post installation methods

Function .onInstSuccess
  Delete "$INSTDIR\Uninstall.exe" ; Delete old uninstaller first
  WriteUninstaller "$INSTDIR\Uninstall.exe"
FunctionEnd

;--------------------------------
; Descriptions

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} $(DESC_Core)
  !insertmacro MUI_DESCRIPTION_TEXT ${DESC_CommandPrompt} $(DESC_CommandPrompt)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Uninstaller Section

Section "Uninstall"
  Call un.Configure
  Call un.Files
  Call un.Registry

  ; If not reboot then jump to end
  IfRebootFlag 0 EndNow
  MessageBox MB_YESNO|MB_ICONQUESTION \
              "Some components could not be fully uninstalled.  You will \
              need to $\nreboot your computer in order to remove them fully. \
              Reboot now?" IDNO EndNow
  Reboot

  EndNow:
SectionEnd

; Remove all configuration
Function un.Configure
  StrCpy $R0 'cscript //NoLogo "$INSTDIR\setup\PathSetup.vbs"'
  nsExec::Exec '$R0 --path-remove "$INSTDIR\bin"'
FunctionEnd

; Remove all files
Function un.Files
  RMDir /r "$INSTDIR"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP

  Delete "$SMPROGRAMS\$MUI_TEMP\Uninstall.lnk"

  RMDir /r "$SMPROGRAMS\$MUI_TEMP"
FunctionEnd

; Remove the registry settings
Function un.Registry
  Call un.RegistryCommandPrompt

  ; Delete registry settings
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}"
  DeleteRegKey HKLM "SOFTWARE\${PRODUCT}"
  DeleteRegKey HKLM "SYSTEM\CurrentControlSet\Services\EventLog\Application\${PRODUCT}"
FunctionEnd

; Remove Command Prompt Here
Function un.RegistryCommandPrompt
  DeleteRegKey HKCR "Folder\shell\Command Prompt Here ${PRODUCT}"
FunctionEnd
