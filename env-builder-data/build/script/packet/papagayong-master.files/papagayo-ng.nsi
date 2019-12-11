OutFile "..\papagayo-ng-installer.exe"
InstallDir "$PROGRAMFILES\Papagayo-NG"
Name "Papagayo-NG"

SetCompressor /final lzma
!include MUI2.nsh

Icon "papagayo-ng\papagayo-ng.ico"
UninstallIcon "papagayo-ng\papagayo-ng.ico"

LicenseData "papagayo-ng\gpl.txt"
!insertmacro MUI_PAGE_LICENSE "papagayo-ng\gpl.txt"

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

Section "Papagayo-NG (required)"
  SectionIn RO
  WriteRegStr HKLM "Software\$(^Name)" "Path" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" "DisplayName" "$(^Name)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" "HelpLink" "https://github.com/morevnaproject/papagayo-ng"

  WriteRegStr HKCR ".pgo" "" "Papagayo.Document"
  WriteRegStr HKCR "Papagayo.Document" "" "Papagayo Document"
  WriteRegStr HKCR "Papagayo.Document\DefaultIcon" "" "$INSTDIR\papagayo-ng\papagayo-ng.ico"
  WriteRegStr HKCR "Papagayo.Document\shell\open\command" "" '"$INSTDIR\papagayo-ng.bat" "%1"'

  SetOutPath $INSTDIR
  File /r /x papagayo-ng.nsi *
  WriteUninstaller "uninstall.exe"
SectionEnd

Section "Start Menu Shortcuts"
  SetShellVarContext all
  CreateDirectory "$SMPROGRAMS\$(^Name)"
  CreateShortCut "$SMPROGRAMS\$(^Name)\$(^Name).lnk" "$INSTDIR\papagayo-ng.bat" "" "$INSTDIR\papagayo-ng\papagayo-ng.ico"
  CreateShortCut "$SMPROGRAMS\$(^Name)\Uninstall $(^Name).lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\papagayo-ng\papagayo-ng.ico"
SectionEnd

Section "Uninstall"
  Var /GLOBAL testkey

  DeleteRegKey HKLM "Software\$(^Name)\"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"

  ReadRegStr $testkey HKCR "Papagayo.Document\DefaultIcon" ""
  StrCmp $testkey "$INSTDIR\papagayo-ng\papagayo-ng.ico" 0 +2
  DeleteRegKey HKCR "Papagayo.Document\DefaultIcon"

  ReadRegStr $testkey HKCR "Papagayo.Document\shell\open\command" ""
  StrCmp $testkey '"$INSTDIR\papagayo-ng.bat" "%1"' 0 +2
  DeleteRegKey HKCR "Papagayo.Document\shell\open\command"

  !include "files-uninstall.nsh"
  Delete "$INSTDIR\uninstall.exe"
  RMDir "$INSTDIR"
SectionEnd

