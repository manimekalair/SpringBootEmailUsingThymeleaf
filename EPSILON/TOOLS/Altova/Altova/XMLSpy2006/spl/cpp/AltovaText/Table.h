[call GenerateFileHeader("Table.h")]
#ifndef __ALTOVATEXT_TABLE_H
#define __ALTOVATEXT_TABLE_H

#include "Header.h"

namespace altova
{
namespace text
{
namespace tablelike
{

struct ISerializer;
class CRecord;

class ALTOVATEXT_DECLSPECIFIER CTable
{
public:
	void Parse(const tstring& filename);
	void Save(const tstring& filename);
	void Clear();
	
	CHeader& GetHeader();
	
	void AddRecord(const CRecord& rhs);
	size_t GetRecordCount() const;
	const CRecord& GetRecordAt(size_t index) const;
	
	void SetByteOrder(int bo) {m_nByteorder = bo;}
	void SetEncoding(unsigned enc) {m_nEncoding = enc;}
	void SetWriteBOM(bool bom) {m_bBom = bom;}

protected:
	CTable();
	virtual ~CTable();

protected:
	virtual ISerializer* CreateSerializer()= 0;
	virtual void InitHeader(CHeader& header)= 0;

private:
	void Setup();
	
private:
	typedef std::vector <CRecord*> TRecordArray;

private:
	ISerializer* m_pSerializer;
	TRecordArray m_Records;
	CHeader		 m_Header;
	unsigned m_nEncoding;
	int m_nByteorder;
	bool m_bBom;
};

} // namespace tablelike
} // namespace text
} // namespace altova

#endif 
