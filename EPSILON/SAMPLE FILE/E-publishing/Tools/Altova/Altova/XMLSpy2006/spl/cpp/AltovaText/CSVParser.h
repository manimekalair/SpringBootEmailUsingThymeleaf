[call GenerateFileHeader("CSVParser.h")]
#ifndef __ALTOVATEXT_CSVPARSER_H
#define __ALTOVATEXT_CSVPARSER_H

#include "RecordBasedParser.h"

namespace altova
{
namespace text
{
namespace tablelike
{
namespace csv
{

class ALTOVATEXT_DECLSPECIFIER CBadFormatException : public CMappingException
{
public:
	CBadFormatException(const tstring& msg);
};

class ALTOVATEXT_DECLSPECIFIER CParserException : public CMappingException
{
public:
	CParserException(const CBadFormatException& ex, size_t linenumber);
	size_t GetLineNumber() const;

private:
	size_t m_LineNumber;
};

struct ALTOVATEXT_DECLSPECIFIER IInternalParserInterface
{
	virtual bool WasLastCharacterQuote() const= 0;
	virtual bool WasLastCharacterFieldDelimiter() const= 0;
	virtual bool IsEndOfBuffer() const= 0;
	virtual TCHAR GetCurrentCharacter() const= 0;
	virtual void NotifyAboutTokenComplete()= 0;
	virtual void NotifyAboutEndOfRecord()= 0;
	virtual void MoveNext()= 0;
	virtual void AppendCharacterToToken(TCHAR rhs)= 0;
};

class CWaitingForFieldState;
class CInsideFieldState;
class CInsideQuotedFieldState;

class ALTOVATEXT_DECLSPECIFIER CParserStateFactory
{
public:
	CParserStateFactory(IInternalParserInterface& owner);
	~CParserStateFactory();
	CWaitingForFieldState& GetWaitingForField() const;
	CInsideFieldState& GetInsideField() const;
	CInsideQuotedFieldState& GetInsideQuotedField() const;

private:
	CWaitingForFieldState* m_pWaitingForField;
	CInsideFieldState* m_pInsideField;
	CInsideQuotedFieldState* m_pInsideQuotedField;
};

class ALTOVATEXT_DECLSPECIFIER CParserState
{
public:
	virtual CParserState& Process(TCHAR current)= 0;
	virtual CParserState& ProcessFieldDelimiter(TCHAR current)= 0;
	virtual CParserState& ProcessRecordDelimiter(TCHAR current)= 0;
	virtual CParserState& ProcessQuoteCharacter(TCHAR current)= 0;
	
protected:
	CParserState(IInternalParserInterface& owner, CParserStateFactory& states);
	IInternalParserInterface& GetOwner() const;
	CParserStateFactory& GetStates();
	
private:
	IInternalParserInterface& m_Owner;
	CParserStateFactory& m_States;
};

class ALTOVATEXT_DECLSPECIFIER CWaitingForFieldState : public CParserState
{
public:
	CWaitingForFieldState(IInternalParserInterface& owner, CParserStateFactory& states);
	
public:
	virtual CParserState& Process(TCHAR current);
	virtual CParserState& ProcessFieldDelimiter(TCHAR current);
	virtual CParserState& ProcessRecordDelimiter(TCHAR current);
	virtual CParserState& ProcessQuoteCharacter(TCHAR current);
};

class ALTOVATEXT_DECLSPECIFIER CInsideFieldState : public CParserState
{
public:
	CInsideFieldState(IInternalParserInterface& owner, CParserStateFactory& states);
public:
	virtual CParserState& Process(TCHAR current);
	virtual CParserState& ProcessFieldDelimiter(TCHAR current);
	virtual CParserState& ProcessRecordDelimiter(TCHAR current);
	virtual CParserState& ProcessQuoteCharacter(TCHAR current);

};

class ALTOVATEXT_DECLSPECIFIER CInsideQuotedFieldState : public CParserState
{
public:
	CInsideQuotedFieldState(IInternalParserInterface& owner, CParserStateFactory& states);

public:
	virtual CParserState& Process(TCHAR current);
	virtual CParserState& ProcessFieldDelimiter(TCHAR current);
	virtual CParserState& ProcessRecordDelimiter(TCHAR current);
	virtual CParserState& ProcessQuoteCharacter(TCHAR current);

};

class CFormat;

struct ALTOVATEXT_DECLSPECIFIER IParser : public CRecordBasedParser
{
	virtual CFormat& GetFormat()= 0;
};

class ALTOVATEXT_DECLSPECIFIER CParser : public IParser, public IInternalParserInterface 
{
public:
	CParser(CFormat& format);
	virtual ~CParser();
	
public: // implementing IParser:
	virtual int Parse(const tstring& buffer);
	virtual CFormat& GetFormat();

public:	// implementing IInternalParserInterface
	virtual bool IsEndOfBuffer() const;
	virtual bool WasLastCharacterFieldDelimiter() const;
	virtual bool WasLastCharacterQuote() const;
	virtual TCHAR GetCurrentCharacter() const;
	virtual void MoveNext();
	virtual void AppendCharacterToToken(TCHAR rhs);
	virtual void NotifyAboutEndOfRecord();
	virtual void NotifyAboutTokenComplete();

private:
	void ClearFields();

private:
	CFormat& m_Format;
	tstring m_Buffer;
	tstring::size_type m_CurrentOffset;
	CParserState* m_CurrentState;
	CParserStateFactory* m_States;
	tstring m_Token;
	TStringList m_Fields;
	size_t m_FirstRecordFieldCount;
	size_t m_RecordCount;
};

} // namespace csv
} // namespace tablelike
} // namespace text
} // namespace altova

#endif 
