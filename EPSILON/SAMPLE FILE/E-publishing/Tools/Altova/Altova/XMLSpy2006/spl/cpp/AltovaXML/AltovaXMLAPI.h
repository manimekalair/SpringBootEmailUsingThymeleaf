////////////////////////////////////////////////////////////////////////
//
// AltovaXMLAPI.h
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

#ifndef ALTOVA_XML_API_H_INCLUDED
#define ALTOVA_XML_API_H_INCLUDED

#if _MSC_VER > 1000
	#pragma once
#endif // _MSC_VER > 1000


#ifndef _USRDLL
	#define ALTOVAXML_DECLSPECIFIER
#else
	#ifdef ALTOVAXML_EXPORTS
		#define ALTOVAXML_DECLSPECIFIER __declspec(dllexport)
		#define ALTOVAXML_EXPIMP_TEMPLATE
	#else
		#define ALTOVAXML_DECLSPECIFIER __declspec(dllimport)
		#define ALTOVAXML_EXPIMP_TEMPLATE extern
	#endif

	#ifndef _MFC_VER
		#pragma warning(disable: 4660)
		#pragma warning(disable: 4231)
		#pragma warning(disable: 4251)
	#endif
#endif

#endif // ALTOVA_XML_API_H_INCLUDED