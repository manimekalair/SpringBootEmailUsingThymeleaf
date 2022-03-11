# Microsoft Developer Studio Project File - Name="AltovaFunctions" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

[if $libtype = 1
	]# TARGTYPE "Win32 (x86) Static Library" 0x0104
[else
	$dllexp = " /D \"ALTOVAFUNCTIONS_EXPORTS\""
	]# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102
[endif]

CFG=AltovaFunctions - Win32 Unicode Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "AltovaFunctions.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "AltovaFunctions.mak" CFG="AltovaFunctions - Win32 Unicode Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "AltovaFunctions - Win32 Release" (based on "Win32 (x86) [=$libtypename]")
!MESSAGE "AltovaFunctions - Win32 Debug" (based on "Win32 (x86) [=$libtypename]")
!MESSAGE "AltovaFunctions - Win32 Unicode Release" (based on "Win32 (x86) [=$libtypename]")
!MESSAGE "AltovaFunctions - Win32 Unicode Debug" (based on "Win32 (x86) [=$libtypename]")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
[if $libtype = 2]MTL=midl.exe
[endif]RSC=rc.exe

!IF  "$(CFG)" == "AltovaFunctions - Win32 Release"

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
# ADD BASE CPP[=$dllexp][=$CPPOpt] /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /Yu"stdafx.h" /FD /c
# ADD CPP[=$dllexp][=$CPPOpt] /nologo /W3 /GR /GX /O2 /I "..\\Altova" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /FD /c
[if $libtype = 2]
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
[endif]
# ADD BASE RSC /l 0x409 /d "NDEBUG"[=$RSCOpt]
# ADD RSC /l 0x409 /d "NDEBUG"[=$RSCOpt]
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
[if $libtype = 1]
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo
[else]
LINK32=link.exe
# ADD BASE LINK32[=$LINKOpt] /nologo /dll /machine:I386
# ADD LINK32[=$LINKOpt] /nologo /dll /machine:I386
# Begin Special Build Tool
TargetPath=.\\Release\\AltovaFunctions.dll
SOURCE="$(InputPath)"
PostBuild_Cmds=@mkdir ..\\[=$AppProjectName]\\Release >nul	@copy $(TargetPath) ..\\[=$AppProjectName]\\Release\\ >nul
# End Special Build Tool
[endif]

!ELSEIF  "$(CFG)" == "AltovaFunctions - Win32 Debug"

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
# ADD BASE CPP[=$dllexp][=$CPPOpt]d /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP[=$dllexp][=$CPPOpt]d /nologo /W3 /Gm /GR /GX /ZI /Od /I "..\\Altova" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /FR /Yu"stdafx.h" /FD /GZ /c
[if $libtype = 2]
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
[endif]
# ADD BASE RSC /l 0x409 /d "_DEBUG"[=$RSCOpt]
# ADD RSC /l 0x409 /d "_DEBUG"[=$RSCOpt]
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
[if $libtype = 1]
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo
[else]
LINK32=link.exe
# ADD BASE LINK32[=$LINKOpt] /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32[=$LINKOpt] /nologo /dll /debug /machine:I386 /pdbtype:sept
# Begin Special Build Tool
TargetPath=.\\Debug\\AltovaFunctions.dll
SOURCE="$(InputPath)"
PostBuild_Cmds=@mkdir ..\\[=$AppProjectName]\\Debug >nul	@copy $(TargetPath) ..\\[=$AppProjectName]\\Debug\\ >nul
# End Special Build Tool
[endif]

!ELSEIF  "$(CFG)" == "AltovaFunctions - Win32 Unicode Release"

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
# ADD BASE CPP[=$dllexp][=$CPPOpt] /nologo /W3 /GR /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /FD /c
# ADD CPP[=$dllexp][=$CPPOpt] /nologo /W3 /GR /GX /O2 /I "..\\Altova" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /Yu"stdafx.h" /FD /c
[if $libtype = 2]
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
[endif]
# ADD BASE RSC /l 0x409 /d "NDEBUG"[=$RSCOpt]
# ADD RSC /l 0x409 /d "NDEBUG"[=$RSCOpt]
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
[if $libtype = 1]
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo
[else]
LINK32=link.exe
# ADD BASE LINK32[=$LINKOpt] /nologo /dll /machine:I386
# ADD LINK32[=$LINKOpt] /nologo /dll /machine:I386
# Begin Special Build Tool
TargetPath=.\\UnicodeRelease\\AltovaFunctions.dll
SOURCE="$(InputPath)"
PostBuild_Cmds=@mkdir ..\\[=$AppProjectName]\\UnicodeRelease >nul	@copy $(TargetPath) ..\\[=$AppProjectName]\\UnicodeRelease\\ >nul
# End Special Build Tool
[endif]

!ELSEIF  "$(CFG)" == "AltovaFunctions - Win32 Unicode Debug"

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
# ADD BASE CPP[=$dllexp][=$CPPOpt]d /nologo /W3 /Gm /GR /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP[=$dllexp][=$CPPOpt]d /nologo /W3 /Gm /GR /GX /ZI /Od /I "..\\Altova" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /FR /Yu"stdafx.h" /FD /GZ /c
[if $libtype = 2]
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
[endif]
# ADD BASE RSC /l 0x409 /d "_DEBUG"[=$RSCOpt]
# ADD RSC /l 0x409 /d "_DEBUG"[=$RSCOpt]
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
[if $libtype = 1]
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo
[else]
LINK32=link.exe
# ADD BASE LINK32[=$LINKOpt] /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32[=$LINKOpt] /nologo /dll /debug /machine:I386 /pdbtype:sept
# Begin Special Build Tool
TargetPath=.\\UnicodeDebug\\AltovaFunctions.dll
SOURCE="$(InputPath)"
PostBuild_Cmds=@mkdir ..\\[=$AppProjectName]\\UnicodeDebug >nul	@copy $(TargetPath) ..\\[=$AppProjectName]\\UnicodeDebug\\ >nul
# End Special Build Tool
[endif]

!ENDIF 

# Begin Target

# Name "AltovaFunctions - Win32 Release"
# Name "AltovaFunctions - Win32 Debug"
# Name "AltovaFunctions - Win32 Unicode Release"
# Name "AltovaFunctions - Win32 Unicode Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\\Db.cpp
# End Source File
# Begin Source File

SOURCE=.\\Lang.cpp
# End Source File
# Begin Source File

SOURCE=.\\Edifact.cpp
# End Source File
# Begin Source File

SOURCE=.\\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# Begin Source File

SOURCE=.\\Core.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\\AltovaFunctionsAPI.h
# End Source File
# Begin Source File

SOURCE=.\\Db.h
# End Source File
# Begin Source File

SOURCE=.\\Lang.h
# End Source File
# Begin Source File

SOURCE=.\\Edifact.h
# End Source File
# Begin Source File

SOURCE=.\\StdAfx.h
# End Source File
# Begin Source File

SOURCE=.\\Core.h
# End Source File
# End Group
# End Target
# End Project
