[call GenerateFileHeader("Header.h")]
#ifndef __ALTOVATEXT_HEADER_H
#define __ALTOVATEXT_HEADER_H

#include "ColumnSpecification.h"

namespace altova
{
namespace text
{
namespace tablelike
{

typedef std::vector <CColumnSpecification*> TColumnSpecificationArray;

class ALTOVATEXT_DECLSPECIFIER CHeader  
{
public:
	CHeader();
	virtual ~CHeader();

public:
	TColumnSpecificationArray& GetColumns();
	const TColumnSpecificationArray& GetColumns() const;

private:
	TColumnSpecificationArray m_Columns;
};

} // namespace tablelike
} // namespace text
} // namespace altova

#endif 
