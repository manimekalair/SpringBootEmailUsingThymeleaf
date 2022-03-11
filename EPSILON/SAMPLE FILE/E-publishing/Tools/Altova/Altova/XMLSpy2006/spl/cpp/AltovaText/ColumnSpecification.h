[call GenerateFileHeader("ColumnSpecification.h")]
#ifndef __ALTOVATEXT_COLUMNSPECIFICATION_H
#define __ALTOVATEXT_COLUMNSPECIFICATION_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{
namespace tablelike
{

class ALTOVATEXT_DECLSPECIFIER CColumnSpecification
{
public:
	CColumnSpecification(const tstring& name = _T(""), size_t length = 0);

	const tstring& GetName() const;
	void SetName(const tstring& rhs);
	
	size_t GetLength() const;
	void SetLength(size_t rhs);

private:
	tstring m_Name;
	size_t	m_Length;
};

} // namespace tablelike
} // namespace text
} // namespace altova

#endif
