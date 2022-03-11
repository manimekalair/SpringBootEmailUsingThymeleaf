[call GenerateFileHeader("Serializer.cpp")]
#include "stdafx.h"
#include "Serializer.h"
#include "Helpers.h"
#include "Table.h"
#include "Record.h"

namespace altova
{
namespace text
{
namespace tablelike
{

ASerializer::ASerializer(CTable& table)
: m_Table(table)
, m_CodePage(CP_ACP)
, m_Stream(NULL)
{}

void ASerializer::SetCodePage(UINT codepage)
{
	m_CodePage = codepage;
}
	
 void ASerializer::SetStream (tstringstream& stream)
{
	m_Stream = &stream; 
}

void
ASerializer::Write(const tstring& rhs)
{
	m_Stream->write(rhs.c_str(), rhs.length());
}

void
ASerializer::Write(TCHAR rhs)
{
	m_Stream->put(rhs);
}

CTable&
ASerializer::GetTable()
{
	return m_Table;
}

void
ASerializer::AddRecordFromFields(const TStringList& fields)
{
	int fieldcount= fields.size();
	CRecord record(fieldcount);
	for (int i= 0; i<fieldcount; ++i)
	{
		const tstring* field = fields\[i\];
		if (field)
		{
			record.SetFieldAt(i, *field);
		}
	}
	GetTable().AddRecord(record);
}

void
ASerializer::SaveAllRecords()
{
	int recordcount= m_Table.GetRecordCount();
	for (int i= 0; i<recordcount; ++i)
	{
		this->SaveRecord(m_Table.GetRecordAt(i));
	}
}

void
ASerializer::Deserialize(const tstring& filename)
{
	tstring buffer;
	LoadFileIntoBuffer(filename, buffer, m_CodePage);
	m_Table.Clear();
	CRecordBasedParser* parser= this->GetParser();
	parser->SetObserver(this);
	parser->Parse(buffer);
	delete parser;
}

} // namespace tablelike
} // namespace text
} // namespace altova
