[call GenerateFileHeader("FLFFormat.cpp")]
#include "stdafx.h"
#include "FLFFormat.h"

namespace altova
{
namespace text
{
namespace tablelike
{
namespace flf
{

CFormat::CFormat()
:	m_AssumeRecordDelimiters(false)
,	m_FillCharacter(_T(' '))
{
	m_RecordDelimiters\[0\]= _T('\\r');
	m_RecordDelimiters\[1\]= _T('\\n'); 
}

bool CFormat::GetAssumeRecordDelimiters() const
{
	return m_AssumeRecordDelimiters;
}

void CFormat::SetAssumeRecordDelimiters(bool rhs)
{
	m_AssumeRecordDelimiters= rhs;
}

TCHAR CFormat::GetFillCharacter() const
{
	return m_FillCharacter;
}

void CFormat::SetFillCharacter(TCHAR rhs)
{
	m_FillCharacter= rhs;
}

bool CFormat::IsRecordDelimiter(TCHAR rhs) const
{
	for (size_t i= 0; i<2; ++i)
	{
		if (rhs == m_RecordDelimiters\[i\])
			return true;
	}
	return false;
}

} // namespace flf
} // namespace tablelike
} // namespace text
} // namespace altova

