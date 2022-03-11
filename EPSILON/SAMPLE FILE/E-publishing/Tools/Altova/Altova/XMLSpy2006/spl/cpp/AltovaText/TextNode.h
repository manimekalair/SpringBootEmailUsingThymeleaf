[call GenerateFileHeader("TextNode.h")]
#ifndef __ALTOVATEXT_TEXTNODE_H
#define __ALTOVATEXT_TEXTNODE_H

#include "AltovaTextAPI.h"

#include <list>

namespace altova
{
namespace text
{

class CTextNode;
typedef std::list<CTextNode*>		CTextNodePtrList;
typedef std::vector<CTextNode*>		CTextNodePtrVector;

class ALTOVATEXT_DECLSPECIFIER CTextNodeContainer
{
public:
	virtual ~CTextNodeContainer() {}
	size_t GetCount() const;
	const CTextNode& GetAt(size_t index) const;
	CTextNode& GetAt(size_t index);
	virtual bool Add(CTextNode* rhs);
	virtual void Insert(CTextNode* rhs, size_t index);
	void FilterByName(const tstring& name, CTextNodeContainer& target) const;
	bool HasNodeByName(const tstring& name) const;
	const CTextNode* GetFirstNodeByName(const tstring& name) const;
	bool Contains(CTextNode& rhs) const;
	void RemoveAt(size_t index);

	template <class VoidFunctor>
	inline void ApplyToAll(VoidFunctor& functor) const
	{
		CTextNodePtrVector::const_iterator i= m_List.begin(), e = m_List.end();
		for(; i!=e; ++i) functor(**i);
	}

	template <class BoolFunctor>
	inline bool ConditionalApplyToAll(BoolFunctor& functor) const
	{
		bool docontinue = TRUE;
		CTextNodePtrVector::const_iterator i= m_List.begin(), e= m_List.end();
		for(; i!=e && docontinue; ++i) docontinue= functor(**i);
		return docontinue;
	}

protected:
	CTextNodePtrVector& GetInternalList();

private:
	void AddToMap(CTextNode*);
	void RemoveFromMap(CTextNode*);

private:
	typedef std::map<tstring, CTextNodePtrVector> CName2TextNodePtrVectorMap;
	CName2TextNodePtrVectorMap m_Map;
	CTextNodePtrVector m_List;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER COwnedTextNodeContainer : public CTextNodeContainer
{
public:
	COwnedTextNodeContainer(CTextNode& owner);
	~COwnedTextNodeContainer();

	void AddWithoutSettingParent(CTextNode* rhs);

public: // overriding CTextNodeContainer
	virtual bool Add(CTextNode* rhs);
	virtual void Insert(CTextNode* rhs, size_t index);

private:
	CTextNode& m_Owner;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CAlwaysEmptyTextNodeContainer : public CTextNodeContainer
{
public: // override CTextNodeContainer
	virtual bool Add(CTextNode* );
	virtual void Insert(CTextNode*, size_t);
};

//////////////////////////////////////////////////////////////////////////

enum ENodeClass
{
	Undefined,
	DataElement,
	Composite,
	Segment,
	Group
};

//////////////////////////////////////////////////////////////////////////

class CRootTextNode;

class ALTOVATEXT_DECLSPECIFIER CTextNodeFactory
{
public:
	static CTextNodeFactory& GetInstance();
	~CTextNodeFactory();
	CTextNode* Create(CTextNode&, const tstring&, const tstring& = _T(""));
	CRootTextNode* CreateRootNode(CTextNode* = NULL);
	void Delete(CTextNode*&);

private:
	CTextNodeFactory();

private:
	typedef std::set<CTextNode*> CTextNodePtrSet;
	CTextNodePtrSet m_RegisteredNodes;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CTextNode
{
friend CTextNodeFactory;

public:
	virtual CTextNode& GetRoot();
	virtual const CTextNode& GetRoot() const;
	virtual CTextNode& GetParent();
	virtual const CTextNode& GetParent() const;
	virtual void SetParent(CTextNode&, bool = true);

	virtual CTextNodeContainer& GetChildren();
	virtual const CTextNodeContainer& GetChildren() const;

	virtual const tstring& GetName() const;
	virtual const tstring& GetValue() const;
	virtual ENodeClass GetClass() const;
	virtual bool HasDecimalData() const;
	virtual size_t GetMaximumLength() const;
	virtual const tstring& GetNativeName() const;
	virtual const tstring& GetFollowingSeparators() const;
	virtual const tstring& GetPrecedingSeparators() const;
	virtual size_t GetPositionInFather() const;
	virtual bool IsContainedInTree(const CTextNode&) const;
	virtual bool IsNull() const;

	virtual void SetName(const tstring&);
	virtual void SetValue(const tstring&);
	virtual void SetClass(ENodeClass);
	virtual void SetHasDecimalData(bool);
	virtual void SetMaximumLength(size_t);
	virtual void SetNativeName(const tstring&);
	virtual void SetFollowingSeparators(const tstring&);
	virtual void SetPrecedingSeparators(const tstring&);
	virtual void SetPositionInFather(size_t);

protected:
	CTextNode();
	virtual ~CTextNode();

private:
	COwnedTextNodeContainer* m_Children;
	CTextNode* m_Parent;
	tstring m_Name;
	tstring m_Value;
	ENodeClass m_Class;
	bool m_HasDecimalData;
	size_t m_MaximumLength;
	tstring m_NativeName;
	tstring m_PrecedingSeparators;
	tstring m_FollowingSeparators;
	size_t m_PositionInFather;

private:
	CTextNode(const CTextNode&);
	CTextNode& operator=(const CTextNode&);
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CNullTextNode : public CTextNode
{
public:
	static CNullTextNode& GetInstance();

public: // overriding CTextNode
	virtual CTextNode& GetRoot();
	virtual const CTextNode& GetRoot() const;
	virtual CTextNode& GetParent();
	virtual void SetParent(CTextNode& rhs);

	virtual CTextNodeContainer& GetChildren();
	virtual const CTextNodeContainer& GetChildren() const;

	virtual const tstring& GetName() const;
	virtual const tstring& GetValue() const;
	virtual ENodeClass GetClass() const;
	virtual bool HasDecimalData() const;
	virtual const tstring& GetNativeName() const;
	virtual const tstring& GetFollowingSeparators() const;
	virtual const tstring& GetPrecedingSeparators() const;
	virtual size_t GetPositionInFather() const;
	virtual bool IsContainedInTree(const CTextNode& rhs) const;
	virtual bool IsNull() const;

	virtual void SetName(const tstring&);
	virtual void SetValue(const tstring&);
	virtual void SetClass(ENodeClass);
	virtual void SetHasDecimalData(bool);
	virtual void SetNativeName(const tstring&);
	virtual void SetFollowingSeparators(const tstring&);
	virtual void SetPrecedingSeparators(const tstring&);
	virtual void SetPositionInFather(size_t);

private:
	CNullTextNode();

private:
	CAlwaysEmptyTextNodeContainer m_Children;
	tstring m_Name;
	tstring m_Value;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CRootTextNode : public CTextNode
{
friend CTextNodeFactory;

private:
	CRootTextNode();
	CRootTextNode(CTextNode&);

public: // overriding CTextNode
	virtual CTextNode& GetRoot();
	virtual const CTextNode& GetRoot() const;
	virtual CTextNode& GetParent();
	virtual void SetParent(CTextNode&);
	virtual void SetClass(ENodeClass);

	TCHAR GetDecimalSeparator() const { return m_DecimalSeparator; }
	void SetDecimalSeparator(TCHAR ch) { m_DecimalSeparator = ch; }

private:
	TCHAR m_DecimalSeparator;
};

} // namespace text
} // namespace altova

#endif
