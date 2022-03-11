[call GenerateFileHeader("EDIX12DataCompletion.h")]
#ifndef __EDIX12DATACOMPLETION_H
#define __EDIX12DATACOMPLETION_H

#include "DataCompletion.h"

namespace altova
{
namespace text
{
namespace edi
{

class CEDIX12Settings;

class ALTOVATEXT_DECLSPECIFIER CEDIX12DataCompletion : public CDataCompletion
{
public:
	CEDIX12DataCompletion(const CEDIX12Settings&, const tstring&);

public: // implementing CDataCompletion
	virtual void CompleteData(CTextNode&);

private:
	void CompleteInterchange();
	void CompleteGroup();
	void CompleteMessage();

private:
	const CEDIX12Settings& m_Settings;
	CTextNode* m_Root;
	CTextNode* m_GroupRoot;
	CTextNode* m_MessageRoot;
};

} // namespace edi
} // namespace text
} // namespace altova


#endif