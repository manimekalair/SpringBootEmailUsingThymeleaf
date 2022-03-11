[call GenerateFileHeader("DataCompletion.h")]
#ifndef __DATACOMPLETION_H
#define __DATACOMPLETION_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{

class CTextNode;


namespace edi
{

class ALTOVATEXT_DECLSPECIFIER CDataCompletion
{
public: // descendant obligations:
	virtual void CompleteData(CTextNode&) = 0;

protected:
	CDataCompletion(const tstring&);
	const tstring& GetStructureName() const;
	
	static bool HasKid(const CTextNode&, tstring);
	static CTextNode& GetKid(const CTextNode&, tstring);
	static void ConservativeSetValue(CTextNode&, tstring);
	static void ConservativeSetValue(CTextNode&, TCHAR);
	static void ConservativeSetValue(CTextNode&, long);
	static long GetSegmentChildrenCount(const CTextNode&);
	static long GetNamedChildrenCount(const CTextNode&, const tstring&);
	static tstring GetCurrentDateAsEDIString();
	static tstring GetCurrentTimeAsEDIString();
	
private:
	tstring m_StructureName;
};

} // namespace edi
} // namespace text
} // namespace altova
	
#endif