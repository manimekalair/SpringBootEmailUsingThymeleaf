[call GenerateFileHeader("AltovaTextAPI.h")]
#ifndef ALTOVA_TEXT_API_H_INCLUDED
#define ALTOVA_TEXT_API_H_INCLUDED

#if _MSC_VER > 1000
	#pragma once
#endif // _MSC_VER > 1000


#ifndef _USRDLL
	#define ALTOVATEXT_DECLSPECIFIER
#else
	#ifdef ALTOVATEXT_EXPORTS
		#define ALTOVATEXT_DECLSPECIFIER __declspec(dllexport)
		#define ALTOVATEXT_EXPIMP_TEMPLATE
	#else
		#define ALTOVATEXT_DECLSPECIFIER __declspec(dllimport)
		#define ALTOVATEXT_EXPIMP_TEMPLATE extern
	#endif

	#ifndef _MFC_VER
		#pragma warning(disable: 4660)
		#pragma warning(disable: 4231)
		#pragma warning(disable: 4251)
	#endif
#endif

#endif // ALTOVA_TEXT_API_H_INCLUDED
