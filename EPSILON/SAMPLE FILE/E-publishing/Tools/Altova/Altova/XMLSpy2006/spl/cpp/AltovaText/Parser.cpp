[call GenerateFileHeader("Parser.cpp")]
#include "StdAfx.h"
#include "Parser.h"

namespace altova
{
namespace text
{
namespace edi
{
CScanner& CParser::GetScanner()
{
	return m_Scanner;
}
const CScanner&	CParser::GetScanner() const
{
	return m_Scanner;
}
void CParser::Parse(const TCHAR* buffer)
{
	m_Scanner.Init(buffer);

	this->Prolog();
	Indicator indicator= kEnd;
	do
	{
		indicator= m_Scanner.Scan();
		if (kEnd!=indicator) this->ProcessToken(m_Scanner.Token());
	}
	while (kEnd!=indicator);
	this->Epilog();
}

} // namespace edi
} // namespace text
} // namespace altova
