[call GenerateFileHeader("Functions.cpp")]
#include "StdAfx.h"
#include "Functions.h"
#include "Function.h"

namespace altova
{
namespace text
{
namespace edi
{

CStringToFunctionMap::CStringToFunctionMap()
: m_Map(new TString2FunctionMap())
{}

CStringToFunctionMap::~CStringToFunctionMap()
{
	this->Clear();
	delete m_Map;
}
void CStringToFunctionMap::Add(const tstring& key, CFunction* value)
{
	TString2FunctionMap::iterator hit= m_Map->find(key);
	if (m_Map->end()==hit)
	{
		m_Map->operator\[\](key) = value;
	}
	else
	{
		tstring msg;
		msg+= _T("Warning: function '");
		msg+= key;
		msg+= _T("' redefined.");
		TRACE(msg.c_str());

		delete hit->second;
		hit->second = value;
	}
}
bool CStringToFunctionMap::IsCRLF(const tstring& rhs) const
{
	if (1!=rhs.size()) return false;
	if (_T('\\n')==rhs\[0\]) return true;
	return (_T('\\r')==rhs\[0\]);
}
CFunction* CStringToFunctionMap::FindFunctionForString(const tstring& key) const
{
	TString2FunctionMap::const_iterator hit= m_Map->find(key);
	if (hit==m_Map->end()) return NULL;
	return hit->second;
}
CFunction* CStringToFunctionMap::Get(const tstring& key) const
{
	if (key.empty()) return &CFunction::k_Default;
	if (this->IsCRLF(key))	return &CFunction::k_Default;
	return this->FindFunctionForString(key);
}
void CStringToFunctionMap::Clear()
{
	for (TString2FunctionMap::iterator it= m_Map->begin();
		 it!=m_Map->end(); ++it)
	{
		delete it->second;
		it->second= NULL;
	}
	m_Map->clear();
}

} // namespace edi
} // namespace text
} // namespace altova
