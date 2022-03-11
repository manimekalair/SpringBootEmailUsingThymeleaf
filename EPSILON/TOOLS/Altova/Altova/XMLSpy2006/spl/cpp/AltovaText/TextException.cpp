[call GenerateFileHeader("TextException.cpp")]
#include "StdAfx.h"
#include "../Altova/SchemaTypes.h"
#include "TextException.h"


namespace altova
{
namespace text
{

CTextException::CTextException(int nCode, const tstring& sMessage)
:	CAltovaException(nCode, sMessage)
{
}

} // namespace text
} // namespace altova
