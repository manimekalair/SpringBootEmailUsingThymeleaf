[call GenerateFileHeader("CodePageInformation.h")]
#ifndef __ALTOVATEXT_CODEPAGEINFORMATION_H
#define __ALTOVATEXT_CODEPAGEINFORMATION_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{

class CodePageInformation;
class ALTOVATEXT_DECLSPECIFIER CodePage
{
friend CodePageInformation;
public:
	CodePage();

	UINT Number() const;
	const tstring& LocalizedName() const;
	bool IsInstalled() const;

private:
	UINT m_Number;
	tstring m_LocalizedName;
	bool m_IsInstalled;
};

typedef std::map<UINT, CodePage*> TCodePagePointerMap;

class ALTOVATEXT_DECLSPECIFIER CodePageInformation
{
public:
	~CodePageInformation();
	const TCodePagePointerMap& CodePages();

	static CodePageInformation& Instance();

private:
	CodePageInformation();
	void Initialize();
	void CreateCodePage(UINT);
	void SetCodePageInstalled(UINT);
	void AddNames();
	void AddName(CodePage*);
	
private:
	TCodePagePointerMap m_CodePages;
	bool m_HasBeenInitialized;
};

} // namespace text
} // namespace altova
#endif