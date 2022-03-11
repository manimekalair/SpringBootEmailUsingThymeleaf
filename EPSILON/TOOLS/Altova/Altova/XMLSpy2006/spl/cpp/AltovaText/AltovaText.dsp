# Microsoft Developer Studio Project File - Name="AltovaText" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

[if $libtype = 1
	]# TARGTYPE "Win32 (x86) Static Library" 0x0104
[else
	$dllexp = " /D \"ALTOVATEXT_EXPORTS\""
	]# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102
[endif]

CFG=AltovaText - Win32 Unicode Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "AltovaText.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "AltovaText.mak" CFG="AltovaText - Win32 Unicode Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "AltovaText - Win32 Release" (based on "Win32 (x86) [=$libtypename]")
!MESSAGE "AltovaText - Win32 Debug" (based on "Win32 (x86) [=$libtypename]")
!MESSAGE "AltovaText - Win32 Unicode Release" (based on "Win32 (x86) [=$libtypename]")
!MESSAGE "AltovaText - Win32 Unicode Debug" (based on "Win32 (x86) [=$libtypename]")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
[if $libtype = 2]MTL=midl.exe
[endif]RSC=rc.exe

!IF  "$(CFG)" == "AltovaText - Win32 Release"

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
# ADD CPP[=$dllexp][=$CPPOpt] /nologo /W3 /GR /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /FD /c
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
TargetPath=.\\Release\\AltovaText.dll
SOURCE="$(InputPath)"
PostBuild_Cmds=@mkdir ..\\[=$AppProjectName]\\Release >nul	@copy $(TargetPath) ..\\[=$AppProjectName]\\Release\\ >nul
# End Special Build Tool
[endif]

!ELSEIF  "$(CFG)" == "AltovaText - Win32 Debug"

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
# ADD CPP[=$dllexp][=$CPPOpt]d /nologo /W3 /Gm /GR /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /FR /Yu"stdafx.h" /FD /GZ /c
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
TargetPath=.\\Debug\\AltovaText.dll
SOURCE="$(InputPath)"
PostBuild_Cmds=@mkdir ..\\[=$AppProjectName]\\Debug >nul	@copy $(TargetPath) ..\\[=$AppProjectName]\\Debug\\ >nul
# End Special Build Tool
[endif]

!ELSEIF  "$(CFG)" == "AltovaText - Win32 Unicode Release"

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
# ADD CPP[=$dllexp][=$CPPOpt] /nologo /W3 /GR /GX /O2 /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /Yu"stdafx.h" /FD /c
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
TargetPath=.\\UnicodeRelease\\AltovaText.dll
SOURCE="$(InputPath)"
PostBuild_Cmds=@mkdir ..\\[=$AppProjectName]\\UnicodeRelease >nul	@copy $(TargetPath) ..\\[=$AppProjectName]\\UnicodeRelease\\ >nul
# End Special Build Tool
[endif]

!ELSEIF  "$(CFG)" == "AltovaText - Win32 Unicode Debug"

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
# ADD CPP[=$dllexp][=$CPPOpt]d /nologo /W3 /Gm /GR /GX /ZI /Od /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /FR /Yu"stdafx.h" /FD /GZ /c
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
TargetPath=.\\UnicodeDebug\\AltovaText.dll
SOURCE="$(InputPath)"
PostBuild_Cmds=@mkdir ..\\[=$AppProjectName]\\UnicodeDebug >nul	@copy $(TargetPath) ..\\[=$AppProjectName]\\UnicodeDebug\\ >nul
# End Special Build Tool
[endif]

!ENDIF 

# Begin Target

# Name "AltovaText - Win32 Release"
# Name "AltovaText - Win32 Debug"
# Name "AltovaText - Win32 Unicode Release"
# Name "AltovaText - Win32 Unicode Debug"
# Begin Group "TableBased"

# PROP Default_Filter ""
# Begin Group "Headers (TableBased)"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=.\\ColumnSpecification.h
# End Source File
# Begin Source File

SOURCE=.\\CSVFormat.h
# End Source File
# Begin Source File

SOURCE=.\\CSVParser.h
# End Source File
# Begin Source File

SOURCE=.\\CSVSerializer.h
# End Source File
# Begin Source File

SOURCE=.\\FLFFormat.h
# End Source File
# Begin Source File

SOURCE=.\\FLFParser.h
# End Source File
# Begin Source File

SOURCE=.\\FLFSerializer.h
# End Source File
# Begin Source File

SOURCE=.\\Header.h
# End Source File
# Begin Source File

SOURCE=.\\Record.h
# End Source File
# Begin Source File

SOURCE=.\\RecordBasedParser.h
# End Source File
# Begin Source File

SOURCE=.\\Serializer.h
# End Source File
# Begin Source File

SOURCE=.\\Table.h
# End Source File
# Begin Source File

SOURCE=.\\TextException.h
# End Source File
# End Group
# Begin Group "Sources (TableBased)"

# PROP Default_Filter "cpp"
# Begin Source File

SOURCE=.\\ColumnSpecification.cpp
# End Source File
# Begin Source File

SOURCE=.\\CSVFormat.cpp
# End Source File
# Begin Source File

SOURCE=.\\CSVParser.cpp
# End Source File
# Begin Source File

SOURCE=.\\CSVSerializer.cpp
# End Source File
# Begin Source File

SOURCE=.\\FLFFormat.cpp
# End Source File
# Begin Source File

SOURCE=.\\FLFParser.cpp
# End Source File
# Begin Source File

SOURCE=.\\FLFSerializer.cpp
# End Source File
# Begin Source File

SOURCE=.\\Header.cpp
# End Source File
# Begin Source File

SOURCE=.\\Record.cpp
# End Source File
# Begin Source File

SOURCE=.\\RecordBasedParser.cpp
# End Source File
# Begin Source File

SOURCE=.\\Serializer.cpp
# End Source File
# Begin Source File

SOURCE=.\\Table.cpp
# End Source File
# Begin Source File

SOURCE=.\\TextException.cpp
# End Source File
# End Group
# End Group
# Begin Group "TreeBased"

# PROP Default_Filter ""
# Begin Group "Headers (TreeBased)"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=.\\BaseNode.h
# End Source File
# Begin Source File

SOURCE=.\\Generator.h
# End Source File
# Begin Source File

SOURCE=.\\FlexCommand.h
# End Source File
# Begin Source File

SOURCE=.\\FlexUtilities.h
# End Source File
# Begin Source File

SOURCE=.\\TextDocument.h
# End Source File
# Begin Source File

SOURCE=.\\TextNode.h
# End Source File
# Begin Source File

SOURCE=.\\TextNodeXMLWriter.h
# End Source File
# End Group
# Begin Group "Headers (EDIFACT)"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=.\\Command.h
# End Source File
# Begin Source File

SOURCE=.\\Commands.h
# End Source File
# Begin Source File

SOURCE=.\\Condition.h
# End Source File
# Begin Source File

SOURCE=.\\Conditions.h
# End Source File
# Begin Source File

SOURCE=.\\DataCompletion.h
# End Source File
# Begin Source File

SOURCE=.\\EDIFactSerializer.h
# End Source File
# Begin Source File

SOURCE=.\\EDIFactSettings.h
# End Source File
# Begin Source File

SOURCE=.\\EDISettings.h
# End Source File
# Begin Source File

SOURCE=.\\EDIX12Settings.h
# End Source File
# Begin Source File

SOURCE=.\\EDIFactDataCompletion.h
# End Source File
# Begin Source File

SOURCE=.\\EDIX12DataCompletion.h
# End Source File
# Begin Source File

SOURCE=.\\MakeSureHasChild.h
# End Source File
# Begin Source File

SOURCE=.\\Function.h
# End Source File
# Begin Source File

SOURCE=.\\Functions.h
# End Source File
# Begin Source File

SOURCE=.\\Parser.h
# End Source File
# Begin Source File

SOURCE=.\\Scanner.h
# End Source File
# Begin Source File

SOURCE=.\\ServiceStringAdvice.h
# End Source File
# End Group
# Begin Group "Sources (TreeBased)"

# PROP Default_Filter "cpp"
# Begin Source File

SOURCE=.\\BaseNode.cpp
# End Source File
# Begin Source File

SOURCE=.\\Generator.cpp
# End Source File
# Begin Source File

SOURCE=.\\FlexCommand.cpp
# End Source File
# Begin Source File

SOURCE=.\\FlexUtilities.cpp
# End Source File
# Begin Source File

SOURCE=.\\TextDocument.cpp
# End Source File
# Begin Source File

SOURCE=.\\TextNode.cpp
# End Source File
# Begin Source File

SOURCE=.\\TextNodeXMLWriter.cpp
# End Source File
# End Group
# Begin Group "Sources (EDIFACT)"

# PROP Default_Filter "cpp"
# Begin Source File

SOURCE=.\\Command.cpp
# End Source File
# Begin Source File

SOURCE=.\\Commands.cpp
# End Source File
# Begin Source File

SOURCE=.\\Condition.cpp
# End Source File
# Begin Source File

SOURCE=.\\Conditions.cpp
# End Source File
# Begin Source File

SOURCE=.\\DataCompletion.cpp
# End Source File
# Begin Source File

SOURCE=.\\EDIFactSerializer.cpp
# End Source File
# Begin Source File

SOURCE=.\\EDIFactSettings.cpp
# End Source File
# Begin Source File

SOURCE=.\\EDISettings.cpp
# End Source File
# Begin Source File

SOURCE=.\\EDIX12Settings.cpp
# End Source File
# Begin Source File

SOURCE=.\\EDIFactDataCompletion.cpp
# End Source File
# Begin Source File

SOURCE=.\\EDIX12DataCompletion.cpp
# End Source File
# Begin Source File

SOURCE=.\\MakeSureHasChild.cpp
# End Source File
# Begin Source File

SOURCE=.\\Function.cpp
# End Source File
# Begin Source File

SOURCE=.\\Functions.cpp
# End Source File
# Begin Source File

SOURCE=.\\Parser.cpp
# End Source File
# Begin Source File

SOURCE=.\\Scanner.cpp
# End Source File
# Begin Source File

SOURCE=.\\ServiceStringAdvice.cpp
# End Source File
# End Group
# End Group
# Begin Group "General"

# PROP Default_Filter ""
# Begin Group "Headers (General)"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\\AltovaTextAPI.h
# End Source File
# Begin Source File

SOURCE=.\\CodePageInformation.h
# End Source File
# Begin Source File

SOURCE=.\\Helpers.h
# End Source File
# Begin Source File

SOURCE=.\\StdAfx.h
# End Source File
# End Group
# Begin Group "Sources (General)"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\\CodePageInformation.cpp
# End Source File
# Begin Source File

SOURCE=.\\Helpers.cpp
# End Source File
# Begin Source File

SOURCE=.\\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# End Group
# End Group

# End Target
# End Project
