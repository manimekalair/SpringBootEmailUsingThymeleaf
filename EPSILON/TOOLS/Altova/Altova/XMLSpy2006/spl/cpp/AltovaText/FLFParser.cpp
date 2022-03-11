[call GenerateFileHeader("FLFParser.cpp")]
#include "stdafx.h"
#include "FLFParser.h"
#include "Helpers.h"

namespace altova
{
namespace text
{
namespace tablelike
{
namespace flf
{

// CParserException:
CParserException::CParserException(tstring message, size_t offset)
:	m_Offset(offset)
{
#ifdef _UNICODE
	std::wstringstream ss;
#else
	std::stringstream ss;
#endif
	ss << message << _T(" at offset #") << offset;
	CMappingException::SetMessage(ss.str());
}
size_t CParserException::GetOffset() const
{
	return m_Offset;
}

// ---------------------------------------------------------------------------------------

CParser::CParser(const flf::CFormat& format, const CHeader& header)
:	m_Format(format)
,	m_Header(header)
,	m_Offset(0)
,	m_MaxOffset(0)
,	m_Buffer(_T(""))
{
}

int CParser::Parse(const tstring& buffer)
{
	int result = 0;
	m_Buffer = buffer;
	m_MaxOffset = m_Buffer.size() - GetRecordLength();
	m_Offset = 0;
	
	if (m_Format.GetAssumeRecordDelimiters())
	{
		size_t minLength =0;
		for (size_t i = 0; i < m_Header.GetColumns().size()-1; ++i)
			minLength += m_Header.GetColumns()\[i\]->GetLength();
		if (m_Buffer.size()-2 < minLength)
			throw CParserException(_T("The input buffer is not long enough for even just one record."), m_Buffer.length());
	}
	else
		if (0>m_MaxOffset)
			throw CParserException(_T("The input buffer is not long enough for even just one record."), m_Buffer.length());
	
	do
	{
		ParseRecord();
		++result;
	}
	while (m_Offset<m_Buffer.length());
	return result;
}

int CParser::GetRecordLength()
{
	int result = 0;
	const TColumnSpecificationArray& cols = m_Header.GetColumns();
	TColumnSpecificationArray::const_iterator it, itEnd = cols.end();
	for (it = cols.begin(); it != itEnd; ++it)
		result += (*it)->GetLength();
	return result;
}

size_t CParser::ExtractFieldValueFromBuffer(int bufferstartoffset, TStringList& fields, size_t fieldindex)
{
	size_t len = m_Header.GetColumns()\[fieldindex\]->GetLength();
	tstring value = m_Buffer.substr(bufferstartoffset, len);
	Trim(value);
	fields.push_back(new tstring(value));
	return len;
}

void CParser::ParseFields(TStringList& fields, size_t fieldcount)
{
	if (m_Format.GetAssumeRecordDelimiters())
	{
		size_t i=0;
		while (i < fieldcount)
		{
			int count = m_Header.GetColumns()\[i\]->GetLength();
			tstring value = m_Buffer.substr(m_Offset, count);
			size_t recSepPos = value.find(_T('\\r'), 0);
			if (recSepPos != tstring::npos)
			{
				value.resize(recSepPos);
				Trim(value);
				fields.push_back(new tstring(value));
				m_Offset += recSepPos;
				i++;
				break;
			}
			else
			{
				Trim(value);
				fields.push_back(new tstring(value));
				m_Offset += count;
				i++;
			}
		}
		if (i<fieldcount)
			for (size_t j = i; j < fieldcount; j++)
				fields\[j\] = new tstring(_T(""));
	}
	else
	{
		for (size_t i = 0; i < fieldcount; ++i)
		{
			size_t len = m_Header.GetColumns()\[i\]->GetLength();
			tstring value = m_Buffer.substr(m_Offset, len);
			Trim(value);
			fields.push_back(new tstring(value));
			m_Offset += len;
		}
	}
}

void CParser::ParseRecord()
{
	TStringList fields;
	const TColumnSpecificationArray& cols= m_Header.GetColumns();
	if (m_Format.GetAssumeRecordDelimiters())
	{
		size_t maxfieldindex = cols.size() - 1;
		ParseFields(fields, maxfieldindex);
		size_t start = m_Offset;
		MoveToNextRecordDelimiter();
		size_t len = min(m_Offset-start, cols\[maxfieldindex\]->GetLength());
		tstring value = m_Buffer.substr(start, len);
		Trim(value);
		fields.push_back(new tstring(value));

		SwallowTillNextRecord();
	}
	else 
	{
		ParseFields(fields, cols.size());
	}
	CRecordBasedParser::NotifyObserverAboutRecordFound(fields);
	DeleteContainedPointers(fields);
}

void CParser::MoveToNextNonRecordDelimiter()
{
	while ((m_Offset<m_Buffer.size()) && (m_Format.IsRecordDelimiter(m_Buffer\[m_Offset\])))
		++m_Offset;
}

void CParser::MoveToNextRecordDelimiter()
{
	while ((m_Offset<m_Buffer.size()) && (!m_Format.IsRecordDelimiter(m_Buffer\[m_Offset\])))
		++m_Offset;
}

void CParser::SwallowTillNextRecord()
{
	MoveToNextRecordDelimiter();
	MoveToNextNonRecordDelimiter();
}

void CParser::Trim(tstring& rhs)
{
	if(rhs.empty()) return;
	TCHAR fillcharacter = m_Format.GetFillCharacter();
	size_t size = rhs.size();
	int end = size - 1;
	while ((end>-1) && (fillcharacter==rhs\[end\]))
		--end;
	rhs = rhs.substr(0, end+1);
}

// ---------------------------------------------------------------------------------------

} // namespace flf
} // namespace tablelike
} // namespace text
} // namespace altova
