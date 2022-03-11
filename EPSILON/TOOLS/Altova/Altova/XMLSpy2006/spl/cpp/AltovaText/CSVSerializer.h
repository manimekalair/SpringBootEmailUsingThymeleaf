[call GenerateFileHeader("CSVSerializer.h")]
#ifndef __ALTOVATEXT_CSVSERIALIZER_H
#define __ALTOVATEXT_CSVSERIALIZER_H

#include "Serializer.h"
#include "RecordBasedParser.h"
#include "CSVFormat.h"

namespace altova
{
namespace text
{
namespace tablelike
{

class CRecord;

class ALTOVATEXT_DECLSPECIFIER CCSVSerializer : public ASerializer
{
public:
	CCSVSerializer(CTable& table);
	csv::CFormat& GetFormat();

public: // implementing ISerializer:
	virtual void Serialize();

protected: // implementing ASerializer:
	virtual void SaveRecord(const CRecord& record);
	virtual CRecordBasedParser* GetParser();

public: // implementing IRecordBasedParserObserver:
	virtual void NotifyAboutRecordFound(const TStringList& fields);

private:
	void SaveHeaders();
	void WriteFieldEnd();
	void WriteRecordEnd();
	bool DoesContainQuoteNeedingCharacters(tstring& rhs) const;
	bool DoesStartOrEndWithWhiteSpace(tstring& rhs) const;
	void AssureCorrectFieldFormat(tstring& rhs) const;

private:
	csv::CFormat m_Format;
	bool m_WaitingForHeaderRecord;
};

} // namespace tablelike
} // namespace text
} // namespace altova

#endif
