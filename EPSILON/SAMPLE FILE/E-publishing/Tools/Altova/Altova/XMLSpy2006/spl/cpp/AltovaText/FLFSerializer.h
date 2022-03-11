[call GenerateFileHeader("FLFSerializer.h")]
#ifndef __ALTOVATEXT_FLFSERIALIZER_H
#define __ALTOVATEXT_FLFSERIALIZER_H

#include "Serializer.h"
#include "RecordBasedParser.h"
#include "FLFFormat.h"

namespace altova
{
namespace text
{
namespace tablelike
{

class CRecord;
class ALTOVATEXT_DECLSPECIFIER CFLFSerializer : public ASerializer
{
public:
	CFLFSerializer(CTable& table);
	flf::CFormat& GetFormat();

public: // implementing ISerializer:
	virtual void Serialize();

protected: // implementing ASerializer:
	virtual CRecordBasedParser* GetParser();
	virtual void SaveRecord(const CRecord& record);

public: // implementing IRecordBasedParserObserver:
	virtual void NotifyAboutRecordFound(const TStringList& fields);

private:
	void AssureCorrectFieldFormat(tstring& field, size_t desiredlength);

private:
	flf::CFormat m_Format;
};

} // namespace tablelike
} // namespace text
} // namespace altova

#endif
