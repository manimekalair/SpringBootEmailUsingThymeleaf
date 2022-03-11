[call GenerateFileHeader("FlexUtilities.h")]
#ifndef __ALTOVATEXT_FLEXUTILITIES_H
#define __ALTOVATEXT_FLEXUTILITIES_H

#include "TextNode.h"

namespace altova 
{
namespace text
{

class CGenerator;
class CTextNode;


namespace flex
{

//////////////////////////////////////////////////////////////////////////

struct CTextRange
{
	const TCHAR* m_pStart;
	const TCHAR* m_pEnd;

	CTextRange(const TCHAR* start, const TCHAR* end) : m_pStart(start), m_pEnd(end)
	{}
	CTextRange(const TCHAR* start, size_t n) : m_pStart(start), m_pEnd(start + n)
	{}
	CTextRange(const tstring& str) : m_pStart(str.c_str()), m_pEnd(str.c_str() + str.length())
	{}
	size_t length() { return m_pEnd - m_pStart; }
    operator bool() { return m_pStart < m_pEnd; }
	tstring ToString() { return tstring(m_pStart, length()); }
	void AppendTo(tstring& str) { str.append(m_pStart, length()); }
	bool StartsWith(TCHAR ch) { return (m_pStart < m_pEnd) && (m_pStart\[0\] == ch); }
	bool EndsWith(TCHAR ch) { return (m_pStart < m_pEnd) && (m_pEnd\[-1\] == ch); }
	bool StartsWith(const tstring& str) { return (length() >= str.length() && equal(str.begin(), str.end(), m_pStart)); }
	bool Contains(const tstring& str) {return (length() >= str.length() && search(m_pStart, m_pEnd, str.begin(), str.end()) != m_pEnd); }
};

//////////////////////////////////////////////////////////////////////////

struct ALTOVATEXT_DECLSPECIFIER CTextDocumentReader
{
	CTextRange m_Range;
	const tstring& m_Content;
	CGenerator* m_pOutputGenerator;

	CGenerator& GetOutputTree() { return *m_pOutputGenerator; }
	CTextRange& GetRange() { return m_Range; }

	CTextDocumentReader(const tstring& content, CGenerator* pTree) : 
		m_Content(content),
		m_Range(&content\[0\], content.size()),
		m_pOutputGenerator(pTree)
	{}

	CTextDocumentReader(const CTextDocumentReader& other) :
		m_Range(other.m_Range),
		m_Content(other.m_Content),
		m_pOutputGenerator(other.m_pOutputGenerator)
	{}

	CTextDocumentReader(const CTextDocumentReader& other, const CTextRange& range) :
		m_Range(range),
		m_Content(other.m_Content),
		m_pOutputGenerator(other.m_pOutputGenerator)
	{}
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CTextAppender
{
public:
	virtual void AppendText(const tstring& addtext) = 0;
};

struct ALTOVATEXT_DECLSPECIFIER CTextDocumentWriter : public CTextAppender
{
	const CTextNode& m_Tree;
	const CTextNode* m_pCurrentNode;

	tstring& m_Content;

	const CTextNode& GetInputTree() const { return m_Tree; }

	const CTextNode* EnterElement(const tstring& name)
	{
		const CTextNode* pChild = m_pCurrentNode->GetChildren().GetFirstNodeByName(name);
		if (pChild)
			m_pCurrentNode = pChild;
		return pChild;
	}
	void LeaveElement()
	{
		if (m_pCurrentNode != &m_Tree)
			m_pCurrentNode = &(m_pCurrentNode->GetParent());
	}

	CTextDocumentWriter(const CTextNode& tree, tstring& content) :
		m_Tree(tree),
		m_Content(content)
	{
		m_pCurrentNode = &m_Tree;
	}


	virtual void AppendText(const tstring& addtext)	{ m_Content.append(addtext); }
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CTextSplitter
{
public:
	virtual CTextRange Split(CTextRange& range) const = 0;
	virtual void AppendDelimiter(CTextAppender& output) const = 0;
};


class ALTOVATEXT_DECLSPECIFIER CSplitAtPosition : public CTextSplitter
{
public:
	CSplitAtPosition(int nPosition) : m_nPosition(nPosition) {}
	virtual CTextRange Split(CTextRange& range) const;
	virtual void AppendDelimiter(CTextAppender& output) const {}

protected:
	int m_nPosition;
};


class ALTOVATEXT_DECLSPECIFIER CSplitLines : public CTextSplitter
{
public:
	CSplitLines(int nLines, bool removeDelimiter = false) : m_nLines(nLines), m_RemoveDelimiter(removeDelimiter) {}
	virtual CTextRange Split(CTextRange& range) const;
	virtual void AppendDelimiter(CTextAppender& output) const;

protected:
	int m_nLines;
	bool m_RemoveDelimiter;
};


class ALTOVATEXT_DECLSPECIFIER CSplitAtDelimiter : public CTextSplitter
{
public:
	CSplitAtDelimiter(const tstring& sDelimiter, bool reverse = false) : m_sDelimiter(sDelimiter), m_Reverse(reverse) {}
	virtual CTextRange Split(CTextRange& range) const;
	virtual void AppendDelimiter(CTextAppender& output) const { output.AppendText(m_sDelimiter); }

protected:
	tstring m_sDelimiter;
	bool m_Reverse;
};


class ALTOVATEXT_DECLSPECIFIER CSplitAtDelimiterLineBased : public CSplitAtDelimiter
{
public:
	CSplitAtDelimiterLineBased(const tstring& sDelimiter, bool reverse) : CSplitAtDelimiter(sDelimiter, reverse) {}
	virtual CTextRange Split(CTextRange& range) const;
	virtual void AppendDelimiter(CTextAppender& output) const {} // delimiter must already be in second part
};


class ALTOVATEXT_DECLSPECIFIER CSplitAtDelimiterLineBasedMultiple : public CSplitAtDelimiterLineBased
{
public:
	CSplitAtDelimiterLineBasedMultiple(const tstring& sDelimiter) : CSplitAtDelimiterLineBased(sDelimiter, false) {}
	virtual CTextRange Split(CTextRange& range) const;
};


//////////////////////////////////////////////////////////////////////////

} // namespace flex
} // namespace text
} // namespace altova

#endif
