[call GenerateFileHeader("Generator.cpp")]
#include "StdAfx.h"
#include "Generator.h"
#include "TextNode.h"
#include "Helpers.h"
#include "TextNodeXMLWriter.h"
#include "TextException.h"

namespace altova
{
namespace text
{

const static tstring k_sEmpty(_T(""));



CGenerator::CGenerator()
{
	this->Init();
}
CGenerator::~CGenerator()
{
	this->Exit();
}
void CGenerator::Init()
{
	m_pCurrent= &CNullTextNode::GetInstance();
}
void CGenerator::Done()
{
	m_pCurrent= &m_pCurrent->GetRoot();
}
void CGenerator::Save(const tstring& filename)
{
	tstringstream stream;
	
	CTextNodeXMLWriter visitor(stream);
	visitor.Visit(m_pCurrent->GetRoot());
	SaveFileFromBuffer(filename, stream.str());
}

void CGenerator::Exit()
{
	this->Done();
	CTextNodeFactory::GetInstance().Delete(m_pCurrent);
}
void CGenerator::EnterElement(const tstring& name, ENodeClass eClass)
{
	CTextNode* node= (m_pCurrent->IsNull())
					 ? CTextNodeFactory::GetInstance().CreateRootNode()
					 : CTextNodeFactory::GetInstance().Create(*m_pCurrent, name);
	node->SetName(name);
	node->SetClass(eClass);
	m_pCurrent= node;
}
void CGenerator::LeaveElement(const tstring& name)
{
	CTextNode& tobeleft= (name.empty()) ? *m_pCurrent : this->FindElementUpwardsByName(name);
	if (!tobeleft.IsNull())
	{
		CTextNode& parent= tobeleft.GetParent();
		m_pCurrent= (parent.IsNull()) ? &tobeleft : &parent;
	}
}
void CGenerator::InsertElement (const tstring& name, const tstring& value, ENodeClass eClass)
{
	CTextNode* node= CTextNodeFactory::GetInstance().Create(*m_pCurrent, name);
	node->SetValue(value);
	node->SetClass(eClass);
}
bool CGenerator::DoesCurrentsNameEqual(const tstring& name) const
{
	return (name==m_pCurrent->GetName());
}
bool CGenerator::DoesHaveChildByName(const tstring& name) const
{
	return m_pCurrent->GetChildren().HasNodeByName(name);
}
tstring CGenerator::GetRootName() const
{
	return GetRootNode().GetName();
}
CTextNode& CGenerator::GetRootNode() const
{
	return m_pCurrent->GetRoot();
}
void CGenerator::SetRootNode(CTextNode& rhs)
{
	m_pCurrent= CTextNodeFactory::GetInstance().CreateRootNode(&rhs);
}
CTextNode& CGenerator::GetCurrentNode() const
{
	return *m_pCurrent;
}
CTextNode& CGenerator::FindElementUpwardsByName(const tstring& name) const
{
	CTextNode* result= m_pCurrent;
	while (!result->IsNull())
	{
		if (name==result->GetName()) return *result;
		result= &result->GetParent();
	}
	return *result;
}


} // namespace text
} // namespace altova

