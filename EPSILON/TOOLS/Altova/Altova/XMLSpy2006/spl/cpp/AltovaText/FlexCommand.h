[call GenerateFileHeader("FlexCommand.h")]
#ifndef __ALTOVATEXT_FLEXCOMMAND_H
#define __ALTOVATEXT_FLEXCOMMAND_H

#include "FlexUtilities.h"

namespace altova 
{
namespace text
{
namespace flex
{

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CFlexCommand
{
public:
	CFlexCommand(const TCHAR* pName = _T("")) : m_sName(pName), m_pNext(NULL) { }
	virtual ~CFlexCommand() {}

	virtual bool ReadText(CTextDocumentReader& document);
	virtual bool WriteText(CTextDocumentWriter& document);

	tstring GetName() { return m_sName; }

	void SetNext(CFlexCommand* pNext) { m_pNext = pNext; }

protected:
	CFlexCommand* m_pNext;
	tstring m_sName;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CFlexCommandBlock : public CFlexCommand
{
public:
	CFlexCommandBlock(const TCHAR* pName) :
		CFlexCommand(pName)
	{
	}

	virtual bool ReadText(CTextDocumentReader& document);
	virtual bool WriteText(CTextDocumentWriter& document);
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CFlexCommandProject : public CFlexCommandBlock
{
public:
	CFlexCommandProject(const TCHAR* pName, int tabsize = 0) :
		CFlexCommandBlock(pName), m_TabSize(tabsize)
	{
	}

	virtual bool ReadText(CTextDocumentReader& document);
	virtual bool WriteText(CTextDocumentWriter& document);

protected:
	static tstring ExpandTabs(CTextRange range, int tabsize);
	int m_TabSize;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CFlexCommandSplitSingle : public CFlexCommand
{
public:
	CFlexCommandSplitSingle(const TCHAR* pName, CTextSplitter* pSplitter, int orientation = 0, int offset = 0) :
		CFlexCommand(pName), m_pSplitter(pSplitter), m_Orientation(orientation), m_Offset(offset)
	{}

	virtual bool ReadText(CTextDocumentReader& document);
	virtual bool WriteText(CTextDocumentWriter& document);

	void SetFirst(CFlexCommand* pFirst) { m_pFirst = pFirst; }

protected:
	bool ContainsMultipleLines(const CTextRange& range);
	bool ContainsMultipleLines(const tstring& str);
	bool WriteNodeAndCallChildren(CTextDocumentReader& first, CTextDocumentReader& rest);
	bool ReadTextMultilineVertical(CTextDocumentReader& document);
	void SplitMultilineVertical(CTextRange range, tstring* pLeft, tstring* pRight);
	tstring MergeMultilineVertical(const tstring& left, const tstring& right);

	CTextSplitter* m_pSplitter;
	CFlexCommand* m_pFirst;
	int m_Orientation;
	int m_Offset;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CFlexCommandSplitMultiple : public CFlexCommandSplitSingle
{
public:
	CFlexCommandSplitMultiple(const TCHAR* pName, CTextSplitter* pSplitter, int orientation = 0, int offset = 0) :
		CFlexCommandSplitSingle(pName, pSplitter, orientation, offset)
	{}

	virtual bool ReadText(CTextDocumentReader& document);
	virtual bool WriteText(CTextDocumentWriter& document);

protected:
	bool ReadTextMultilineVertical(CTextDocumentReader& document);
	bool WriteTextMultilineVertical(CTextDocumentWriter& document);
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CFlexCommandStore : public CFlexCommand
{
public:
	CFlexCommandStore(const TCHAR* pName, int trimside, const TCHAR* pTrimChars) :
		CFlexCommand(pName), m_TrimSide(trimside), m_TrimChars(pTrimChars)
	{}

	virtual bool ReadText(CTextDocumentReader& document);
	virtual bool WriteText(CTextDocumentWriter& document);

protected:
	int m_TrimSide;
	tstring m_TrimChars;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CFlexCondition : public CFlexCommand
{
public:
	enum ConditionType {ContentStartWith, ContentContains};
	CFlexCondition(const TCHAR* pName, ConditionType type, const TCHAR* pValue) :
		CFlexCommand(pName), m_Type(type), m_Value(pValue)
	{}

	virtual bool Evaluate(CTextDocumentReader& document);
	virtual bool ReadText(CTextDocumentReader& document);
	virtual bool WriteText(CTextDocumentWriter& document);

protected:
	tstring m_Value;
	ConditionType m_Type;
};

class ALTOVATEXT_DECLSPECIFIER CFlexCommandSwitch : public CFlexCommand
{
public:
	CFlexCommandSwitch(const TCHAR* pName, int nConditions, CFlexCondition conditions\[\], int mode) :
		CFlexCommand(pName), m_nConditions(nConditions), m_Conditions(conditions), m_nMode(mode)
	{}

	virtual bool ReadText(CTextDocumentReader& document);
	virtual bool WriteText(CTextDocumentWriter& document);
	CFlexCondition& GetCondition(int index) {return m_Conditions\[index\];}

protected:
	int m_nConditions;
	CFlexCondition* m_Conditions;
	int m_nMode;
};

//////////////////////////////////////////////////////////////////////////

struct ALTOVATEXT_DECLSPECIFIER CFlexColumnDelimited
{
	CFlexCommand* m_pNext;
	const TCHAR* m_pName;
};

class ALTOVATEXT_DECLSPECIFIER CFlexCommandCSV : public CFlexCommand
{
public:
	CFlexCommandCSV(const TCHAR* pName, int nColumns, const CFlexColumnDelimited columns\[\], bool headers, const tstring& rowsep, const tstring& colsep, TCHAR quote, TCHAR escape) :
		CFlexCommand(pName), m_nColumns(nColumns), m_pColumns(columns), m_ColumnHeaders(headers), m_RowDelimiter(rowsep), m_ColDelimiter(colsep), m_QuoteChar(quote), m_EscapeChar(escape)
	{}

	virtual bool ReadText(CTextDocumentReader& document);
	virtual bool WriteText(CTextDocumentWriter& document);

protected:
	int m_nColumns;
	const CFlexColumnDelimited* m_pColumns;
	bool m_ColumnHeaders;
	tstring m_RowDelimiter;
	tstring m_ColDelimiter;
	TCHAR m_QuoteChar;
	TCHAR m_EscapeChar;

	bool ReadNextRow(CTextRange& range, vector<tstring>& values);
	bool ReadNextCell(CTextRange& range, tstring& value);
	bool CFlexCommandCSV::DelimiterMatches(const TCHAR* p, const TCHAR* pEnd, const tstring& delimiter)
	{
		return (delimiter.length() <= (size_t)(pEnd - p) && !memcmp(delimiter.c_str(), p, delimiter.length() * sizeof(TCHAR)));
	}
	const tstring& QuoteIfNeeded(const tstring& str, tstring& quoted);
};

//////////////////////////////////////////////////////////////////////////

struct ALTOVATEXT_DECLSPECIFIER CFlexColumnFixed
{
	CFlexCommand* m_pNext;
	int m_Width;
	TCHAR m_FillChar;
	int m_Alignment;
	const TCHAR* m_pName;
};

class ALTOVATEXT_DECLSPECIFIER CFlexCommandFLF : public CFlexCommand
{
public:
	CFlexCommandFLF(const TCHAR* pName, int nColumns, const CFlexColumnFixed columns\[\], bool headers, CTextSplitter* pSplitterRows) :
		CFlexCommand(pName), m_nColumns(nColumns), m_pColumns(columns), m_ColumnHeaders(headers), m_pSplitter(pSplitterRows)
	{}

	virtual bool ReadText(CTextDocumentReader& document);
	virtual bool WriteText(CTextDocumentWriter& document);

protected:
	CTextSplitter* m_pSplitter;
	int m_nColumns;
	const CFlexColumnFixed* m_pColumns;
	bool m_ColumnHeaders;

	tstring FormatCell(tstring str, const CFlexColumnFixed &Column);
};

//////////////////////////////////////////////////////////////////////////

} // namespace flex
} // namespace text
} // namespace altova

#endif
