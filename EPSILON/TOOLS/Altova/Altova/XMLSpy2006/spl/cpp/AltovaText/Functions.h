[call GenerateFileHeader("Functions.h")]
#ifndef __ALTOVATEXT_FUNCTIONS_H
#define __ALTOVATEXT_FUNCTIONS_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{
namespace edi
{
	
class CFunction;

class ALTOVATEXT_DECLSPECIFIER CStringToFunctionMap
{
public:
	CStringToFunctionMap();
	~CStringToFunctionMap();
	void Add(const tstring& key, CFunction* value);
	CFunction* Get(const tstring& key) const;
	void Clear();

private:
	bool IsCRLF(const tstring& rhs) const;
	CFunction* FindFunctionForString(const tstring& key) const;

private:
	typedef std::map<tstring, CFunction*> TString2FunctionMap;
	// because of VC 6.0's problem with exporting STL containers which use a tree internally, we need to use a pointer here
	TString2FunctionMap* m_Map;
};

} // namespace edi
} // namespace text
} // namespace altova


#endif
