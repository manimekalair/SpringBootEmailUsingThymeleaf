[call GenerateFileHeader("CSVFormat.h")]
#ifndef __ALTOVATEXT_CSVFORMAT_H
#define __ALTOVATEXT_CSVFORMAT_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{
namespace tablelike
{
namespace csv
{

class ALTOVATEXT_DECLSPECIFIER CFormat
{
public:
	CFormat();

	bool GetAssumeFirstRowAsHeaders() const;
	void SetAssumeFirstRowAsHeaders(bool rhs);

	TCHAR GetQuoteCharacter() const;
	void SetQuoteCharacter(TCHAR rhs);

	TCHAR GetFieldDelimiter() const;
	void SetFieldDelimiter(TCHAR rhs);

	const TCHAR* GetRecordDelimiters() const;
	const TCHAR* GetQuoteNeedingCharacters() const;

	bool IsFieldDelimiter(TCHAR rhs) const;
	bool IsRecordDelimiter(TCHAR rhs) const;
	bool IsQuoteCharacter(TCHAR rhs) const;
	
	void QuoteString(tstring& rhs) const;

private:
	TCHAR m_FieldDelimiter;
	TCHAR m_RecordDelimiters\[2\];
	TCHAR m_QuoteCharacter;
	TCHAR m_QuoteNeedingCharacters\[5\];
	bool m_AssumeFirstRowAsHeaders;
	bool m_ExpectQuoteCharacter;

private:
	void UpdateQuoteNeedingCharacters();
};


} // namespace csv
} // namespace tablelike
} // namespace text
} // namespace altova
#endif 
