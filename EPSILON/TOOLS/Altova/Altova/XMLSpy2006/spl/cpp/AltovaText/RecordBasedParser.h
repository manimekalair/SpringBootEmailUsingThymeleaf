[call GenerateFileHeader("RecordBasedParser.h")]
#ifndef __ALTOVATEXT_RECORBASEDPARSER_H
#define __ALTOVATEXT_RECORBASEDPARSER_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{
namespace tablelike
{

typedef std::vector<tstring*> TStringList;

struct ALTOVATEXT_DECLSPECIFIER IRecordBasedParserObserver
{
	virtual void NotifyAboutRecordFound(const TStringList& fields) = 0;
	virtual ~IRecordBasedParserObserver() {}
};

class ALTOVATEXT_DECLSPECIFIER CRecordBasedParser  
{
public:
	CRecordBasedParser();
	virtual ~CRecordBasedParser();

	IRecordBasedParserObserver* GetObserver() const;
	void SetObserver(IRecordBasedParserObserver* rhs);

public:
	virtual int Parse(const tstring& buffer)= 0;

protected:
	void NotifyObserverAboutRecordFound(const TStringList& fields);

private:
	IRecordBasedParserObserver* m_pObserver;
};

class ALTOVATEXT_DECLSPECIFIER CMappingException
{
public:
	CMappingException();
	CMappingException(const tstring& message);
	const tstring& GetMessage() const;

protected:
	void SetMessage(const tstring& message);
	
private:
	tstring m_Message;
};
} // namespace tablelike
} // namespace text
} // namespace altova
#endif 
