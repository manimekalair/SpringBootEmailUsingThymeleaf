[call GenerateFileHeader("Serializer.h")]
#ifndef __ALTOVATEXT_SERIALIZER_H
#define __ALTOVATEXT_SERIALIZER_H

#include "AltovaTextAPI.h"
#include "RecordBasedParser.h"

namespace altova
{
namespace text
{
namespace tablelike
{

struct ALTOVATEXT_DECLSPECIFIER ISerializer
{
	virtual void Serialize()= 0;
	virtual void SetStream(tstringstream&) =0;
	virtual void Deserialize(const tstring& filename)= 0;
	virtual void SetCodePage(UINT codepage)= 0;
	virtual ~ISerializer() {};
};


class CTable;
class CRecord;

class ALTOVATEXT_DECLSPECIFIER ASerializer : public ISerializer, public IRecordBasedParserObserver
{
public: // implementing ISerializer:
	virtual void SetCodePage(UINT codepage);
	virtual void Deserialize(const tstring& filename);

	virtual void SetStream(tstringstream& stream);

protected: //descendant obligations:
	virtual void SaveRecord(const CRecord& record) = 0;
	virtual CRecordBasedParser* GetParser() = 0;

protected:
	ASerializer(CTable& table);
	void Write(const tstring& rhs);
	void Write(TCHAR rhs);
	CTable& GetTable();
	void AddRecordFromFields(const TStringList& fields);
	void SaveAllRecords();
	tstringstream* m_Stream;

private:
	CTable& m_Table;
	UINT m_CodePage;
};

} // namespace tablelike
} // namespace text
} // namespace altova
#endif
