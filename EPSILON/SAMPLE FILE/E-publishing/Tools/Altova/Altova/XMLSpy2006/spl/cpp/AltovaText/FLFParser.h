[call GenerateFileHeader("FLFParser.h")]
#ifndef __ALTOVATEXT_FLFPARSER_H
#define __ALTOVATEXT_FLFPARSER_H

#include "RecordBasedParser.h"
#include "FLFFormat.h"
#include "Header.h"

namespace altova
{
namespace text
{
namespace tablelike
{
namespace flf
{

class ALTOVATEXT_DECLSPECIFIER CParserException : public CMappingException
{
public:
	CParserException(tstring message, size_t offset);
	size_t GetOffset() const;

private:
	size_t m_Offset;
};

class ALTOVATEXT_DECLSPECIFIER CParser : public CRecordBasedParser
{
public:
	CParser(const flf::CFormat& format, const CHeader& header);
	int Parse(const tstring& buffer);
	
private:
	void ParseRecord();
	void ParseFields(TStringList& fields, size_t fieldcount);
	void MoveToNextNonRecordDelimiter();
	void MoveToNextRecordDelimiter();
	void SwallowTillNextRecord();
	size_t ExtractFieldValueFromBuffer(int bufferstartoffset, TStringList& fields, size_t fieldindex);
	void Trim(tstring& rhs);
	int GetRecordLength();
	
private:
	const CFormat& m_Format;
	const CHeader& m_Header;
	size_t m_Offset;
	size_t m_MaxOffset;
	tstring m_Buffer;
};

} // namespace flf
} // namespace tablelike
} // namespace text
} // namespace altova
#endif
