[call GenerateFileHeader("CSVFormat.cpp")]
#include "stdafx.h"
#include "CSVFormat.h"

namespace altova
{
namespace text
{
namespace tablelike
{
namespace csv
{

CFormat::CFormat()
:	m_FieldDelimiter(_T(','))
,	m_QuoteCharacter(_T('"'))
,	m_AssumeFirstRowAsHeaders(true)
,	m_ExpectQuoteCharacter(false)
{
	m_RecordDelimiters\[0\]= _T('\\r');
	m_RecordDelimiters\[1\]= _T('\\n');
	UpdateQuoteNeedingCharacters();
}

void CFormat::UpdateQuoteNeedingCharacters()
{
	for (size_t i= 0; i < 2; ++i)
	{
		m_QuoteNeedingCharacters\[i\] = m_RecordDelimiters\[i\];
	}
	m_QuoteNeedingCharacters\[2\] = m_FieldDelimiter;
	m_QuoteNeedingCharacters\[3\] = (m_ExpectQuoteCharacter) ? m_QuoteCharacter : (TCHAR) 0;
	m_QuoteNeedingCharacters\[4\] = (TCHAR) 0;
}

bool CFormat::GetAssumeFirstRowAsHeaders() const
{
	return m_AssumeFirstRowAsHeaders;
}

void CFormat::SetAssumeFirstRowAsHeaders(bool rhs)
{
	m_AssumeFirstRowAsHeaders = rhs;
}

TCHAR CFormat::GetQuoteCharacter() const
{
	return m_QuoteCharacter;
}

void CFormat::SetQuoteCharacter(TCHAR rhs)
{
	m_ExpectQuoteCharacter = true;
	m_QuoteCharacter = rhs;
	m_QuoteNeedingCharacters\[3\] = rhs;
}

TCHAR CFormat::GetFieldDelimiter() const
{
	return m_FieldDelimiter;
}

void CFormat::SetFieldDelimiter(TCHAR rhs)
{
	m_FieldDelimiter = rhs;
	m_QuoteNeedingCharacters\[2\] = rhs;
}

const TCHAR* CFormat::GetRecordDelimiters() const
{
	return m_RecordDelimiters;
}

const TCHAR* CFormat::GetQuoteNeedingCharacters() const
{
	return m_QuoteNeedingCharacters;
}

bool CFormat::IsFieldDelimiter(TCHAR rhs) const
{
	return rhs == m_FieldDelimiter;
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

bool CFormat::IsQuoteCharacter(TCHAR rhs) const
{
	return m_ExpectQuoteCharacter && (rhs == m_QuoteCharacter);
}

void CFormat::QuoteString(tstring& rhs) const
{
	if (!m_ExpectQuoteCharacter) return;
	tstring result = _T("");
	size_t n = rhs.length();
	for (size_t i = 0; i < n; ++i)
	{
		const TCHAR c = rhs\[i\];
		result += c;
		if (c == m_QuoteCharacter)
			result += c;
	}
	result = m_QuoteCharacter + result + m_QuoteCharacter;
	rhs = result;
}

} // namespace csv
} // namespace tablelike
} // namespace text
} // namespace altova

