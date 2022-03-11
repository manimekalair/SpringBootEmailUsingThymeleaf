[call GenerateFileHeader("Record.cpp")]
#include "stdafx.h"
#include "Record.h"

namespace altova
{
namespace text
{
namespace tablelike
{


CRecord::CRecord(size_t fieldcount)
:	m_FieldCount(fieldcount)
{
	m_Fields= new tstring\[m_FieldCount\];
}

CRecord::CRecord(const CRecord& rhs)
{
	m_FieldCount = rhs.m_FieldCount;
	m_Fields = new tstring\[m_FieldCount\];
	for (size_t i = 0; i < m_FieldCount; ++i)
		m_Fields\[i\] = rhs.m_Fields\[i\];
}

CRecord::~CRecord()
{
	delete \[\] m_Fields;
}

void CRecord::Assign(const CRecord& rhs)
{
	delete \[\] m_Fields;
	m_FieldCount = rhs.m_FieldCount;
	m_Fields = new tstring\[m_FieldCount\];
	for (size_t i = 0; i < m_FieldCount; ++i)
		m_Fields\[i\] = rhs.m_Fields\[i\];
}

bool CRecord::HasFieldAt(size_t index) const
{
	return (index < m_FieldCount);
}

const tstring& CRecord::GetFieldAt(size_t index) const
{
	static const tstring empty = _T("");
	if (0 <= index && index < m_FieldCount)
		return m_Fields\[index\];
	else
		return empty;
}

void CRecord::SetFieldAt(size_t index, const tstring& rhs)
{
	if (0 <= index && index < m_FieldCount)
		m_Fields\[index\] = rhs;
}

} // namespace tablelike
} // namespace text
} // namespace altova
