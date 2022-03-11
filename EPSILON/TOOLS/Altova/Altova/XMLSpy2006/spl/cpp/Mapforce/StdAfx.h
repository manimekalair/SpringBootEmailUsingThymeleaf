////////////////////////////////////////////////////////////////////////
//
// StdAfx.h
//
// This file was generated by [=$Host].
//
// YOU SHOULD NOT MODIFY THIS FILE, BECAUSE IT WILL BE
// OVERWRITTEN WHEN YOU RE-RUN CODE GENERATION.
//
// Refer to the [=$HostShort] Documentation for further details.
// [=$HostURL]
//
////////////////////////////////////////////////////////////////////////


#ifndef [=$application.Name]_STDAFX_H_INCLUDED
#define [=$application.Name]_STDAFX_H_INCLUDED

#if _MSC_VER > 1000
	#pragma once
#endif // _MSC_VER > 1000

#ifdef _MFC_VER	// suppress annoying warnings in Visual C++
#pragma warning ( disable : 4786 )	// identifier was truncated to '255' characters in the debug information
#pragma warning ( disable : 4800 )	// forcing value to bool 'true' or 'false' (performance warning)
#endif // _MFC_VER

[if $mfc]
#define VC_EXTRALEAN		// Exclude rarely-used stuff from Windows headers
#include <afx.h>
#include <afxwin.h>			// MFC core and standard components
#include <afxext.h>			// MFC extensions
#include <afxdtctl.h>		// MFC support for Internet Explorer 4 Common Controls
#include <comdef.h>

#ifndef _AFX_NO_AFXCMN_SUPPORT
	#include <afxcmn.h>		// MFC support for Windows Common Controls
#endif // _AFX_NO_AFXCMN_SUPPORT
[else]
#include <tchar.h>
[endif]

[if $domtype = 1]
#import "msxml4.dll" named_guids no_implementation


[else]
#include <xercesc/dom/DOM.hpp>
#include <xercesc/util/PlatformUtils.hpp>
#include <xercesc/sax/HandlerBase.hpp>
#include <xercesc/framework/LocalFileFormatTarget.hpp>

#ifdef _DEBUG
	#pragma comment(lib, "xerces-c_2D")
#else
	#pragma comment(lib, "xerces-c_2")
#endif
[endif]

[if $DBLibraryCount > 0]
#pragma warning(disable: 4146)
// If you get a compiler-error on the line below, add the path to the DLL
// at Tools|Options|Directories|Include Directories.
// Hint: Depending on your installation it might be C:\\Program Files\\Common Files\\System\\ADO
#import "msado15.dll" rename("EOF", "EndOfFile") no_implementation
#pragma warning(default: 4146)
[endif]

#pragma warning( disable: 4786 )
#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <list>
#include <algorithm>
#include <set>

#include <Altova.h>
#include <SchemaTypes.h>
#include <AltovaException.h>
#include <SchemaTypeString.h>
#include <SchemaTypeNumber.h>
#include <SchemaTypeCalendar.h>
#include <SchemaTypeBinary.h>
#include <XmlException.h>

#include <Doc.h>
#include <Node.h>
[if $DBLibraryCount > 0]
#include <AltovaDB.h>
[endif]
#include <Core.h>
#include <Db.h>
#include <Lang.h>
#include <Edifact.h>
using namespace altova;

[' add includes for all local-functions
foreach $Mapping in $application.Mappings
	foreach $AlgorithmGroup in $Mapping.AllLocalFunctions
]#include \"[=$AlgorithmGroup.LocalFunctionNamespace]_[=$AlgorithmGroup.Name].h\"
[
	next
next
]

//{{AFX_INSERT_LOCATION}}

#endif // [=$application.Name]_STDAFX_H_INCLUDED