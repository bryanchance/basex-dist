!define JAR "BaseX.jar"
!define PRODUCT_NAME "BaseX"
!define PRODUCT_PUBLISHER "BaseX Team"
!define PRODUCT_WEB_SITE "http://basex.org"
!define PRODUCT_WEB_DOCS "http://docs.basex.org"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${JAR}"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define ALPHA "abcdefghijklmnopqrstuvwxyz1234567890"
!define BETA "abcdefghijklmnopqrstuvwxyz1234567890\/:"
!define NUMERIC "1234567890"
RequestExecutionLevel admin

; MUI 1.67 compatible ------
!include "MUI.nsh"
!include "FileFunc.nsh"
!include "FileAssociation.nsh"
!include "Environment.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "..\images\BaseX.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_FINISHPAGE_NOAUTOCLOSE
Function .onInit
!insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "Options.ini" "Options"
FunctionEnd

!macro IndexOf Var Str Char
Push "${Char}"
Push "${Str}"
 Call IndexOf
Pop "${Var}"
!macroend

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; check jre page
Page custom CheckInstalledJRE
; License page
!define MUI_LICENSEPAGE_RADIOBUTTONS
!insertmacro MUI_PAGE_LICENSE "..\license.txt"
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Custom page
Page custom OptionsPage OptionsLeave
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION run_basex
!insertmacro MUI_PAGE_FINISH

Function run_basex
  nsExec::Exec '"$INSTDIR\BaseX.exe"'
FunctionEnd

Function CheckInstalledJRE
  ReadRegStr $1 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion"
  ${If} $1 == ""
    SetRegView 64 
    ReadRegStr $1 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion"
    ${If} $1 == ""
      MessageBox MB_OK "Please install Java before executing the installer."
      Quit
    ${EndIf}
  ${EndIf}
FunctionEnd

Function WriteToFile
 Exch $0 ;file to write to
 Exch
 Exch $1 ;text to write
 
  FileOpen $0 $0 a #open file
   FileSeek $0 0 END #go to end
   FileWrite $0 $1 #write to file
  FileClose $0
 
 Pop $1
 Pop $0
FunctionEnd
 
!macro WriteToFile String File
 Push "${String}"
 Push "${File}"
  Call WriteToFile
!macroend
!define WriteToFile "!insertmacro WriteToFile"

# CUSTOM PAGE.
# =========================================================================
#
Function OptionsPage
Delete $INSTDIR\bin\basexhttp.bat
!insertmacro MUI_HEADER_TEXT "Installation Options" "Choose optional settings for the BaseX installation."
# Display the page.
!insertmacro MUI_INSTALLOPTIONS_DISPLAY "Options"
FunctionEnd

Function OptionsLeave
# Get the user entered values.
# first password field
!insertmacro MUI_INSTALLOPTIONS_READ $R0 "Options" "Field 7" "State"
# second password field
!insertmacro MUI_INSTALLOPTIONS_READ $R1 "Options" "Field 8" "State"
# serverport field
!insertmacro MUI_INSTALLOPTIONS_READ $R2 "Options" "Field 9" "State"
# HTTP port field
!insertmacro MUI_INSTALLOPTIONS_READ $R3 "Options" "Field 10" "State"
# dbpath field
!insertmacro MUI_INSTALLOPTIONS_READ $R4 "Options" "Field 6" "State"
# Admin password modification
${If} $R1 == $R0
  Push "$R1"
  Push "${ALPHA}"
  Call Validate
  Pop $0
  ${If} $0 == 0
    MessageBox MB_OK "Passwords contain invalid characters."
    Abort    
  ${EndIf}
${Else}
  MessageBox MB_OK "Passwords do not match."
  Abort
${EndIf}
# Server port check
${If} $R2 != "1984"
  Push "$R2"
  Push "${NUMERIC}"
  Call Validate
  Pop $0
  ${If} $0 == 0
    MessageBox MB_OK "Server port contains invalid characters."
    Abort
  ${EndIf}
${EndIf}
# HTTP port check
${If} $R3 != "8984"
  Push "$R3"
  Push "${NUMERIC}"
  Call Validate
  Pop $0
  ${If} $0 == 0
    MessageBox MB_OK "HTTP port contains invalid characters."
    Abort
  ${EndIf}
${EndIf}
# DBPATH check
${If} $R4 != "data"
  Push "$R4"
  Push "${BETA}"
  Call Validate
  Pop $0
  ${If} $0 == 0
    MessageBox MB_OK "Database Path contains invalid characters."
    Abort
  ${EndIf}
${EndIf}
# xq field
!insertmacro MUI_INSTALLOPTIONS_READ $R5 "Options" "Field 3" "State"
# xml field
!insertmacro MUI_INSTALLOPTIONS_READ $R6 "Options" "Field 5" "State"
# .xq file Association
        ${If} $R5 == 1
          ${registerExtension} "$INSTDIR\${PRODUCT_NAME}.exe" ".xq" "XQuery File"
          ${registerExtension} "$INSTDIR\${PRODUCT_NAME}.exe" ".xqm" "XQuery File"
          ${registerExtension} "$INSTDIR\${PRODUCT_NAME}.exe" ".xqy" "XQuery File"
          ${registerExtension} "$INSTDIR\${PRODUCT_NAME}.exe" ".xquery" "XQuery File"
          ${registerExtension} "$INSTDIR\${PRODUCT_NAME}.exe" ".xql" "XQuery Library"
        ${EndIf}
# .xml file Association
        ${If} $R6 == 1
          ${registerExtension} "$INSTDIR\${PRODUCT_NAME}.exe" ".xml" "XML Document"
        ${EndIf}
        ${RefreshShellIcons}
FunctionEnd

; Language files
!insertmacro MUI_LANGUAGE "English"
; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; MUI end ------

Name "${PRODUCT_NAME}"
OutFile "Setup.exe"
InstallDir "$PROGRAMFILES\BaseX"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "Hauptgruppe" SEC01
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File "..\release\BaseX.exe"
  CreateDirectory "$INSTDIR\etc"
  SetOutPath "$INSTDIR\etc"
  File "..\etc\*"
  CreateDirectory "$INSTDIR\bin"
  SetOutPath "$INSTDIR\bin"
  File "..\release\bin\*.bat"
  CreateDirectory "$INSTDIR\http"
  SetOutPath "$INSTDIR\http"
  File "..\http\*"
  CreateDirectory "$INSTDIR\lib"
  SetOutPath "$INSTDIR\lib"
  File "..\release\basex-api.jar"
  File "..\..\basex-dist\lib\*"
  File "..\..\basex-api\lib\*"
  File "..\..\basex\lib\*"
  SetOutPath "$INSTDIR"
  File "..\release\${JAR}"
  File "..\..\basex\license.txt"
  File "..\..\basex\changelog.txt"
  File "..\readme.txt"
  File ".basex"
  CreateDirectory "$INSTDIR\ico"
  SetOutPath "$INSTDIR\ico"
  File "..\images\*.ico"
  CreateDirectory "$INSTDIR\repo"
  AccessControl::GrantOnFile "$INSTDIR" "(S-1-1-0)" "GenericRead + GenericWrite + GenericExecute + Delete"
  CreateDirectory "$INSTDIR\http"
  CreateDirectory "$INSTDIR\repo"
  # set dbpath, port and webport
  StrLen $0 $R4
  IntOp $0 $0 - 1
  StrCpy $2 $R4 1 $0
  ${If} $2 == "\"
    StrCpy $R4 $R4 -1
  ${EndIf}
  !insertmacro IndexOf $9 "$R4" ":"
  ${If} $9 == -1
    CreateDirectory "$INSTDIR\$R4"
    nsExec::Exec '"$INSTDIR\bin\basex.bat" "-Wc" "set dbpath \"$INSTDIR\$R4\"; set httppath \"$INSTDIR\http\"; set repopath \"$INSTDIR\repo\""'
  ${Else}
    CreateDirectory "$R4"
    nsExec::Exec '"$INSTDIR\bin\basex.bat" "-Wc" "set dbpath \"$R4\"; set httppath \"$INSTDIR\http\"; set repopath \"$INSTDIR\repo\""'
  ${EndIf}
  nsExec::Exec '"$INSTDIR\bin\basex.bat" "-Wc" "set port $R2; set serverport $R2; set httpport $R3"'

  md5dll::GetMD5String "$R0"
  Pop $0
  # change admin password
  nsExec::Exec '"$INSTDIR\bin\basex.bat" "-c" "alter user admin $0"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BaseX" \
                 "DisplayName" "BaseX"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BaseX" \
                 "DisplayIcon" "$\"$INSTDIR\BaseX.ico$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BaseX" \
                 "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  ${EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\bin"  ; Remove path of old rev
  ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR\bin"  ; Append the new one
SectionEnd

Section -AdditionalIcons
  SetOutPath "$INSTDIR"
  SetOverwrite try
  # desktop shortcut
  !insertmacro MUI_INSTALLOPTIONS_READ $R7 "Options" "Field 2" "State"
  # startmenu
  !insertmacro MUI_INSTALLOPTIONS_READ $R8 "Options" "Field 4" "State"
  ${If} $R7 == 1
    CreateShortCut "$DESKTOP\BaseX GUI.lnk" "$INSTDIR\BaseX.exe" "" "$INSTDIR\ico\BaseX.ico" 0
  ${EndIf}
  ${If} $R8 == 1
    CreateDirectory "$SMPROGRAMS\BaseX"
    CreateShortCut "$SMPROGRAMS\BaseX\BaseX GUI.lnk" "$INSTDIR\BaseX.exe" "" "$INSTDIR\ico\BaseX.ico" 0
    CreateShortCut "$SMPROGRAMS\BaseX\BaseX Server (Start).lnk" "$INSTDIR\bin\basexhttp.bat" "-S" "$INSTDIR\ico\start.ico" 0
    CreateShortCut "$SMPROGRAMS\BaseX\BaseX Server (Stop).lnk" "$INSTDIR\bin\basexhttp.bat" "stop" "$INSTDIR\ico\stop.ico" 0
    CreateShortCut "$SMPROGRAMS\BaseX\BaseX Client.lnk" "$INSTDIR\bin\basexclient.bat" "" "$INSTDIR\ico\shell.ico" 0
    CreateShortCut "$SMPROGRAMS\BaseX\BaseX Standalone.lnk" "$INSTDIR\bin\basex.bat" "" "$INSTDIR\ico\shell.ico" 0
    WriteINIStr "$SMPROGRAMS\BaseX\BaseX Documentation.url" "InternetShortcut" "URL" "${PRODUCT_WEB_DOCS}"
    CreateShortCut "$SMPROGRAMS\BaseX\Uninstall BaseX.lnk" "$INSTDIR\uninst.exe"
  ${EndIf}
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) has been uninstalled from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Uninstall all components of $(^Name) ?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Delete "$DESKTOP\BaseX GUI.lnk"
  RMDir /r "$SMPROGRAMS\BaseX"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BaseX"
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BaseX"
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\bin"
  ${unregisterExtension} ".xq" "XQuery File"
  ${unregisterExtension} ".xqm" "XQuery File"
  ${unregisterExtension} ".xqy" "XQuery File"
  ${unregisterExtension} ".xquery" "XQuery File"
  ${unregisterExtension} ".xql" "XQuery Library"
  ${unregisterExtension} ".xml" "XML Document"
  ${RefreshShellIcons}
  SetAutoClose true
SectionEnd

Function Validate
  Push $0
  Push $1
  Push $2
  Push $3 ;value length
  Push $4 ;count 1
  Push $5 ;tmp var 1
  Push $6 ;list length
  Push $7 ;count 2
  Push $8 ;tmp var 2
  Exch 9
  Pop $1 ;list
  Exch 9
  Pop $2 ;value
  StrCpy $0 1
  StrLen $3 $2
  StrLen $6 $1
  StrCpy $4 0
  lbl_loop:
    StrCpy $5 $2 1 $4
    StrCpy $7 0
    lbl_loop2:
      StrCpy $8 $1 1 $7
      StrCmp $5 $8 lbl_loop_next 0
      IntOp $7 $7 + 1
      IntCmp $7 $6 lbl_loop2 lbl_loop2 lbl_error
  lbl_loop_next:
  IntOp $4 $4 + 1
  IntCmp $4 $3 lbl_loop lbl_loop lbl_done
  lbl_error:
  StrCpy $0 0
  lbl_done:
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Exch 2
  Pop $7
  Pop $8
  Exch $0
FunctionEnd

Function IndexOf
Exch $0
Exch
Exch $1
Push $2
Push $3
 
 StrCpy $3 $0
 StrCpy $0 -1
 IntOp $0 $0 + 1
  StrCpy $2 $3 1 $0
  StrCmp $2 "" +2
  StrCmp $2 $1 +2 -3
 
 StrCpy $0 -1
 
Pop $3
Pop $2
Pop $1
Exch $0
FunctionEnd
