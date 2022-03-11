[call GenerateFileHeader("EDISettings.h")]
#ifndef __EDISETTINGS_H
#define __EDISETTINGS_H

#include "ServiceStringAdvice.h"

namespace altova
{
namespace text
{
namespace edi
{

class ALTOVATEXT_DECLSPECIFIER CEDISettings
{
public:
	CEDISettings();
	virtual ~CEDISettings() {};

	const CServiceStringAdvice& GetServiceStringAdvice() const;
	CServiceStringAdvice& GetServiceStringAdvice();
	bool GetTerminateSegmentsWithLinefeed() const;
	bool GetAutoCompleteData() const;
	void SetTerminateSegmentsWithLinefeed(bool);
	void SetAutoCompleteData(bool);

private:
	CServiceStringAdvice m_UNA;
	bool m_TerminateSegmentsWithLinefeed;
	bool m_AutoCompleteData;
};

} // namespace edi
} // namespace text
} // namespace altova

#endif