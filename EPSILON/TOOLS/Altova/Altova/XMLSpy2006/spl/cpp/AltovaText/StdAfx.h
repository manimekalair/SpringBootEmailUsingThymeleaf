[call GenerateFileHeader("StdAfx.h")]
#if !defined(AFX_STDAFX_H__1530D665_1673_4B1F_816B_1CFD7DE0DE5A__INCLUDED_)
#define AFX_STDAFX_H__1530D665_1673_4B1F_816B_1CFD7DE0DE5A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000



#pragma warning ( disable : 4786 )	// identifier was truncated to '255' characters in the debug information
#pragma warning ( disable : 4800 )	// forcing value to bool 'true' or 'false' (performance warning)

#define VC_EXTRALEAN // Exclude rarely-used stuff from Windows headers
[if $mfc]
#include <afx.h>
#include <afxwin.h>
#include <afxdisp.h>
#include <comdef.h>
#include <atlconv.h>
[else]
#include <windows.h>
#include <tchar.h>
#define TRACE
#define ASSERT
[endif]

#include <stdlib.h>

// STL
#include <set>
#include <map>
#include <list>
#include <vector>
#include <string>
#include <iosfwd>
#include <fstream>
#include <sstream>
#include <iostream>
#include <functional>
#include <algorithm>
using namespace std;

// Altova Base Library
#include "../Altova/Altova.h"
#include "../Altova/SchemaTypes.h"
#include "../Altova/AltovaException.h"


#if defined(UNICODE) || defined(_UNICODE)
	#ifndef tofstream
		#define tofstream		std::wofstream
	#endif
	#ifndef tostream
		#define tostream		std:wostream
	#endif
	#ifndef tsstream
		#define tsstream		std::wstringstream
	#endif
#else
	#ifndef tofstream
		#define tofstream		std::ofstream
	#endif
	#ifndef tostream
		#define tostream		std::ostream
	#endif
	#ifndef tsstream
		#define	tsstream		std::stringstream
	#endif
#endif

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__1530D665_1673_4B1F_816B_1CFD7DE0DE5A__INCLUDED_)
