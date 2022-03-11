# Microsoft Developer Studio Project File - Name="[=$module]Test" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=[=$module]Test - Win32 Unicode Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "[=$module]Test.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "[=$module]Test.mak" CFG="[=$module]Test - Win32 Unicode Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "[=$module]Test - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "[=$module]Test - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE "[=$module]Test - Win32 Unicode Release" (based on "Win32 (x86) Console Application")
!MESSAGE "[=$module]Test - Win32 Unicode Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "[=$module]Test - Win32 Release"

# PROP BASE Use_MFC [=$MFCCode]
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC [=$MFCCode]
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo[=$RTLOpt] /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS"[if $mfc] /D "_AFXDLL"[endif] /Yu"stdafx.h" /FD /c
# ADD CPP /nologo[=$RTLOpt] /W3 /GR /GX /O2 /I "..\\Altova" /I "..\\AltovaXML" /I "..\\[=$module]" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS"[if $mfc] /D "_AFXDLL"[endif] /Yu"stdafx.h" /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"[=$RSCOpt]
# ADD RSC /l 0x409 /d "NDEBUG"[=$RSCOpt]
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "[=$module]Test - Win32 Debug"

# PROP BASE Use_MFC [=$MFCCode]
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC [=$MFCCode]
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo[=$RTLOpt]d /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS"[if $mfc] /D "_AFXDLL"[endif] /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo[=$RTLOpt]d /W3 /Gm /GR /GX /ZI /Od /I "..\\Altova" /I "..\\AltovaXML" /I "..\\[=$module]" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS"[if $mfc] /D "_AFXDLL"[endif] /FR /Yu"stdafx.h" /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"[=$RSCOpt]
# ADD RSC /l 0x409 /d "_DEBUG"[=$RSCOpt]
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept

!ELSEIF  "$(CFG)" == "[=$module]Test - Win32 Unicode Release"

# PROP BASE Use_MFC [=$MFCCode]
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "UnicodeRelease"
# PROP BASE Intermediate_Dir "UnicodeRelease"
# PROP BASE Target_Dir ""
# PROP Use_MFC [=$MFCCode]
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "UnicodeRelease"
# PROP Intermediate_Dir "UnicodeRelease"
# PROP Target_Dir ""
# ADD BASE CPP /nologo[=$RTLOpt] /W3 /GR /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS"[if $mfc] /D "_AFXDLL"[endif] /Yu"stdafx.h" /FD /c
# ADD CPP /nologo[=$RTLOpt] /W3 /GR /GX /O2 /I "..\\Altova" /I "..\\AltovaXML" /I "..\\[=$module]" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_UNICODE" /D "UNICODE"[if $mfc] /D "_AFXDLL"[endif] /Yu"stdafx.h" /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"[=$RSCOpt]
# ADD RSC /l 0x409 /d "NDEBUG"[=$RSCOpt]
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "[=$module]Test - Win32 Unicode Debug"

# PROP BASE Use_MFC [=$MFCCode]
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "UnicodeDebug"
# PROP BASE Intermediate_Dir "UnicodeDebug"
# PROP BASE Target_Dir ""
# PROP Use_MFC [=$MFCCode]
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "UnicodeDebug"
# PROP Intermediate_Dir "UnicodeDebug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo[=$RTLOpt]d /W3 /Gm /GR /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS"[if $mfc] /D "_AFXDLL"[endif] /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo[=$RTLOpt]d /W3 /Gm /GR /GX /ZI /Od /I "..\\Altova" /I "..\\AltovaXML" /I "..\\[=$module]" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_UNICODE" /D "UNICODE"[if $mfc] /D "_AFXDLL"[endif] /FR /Yu"stdafx.h" /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"[=$RSCOpt]
# ADD RSC /l 0x409 /d "_DEBUG"[=$RSCOpt]
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "[=$module]Test - Win32 Release"
# Name "[=$module]Test - Win32 Debug"
# Name "[=$module]Test - Win32 Unicode Release"
# Name "[=$module]Test - Win32 Unicode Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\\[=$module]Test.cpp
# End Source File
# Begin Source File

SOURCE=.\\[=$module]Test.rc
# End Source File
# Begin Source File

SOURCE=.\\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\\[=$module]Test.h
# End Source File
# Begin Source File

SOURCE=.\\Resource.h
# End Source File
# Begin Source File

SOURCE=.\\StdAfx.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
