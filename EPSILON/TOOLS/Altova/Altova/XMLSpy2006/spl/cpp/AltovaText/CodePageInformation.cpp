[call GenerateFileHeader("CodePageInformation.cpp")]
#include "StdAfx.h"
#include "CodePageInformation.h"
#include "TextException.h"
#include "Helpers.h"

namespace altova
{
namespace text
{

CodePage::CodePage()
:	m_Number(0)
,	m_LocalizedName(_T(""))
,	m_IsInstalled(false)
{}

UINT 
CodePage::Number() const
{
	return m_Number;
}

const tstring& 
CodePage::LocalizedName() const
{
	return m_LocalizedName;
}

bool 
CodePage::IsInstalled() const
{
	return m_IsInstalled;
}

// --------------------------------------------------------------------
CodePageInformation::CodePageInformation()
:	m_HasBeenInitialized(false)
{}

CodePageInformation::~CodePageInformation()
{
	TCodePagePointerMap::iterator i= m_CodePages.begin(), e= m_CodePages.end();
	for ( ; i!=e; ++i)
		delete i->second;
}

CodePageInformation& CodePageInformation::Instance()
{
	static CodePageInformation instance;
	return instance;
}

const TCodePagePointerMap& 
CodePageInformation::CodePages()
{
	Initialize();
	return m_CodePages;
}

typedef std::set<UINT> TUIntSet;

class CallbackWrapper
{
public:
	static TUIntSet Enumerate(DWORD type)
	{
		m_Codes.clear();
		if (!::EnumSystemCodePages(EnumCodePagesCallback, type))
			throw CTextException(0, _T("Could not enumerate code pages."));
		return m_Codes;
	}

private:
	static BOOL CALLBACK EnumCodePagesCallback(LPTSTR pCodePageString)
	{
		UINT code= (UINT) _tcstoul(pCodePageString, NULL, 10);
		m_Codes.insert(code);
		return TRUE;
	}

	static TUIntSet m_Codes;	
};
TUIntSet CallbackWrapper::m_Codes;

void
CodePageInformation::CreateCodePage(UINT code)
{
	CodePage* codepage= new CodePage();
	codepage->m_Number= code;
	m_CodePages.insert(TCodePagePointerMap::value_type(code, codepage));
}

void
CodePageInformation::SetCodePageInstalled(UINT code)
{
	TCodePagePointerMap::iterator hit= m_CodePages.find(code);
	if (hit==m_CodePages.end()) return;
	hit->second->m_IsInstalled= true;
}

void 
CodePageInformation::Initialize()
{
	if (m_HasBeenInitialized) return;
	m_HasBeenInitialized= true;
	
	TUIntSet supportedcodes= CallbackWrapper::Enumerate(CP_SUPPORTED);
	TUIntSet installedcodes= CallbackWrapper::Enumerate(CP_INSTALLED);
	
	TUIntSet::const_iterator i= supportedcodes.begin(), e= supportedcodes.end();
	for ( ; i!=e; ++i) CreateCodePage(*i);
	
	i= installedcodes.begin(), e= installedcodes.end();
	for ( ; i!=e; ++i) SetCodePageInstalled(*i);

	AddNames();	
}

void
CodePageInformation::AddNames()
{
	TCodePagePointerMap::iterator i= m_CodePages.begin(), e= m_CodePages.end();
	for ( ; i!=e; ++i) 
	{
		if (i->second->m_IsInstalled) AddName(i->second);
	}
}

void
CodePageInformation::AddName(CodePage* codepage)
{
	static ::CPINFOEX codepageinfo;
	if (::GetCPInfoEx(codepage->m_Number, 0, &codepageinfo))
		codepage->m_LocalizedName= codepageinfo.CodePageName;
}

} // namespace text
} // namespace altova
