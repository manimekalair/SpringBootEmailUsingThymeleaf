[call GenerateFileHeader("FLFSerializer.cpp")]
#include "stdafx.h"
#include "FLFSerializer.h"
#include "FLFFormat.h"
#include "Helpers.h"
#include "FLFParser.h"
#include "Table.h"
#include "Record.h"

namespace altova
{
namespace text
{
namespace tablelike
{

CFLFSerializer::CFLFSerializer(CTable& table)
: ASerializer(table)
{
}

void CFLFSerializer::Serialize()
{
	SaveAllRecords();
}

CRecordBasedParser* CFLFSerializer::GetParser()
{
	flf::CParser* result = new flf::CParser(m_Format, GetTable().GetHeader());
	return result;
}

void CFLFSerializer::NotifyAboutRecordFound(const TStringList& fields)
{
	AddRecordFromFields(fields);
}

void CFLFSerializer::SaveRecord(const CRecord& record)
{
	TColumnSpecificationArray& cols= GetTable().GetHeader().GetColumns();
	size_t fieldcount= cols.size();
	for (size_t i= 0; i<fieldcount; ++i)
	{
		CColumnSpecification* cs = cols\[i\];
		tstring name = cs->GetName();
		int desiredlength = cs->GetLength();
		tstring value = record.GetFieldAt(i);
		AssureCorrectFieldFormat(value, desiredlength);
		Write(value);
	}
	if (m_Format.GetAssumeRecordDelimiters())
		Write(_T("\\n"));
}
void CFLFSerializer::AssureCorrectFieldFormat(tstring& field, size_t desiredlength)
{
	if (field.length() > desiredlength) throw CMappingException(_T("Field longer than field length definition."));
	TCHAR c = m_Format.GetFillCharacter();
	field.resize(desiredlength, c);
}

flf::CFormat& CFLFSerializer::GetFormat()
{
	return m_Format;
}

} // namespace tablelike
} // namespace text
} // namespace altova
