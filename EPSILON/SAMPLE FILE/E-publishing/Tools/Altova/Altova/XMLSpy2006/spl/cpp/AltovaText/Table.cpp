[call GenerateFileHeader("Table.cpp")]
#include "stdafx.h"
#include "Table.h"
#include "Helpers.h"
#include "Serializer.h"
#include "Record.h"
#include "Header.h"
#include "RecordBasedParser.h"
#include "../Altova/AltovaException.h"

namespace altova
{
namespace text
{
namespace tablelike
{

CTable::CTable()
:	m_pSerializer(NULL)
{
}

CTable::~CTable()
{
	delete m_pSerializer;
	m_pSerializer = NULL;

	Clear();
}

void CTable::Parse(const tstring& filename)
{
	try
	{
		Setup();

		m_pSerializer->Deserialize(filename);
	}
	catch (CMappingException& x)
	{
		throw altova::CAltovaException(0, filename + _T(":") + x.GetMessage());
	}
}

void CTable::Save(const tstring& filename)
{
	tstringstream stream;
	
	Setup();
	
	m_pSerializer->SetStream(stream);
	m_pSerializer->Serialize();
	
	SaveFileFromBuffer(filename, stream.str(), m_nEncoding, m_nByteorder, m_bBom);
}

size_t CTable::GetRecordCount() const
{
	return m_Records.size();
}

const CRecord& CTable::GetRecordAt(size_t index) const
{
	return *m_Records\[index\];
}

void CTable::AddRecord(const CRecord& rhs)
{
	m_Records.push_back(new CRecord(rhs));
}

void CTable::Clear()
{
	DeleteContainedPointers( m_Records );
	m_Records.clear();
}

CHeader& CTable::GetHeader()
{
	return m_Header;
}

void CTable::Setup()
{
	if( NULL == m_pSerializer )
	{
		InitHeader(m_Header);
		
		m_pSerializer = CreateSerializer();
	}
}

} // namespace tablelike
} // namespace text
} // namespace altova
