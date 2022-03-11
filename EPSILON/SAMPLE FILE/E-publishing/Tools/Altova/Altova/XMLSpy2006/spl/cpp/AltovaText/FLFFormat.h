[call GenerateFileHeader("FLFFormat.h")]
#ifndef __ALTOVATEXT_FLFFORMAT_H
#define __ALTOVATEXT_FLFFORMAT_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{
namespace tablelike
{
namespace flf
{

class ALTOVATEXT_DECLSPECIFIER CFormat
{
public:
	CFormat();

	bool GetAssumeRecordDelimiters() const;
	void SetAssumeRecordDelimiters(bool rhs);

	TCHAR GetFillCharacter() const;
	void SetFillCharacter(TCHAR rhs);

	bool IsRecordDelimiter(TCHAR rhs) const;
	
private:
	bool m_AssumeRecordDelimiters;
	TCHAR m_FillCharacter;
	TCHAR m_RecordDelimiters\[2\];
};

} // namespace flf
} // namespace tablelike
} // namespace text
} // namespace altova

#endif 
