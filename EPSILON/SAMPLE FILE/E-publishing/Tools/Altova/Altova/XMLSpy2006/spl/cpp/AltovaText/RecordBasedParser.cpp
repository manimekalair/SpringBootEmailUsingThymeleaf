[call GenerateFileHeader("RecordBasedParser.cpp")]
#include "stdafx.h"
#include "RecordBasedParser.h"


namespace altova
{
namespace text
{
namespace tablelike
{


CRecordBasedParser::CRecordBasedParser()
	: m_pObserver(NULL)
{}

CRecordBasedParser::~CRecordBasedParser() {} // NO-OP

IRecordBasedParserObserver* CRecordBasedParser::GetObserver() const
{
	return m_pObserver;
}
void CRecordBasedParser::SetObserver(IRecordBasedParserObserver* rhs)
{
	m_pObserver= rhs;
}
void CRecordBasedParser::NotifyObserverAboutRecordFound(const TStringList& fields)
{
	if (NULL!=m_pObserver) m_pObserver->NotifyAboutRecordFound(fields);
}

CMappingException::CMappingException(const tstring& message)
:	m_Message(message)
{}
CMappingException::CMappingException()
:	m_Message(_T(""))
{}
const tstring& CMappingException::GetMessage() const
{
	return m_Message;
}
void CMappingException::SetMessage(const tstring& message)
{
	m_Message= message;
}

} // namespace tablelike
} // namespace text
} // namespace altova
