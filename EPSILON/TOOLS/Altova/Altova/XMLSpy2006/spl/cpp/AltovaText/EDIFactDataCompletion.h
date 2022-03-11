[call GenerateFileHeader("EDIFactDataCompletion.h")]
#ifndef __EDIFACTDATACOMPLETION_H
#define __EDIFACTDATACOMPLETION_H

#include "DataCompletion.h"

namespace altova
{
namespace text
{
namespace edi
{

class CEDIFactSettings;

class CEDIFactDataCompletion : public CDataCompletion
{
public:
	CEDIFactDataCompletion(const CEDIFactSettings&, const tstring&);
	void CEDIFactDataCompletion::CompleteData(CTextNode& dataroot);

protected:
	void CEDIFactDataCompletion::CompleteEnvelope (CTextNode& envelope);
	void CEDIFactDataCompletion::CompleteInterchange(CTextNode& interchange);
	void CEDIFactDataCompletion::CompleteInterchangeHeader(CTextNode& unb);
	void CEDIFactDataCompletion::CompleteInterchangeTrailer(CTextNode& unz);
	void CEDIFactDataCompletion::CompleteGroup(CTextNode& group);
	void CEDIFactDataCompletion::CompleteGroupHeader(CTextNode& ung);
	void CEDIFactDataCompletion::CompleteGroupTrailer(CTextNode& une);
	void CEDIFactDataCompletion::CompleteMessage(CTextNode& message);
	void CEDIFactDataCompletion::CompleteMessageHeader(CTextNode& unh);
	void CEDIFactDataCompletion::CompleteMessageTrailer(CTextNode& unt);
	void CEDIFactDataCompletion::CompleteS001(CTextNode& s001);
	void CEDIFactDataCompletion::CompleteS004(CTextNode& s004);
	void CEDIFactDataCompletion::CompleteS009(CTextNode& s009);
	long CEDIFactDataCompletion::GetNumberOfFunctionGroupsOrMessages(CTextNode& node);

private:
	const CEDIFactSettings& m_Settings;
};

} // namespace edi
} // namespace text
} // namespace altova


#endif