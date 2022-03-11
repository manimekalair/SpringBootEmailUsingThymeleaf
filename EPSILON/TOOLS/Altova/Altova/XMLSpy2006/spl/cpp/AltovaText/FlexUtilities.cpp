[call GenerateFileHeader("FlexUtilities.cpp")]
#include "StdAfx.h"
#include "Generator.h"
#include "FlexUtilities.h"

namespace altova
{
namespace text
{
namespace flex
{

static const TCHAR CR = _T('\\r');
static const TCHAR LF = _T('\\n');
static const TCHAR TAB = _T('\\t');


//////////////////////////////////////////////////////////////////////////

CTextRange CSplitAtPosition::Split(CTextRange& range) const
{
	if (m_nPosition < 0)
	{
		// count from right
		size_t nChars = min((size_t)-m_nPosition, range.length());
		CTextRange result(range.m_pEnd - nChars, nChars);
		range.m_pStart = result.m_pEnd;
		return result;
	}
	else
	{
		// count from left
		CTextRange result(range.m_pStart, min((size_t)m_nPosition, range.length()));
		range.m_pStart = result.m_pEnd;
		return result;
	}
}

//////////////////////////////////////////////////////////////////////////

CTextRange CSplitLines::Split(CTextRange& range) const
{
	CTextRange result(range.m_pStart, range.m_pStart);
	if (m_nLines >= 0)
	{
		// count from top
		const TCHAR*& p = result.m_pEnd;

		for (int nLines = m_nLines; nLines > 0 && p != range.m_pEnd; ++p)
		{
			if (*p == CR || *p == LF)
			{
				if (*p == CR && p != range.m_pEnd-1 && *(p+1) == LF)
					++p;

				nLines--;
			}
		}
	}
	else
	{
		// count from bottom
		result.m_pEnd = range.m_pEnd;
		const TCHAR*& p = result.m_pEnd;
		int nLines = -m_nLines;
		if (result && (*(p-1) == CR || *(p-1) == LF))
			nLines++;

		for (; p > range.m_pStart; --p)
		{
			if (*(p-1) == CR || *(p-1) == LF)
			{
				if (!--nLines)
					break;
				if (nLines && *(p-1) == LF && p > range.m_pStart+1 && *(p-2) == CR)
					--p;
			}
		}
	}
	range.m_pStart = result.m_pEnd;
	if (m_RemoveDelimiter)
	{
		if (result.EndsWith(LF))
			result.m_pEnd--;
		if (result.EndsWith(CR))
			result.m_pEnd--;
	}
	return result;
}

void CSplitLines::AppendDelimiter(CTextAppender& output) const
{
	if (m_RemoveDelimiter)
		output.AppendText(_T("\\r\\n"));
}

//////////////////////////////////////////////////////////////////////////

CTextRange CSplitAtDelimiter::Split(CTextRange& range) const
{
	if (m_sDelimiter.empty())
	{
		CTextRange result(range);
		range.m_pStart = range.m_pEnd;
		return result;
	}

	if (m_Reverse)
	{
		CTextRange result(range.m_pStart, range.m_pStart);
		for (const TCHAR* p = range.m_pEnd - m_sDelimiter.length(); p >= range.m_pStart; --p)
		{
			if (*p == m_sDelimiter\[0\])
				if (!memcmp(p, &(m_sDelimiter\[0\]), m_sDelimiter.length() * sizeof(TCHAR)))
				{
					result.m_pEnd = p;
					range.m_pStart = p + m_sDelimiter.length();
					return result;
				}
		}
		return result;
	}
	else
	{
		CTextRange result(range.m_pStart, range.m_pStart);
		result.m_pEnd = search(range.m_pStart, range.m_pEnd, m_sDelimiter.begin(), m_sDelimiter.end());
		range.m_pStart = result.m_pEnd + (result.m_pEnd == range.m_pEnd ? 0 : m_sDelimiter.length() );
		return result;
	}
}

//////////////////////////////////////////////////////////////////////////

CTextRange CSplitAtDelimiterLineBased::Split(CTextRange& range) const
{
	if (m_sDelimiter.empty())
	{
		CTextRange result(range);
		range.m_pStart = range.m_pEnd;
		return result;
	}

	CTextRange result = CSplitAtDelimiter::Split(range);

	while (result && *(result.m_pEnd-1) != CR && *(result.m_pEnd-1) != LF)
		result.m_pEnd--;
	range.m_pStart = result.m_pEnd;
	return result;
}

//////////////////////////////////////////////////////////////////////////

CTextRange CSplitAtDelimiterLineBasedMultiple::Split(CTextRange& range) const
{
	static const CSplitLines splitAtFirstLine(1);
	CTextRange firstLine = splitAtFirstLine.Split(range);
	CTextRange result = CSplitAtDelimiterLineBased::Split(range);
	result.m_pStart = firstLine.m_pStart;
	return result;
}

//////////////////////////////////////////////////////////////////////////

} // namespace flex
} // namespace text
} // namespace altova
