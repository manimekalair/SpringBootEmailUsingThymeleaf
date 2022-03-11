[call GenerateFileHeader("Record.h")]
#ifndef __ALTOVATEXT_RECORD_H
#define __ALTOVATEXT_RECORD_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{
namespace tablelike
{

class ALTOVATEXT_DECLSPECIFIER CRecord  
{
public:
	CRecord(size_t fieldcount);
	CRecord(const CRecord& rhs);
	virtual ~CRecord();

	bool HasFieldAt(size_t index) const;
	const tstring& GetFieldAt(size_t index) const;
	void SetFieldAt(size_t index, const tstring& rhs);
	
	void Assign(const CRecord& rhs);
	
private:
	tstring* m_Fields;
	size_t	m_FieldCount;
	
private:
	CRecord& operator=(const CRecord&);
};

} // namespace tablelike
} // namespace text
} // namespace altova
#endif
