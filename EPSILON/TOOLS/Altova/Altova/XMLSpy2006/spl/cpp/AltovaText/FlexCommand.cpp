[call GenerateFileHeader("FlexCommand.cpp")]
#include "StdAfx.h"
#include "FlexCommand.h"
#include "Generator.h"
#include "TextDocument.h"

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

bool CFlexCommand::ReadText(CTextDocumentReader& document)
{
	if (m_pNext)
		return m_pNext->ReadText(document);
	return true;
}

bool CFlexCommand::WriteText(CTextDocumentWriter& document)
{
	if (m_pNext)
		return m_pNext->WriteText(document);
	return true;
}

//////////////////////////////////////////////////////////////////////////

bool CFlexCommandBlock::ReadText(CTextDocumentReader& document)
{
	tstring sName = GetName();
	CGenerator& rOutputTree = document.GetOutputTree();

	rOutputTree.EnterElement(sName, Group);
	CFlexCommand::ReadText(document);
	rOutputTree.LeaveElement(sName);
	return true;
}

bool CFlexCommandBlock::WriteText(CTextDocumentWriter& document)
{
	CTextNodeContainer children;
	document.m_pCurrentNode->GetChildren().FilterByName(GetName(), children);
	for (size_t i = 0; i < children.GetCount(); ++i)
	{
		tstring restString;
		CTextDocumentWriter rest(children.GetAt(i), restString);

		CFlexCommand::WriteText(document);

		document.AppendText(restString);
	}

	return true;
}

//////////////////////////////////////////////////////////////////////////

bool CFlexCommandProject::ReadText(CTextDocumentReader& document)
{
	if (m_TabSize > 0)
	{
		tstring str = ExpandTabs(document.GetRange(), m_TabSize);
		CTextDocumentReader expandedDoc(str, &(document.GetOutputTree()));

		return CFlexCommandBlock::ReadText(expandedDoc);
	}

	return CFlexCommandBlock::ReadText(document);
}

bool CFlexCommandProject::WriteText(CTextDocumentWriter& document)
{
	return CFlexCommand::WriteText(document);
}

tstring CFlexCommandProject::ExpandTabs(CTextRange range, int tabsize)
{
	tstring result;

	int pos = 0;
	const TCHAR* pStart = range.m_pStart;
	for (const TCHAR* p = pStart; p != range.m_pEnd; ++p)
	{
		if (*p == CR || *p == LF)
			pos = 0;
		else if (*p == TAB)
		{
			result.append(pStart, p - pStart);
			result.append(tabsize - (pos % tabsize), _T(' '));
			pStart = p+1;
			pos = 0;
		}
		else
			pos++;
	}
	result.append(pStart, range.m_pEnd - pStart);
	return result;
}

//////////////////////////////////////////////////////////////////////////

bool CFlexCommandSplitSingle::ReadText(CTextDocumentReader& document)
{
	CTextRange range = document.GetRange();

	if (m_Orientation == 1 && ContainsMultipleLines(range))
		return ReadTextMultilineVertical(document);

	CTextRange firstRange = m_pSplitter->Split(range);

	CTextDocumentReader first(document, firstRange);
	CTextDocumentReader rest(document, range);

	return WriteNodeAndCallChildren(first, rest);
}

bool CFlexCommandSplitSingle::ContainsMultipleLines(const CTextRange& range)
{
	static const CSplitLines lineSplitter(1);
	CTextRange range2 = range;
	lineSplitter.Split(range2);
	return range2;
}

bool CFlexCommandSplitSingle::ContainsMultipleLines(const tstring& str)
{
	CTextRange range(str);
	return ContainsMultipleLines(range);
}

bool CFlexCommandSplitSingle::WriteNodeAndCallChildren(CTextDocumentReader& first, CTextDocumentReader& rest)
{
	CGenerator& rOutputTree = first.GetOutputTree();
	rOutputTree.EnterElement(GetName(), Group);
	{
		if (m_pFirst)
			m_pFirst->ReadText(first);
		if (m_pNext)
			m_pNext->ReadText(rest);
	}
	rOutputTree.LeaveElement(GetName());
	return true;
}

bool CFlexCommandSplitSingle::ReadTextMultilineVertical(CTextDocumentReader& document)
{
	tstring leftCol, rightCol;

	SplitMultilineVertical(document.GetRange(), m_pFirst ? &leftCol : NULL, m_pNext ? &rightCol : NULL);

	CTextDocumentReader first(leftCol, &document.GetOutputTree());
	CTextDocumentReader rest(rightCol, &document.GetOutputTree());

	return WriteNodeAndCallChildren(first, rest);
}

void CFlexCommandSplitSingle::SplitMultilineVertical(CTextRange range, tstring* pLeft, tstring* pRight)
{
	static const CSplitLines lineSplitter(1);
	while (range)
	{
		CTextRange line = lineSplitter.Split(range);
		CTextRange leftRange = m_pSplitter->Split(line);

		if (leftRange.EndsWith(CR) && line.StartsWith(LF))
		{
			leftRange.m_pEnd--;
			line.m_pStart--;
		}

		if (pLeft)
		{
			leftRange.AppendTo(*pLeft);
			if (!leftRange.EndsWith(CR) && !leftRange.EndsWith(LF))
				pLeft->append(_T("\\r\\n"));
		}

		if (pRight)
		{
			if (line)
				line.AppendTo(*pRight);
			else
				pRight->append(_T("\\r\\n"));
		}
	}
}

bool CFlexCommandSplitSingle::WriteText(CTextDocumentWriter& document)
{
	CTextNodeContainer children;
	document.m_pCurrentNode->GetChildren().FilterByName(GetName(), children);
	for (size_t i = 0; i < children.GetCount(); ++i)
	{
		tstring firstString, restString;
		if (m_pFirst)
		{
			CTextDocumentWriter first(children.GetAt(i), firstString);
			m_pFirst->WriteText(first);
		}
		if (m_pNext)
		{
			CTextDocumentWriter rest(children.GetAt(i), restString);
			m_pNext->WriteText(rest);
		}

		if (m_Orientation == 1 && (ContainsMultipleLines(firstString) || ContainsMultipleLines(restString)))
		{
			document.AppendText(MergeMultilineVertical(firstString, restString));
		}
		else
		{
			document.AppendText(firstString);
			m_pSplitter->AppendDelimiter(document);
			document.AppendText(restString);
		}
	}

	return true;
}

tstring CFlexCommandSplitSingle::MergeMultilineVertical(const tstring& left, const tstring& right)
{
	tstring result;
	static const CSplitLines lineSplitter(1);
	CTextRange leftRange(left);
	CTextRange rightRange(right);

	while (leftRange || rightRange)
	{
		CTextRange leftLine = lineSplitter.Split(leftRange);
		CTextRange rightLine = lineSplitter.Split(rightRange);
		if (leftLine.EndsWith(LF))
			leftLine.m_pEnd--;
		if (leftLine.EndsWith(CR))
			leftLine.m_pEnd--;
		if (m_Offset >= 0)
		{
			result += leftLine.ToString().substr(0, min(leftLine.length(), (size_t) m_Offset)); 
			if (leftLine.length() < (size_t) m_Offset)
			{
				tstring filler(m_Offset - leftLine.length(), _T(' '));
				result += filler;
			}
			result += rightLine.ToString();
		}
		else
		{
			result += leftLine.ToString();
			if (rightLine.length() < (size_t) -m_Offset)
			{
				tstring filler(-m_Offset - rightLine.length(), _T(' '));
				result += filler;
			}
			result += rightLine.ToString().substr(max(0, ((int)rightLine.length()) + m_Offset));
		}
	}

	return result;
}


//////////////////////////////////////////////////////////////////////////

bool CFlexCommandSplitMultiple::ReadText(CTextDocumentReader& document)
{
	if (!m_pNext)
		return true;

	CTextRange range = document.GetRange();

	if (m_Orientation == 1 && ContainsMultipleLines(range))
		return ReadTextMultilineVertical(document);

	while (range)
	{
		CTextRange partRange = m_pSplitter->Split(range);

		CTextDocumentReader part(document, partRange);

		CGenerator& rOutputTree = document.GetOutputTree();
		rOutputTree.EnterElement(GetName(), Group);
		m_pNext->ReadText(part);
		rOutputTree.LeaveElement(GetName());
	}
	return true;
}

bool CFlexCommandSplitMultiple::ReadTextMultilineVertical(CTextDocumentReader& document)
{
	tstring text = document.GetRange().ToString();

	while (text.find_first_not_of(_T("\\r\\n")) != tstring::npos)
		{
		tstring leftCol, rest;
		CTextRange range(text);
		SplitMultilineVertical(range, &leftCol, &rest);

		CGenerator& rOutputTree = document.GetOutputTree();
		rOutputTree.EnterElement(GetName(), Group);
		CTextDocumentReader part(leftCol, &rOutputTree);
		m_pNext->ReadText(part);
		rOutputTree.LeaveElement(GetName());

		text = rest;
	}
	return true;
}

bool CFlexCommandSplitMultiple::WriteText(CTextDocumentWriter& document)
{
	CTextNodeContainer children;
	document.m_pCurrentNode->GetChildren().FilterByName(GetName(), children);
	if (m_Orientation == 1 && m_pNext)
	{
		return WriteTextMultilineVertical(document);
	}
	for (size_t i = 0; i < children.GetCount(); ++i)
	{
		if (i != 0)
			m_pSplitter->AppendDelimiter(document);

		tstring restString;
		CTextDocumentWriter rest(children.GetAt(i), restString);

		CFlexCommand::WriteText(rest);

		document.AppendText(restString);
	}

	return true;
}

bool CFlexCommandSplitMultiple::WriteTextMultilineVertical(CTextDocumentWriter& document)
{
	vector<tstring> lines;
	CTextNodeContainer children;
	document.m_pCurrentNode->GetChildren().FilterByName(GetName(), children);
	for (size_t i = 0; i < children.GetCount(); ++i)
	{
		tstring col;
		CTextDocumentWriter colWriter(children.GetAt(i), col);
		m_pNext->WriteText(colWriter);

		bool isLast = (i == children.GetCount() - 1);

		static const CSplitLines lineSplitter(1);
		unsigned int lineno = 0;
		CTextRange range(col);
		while (range)
		{
			CTextRange lineRange = lineSplitter.Split(range);
			if (!isLast)
			{
				if (lineRange.EndsWith(LF))
					lineRange.m_pEnd--;
				if (lineRange.EndsWith(CR))
					lineRange.m_pEnd--;
			}
			tstring line = lineRange.ToString();
			if (!isLast && line.length() < (size_t) m_Offset)
			{
				tstring filler(m_Offset - line.length(), _T(' '));
				line += filler;
			}
			
			++lineno;
			if (lines.size() < lineno)
				lines.resize(lineno);
			lines\[lineno-1\] += line;
		}
	}

	for (vector<tstring>::const_iterator it = lines.begin(); it != lines.end(); ++it)
		document.AppendText(*it);

	return true;
}

//////////////////////////////////////////////////////////////////////////

bool CFlexCommandStore::ReadText(CTextDocumentReader& document)
{
	CGenerator& rOutputTree = document.GetOutputTree();
	tstring value = document.GetRange().ToString();
	if (m_TrimSide & 2)
	{
		tstring::size_type pos = value.find_last_not_of(m_TrimChars);
		if (pos != tstring::npos)
			value.erase(pos+1);
	}	
	if (m_TrimSide & 1)
	{
		tstring::size_type pos = value.find_first_not_of(m_TrimChars);
		if (pos != tstring::npos)
			value.erase(0, pos);
	}
	rOutputTree.InsertElement(GetName(), value, DataElement);
	return true;
}

bool CFlexCommandStore::WriteText(CTextDocumentWriter& document)
{
	const CTextNode* pNode = document.EnterElement(GetName());
	if (pNode)
	{
		tstring sFieldValue = pNode->GetValue();
		document.AppendText(sFieldValue);
		document.LeaveElement();
		return true;
	}

	return false;
}

//////////////////////////////////////////////////////////////////////////

bool CFlexCondition::Evaluate(CTextDocumentReader& document)
{
	CTextRange range = document.GetRange();
	switch (m_Type) 
	{
		case ContentStartWith:
			return range.StartsWith(m_Value);
		
		case ContentContains:
			return range.Contains(m_Value);
	}
	return false;
}

bool CFlexCondition::ReadText(CTextDocumentReader& document)
{
	if (!Evaluate(document))
		return false;
	return CFlexCommand::ReadText(document);
}

bool CFlexCondition::WriteText(CTextDocumentWriter& document)
{
	return CFlexCommand::WriteText(document);
}

bool CFlexCommandSwitch::ReadText(CTextDocumentReader& document)
{
	bool ret = true;
	int nMatches = 0;
	
	document.GetOutputTree().EnterElement(GetName(), Group);
	
    for (int i = 0; i < m_nConditions; ++i)
    	if (m_Conditions\[i\].ReadText(document))
		{
    		nMatches++;
			if (m_nMode == 0) // first match
				break;
		}
    if (!nMatches)		// default
    	ret = CFlexCommand::ReadText(document);

	document.GetOutputTree().LeaveElement(GetName());
	
	return true;
}

bool CFlexCommandSwitch::WriteText(CTextDocumentWriter& document)
{
	CTextNodeContainer children;
	document.m_pCurrentNode->GetChildren().FilterByName(GetName(), children);
	
	for(size_t i=0;i<children.GetCount();++i)
	{
		tstring restString;
		CTextDocumentWriter restDoc(children.GetAt(i), restString);
		for (int cond=0; cond<m_nConditions; ++cond)
			m_Conditions\[cond\].WriteText(restDoc);
		
		CFlexCommand::WriteText(restDoc);
		
		document.AppendText(restString);
	}
	return true;
}

//////////////////////////////////////////////////////////////////////////

bool CFlexCommandCSV::ReadText(CTextDocumentReader& document)
{
	CTextRange range = document.GetRange();
	int nColumns = m_nColumns;

	if (m_ColumnHeaders)
	{
		static const CSplitAtDelimiter splitAtFirstLine(m_RowDelimiter);
		CTextRange firstLine = splitAtFirstLine.Split(range);
	}

	while (range)
	{
		vector<tstring> values;
		ReadNextRow(range, values);

		CGenerator& rOutputTree = document.GetOutputTree();
		rOutputTree.EnterElement(GetName(), Group);
		for (int col = 0; col < min(nColumns, (int) values.size()); ++col)
		{
			if (col >= 0 && col < m_nColumns && m_pColumns\[col\].m_pNext)
			{
				CTextDocumentReader cell(values\[col\], &document.GetOutputTree());
				m_pColumns\[col\].m_pNext->ReadText(cell);
			}
		}
		rOutputTree.LeaveElement(GetName());
	}
	
	return true;
}

bool CFlexCommandCSV::ReadNextRow(CTextRange& range, vector<tstring>& values)
{
	bool morecols = true;
	while (range && morecols)
	{
		tstring value;
		morecols = ReadNextCell(range, value);
		values.push_back(value);
	}
	return true;
}

bool CFlexCommandCSV::ReadNextCell(CTextRange& range, tstring& value)
{
	value = _T("");
	bool insideQuotes = false;
	bool escaped = false;

	for (const TCHAR*& p = range.m_pStart; p != range.m_pEnd; ++p)
	{
		if (*p == m_RowDelimiter\[0\] && !insideQuotes && DelimiterMatches(p, range.m_pEnd, m_RowDelimiter))
		{
			range.m_pStart += m_RowDelimiter.length();
			return false; // last column
		}

		if (*p == m_ColDelimiter\[0\] && !insideQuotes && DelimiterMatches(p, range.m_pEnd, m_ColDelimiter))
		{
			range.m_pStart += m_ColDelimiter.length();
			return true; // more columns follow
		}

		if (*p == m_EscapeChar && !escaped && insideQuotes)
		{
			escaped = true;
			continue;
		}

		if (*p == m_QuoteChar && !escaped)
		{
			insideQuotes = !insideQuotes;
			continue;
		}

		value += *p;
		escaped = false;
	}

	return false; // incomplete row, no more columns
}

bool CFlexCommandCSV::WriteText(CTextDocumentWriter& document)
{
	if (m_ColumnHeaders)
	{
		for (int col = 0; col < m_nColumns; ++col)
		{
			if (col != 0)
				document.AppendText(m_ColDelimiter);
			tstring quotedString;
			document.AppendText(QuoteIfNeeded(m_pColumns\[col\].m_pName, quotedString));
		}
		document.AppendText(m_RowDelimiter);
	}

	CTextNodeContainer children;
	document.m_pCurrentNode->GetChildren().FilterByName(GetName(), children);
	for (size_t row = 0; row < children.GetCount(); ++row)
	{
		CTextNode& rowNode = children.GetAt(row);

		for (int col = 0; col < m_nColumns; ++col)
		{
			if (col != 0)
				document.AppendText(m_ColDelimiter);

			if (m_pColumns\[col\].m_pNext)
			{
				tstring cellString;
				CTextDocumentWriter cellDoc(rowNode, cellString);
				m_pColumns\[col\].m_pNext->WriteText(cellDoc);
				tstring quotedString;
				document.AppendText(QuoteIfNeeded(cellString, quotedString));
			}
		}
		document.AppendText(m_RowDelimiter);
	}

	return true;
}

const tstring& CFlexCommandCSV::QuoteIfNeeded(const tstring& str, tstring& quoted)
{
	if (m_QuoteChar == 0)
		return str; // quoting is disabled
	tstring::size_type p = str.find(m_QuoteChar);
	if (p == tstring::npos)
		p = str.find(m_ColDelimiter);
	if (p == tstring::npos)
		p = str.find(m_RowDelimiter);
	if (p != tstring::npos)
	{
		quoted = m_QuoteChar;
		quoted.append(str.begin(), str.begin() + p);
		for (tstring::const_iterator it = str.begin() + p; it != str.end(); ++it)
		{
			if (*it == m_QuoteChar || *it == m_EscapeChar)
				quoted += m_EscapeChar ? m_EscapeChar : m_QuoteChar;
			quoted += *it;
		}
		quoted += m_QuoteChar;
		return quoted;
	}
	return str;
}

//////////////////////////////////////////////////////////////////////////

bool CFlexCommandFLF::ReadText(CTextDocumentReader& document)
{
	CTextRange range = document.GetRange();

	if (m_ColumnHeaders)
	{
		CTextRange firstLine = m_pSplitter->Split(range);
	}

	while (range)
	{
		CTextRange lineRange = m_pSplitter->Split(range);

		CGenerator& rOutputTree = document.GetOutputTree();
		rOutputTree.EnterElement(GetName(), Group);
		{
			for (int col = 0; col < m_nColumns; ++col)
			{
				CSplitAtPosition splitField(m_pColumns\[col\].m_Width);
				CTextRange cellRange = splitField.Split(lineRange);
				if (m_pColumns\[col\].m_pNext)
				{
					CTextDocumentReader cell(document, cellRange);
					m_pColumns\[col\].m_pNext->ReadText(cell);
				}
			}
		}
		rOutputTree.LeaveElement(GetName());
	}
	
	return true;
}

bool CFlexCommandFLF::WriteText(CTextDocumentWriter& document)
{
	if (m_ColumnHeaders)
	{
		for (int col = 0; col < m_nColumns; ++col)
		{
			document.AppendText(FormatCell(m_pColumns\[col\].m_pName, m_pColumns\[col\]));
		}
		m_pSplitter->AppendDelimiter(document);
	}

	CTextNodeContainer children;
	document.m_pCurrentNode->GetChildren().FilterByName(GetName(), children);
	for (size_t row = 0; row < children.GetCount(); ++row)
	{
		CTextNode& rowNode = children.GetAt(row);

		for (int col = 0; col < m_nColumns; ++col)
		{
			if (m_pColumns\[col\].m_pNext)
			{
				tstring cellString;
				CTextDocumentWriter cellDoc(rowNode, cellString);
				m_pColumns\[col\].m_pNext->WriteText(cellDoc);
				cellString = FormatCell(cellString, m_pColumns\[col\]);
				document.AppendText(cellString);
			}
		}
		m_pSplitter->AppendDelimiter(document);
	}
	return true;
}

tstring CFlexCommandFLF::FormatCell(tstring str, const CFlexColumnFixed &Column)
{
	if (Column.m_Alignment == 1)
	{
		// align right
		if (str.length() > (size_t) Column.m_Width)
			str.erase(0, str.length() - Column.m_Width);
		tstring strFill(Column.m_Width - str.length(), Column.m_FillChar);
		str = strFill + str;
	}
	else
	{
		// align left
		if (str.length() > (size_t) Column.m_Width)
			str.erase(Column.m_Width);
		tstring strFill(Column.m_Width - str.length(), Column.m_FillChar);
		str += strFill;
	}
	return str;
}


//////////////////////////////////////////////////////////////////////////

} // namespace flex
} // namespace text
} // namespace altova
