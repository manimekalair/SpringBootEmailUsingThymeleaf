////////////////////////////////////////////////////////////////////////
//
// [=$module]Functions.h
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


#ifndef [=$module]Functions_H_INCLUDED
#define [=$module]Functions_H_INCLUDED

#if _MSC_VER > 1000
	#pragma once
#endif // _MSC_VER > 1000

[if $library.ParseMode = 0]

#include "[=$module]API.h"
#include "../AltovaText/Function.h"
using namespace altova::text;
using namespace altova::text::edi;

namespace [=$module]
{

[foreach $handler in $library.Handlers
]class [=$module]_DECLSPECIFIER CHandler[=$handler.Name] : public CFunction 
{
public:
	CHandler[=$handler.Name]();
};

[next
]

//////////////////////////////////////////////////////////////////////////

[foreach $function in $library.Functions
]class [=$module]_DECLSPECIFIER CFunction[=$function.Name] : public CFunction 
{
public:
	CFunction[=$function.Name]();
};

[next
]

} // namespace [=$module]

[endif ' ParseMode]
#endif // [=$module]Functions_H_INCLUDED