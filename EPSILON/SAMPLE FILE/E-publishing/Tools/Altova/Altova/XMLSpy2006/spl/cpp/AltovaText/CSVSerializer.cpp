[call GenerateFileHeader("CSVSerializer.cpp")]
#include "stdafx.h"
#include "CSVSerializer.h"
#include "Table.h"
#include "Record.h"
#include "CSVParser.h"
#include "Helpers.h"

namespace altova
{
namespace text
{
namespace tablelike
{

CCSVSerializer::CCSVSerializer(CTable& table)
:	ASerializer(table)
{
}

void CCSVSerializer::Serialize()
{
	if (m_Format.GetAssumeFirstRowAsHeaders()) 
		SaveHeaders();
	
	SaveAllRecords();
}

CRecordBasedParser* CCSVSerializer::GetParser()
{
	m_WaitingForHeaderRecord = m_Format.GetAssumeFirstRowAsHeaders();
	csv::CParser* result= new csv::CParser(m_Format);
	return result;
}

void CCSVSerializer::NotifyAboutRecordFound(const TStringList& fields)
{
	if (m_WaitingForHeaderRecord)
	{
		m_WaitingForHeaderRecord = false;
	}
	else 
	{
		AddRecordFromFields(fields);
	}
}

void CCSVSerializer::SaveHeaders()
{
	size_t maximalindex = GetTable().GetHeader().GetColumns().size();
	for (size_t i = 0; i < maximalindex; ++i)
	{
		tstring fieldname = GetTable().GetHeader().GetColumns()\[i\]->GetName();
		AssureCorrectFieldFormat(fieldname);
		Write(fieldname);
		if (i<maximalindex -1) 
			WriteFieldEnd();
	}
	WriteRecordEnd();
}

void CCSVSerializer::SaveRecord(const CRecord& record)
{
	size_t maximalindex = GetTable().GetHeader().GetColumns().size();
	for (size_t i = 0; i < maximalindex; ++i)
	{
		tstring fieldvalue= record.GetFieldAt(i);
		AssureCorrectFieldFormat(fieldvalue);
		Write(fieldvalue);
		if (i < maximalindex - 1) 
			WriteFieldEnd();
	}
	WriteRecordEnd();
}

bool CCSVSerializer::DoesContainQuoteNeedingCharacters(tstring& rhs) const
{
	const TCHAR* lookfor = m_Format.GetQuoteNeedingCharacters();
	tstring::size_type i = rhs.find_first_of(lookfor);
	return (0<=i) && (i<UINT_MAX);
}

bool CCSVSerializer::DoesStartOrEndWithWhiteSpace(tstring& rhs) const
{
	if (0==rhs.length()) 
		return false;
	switch (rhs\[0\])
	{
	case '\\t':
	case '\\r':
	case '\\n':
	case ' ':
		return true;
	}
	switch (rhs\[rhs.length()-1\])
	{
	case '\\t':
	case '\\r':
	case '\\n':
	case ' ':
		return true;
	}
	return false;
}

void CCSVSerializer::AssureCorrectFieldFormat(tstring& rhs) const
{
	if ((DoesContainQuoteNeedingCharacters(rhs)) || (DoesStartOrEndWithWhiteSpace(rhs)))
		m_Format.QuoteString(rhs);
}

void CCSVSerializer::WriteFieldEnd()
{
	Write(m_Format.GetFieldDelimiter());
}

void CCSVSerializer::WriteRecordEnd()
{
	Write(_T('\\n'));
}

csv::CFormat& CCSVSerializer::GetFormat()
{
	return m_Format;
}

} // namespace tablelike
} // namespace text
} // namespace altova
