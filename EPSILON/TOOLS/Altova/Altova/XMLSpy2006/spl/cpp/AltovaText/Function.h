[call GenerateFileHeader("Function.h")]
#ifndef __ALTOVATEXT_FUNCTION_H
#define __ALTOVATEXT_FUNCTION_H

#include "Commands.h"

namespace altova
{
namespace text
{
namespace edi
{

class CTextDocument;

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CFunction
{
public:
	static CFunction k_Default;
	bool Execute(CTextDocument& document);
	
protected:
	void AddCommand(CCommand* rhs);
	
private:
	CCommands m_Commands;
};

} // namespace edi
} // namespace text
} // namespace altova

#endif
