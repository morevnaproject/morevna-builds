;--------------------------------
; Requires files:
;   config.nsh
;   files-install.nsh
;   files-uninstall.nsh
;   files-stuff-install.nsh
;   files-stuff-uninstall.nsh

; Defines which will set by 'config.nsh':
;   PK_NAME         - XxxxxXxxxx               - name without spaces 
;   PK_NAME_FULL    - Xxxxx Xxxxxxxxxx         - full name, may be with spaces
;   PK_ARCH         - XX                       - architecture, 32 or 64
;   PK_VERSION      - X.X                      - first two numbers of version
;   PK_VERSION_FULL - X.X.X-xxxxx-xxxxx        - full version, without spaces 
;   PK_EXECUTABLE   - xxx\XxxxXxxx-xxx_xxx.exe - subpath to executable file 

!include "config.nsh"

;--------------------------------

!include "MUI2.nsh"

;second directory selection

;--------------------------------

; The name of the installer
Name "${PK_NAME_FULL} ${PK_VERSION_FULL}"

; The file to write
OutFile "${PK_NAME}-${PK_VERSION_FULL}.exe"

; The default installation directory and registry
InstallDir "$PROGRAMFILES${PK_ARCH}\${PK_NAME}"
Var STUFFDIR

; Request application privileges for Windows Vista
RequestExecutionLevel highest

!insertmacro MUI_LANGUAGE "English"

!define MUI_ABORTWARNING

!define SHCNE_ASSOCCHANGED 0x8000000
!define SHCNF_IDLIST 0

!define PRODUCT_REG_KEY "Software\${PK_NAME}"
!define PRODUCT_STUFF_KEY "${PRODUCT_REG_KEY}\${PK_NAME}\${PK_VERSION}"
!define PRODUCT_UNINSTALL_KEY  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PK_NAME}"
!define PRODUCT_UNINSTALL_KEY2 "Software\Microsoft\Windows\CurrentVersion\Uninstall\{D9A9B1A3-9370-4BE9-9C8F-7B52EEECB973}_is1"
!define PRODUCT_UNINSTALL_EXE  "uninstall-${PK_NAME}.exe"

;--------------------------------

; Pages

!insertmacro MUI_PAGE_COMPONENTS

!define MUI_PAGE_CUSTOMFUNCTION_LEAVE InstDirPageLeave
!insertmacro MUI_PAGE_DIRECTORY

Function InstDirPageLeave
  StrCpy $STUFFDIR "C:\${PK_NAME} ${PK_VERSION} stuff"
FunctionEnd

!define MUI_DIRECTORYPAGE_VARIABLE $STUFFDIR
!define MUI_DIRECTORYPAGE_TEXT_TOP "Choose stuff directory for ${PK_NAME}..."
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Stuff Directory:"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
; Installer
;--------------------------------

Section "${PK_NAME_FULL} (required)"
  SetRegView ${PK_ARCH}

  SectionIn RO

  SetOutPath "$INSTDIR"
  !include "files-install.nsh"
  
  SetOutPath "$STUFFDIR"
  !include "files-stuff-install.nsh"

  WriteRegStr HKLM "${PRODUCT_REG_KEY}" "Path" "$INSTDIR"
  WriteRegStr HKLM "${PRODUCT_REG_KEY}" "Version" "${PK_VERSION_FULL}"

  WriteRegStr HKLM "${PRODUCT_STUFF_KEY}" "TOONZROOT"          "$STUFFDIR"
  WriteRegStr HKLM "${PRODUCT_STUFF_KEY}" "TOONZPROJECTS"      "$STUFFDIR\projects"
  WriteRegStr HKLM "${PRODUCT_STUFF_KEY}" "TOONZCACHEROOT"     "$STUFFDIR\cache"
  WriteRegStr HKLM "${PRODUCT_STUFF_KEY}" "TOONZCONFIG"        "$STUFFDIR\config"
  WriteRegStr HKLM "${PRODUCT_STUFF_KEY}" "TOONZPROFILES"      "$STUFFDIR\profiles"
  WriteRegStr HKLM "${PRODUCT_STUFF_KEY}" "TOONZFXPRESETS"     "$STUFFDIR\fxs"
  WriteRegStr HKLM "${PRODUCT_STUFF_KEY}" "TOONZLIBRARY"       "$STUFFDIR\library"
  WriteRegStr HKLM "${PRODUCT_STUFF_KEY}" "TOONZSTUDIOPALETTE" "$STUFFDIR\studiopalette"
  WriteRegStr HKLM "${PRODUCT_STUFF_KEY}" "FARMROOT"           ""

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "${PRODUCT_UNINSTALL_KEY}" "DisplayName" "${PK_NAME_FULL}"
  WriteRegStr HKLM "${PRODUCT_UNINSTALL_KEY}" "DisplayVersion" "${PK_VERSION_FULL}"
  WriteRegStr HKLM "${PRODUCT_UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\${PRODUCT_UNINSTALL_EXE}"'
  WriteRegDWORD HKLM "${PRODUCT_UNINSTALL_KEY}" "NoModify" 1
  WriteRegDWORD HKLM "${PRODUCT_UNINSTALL_KEY}" "NoRepair" 1

  System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'

  SetOutPath "$INSTDIR"
  WriteUninstaller "${PRODUCT_UNINSTALL_EXE}"
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"
  SetRegView ${PK_ARCH}

  SetOutPath "$INSTDIR\bin"

  SetShellVarContext All
  CreateDirectory "$SMPROGRAMS\${PK_NAME_FULL}"
  CreateShortCut "$SMPROGRAMS\${PK_NAME_FULL}\Uninstall ${PK_NAME_FULL}.lnk" "$INSTDIR\uninstall-${PK_NAME}.exe" "" "$INSTDIR\uninstall-${PK_NAME}.exe" 0
  CreateShortCut "$SMPROGRAMS\${PK_NAME_FULL}\${PK_NAME_FULL}.lnk" "$INSTDIR\${PK_EXECUTABLE}" "" "$INSTDIR\${PK_EXECUTABLE}" 0
SectionEnd

;--------------------------------
; Uninstaller
;--------------------------------

Section "Uninstall"
  SetRegView ${PK_ARCH}

  ReadRegStr $INSTDIR HKLM "${PRODUCT_REG_KEY}" "Path"
  ReadRegStr $STUFFDIR HKLM "${PRODUCT_REG_KEY}\${PK_NAME}\${PK_VERSION}" "TOONZROOT"

  ; Remove registry keys
  DeleteRegKey HKLM "${PRODUCT_REG_KEY}"
  DeleteRegKey HKLM "${PRODUCT_UNINSTALL_KEY}"

  ; Remove files and uninstaller
  !include "files-stuff-uninstall.nsh"
  !include "files-uninstall.nsh"
  Delete "$INSTDIR\${PRODUCT_UNINSTALL_EXE}"

  ; Remove shortcuts, if any
  SetShellVarContext All
  Delete "$SMPROGRAMS\${PK_NAME_FULL}\${PK_NAME_FULL}.lnk"
  Delete "$SMPROGRAMS\${PK_NAME_FULL}\Uninstall ${PK_NAME_FULL}.lnk"

  ; Remove directories used
  RMDir "$SMPROGRAMS\${PK_NAME_FULL}"
  RMDir "$STUFFDIR"
  RMDir "$INSTDIR"

  System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'
SectionEnd

Function .onInit
  SetRegView 32

  ; Check previous installation
  ReadRegStr $R0 HKLM "${PRODUCT_UNINSTALL_KEY}" "UninstallString"
  StrCmp $R0 "" 0 oops

  ; Check previous installation 2
  ReadRegStr $R0 HKLM "${PRODUCT_UNINSTALL_KEY2}" "UninstallString"
  StrCmp $R0 "" 0 oops

  SetRegView 64

  ; Check previous installation
  ReadRegStr $R0 HKLM "${PRODUCT_UNINSTALL_KEY}" "UninstallString"
  StrCmp $R0 "" 0 oops

  ; Check previous installation 2
  ReadRegStr $R0 HKLM "${PRODUCT_UNINSTALL_KEY2}" "UninstallString"
  StrCmp $R0 "" 0 oops

  BringToFront
  Return

oops:
  MessageBox MB_OK|MB_ICONEXCLAMATION "Another version of ${PK_NAME_FULL} appears to be installed. Please, uninstall it first?"
  Abort
FunctionEnd
