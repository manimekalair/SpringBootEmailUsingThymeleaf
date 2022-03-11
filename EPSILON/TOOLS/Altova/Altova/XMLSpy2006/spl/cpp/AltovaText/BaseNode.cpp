[call GenerateFileHeader("BaseNode.cpp")]
#include "StdAfx.h"
#include "BaseNode.h"
#include "TextNode.h"

namespace altova
{
namespace text
{

CBaseType::CBaseType()
:	m_pNode(NULL)
{}
CBaseType::CBaseType(CTextNode* node)
:	m_pNode(node)
{}
tstring CBaseType::MakeDecimal()
{
	CRootTextNode& root= (CRootTextNode&) m_pNode->GetRoot();
	TCHAR separator= root.GetDecimalSeparator();
	tstring value = m_pNode->GetValue();
	size_t pos= value.find(separator);
	if (pos!=tstring::npos) value\[pos\]= _T('.');
	return value;
}
size_t CBaseType::GetChildCount(const tstring& name) const
{
	CTextNodeContainer matchingchildren;
	m_pNode->GetChildren().FilterByName(name, matchingchildren);
	return matchingchildren.GetCount();
}
CTextNode* CBaseType::GetChildByName(const tstring& name) const
{
	return GetChildByNameAt(name, 0);
}
CTextNode* CBaseType::GetChildByNameAt(const tstring& name, size_t index) const
{
	CTextNodeContainer matchingchildren;
	m_pNode->GetChildren().FilterByName(name, matchingchildren);
	if (index<matchingchildren.GetCount()) return &matchingchildren.GetAt(index);
	return &CNullTextNode::GetInstance();
}
CTextNode& CBaseType::GetNode() const
{
	return *m_pNode;
}

} // namespace text
} // namespace altova
