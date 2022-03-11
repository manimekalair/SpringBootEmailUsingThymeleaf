[call GenerateFileHeader("Function.cpp")]
#include "StdAfx.h"
#include "Function.h"

namespace altova
{
namespace text
{
namespace edi
{

CFunction CFunction::k_Default;

void CFunction::AddCommand(CCommand* rhs)
{
	m_Commands.AddCommand(rhs);
}
bool CFunction::Execute(CTextDocument& document)
{
	return m_Commands.Execute(document);
}


} // namespace edi
} // namespace text
} // namespace altova
