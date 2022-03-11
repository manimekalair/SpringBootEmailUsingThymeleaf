[call GenerateFileHeader("TextNode.cpp")]
#include "StdAfx.h"
#include "TextNode.h"
#include "TextException.h"
#include "Helpers.h"

#include <algorithm>

namespace altova
{
namespace text
{

CTextNodeFactory& CTextNodeFactory::GetInstance()
{
	static CTextNodeFactory instance;
	return instance;
}

CTextNodeFactory::CTextNodeFactory()
{}

CTextNodeFactory::~CTextNodeFactory()
{
	CTextNodePtrSet::const_iterator i= m_RegisteredNodes.begin(), e= m_RegisteredNodes.end();
	for (; i!=e; ++i)
		delete *i;
}

CTextNode* CTextNodeFactory::Create(CTextNode& parent, const tstring& name, const tstring& nativename)
{
	CTextNode* result= new CTextNode();
	result->SetName(name);
	result->SetNativeName((0==nativename.size()) ? name : nativename);
	result->SetParent(parent);
	m_RegisteredNodes.insert(result);
	return result;
}
CRootTextNode* CTextNodeFactory::CreateRootNode(CTextNode* innernode)
{
	CRootTextNode* result= NULL;
	if (NULL==innernode) result= new CRootTextNode();
	else result= new CRootTextNode(*innernode);
	m_RegisteredNodes.insert(result);
	return result;
}
void CTextNodeFactory::Delete(CTextNode*& node)
{
	if (m_RegisteredNodes.end()==m_RegisteredNodes.find(node))
		return;

	if (node->IsNull())
		return;

	delete node;
	m_RegisteredNodes.erase(node);
	node= &CNullTextNode::GetInstance();
}



CTextNode::CTextNode()
:	m_Parent(&CNullTextNode::GetInstance())
,	m_Name(_T(""))
,	m_Value(_T(""))
,	m_Class(Undefined)
,	m_MaximumLength(0)
,	m_PositionInFather(0)
,	m_PrecedingSeparators(_T(""))
,	m_FollowingSeparators(_T(""))
{
	m_Children= new COwnedTextNodeContainer(*this);
}
CTextNode::~CTextNode()
{
	delete m_Children;
}
CTextNode& CTextNode::GetRoot()
{
	return (m_Parent->IsNull()) ? *this : m_Parent->GetRoot();
}
const CTextNode& CTextNode::GetRoot() const
{
	return (m_Parent->IsNull()) ? *this : m_Parent->GetRoot();
}
CTextNode& CTextNode::GetParent()
{
	return *m_Parent;
}
const CTextNode& CTextNode::GetParent() const
{
	return *m_Parent;
}
CTextNodeContainer& CTextNode::GetChildren()
{
	return *m_Children;
}
const CTextNodeContainer& CTextNode::GetChildren() const
{
	return *m_Children;
}
const tstring& CTextNode::GetName() const
{
	return m_Name;
}
const tstring& CTextNode::GetValue() const
{
	return m_Value;
}
ENodeClass CTextNode::GetClass() const
{
	return m_Class;
}
bool CTextNode::HasDecimalData() const
{
	return m_HasDecimalData;
}
size_t CTextNode::GetMaximumLength() const
{
	return m_MaximumLength;
}
const tstring& CTextNode::GetNativeName() const
{
	return m_NativeName;
}
const tstring& CTextNode::GetFollowingSeparators() const
{
	return m_FollowingSeparators;
}
const tstring& CTextNode::GetPrecedingSeparators() const
{
	return m_PrecedingSeparators;
}
size_t CTextNode::GetPositionInFather() const
{
	return m_PositionInFather;
}
bool CTextNode::IsNull() const
{
	return false;
}
void CTextNode::SetName(const tstring& rhs)
{
	m_Name= rhs;
}
void CTextNode::SetValue(const tstring& rhs)
{
	m_Value= rhs;
}
void CTextNode::SetClass(ENodeClass rhs)
{
	m_Class= rhs;
}
void CTextNode::SetHasDecimalData(bool rhs)
{
	m_HasDecimalData= rhs;
}
void CTextNode::SetMaximumLength(size_t rhs)
{
	m_MaximumLength= rhs;
}
void CTextNode::SetNativeName(const tstring& rhs)
{
	m_NativeName= rhs;
}
void CTextNode::SetFollowingSeparators(const tstring& rhs)
{
	m_FollowingSeparators= rhs;
}
void CTextNode::SetPrecedingSeparators(const tstring& rhs)
{
	m_PrecedingSeparators= rhs;
}
void CTextNode::SetPositionInFather(size_t rhs)
{
	m_PositionInFather= rhs;
}
void CTextNode::SetParent(CTextNode& rhs, bool alsoInsert)
{
	ASSERT(m_Parent->IsNull());

	m_Parent = &rhs;
	if (m_Parent->IsNull()) return;

	if (alsoInsert) m_Parent->m_Children->AddWithoutSettingParent(this);
}

namespace Internal
{
	class SearchingFunctor
	{
	public:
		SearchingFunctor(const CTextNode& pattern)
		:	m_Pattern(pattern)
		,	m_Found( FALSE )
		{}

		bool operator() (CTextNode& node)
		{
			m_Found= node.IsContainedInTree(m_Pattern);
			return !m_Found;
		}

		bool HasFound() const
		{
			return m_Found;
		}

	private:
		const CTextNode& m_Pattern;
		bool m_Found;
	};


}

bool CTextNode::IsContainedInTree(const CTextNode& rhs) const
{
	if (this==&rhs) return true;
	if (0==m_Children->GetCount()) return false;
	Internal::SearchingFunctor functor(rhs);
	m_Children->ConditionalApplyToAll(functor);
	return functor.HasFound();
}
// -----------------------------------------------------------------------------------------------
size_t CTextNodeContainer::GetCount() const
{
	return m_List.size();
}
const CTextNode& CTextNodeContainer::GetAt(size_t index) const
{
	if ((0>index) || (index>=m_List.size()))
		return CNullTextNode::GetInstance();
	CTextNodePtrVector::const_iterator i= m_List.begin();
	std::advance(i, index);
	return **i;
}
CTextNode& CTextNodeContainer::GetAt(size_t index)
{
	if ((0>index) || (index>=m_List.size()))
		return CNullTextNode::GetInstance();
	CTextNodePtrVector::const_iterator i= m_List.begin();
	std::advance(i, index);
	return **i;
}
bool CTextNodeContainer::Add(CTextNode* rhs)
{
	m_List.push_back(rhs);
	AddToMap(rhs);
	return true;
}
void CTextNodeContainer::Insert(CTextNode* rhs, size_t index)
{
	CTextNodePtrVector::iterator i= m_List.begin();
	std::advance(i, index);
	m_List.insert(i, rhs);
	AddToMap(rhs);
}
void CTextNodeContainer::FilterByName(const tstring& name, CTextNodeContainer& target) const
{
	CName2TextNodePtrVectorMap::const_iterator hit= m_Map.find(name);
	if (m_Map.end()!=hit)
	{
		target.m_List= hit->second;
	}
}
bool CTextNodeContainer::HasNodeByName(const tstring& name) const
{
	CTextNodeContainer matchingchildren;
	FilterByName(name, matchingchildren);
	return (0<matchingchildren.GetCount());
}
const CTextNode* CTextNodeContainer::GetFirstNodeByName(const tstring& name) const
{
	CTextNodeContainer matchingchildren;
	FilterByName(name, matchingchildren);
	if (0==matchingchildren.GetCount())
		return NULL;
	return &matchingchildren.GetAt(0);
}
bool CTextNodeContainer::Contains(CTextNode& rhs) const
{
	CTextNodePtrVector::const_iterator b= m_List.begin(), e= m_List.end();
	CTextNodePtrVector::const_iterator i= std::find(b, e, &rhs);
	return (e!=i);
}
CTextNodePtrVector& CTextNodeContainer::GetInternalList()
{
	return m_List;
}
void CTextNodeContainer::RemoveAt(size_t index)
{
	CTextNodePtrVector::iterator i= m_List.begin();
	std::advance(i, index);
	RemoveFromMap(*i);
	m_List.erase(i);
}
void CTextNodeContainer::AddToMap(CTextNode* rhs)
{
	tstring key= rhs->GetNativeName();
	if (0==key.size()) key= rhs->GetName();
	std::pair<CName2TextNodePtrVectorMap::iterator, bool> tmp= m_Map.insert(CName2TextNodePtrVectorMap::value_type(key, CTextNodePtrVector()));
	CName2TextNodePtrVectorMap::iterator& i= tmp.first;
	i->second.push_back(rhs);
}
void CTextNodeContainer::RemoveFromMap(CTextNode* rhs)
{
	tstring key= rhs->GetNativeName();
	if (0==key.size()) key= rhs->GetName();
	CName2TextNodePtrVectorMap::iterator& mi= m_Map.find(key);
	CTextNodePtrVector& v = mi->second;
	CTextNodePtrVector::iterator vi = v.begin();
	do
	{
		if (*vi == rhs)
		{
			v.erase(vi);
			break;
		}
		else
		{
			vi++;
		}
	}
	while (vi!= v.end());
}

// -----------------------------------------------------------------------------------------------
COwnedTextNodeContainer::COwnedTextNodeContainer(CTextNode& owner)
:	m_Owner(owner)
{}
COwnedTextNodeContainer::~COwnedTextNodeContainer()
{
	CTextNodePtrVector& internallist= GetInternalList();
	CTextNodePtrVector::iterator i= internallist.begin(), e= internallist.end();
	for (; i!=e; ++i)
		CTextNodeFactory::GetInstance().Delete(*i);
}
void COwnedTextNodeContainer::AddWithoutSettingParent(CTextNode* rhs)
{
	CTextNodeContainer::Add(rhs);
}
bool COwnedTextNodeContainer::Add(CTextNode* rhs)
{
	rhs->SetParent(m_Owner);
	return true;
}
void COwnedTextNodeContainer::Insert(CTextNode* rhs, size_t index)
{
	ASSERT(rhs->GetParent().IsNull());
	CTextNodeContainer::Insert(rhs, index);
	rhs->SetParent(m_Owner, false);
}

// -----------------------------------------------------------------------------------------------
bool CAlwaysEmptyTextNodeContainer::Add(CTextNode* )
{
	return false;
}
void CAlwaysEmptyTextNodeContainer::Insert(CTextNode*, size_t) {} // no-op

// -----------------------------------------------------------------------------------------------
CNullTextNode& CNullTextNode::GetInstance()
{
	static CNullTextNode instance;
	return instance;
}

CTextNode& CNullTextNode::GetRoot()
{
	return *this;
}
const CTextNode& CNullTextNode::GetRoot() const
{
	return *this;
}
CTextNode& CNullTextNode::GetParent()
{
	return *this;
}
CTextNodeContainer& CNullTextNode::GetChildren()
{
	return m_Children;
}
const CTextNodeContainer& CNullTextNode::GetChildren() const
{
	return m_Children;
}
const tstring& CNullTextNode::GetName() const
{
	return m_Name;
}
const tstring& CNullTextNode::GetValue() const
{
	return m_Value;
}
ENodeClass CNullTextNode::GetClass() const
{
	return Undefined;
}
bool CNullTextNode::HasDecimalData() const
{
	return false;
}
const tstring& CNullTextNode::GetNativeName() const
{
	return m_Name;
}
const tstring& CNullTextNode::GetFollowingSeparators() const
{
	return m_Name;
}
const tstring& CNullTextNode::GetPrecedingSeparators() const
{
	return m_Name;
}
size_t CNullTextNode::GetPositionInFather() const
{
	return 0;
}
bool CNullTextNode::IsContainedInTree(const CTextNode&) const
{
	return false;
}
bool CNullTextNode::IsNull() const
{
	return true;
}
void CNullTextNode::SetNativeName(const tstring&) {} // no-op
void CNullTextNode::SetHasDecimalData(bool) {} // no-op
void CNullTextNode::SetClass(ENodeClass) {} // no-op
void CNullTextNode::SetName(const tstring&) {} // no-op
void CNullTextNode::SetValue(const tstring&) {} // no-op
void CNullTextNode::SetParent(CTextNode&) {} // no-op
void CNullTextNode::SetFollowingSeparators(const tstring&) {} // no-op
void CNullTextNode::SetPrecedingSeparators(const tstring&) {} // no-op
void CNullTextNode::SetPositionInFather(size_t) {} // no-op
CNullTextNode::CNullTextNode()
:	m_Name(_T(""))
,	m_Value(_T(""))
{}
// -----------------------------------------------------------------------------------------------------
CRootTextNode::CRootTextNode()
	: m_DecimalSeparator(_T('.'))
{
	CTextNode::SetClass(Group);
}
CRootTextNode::CRootTextNode(CTextNode& source)
{
	SetName(source.GetName());
	SetValue(source.GetValue());
	GetChildren()= source.GetChildren();
}
CTextNode& CRootTextNode::GetRoot()
{
	return *this;
}
const CTextNode& CRootTextNode::GetRoot() const
{
	return *this;
}
CTextNode& CRootTextNode::GetParent()
{
	return CNullTextNode::GetInstance();
}
void CRootTextNode::SetParent( CTextNode& )
{
	ASSERT(false);
}
void CRootTextNode::SetClass(ENodeClass) {} // no-op

} // namespace text
} // namespace altova
