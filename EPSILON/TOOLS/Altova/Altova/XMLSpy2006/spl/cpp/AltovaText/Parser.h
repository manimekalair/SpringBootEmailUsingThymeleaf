[call GenerateFileHeader("Parser.h")]
#ifndef __ALTOVATEXT_PARSER_H
#define __ALTOVATEXT_PARSER_H

#include "Scanner.h"

namespace altova
{
namespace text
{
namespace edi
{

class ALTOVATEXT_DECLSPECIFIER CParser
{
public:
	virtual ~CParser() {}
	CScanner& GetScanner();
	const CScanner&	GetScanner() const;
	
protected:
	virtual void Parse(const TCHAR* szBuffer);
	
protected:
	virtual void Prolog()= 0;
	virtual void Epilog()= 0;
	virtual void ProcessToken(const tstring&) = 0;
	
protected:
	CScanner m_Scanner;
};

} // namespace edi
} // namespace text
} // namespace altova

#endif
