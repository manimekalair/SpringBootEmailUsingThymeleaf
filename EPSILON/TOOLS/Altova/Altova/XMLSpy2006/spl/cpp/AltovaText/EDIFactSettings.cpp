[call GenerateFileHeader("EDIFactSettings.cpp")]
#include "StdAfx.h"
#include "EDIFactSettings.h"

namespace altova
{
namespace text
{
namespace edi
{

CEDIFactSettings::CEDIFactSettings()
:	m_SyntaxVersionNumber(2)
,	m_SyntaxLevel(_T('A'))
,	m_ControllingAgency(_T("UNO"))
,	m_WriteUNA(true)
{}
long CEDIFactSettings::GetSyntaxVersionNumber() const
{
	return m_SyntaxVersionNumber;
}
TCHAR CEDIFactSettings::GetSyntaxLevel() const
{
	return m_SyntaxLevel;
}
const tstring& CEDIFactSettings::GetControllingAgency() const
{
	return m_ControllingAgency;
}
bool CEDIFactSettings::GetWriteUNA() const
{
	return m_WriteUNA;
}
void CEDIFactSettings::SetSyntaxVersionNumber(long rhs)
{
	m_SyntaxVersionNumber= rhs;
}
void CEDIFactSettings::SetSyntaxLevel(TCHAR rhs)
{
	m_SyntaxLevel= rhs;
}
void CEDIFactSettings::SetControllingAgency(const tstring& rhs)
{
	m_ControllingAgency= rhs;
}
void CEDIFactSettings::SetWriteUNA(bool rhs)
{
	m_WriteUNA= rhs;
}

} // namespace edi
} // namespace text
} // namespace altova
