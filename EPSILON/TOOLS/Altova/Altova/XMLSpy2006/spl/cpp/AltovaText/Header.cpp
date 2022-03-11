[call GenerateFileHeader("Header.cpp")]
#include "stdafx.h"
#include "Header.h"
#include "Helpers.h"
#include "ColumnSpecification.h"

namespace altova
{
namespace text
{
namespace tablelike
{


CHeader::CHeader()
{
}

CHeader::~CHeader()
{
	DeleteContainedPointers( m_Columns );
	m_Columns.clear();
}

TColumnSpecificationArray& CHeader::GetColumns()
{
	return m_Columns;
}

const TColumnSpecificationArray& CHeader::GetColumns() const
{
	return m_Columns;
}

} // namespace tablelike
} // namespace text
} // namespace altova
