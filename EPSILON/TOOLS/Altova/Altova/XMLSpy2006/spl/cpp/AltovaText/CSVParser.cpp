[call GenerateFileHeader("CSVParser.cpp")]
#include "stdafx.h"
#include "Helpers.h"
#include "CSVParser.h"
#include "CSVFormat.h"

namespace altova
{
namespace text
{
namespace tablelike
{
namespace csv
{

// CBadFormatException:
CBadFormatException::CBadFormatException(const tstring& msg)
:	CMappingException(msg)
{
}

// ------------------------------------------------------------------------------------

// CParserException:
CParserException::CParserException(const CBadFormatException& ex, size_t linenumber)
:	m_LineNumber(linenumber)
{
#ifdef _UNICODE
	std::wstringstream ss;
#else
	std::stringstream ss;
#endif
	ss << ex.GetMessage() << _T(" at line #") << linenumber;
	CMappingException::SetMessage(ss.str());
}

size_t CParserException::GetLineNumber() const
{
	return m_LineNumber;
}

// ------------------------------------------------------------------------------------

// CParserStateFactory:
CParserStateFactory::CParserStateFactory(IInternalParserInterface& owner)
{
	m_pWaitingForField = new CWaitingForFieldState(owner, *this);
	m_pInsideField = new CInsideFieldState(owner, *this);
	m_pInsideQuotedField = new CInsideQuotedFieldState(owner, *this);
}

CParserStateFactory::~CParserStateFactory()
{
	delete m_pInsideQuotedField;
	delete m_pInsideField;
	delete m_pWaitingForField;
}

CWaitingForFieldState& CParserStateFactory::GetWaitingForField() const
{
	return *m_pWaitingForField;
}

CInsideFieldState& CParserStateFactory::GetInsideField() const
{
	return *m_pInsideField;
}

CInsideQuotedFieldState& CParserStateFactory::GetInsideQuotedField() const
{
	return *m_pInsideQuotedField;
}

// ------------------------------------------------------------------------------------

// CParserState:
CParserState::CParserState(IInternalParserInterface& owner, CParserStateFactory& states)
:	m_Owner(owner)
,	m_States(states)
{
}

IInternalParserInterface& CParserState::GetOwner() const
{
	return m_Owner;
}

CParserStateFactory& CParserState::GetStates()
{
	return m_States;
}

// ------------------------------------------------------------------------------------

// CWaitingForFieldState:
CWaitingForFieldState::CWaitingForFieldState(IInternalParserInterface& owner, CParserStateFactory& states)
	:	CParserState(owner, states)
{
}

CParserState& CWaitingForFieldState::Process(TCHAR current)
{
	return CParserState::GetStates().GetInsideField();
}

CParserState& CWaitingForFieldState::ProcessFieldDelimiter(TCHAR current)
{
	IInternalParserInterface& parser = CParserState::GetOwner();
	if (!parser.WasLastCharacterQuote())
		parser.NotifyAboutTokenComplete();
	parser.MoveNext();
	return *this;
}

CParserState& CWaitingForFieldState::ProcessRecordDelimiter(TCHAR current)
{
	IInternalParserInterface& parser = CParserState::GetOwner();
	if (parser.WasLastCharacterFieldDelimiter())
		parser.NotifyAboutTokenComplete();
	parser.NotifyAboutEndOfRecord();
	parser.MoveNext();
	return *this;
}

CParserState& CWaitingForFieldState::ProcessQuoteCharacter(TCHAR current)
{
	CParserState::GetOwner().MoveNext();
	return CParserState::GetStates().GetInsideQuotedField();
}

// ------------------------------------------------------------------------------------

// CInsideFieldState:
CInsideFieldState::CInsideFieldState(IInternalParserInterface& owner, CParserStateFactory& states)
:	CParserState(owner, states)
{
}

CParserState& CInsideFieldState::Process(TCHAR current)
{
	IInternalParserInterface& parser = CParserState::GetOwner();
	parser.AppendCharacterToToken(current);
	parser.MoveNext();
	return *this;
}

CParserState& CInsideFieldState::ProcessFieldDelimiter(TCHAR current)
{
	IInternalParserInterface& parser = CParserState::GetOwner();
	parser.NotifyAboutTokenComplete();
	parser.MoveNext();
	return CParserState::GetStates().GetWaitingForField();
}

CParserState& CInsideFieldState::ProcessRecordDelimiter(TCHAR current)
{
	IInternalParserInterface& parser = CParserState::GetOwner();
	parser.NotifyAboutTokenComplete();
	parser.NotifyAboutEndOfRecord();
	parser.MoveNext();
	return CParserState::GetStates().GetWaitingForField();
}

CParserState& CInsideFieldState::ProcessQuoteCharacter(TCHAR current)
{
	return Process(current);
}

// ------------------------------------------------------------------------------------

// CInsideQuotedFieldState:
CInsideQuotedFieldState::CInsideQuotedFieldState(IInternalParserInterface& owner, CParserStateFactory& states)
:	CParserState(owner, states)
{
}

CParserState& CInsideQuotedFieldState::Process(TCHAR current)
{
	IInternalParserInterface& parser = CParserState::GetOwner();
	parser.AppendCharacterToToken(current);
	parser.MoveNext();
	return *this;
}

CParserState& CInsideQuotedFieldState::ProcessFieldDelimiter(TCHAR current)
{
	IInternalParserInterface& parser = CParserState::GetOwner();
	parser.AppendCharacterToToken(current);
	parser.MoveNext();
	return *this;
}

CParserState& CInsideQuotedFieldState::ProcessRecordDelimiter(TCHAR current)
{
	IInternalParserInterface& parser = CParserState::GetOwner();
	parser.AppendCharacterToToken(current);
	parser.MoveNext();
	return *this;
}

CParserState& CInsideQuotedFieldState::ProcessQuoteCharacter(TCHAR current)
{
	IInternalParserInterface& parser = CParserState::GetOwner();
	CParserState* result = this;

	parser.MoveNext();
	if (parser.IsEndOfBuffer())
	{
		parser.NotifyAboutTokenComplete();
		result = &(CParserState::GetStates().GetWaitingForField());
	}
	else if (parser.GetCurrentCharacter() == current)
	{
		parser.AppendCharacterToToken(current);
		parser.MoveNext();
	}
	else
	{
		result= &(CParserState::GetStates().GetInsideField());
	}

	return *result;
}

// ------------------------------------------------------------------------------------

// CParser:
CParser::CParser(CFormat& format)
:	m_Buffer(_T(""))
,	m_Format(format)
,	m_CurrentOffset(0)
,	m_CurrentState(NULL)
,	m_States(NULL)
,	m_Token(_T(""))
,	m_FirstRecordFieldCount(0)
,	m_RecordCount(0)
{
	m_States= new CParserStateFactory(*this);
}

CParser::~CParser()
{
	delete m_States;
	m_States = NULL;
	ClearFields();
}

bool CParser::IsEndOfBuffer() const
{
	return (m_CurrentOffset==m_Buffer.size());
}

bool CParser::WasLastCharacterFieldDelimiter() const
{
	if (0!=m_CurrentOffset)
		return m_Format.IsFieldDelimiter(m_Buffer\[m_CurrentOffset-1\]);
	else return false;
}

bool CParser::WasLastCharacterQuote() const
{
	if (0!=m_CurrentOffset)
		return m_Format.IsQuoteCharacter(m_Buffer\[m_CurrentOffset-1\]);
	else return false;
}

TCHAR CParser::GetCurrentCharacter() const
{
	return m_Buffer\[m_CurrentOffset\];
}

void CParser::MoveNext()
{
	++m_CurrentOffset;
}

void CParser::AppendCharacterToToken(TCHAR rhs)
{
	m_Token += rhs;
}

void CParser::NotifyAboutEndOfRecord()
{
	if (0<m_Fields.size())
	{
		if (!( (1==m_Fields.size()) && (0==m_Fields\[0\]->size()) ))
		{
			if (0==m_RecordCount) m_FirstRecordFieldCount = m_Fields.size();
			/* uncomment this for more strict format checking:
			else if (m_Fields.size() != m_FirstRecordFieldCount)
				throw CBadFormatException(_T("Field count doesn't match the field count of the first record."));
			*/
			++m_RecordCount;
			CRecordBasedParser::NotifyObserverAboutRecordFound(m_Fields);
		}
		ClearFields();
	}
}

void CParser::NotifyAboutTokenComplete()
{
	m_Fields.push_back(m_Token.empty() ? NULL : new tstring(m_Token));
	m_Token = _T("");
}

void CParser::ClearFields()
{
	DeleteContainedPointers( m_Fields );
	m_Fields.clear();
}

CFormat& CParser::GetFormat()
{
	return m_Format;
}

int CParser::Parse(const tstring& buffer)
{
	m_Buffer = buffer;
	m_CurrentOffset = 0;
	m_Token = _T("");
	m_FirstRecordFieldCount = 0;
	m_RecordCount = 0;
	m_CurrentState = &m_States->GetWaitingForField();
	try
	{
		while (!IsEndOfBuffer())
		{
			TCHAR current = GetCurrentCharacter();
			if (m_Format.IsFieldDelimiter(current))
			{
				m_CurrentState = &m_CurrentState->ProcessFieldDelimiter(current);
			}
			else 
			if (m_Format.IsRecordDelimiter(current))
			{
				m_CurrentState = &m_CurrentState->ProcessRecordDelimiter(current);
			}
			else 
			if (m_Format.IsQuoteCharacter(current))
			{
				m_CurrentState = &m_CurrentState->ProcessQuoteCharacter(current);
			}
			else 
			{
				m_CurrentState = &m_CurrentState->Process(current);
			}
		}
		if (0<m_Token.length())	
		{
			NotifyAboutTokenComplete();
		}
		NotifyAboutEndOfRecord();
	}
	catch (CBadFormatException& x)
	{
		throw CParserException(x, m_RecordCount);
	}
	return m_RecordCount;
}

// ------------------------------------------------------------------------------------
} // namespace csv
} // namespace tablelike
} // namespace text
} // namespace altova
