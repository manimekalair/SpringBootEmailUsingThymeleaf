[call GenerateFileHeader("Helpers.h")]
#ifndef __ALTOVATEXT_HELPERS_H
#define __ALTOVATEXT_HELPERS_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{

ALTOVATEXT_DECLSPECIFIER bool LoadFileIntoBuffer(const tstring& filename, tstring& buffer, unsigned encoding = CP_ACP, int byteorder = 1);
ALTOVATEXT_DECLSPECIFIER bool SaveFileFromBuffer(const tstring& filename, const tstring& buffer, unsigned encoding = CP_ACP, int byteorder = 1, bool WriteBOM=true);
ALTOVATEXT_DECLSPECIFIER std::wstring ConvertStringToWideString(const tstring& src);
ALTOVATEXT_DECLSPECIFIER void ConvertToWideString(const char* source, DWORD originallen, tstring& target, unsigned encoding = CP_ACP, int byteorder = 1);
ALTOVATEXT_DECLSPECIFIER void ConvertToString(const TCHAR* source, std::string& target, unsigned encoding = CP_ACP);
ALTOVATEXT_DECLSPECIFIER void ConvertWideStringToString(const wchar_t* source, std::string& target);
ALTOVATEXT_DECLSPECIFIER size_t CountFormatCharacters(const tstring&, size_t);
ALTOVATEXT_DECLSPECIFIER void RemoveCRLF(tstring&);
ALTOVATEXT_DECLSPECIFIER void TrimStart(tstring& buffer);
ALTOVATEXT_DECLSPECIFIER tstring GetLastWindowsErrorAsString();

template <typename Collection> void DeleteContainedPointers(Collection& collection)
{
	for (Collection::iterator it= collection.begin(); it!=collection.end(); ++it)
	{
		delete *it;
		*it= NULL;
	}
}

} // namespace text
} // namespace altova
#endif
