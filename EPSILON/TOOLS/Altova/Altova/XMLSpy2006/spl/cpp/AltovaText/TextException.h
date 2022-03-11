[call GenerateFileHeader("TextException.h")]
#ifndef ALTOVATEXT_TEXTEXCEPTION_H
#define ALTOVATEXT_TEXTEXCEPTION_H

#include "AltovaTextAPI.h"
#include "../Altova/AltovaException.h"

namespace altova
{
namespace text
{

class ALTOVATEXT_DECLSPECIFIER CTextException : public CAltovaException
{
public:
	CTextException(int code, const tstring& message);
};

} // namespace text
} // namespace altova

#endif
