[call GenerateFileHeader("EDISettings.cpp")]
#include "StdAfx.h"
#include "EDISettings.h"

namespace altova
{
namespace text
{
namespace edi
{

CEDISettings::CEDISettings()
:	m_TerminateSegmentsWithLinefeed(false)
,	m_AutoCompleteData(true)
{}

const CServiceStringAdvice& CEDISettings::GetServiceStringAdvice() const
{
	return m_UNA;
}
CServiceStringAdvice& CEDISettings::GetServiceStringAdvice()
{
	return m_UNA;
}
bool CEDISettings::GetTerminateSegmentsWithLinefeed() const
{
	return m_TerminateSegmentsWithLinefeed;
}
bool CEDISettings::GetAutoCompleteData() const
{
	return m_AutoCompleteData;
}
void CEDISettings::SetTerminateSegmentsWithLinefeed(bool rhs)
{
	m_TerminateSegmentsWithLinefeed= rhs;
}
void CEDISettings::SetAutoCompleteData(bool rhs)
{
	m_AutoCompleteData= rhs;
}


} // namespace edi
} // namespace text
} // namespace altova
