[call GenerateFileHeader("ColumnSpecification.cpp")]
#include "stdafx.h"
#include "ColumnSpecification.h"

namespace altova
{
namespace text
{
namespace tablelike
{

CColumnSpecification::CColumnSpecification(const tstring& name, size_t length)
:	m_Name(name)
,	m_Length(length)
{
}

const tstring& CColumnSpecification::GetName() const
{
	return m_Name;
}

void CColumnSpecification::SetName(const tstring& rhs)
{
	m_Name = rhs;
}

size_t CColumnSpecification::GetLength() const
{
	return m_Length;
}

void CColumnSpecification::SetLength(size_t rhs)
{
	m_Length = rhs;
}

} // namespace tablelike
} // namespace text
} // namespace altova
