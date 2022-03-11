[call GenerateFileHeader("EDIX12Settings.cpp")]
#include "StdAfx.h"
#include "EDIX12Settings.h"

namespace altova
{
namespace text
{
namespace edi
{

CEDIX12Settings::CEDIX12Settings()
:	m_SubElementSeparator(_T('!'))
,	m_InterchangeControlVersionNumber(_T("05012"))
,	m_RequestAcknowledgement(true)
{}
TCHAR CEDIX12Settings::GetSubElementSeparator() const
{
    return m_SubElementSeparator;
}

void CEDIX12Settings::SetSubElementSeparator(TCHAR rhs)
{
    m_SubElementSeparator = rhs;
}

const tstring& CEDIX12Settings::GetInterchangeControlVersionNumber() const
{
    return m_InterchangeControlVersionNumber;
}

void CEDIX12Settings::SetInterchangeControlVersionNumber(const tstring& rhs)
{
    m_InterchangeControlVersionNumber = rhs;
}

bool CEDIX12Settings::GetRequestAcknowledgement() const
{
    return m_RequestAcknowledgement;
}

void CEDIX12Settings::SetRequestAcknowledgement(bool rhs)
{
    m_RequestAcknowledgement = rhs;
}


} // namespace edi
} // namespace text
} // namespace altova
