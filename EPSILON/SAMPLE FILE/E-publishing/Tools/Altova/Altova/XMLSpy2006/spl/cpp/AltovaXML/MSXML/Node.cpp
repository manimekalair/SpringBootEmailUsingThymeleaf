////////////////////////////////////////////////////////////////////////
//
// Node.cpp
//
// This file was generated by [=$Host].
//
// YOU SHOULD NOT MODIFY THIS FILE, BECAUSE IT WILL BE
// OVERWRITTEN WHEN YOU RE-RUN CODE GENERATION.
//
// Refer to the [=$HostShort] Documentation for further details.
// [=$HostURL]
//
////////////////////////////////////////////////////////////////////////


#include "StdAfx.h"
#include "../Altova/Altova.h"
#include "../Altova/AltovaException.h"
#include "../Altova/SchemaTypes.h"
#include "../Altova/SchemaTypeString.h"
#include "XmlException.h"
#include "Doc.h"
#include "Node.h"

namespace altova {


CNode::CNode()
{
	m_spDocument	= CDoc::GetDocument();
	m_spNode		= CDoc::CreateFragment();
}


CNode::CNode(CNode& rParentNode, MSXML2::IXMLDOMNodePtr spThisNode)
{
	m_spDocument	= rParentNode.m_spDocument;
	m_spNode		= spThisNode;
}


CNode::CNode(MSXML2::IXMLDOMDocument2Ptr& rspDocument)
{
	m_spDocument	= rspDocument;
	m_spNode		= rspDocument->documentElement;
}


CNode::~CNode()
{
	if ( m_spDocument )
		m_spDocument.Release();

	CDoc::CheckDocumentCounter();
}


CNode& CNode::operator=(const CNode& other)
{
	if (m_spDocument != other.m_spDocument)
	{
		if ( m_spDocument )
			m_spDocument.Release();

		CDoc::CheckDocumentCounter();
	}

	m_spDocument	= other.m_spDocument;
	m_spNode		= other.m_spNode;

	return *this;
}


CNode& CNode::Assign(const CNode& other)
{
	if (m_spDocument != other.m_spDocument)
	{
		if ( m_spDocument )
			m_spDocument.Release();

		CDoc::CheckDocumentCounter();
	}

	MSXML2::IXMLDOMTextPtr	pText;
	BSTR	str = other.m_spNode->text;
	pText = other.m_spDocument->createTextNode( str );
	m_spNode->appendChild( pText );

	return *this;
}


tstring CNode::Transform(const tstring& sXSLTFilename)
{
	MSXML2::IXMLDOMDocument2Ptr spXSLTDocument;
	spXSLTDocument.CreateInstance(__uuidof(MSXML2::DOMDocument40));
	spXSLTDocument->async = VARIANT_FALSE;
	spXSLTDocument->setProperty(_T("NewParser"), true);

	if (!spXSLTDocument->load(_variant_t(sXSLTFilename.c_str())))
	{
		MSXML2::IXMLDOMParseErrorPtr spError = spXSLTDocument->parseError;
		throw CXmlException(CXmlException::eError1, (LPCTSTR)spError->reason);
	}

	return (LPCTSTR)m_spNode->transformNode(spXSLTDocument);
}


tstring CNode::GetNodeName() const
{
	return (LPCTSTR)m_spNode->nodeName;
}


tstring CNode::GetNodeText() const
{
	return (LPCTSTR)m_spNode->text;
}


tstring CNode::ToXMLString() const
{
	return (LPCTSTR)m_spNode->xml;
}


MSXML2::IXMLDOMNodePtr CNode::GetDOMNode()
{
	return m_spNode;
}


void CNode::MapPrefix(const tstring& sPrefix, const tstring& sURI)
{
	sm_sTargetNamespacePrefix = sPrefix;
	sm_sTargetNamespaceURI = sURI;
}


tstring CNode::InternalGetElementValue()
{
	return (LPCTSTR)m_spNode->text;
}


void CNode::InternalSetElementValue(tstring sValue)
{
	m_spNode->text = sValue.c_str();
}


void CNode::DeclareNamespace(tstring sPrefix, const tstring& sURI)
{
	if (sURI.empty())
		return;

	MSXML2::IXMLDOMElementPtr spRootElement = m_spDocument->documentElement;

	if (sURI == sm_sTargetNamespaceURI)
		sPrefix = sm_sTargetNamespacePrefix;
	if (sPrefix.empty())
		spRootElement->setAttribute(_T("xmlns"), sURI.c_str());
	else
		spRootElement->setAttribute((_T("xmlns:") + sPrefix).c_str(), sURI.c_str());
}


MSXML2::IXMLDOMNodePtr CNode::CreateNode(ENodeType eNodeType, const tstring& sNamespaceURI, const tstring& sName)
{
	_variant_t varNodeType;
	switch ( eNodeType )
	{
	case Element : 
		varNodeType = (short)MSXML2::NODE_ELEMENT;
		break;
	case Comment : 
		varNodeType = (short)MSXML2::NODE_COMMENT;
		break;
	case ProcessingInstruction : 
		varNodeType = (short)MSXML2::NODE_PROCESSING_INSTRUCTION;
		break;
	case Text:
		varNodeType = (short)MSXML2::NODE_TEXT;
		break;
	case CData:
		varNodeType = (short)MSXML2::NODE_CDATA_SECTION;
		break;
	default:
		varNodeType = (short)MSXML2::NODE_ATTRIBUTE;
		break;
	}
	return m_spDocument->createNode(varNodeType, AdjustQualifiedName(sNamespaceURI, sName).c_str(), sNamespaceURI.c_str());
}

bool CNode::NamesMatch(MSXML2::IXMLDOMNodePtr  pNode, const tstring& sNamespaceURI, const tstring& sName)
{
	return (!pNode->namespaceURI && sNamespaceURI.empty() || pNode->namespaceURI == _bstr_t(sNamespaceURI.c_str()))
		&& pNode->baseName == _bstr_t(sName.c_str());}

tstring	CNode::GetNodeTextValue( MSXML2::IXMLDOMNodePtr pNode )
{
	return (LPCTSTR)pNode->text;
}

bool CNode::CompareChildName(MSXML2::IXMLDOMNodePtr spChild, const tstring& sNamespaceURI, const tstring& sName)
{
	tstring::size_type nPos = sName.find(_T(':'));
	tstring sLocalName;
	if (nPos == tstring::npos)
		sLocalName = sName;
	else
		sLocalName = sName.substr(nPos + 1);

	return (!spChild->namespaceURI && sNamespaceURI.empty() || spChild->namespaceURI == _bstr_t(sNamespaceURI.c_str()))
		&& spChild->baseName == _bstr_t(sLocalName.c_str());
}


tstring CNode::AdjustQualifiedName(const tstring& sNamespaceURI, const tstring& sName)
{
	tstring sPrefix = LookupPrefix(m_spNode, sNamespaceURI);
	tstring::size_type nPos = sName.find(_T(':'));
	if (nPos == tstring::npos)
		return sPrefix.empty() ? sName : ( sPrefix + _T(":") + sName );
	else
		return sPrefix.empty() ? sName.substr( nPos + 1 ) : ( sPrefix + sName.substr( nPos ) );
}


int CNode::ChildCountInternal(ENodeType eNodeType, const tstring& sNamespaceURI, const tstring& sName)
{
	if (eNodeType == Element)
	{
		int nCount = 0;

		for (MSXML2::IXMLDOMNodePtr spChild = m_spNode->firstChild; spChild; spChild = spChild->nextSibling)
			if (CompareChildName(spChild, sNamespaceURI, sName))
				nCount++;
		return nCount;
	}
	else // eNodeType == Attribute
	{
		return m_spNode->attributes->getQualifiedItem(sName.c_str(), sNamespaceURI.c_str()) ? 1 : 0;
	}
}


bool CNode::InternalHasChild(ENodeType eNodeType, const tstring& sNamespaceURI, const tstring& sName)
{
	if (eNodeType == Element)
	{
		for (MSXML2::IXMLDOMNodePtr spChild = m_spNode->firstChild; spChild; spChild = spChild->nextSibling)
			if (CompareChildName(spChild, sNamespaceURI, sName))
				return true;
		return false;
	}
	else // eNodeType == Attribute
	{
		return m_spNode->attributes->getQualifiedItem(sName.c_str(), sNamespaceURI.c_str()) ? true : false;
	}
}


MSXML2::IXMLDOMNodePtr CNode::InternalAppend(ENodeType eNodeType, const tstring& sNamespaceURI, const tstring& sName, const tstring& sValue)
{
	switch ( eNodeType )
	{
	case Text:
		{
		MSXML2::IXMLDOMTextPtr spTextNode = CreateNode(Text, sNamespaceURI, sName);
		spTextNode->text = sValue.c_str();
		m_spNode->appendChild(spTextNode);
		return spTextNode;
		}
	case CData:
		{
		MSXML2::IXMLDOMTextPtr spTextNode = CreateNode(CData, sNamespaceURI, sName);
		spTextNode->text = sValue.c_str();
		m_spNode->appendChild(spTextNode);
		return spTextNode;
		}
	case Comment:
		{
		MSXML2::IXMLDOMCommentPtr spCommentNode = CreateNode(Comment, sNamespaceURI, sName);
		spCommentNode->text = sValue.c_str();
		m_spNode->appendChild(spCommentNode);
		return spCommentNode;
		}
	case ProcessingInstruction:
		{
		MSXML2::IXMLDOMProcessingInstructionPtr spPINode = CreateNode(ProcessingInstruction, sNamespaceURI, sName);
		spPINode->text = sValue.c_str();
		m_spNode->appendChild(spPINode);
		return spPINode;
		}
	case Element:
		{
		MSXML2::IXMLDOMElementPtr spElement = CreateNode(Element, sNamespaceURI, sName);
		spElement->text = sValue.c_str();
		m_spNode->appendChild(spElement);
		return spElement;
		}
	default: // eNodeType == Attribute
		{
		MSXML2::IXMLDOMAttributePtr spAttribute = CreateNode(Attribute, sNamespaceURI, sName);
		spAttribute->text = sValue.c_str();
		m_spNode->attributes->setNamedItem(spAttribute);
		return spAttribute;
		}
	}
}


MSXML2::IXMLDOMNodePtr CNode::InternalAppendNode(const tstring& sNamespaceURI, const tstring& sElement, CNode& rNode, MSXML2::IXMLDOMNodePtr spHostNode/* = MSXML2::IXMLDOMNodePtr()*/)
{
	MSXML2::IXMLDOMElementPtr spElement = CreateNode(Element, sNamespaceURI, sElement);

	for (MSXML2::IXMLDOMNodePtr spChild = rNode.m_spNode->firstChild; spChild; spChild = spChild->nextSibling)
	{
		spElement->appendChild( spChild->cloneNode( VARIANT_TRUE ) );
	}

	MSXML2::IXMLDOMNamedNodeMapPtr spAttributeMap = rNode.m_spNode->attributes;
	long nLength = spAttributeMap->length;
	for (int i = 0; i < nLength; i++)
	{
		spElement->attributes->setNamedItem( spAttributeMap->item\[i\]->cloneNode( VARIANT_TRUE ) );
	}

	rNode.m_spNode = spElement;
	rNode.m_spDocument = m_spDocument;

	if (spHostNode == NULL)
		m_spNode->appendChild(spElement);
	else
		spHostNode->appendChild(spElement);

	rNode.m_spNode = spElement;

	return spElement;
}


MSXML2::IXMLDOMNodePtr CNode::InternalRemoveAt(ENodeType eNodeType, const tstring& sNamespaceURI, const tstring& sName, int nIndex)
{
	if (eNodeType == Element)
	{
		int nCount = 0;
		for (MSXML2::IXMLDOMNodePtr spChild = m_spNode->firstChild; spChild; spChild = spChild->nextSibling)
			if (CompareChildName(spChild, sNamespaceURI, sName))
				if (nCount++ == nIndex)
					return m_spNode->removeChild(spChild);
		if (nCount > 0)
			throw CXmlException(CXmlException::eError1, _T("Index out of range"));
		else
			throw CXmlException(CXmlException::eError1, _T("Not found"));
	}
	else // eNodeType == Attribute
	{
		return m_spNode->attributes->removeNamedItem(sName.c_str());
	}
}


MSXML2::IXMLDOMNodePtr CNode::InternalInsertAt(ENodeType eNodeType, const tstring& sNamespaceURI, const tstring& sName, int nIndex, const tstring& sValue)
{
	if (eNodeType == Element)
	{
		MSXML2::IXMLDOMElementPtr spElement = CreateNode(Element, sNamespaceURI, sName);
		spElement->text = sValue.c_str();
		return m_spNode->insertBefore(spElement, InternalGetAt(Element, sNamespaceURI, sName, nIndex).GetInterfacePtr());

	}
	else // eNodeType == Attribute
	{
		MSXML2::IXMLDOMAttributePtr spAttribute = CreateNode(Attribute, sNamespaceURI, sName);
		spAttribute->text = sValue.c_str();
		m_spNode->attributes->setNamedItem(spAttribute);
		return spAttribute;
	}
}


MSXML2::IXMLDOMNodePtr CNode::InternalInsertNodeAt(const tstring& sNamespaceURI, const tstring& sName, int nIndex, CNode& rNode)
{
	MSXML2::IXMLDOMElementPtr spElement = CreateNode(Element, sNamespaceURI, sName);

	while (rNode.m_spNode->firstChild != 0)
	{
		spElement->appendChild(rNode.m_spNode->removeChild(rNode.m_spNode->firstChild));
	}

	MSXML2::IXMLDOMNamedNodeMapPtr spAttributeMap = rNode.m_spNode->attributes;
	while (spAttributeMap->length > 0)
	{
		spElement->attributes->setNamedItem(spAttributeMap->removeNamedItem(spAttributeMap->item\[0\]->nodeName));
	}

	rNode.m_spNode = spElement;
	rNode.m_spDocument = m_spDocument;
	return m_spNode->insertBefore(spElement, InternalGetAt(Element, sNamespaceURI, sName, nIndex).GetInterfacePtr());
}


MSXML2::IXMLDOMNodePtr CNode::InternalReplaceAt(ENodeType eNodeType, const tstring& sNamespaceURI, const tstring& sName, int nIndex, const tstring& sValue)
{
	if (eNodeType == Element)
	{
		MSXML2::IXMLDOMElementPtr spElement = CreateNode(Element, sNamespaceURI, sName);
		spElement->text = sValue.c_str();
		return m_spNode->replaceChild(spElement, InternalGetAt(Element, sNamespaceURI, sName, nIndex));

	}
	else // eNodeType == Attribute
	{
		if (nIndex > 0)
			throw CXmlException(CXmlException::eError1, _T("Index must be zero"));
		MSXML2::IXMLDOMAttributePtr spAttribute = m_spNode->attributes->getQualifiedItem(sName.c_str(), sNamespaceURI.c_str());
		if (spAttribute)
		{
			spAttribute->text = sValue.c_str();
			return spAttribute;
		}
		else
			throw CXmlException(CXmlException::eError1, _T("Not found"));
	}
}


MSXML2::IXMLDOMNodePtr CNode::InternalReplaceNodeAt(const tstring& sNamespaceURI, const tstring& sName, int nIndex, CNode& rNode)
{
	MSXML2::IXMLDOMElementPtr spElement = CreateNode(Element, sNamespaceURI, sName);

	while (rNode.m_spNode->firstChild != 0)
	{
		spElement->appendChild(rNode.m_spNode->removeChild(rNode.m_spNode->firstChild));
	}

	MSXML2::IXMLDOMNamedNodeMapPtr spAttributeMap = rNode.m_spNode->attributes;
	while (spAttributeMap->length > 0)
	{
		spElement->attributes->setNamedItem(spAttributeMap->removeNamedItem(spAttributeMap->item\[0\]->nodeName));
	}

	rNode.m_spNode = spElement;
	rNode.m_spDocument = m_spDocument;
	return m_spNode->replaceChild(spElement, InternalGetAt(Element, sNamespaceURI, sName, nIndex));
}


MSXML2::IXMLDOMNodePtr CNode::InternalGetAt(ENodeType eNodeType, const tstring& sNamespaceURI, const tstring& sName, int nIndex)
{
	if (eNodeType == Element)
	{
		int nCount = 0;
		for (MSXML2::IXMLDOMNodePtr spChild = m_spNode->firstChild; spChild; spChild = spChild->nextSibling)
			if (CompareChildName(spChild, sNamespaceURI, sName))
				if (nCount++ == nIndex)
					return spChild;
		if (nCount > 0)
			throw CXmlException(CXmlException::eError1, _T("Index out of range"));
		else
			throw CXmlException(CXmlException::eError1, _T("Not found"));
	}
	else // eNodeType == Attribute
	{
		if (nIndex > 0)
			throw CXmlException(CXmlException::eError1, _T("Index must be zero"));
		MSXML2::IXMLDOMNodePtr spAttribute = m_spNode->attributes->getQualifiedItem(sName.c_str(), sNamespaceURI.c_str());
		if (spAttribute)
			return spAttribute;
		else
			throw CXmlException(CXmlException::eError1, _T("Index out of range"));
	}
}

MSXML2::IXMLDOMNodePtr CNode::InternalGetFirstChild(ENodeType eNodeType, const tstring& sNamespaceURI, const tstring& sName)
{
	if (eNodeType == Element)
	{
		for (MSXML2::IXMLDOMNodePtr spChild = m_spNode->firstChild; spChild; spChild = spChild->nextSibling)
			if (CompareChildName(spChild, sNamespaceURI, sName))
					return spChild;
	}
	else // eNodeType == Attribute
	{
		MSXML2::IXMLDOMNodePtr spAttribute = m_spNode->attributes->getQualifiedItem(sName.c_str(), sNamespaceURI.c_str());
		if (spAttribute)
			return spAttribute;
	}
	return NULL;
}

MSXML2::IXMLDOMNodePtr CNode::InternalGetNextChild(ENodeType eNodeType, const tstring& sNamespaceURI, const tstring& sName, MSXML2::IXMLDOMNodePtr pCurNode )
{
	if (eNodeType == Element && pCurNode != NULL )
	{
		for (MSXML2::IXMLDOMNodePtr spChild = pCurNode->nextSibling; spChild; spChild = spChild->nextSibling)
			if (CompareChildName(spChild, sNamespaceURI, sName))
					return spChild;
	}
	
	return NULL;
}


MSXML2::IXMLDOMNodePtr CNode::InternalSet(ENodeType eNodeType, const tstring& sNamespaceURI, const tstring& sName, const tstring& sValue)
{
	if (ChildCountInternal(eNodeType, sNamespaceURI, sName) == 0)
		return InternalAppend(eNodeType, sNamespaceURI, sName, sValue);
	else
		return InternalReplaceAt(eNodeType, sNamespaceURI, sName, 0, sValue);
}


tstring	CNode::sm_sTargetNamespacePrefix;

tstring CNode::sm_sTargetNamespaceURI;

tstring CNode::LookupPrefix(MSXML2::IXMLDOMNodePtr spNode, const tstring& sURI)
{
	if (!(bool)spNode || sURI.empty())
		return _T("");

	if( sURI == sm_sTargetNamespaceURI )
		return sm_sTargetNamespacePrefix;

	if (spNode->nodeTypeString == _bstr_t(L"element"))
	{
		MSXML2::IXMLDOMNamedNodeMapPtr spAttrs = spNode->attributes;
		if (spAttrs)
		{
			long nLength = spAttrs->length;
			for (int i = 0; i < nLength; i++)
			{
				MSXML2::IXMLDOMAttributePtr spAttr = spAttrs->item\[i\];
				_bstr_t bsValue = spAttr->nodeValue;
				if ((LPCTSTR)bsValue == sURI)
				{
					tstring sName = (LPCTSTR)spAttr->nodeName;
					if (sName.length() >= 6 && sName.substr(0, 6) == _T("xmlns:"))
						return sName.substr(6);
					else
						return _T("");
				}
			}
		}
		return LookupPrefix(spNode->parentNode, sURI);
	}
	else if (spNode->nodeTypeString == _bstr_t(L"attribute"))
	{
		return LookupPrefix(spNode->parentNode, sURI);
	}
	else
	{
		return _T("");
	}
}


CAnyTypeNode::CAnyTypeNode(const CSchemaString& Value)
{
	InternalSetElementValue(Value);
}

CAnyTypeNode& CAnyTypeNode::operator=(const CSchemaString& Value)
{
	InternalSetElementValue(Value);
	return *this;
}

void CAnyTypeNode::Assign(const CSchemaString& Value)
{
	InternalSetElementValue(Value);
}

CAnyTypeNode::operator CSchemaString()
{
	return InternalGetElementValue();
}

CNode::EGroupType CAnyTypeNode::GetGroupType()
{
	return eSequence;
}

void CAnyTypeNode::AdjustPrefix()
{
}

void CAnyTypeNode::AddTextNode(CSchemaString text)
{
	InternalAppend(Text, _T(""), _T("#text"), text);
}

void CAnyTypeNode::AddCDataNode(CSchemaString text)
{
	InternalAppend(CData, _T(""), _T("#cdata"), text);
}

void CAnyTypeNode::AddComment(CSchemaString text)
{
	InternalAppend(Comment, _T(""), _T("#cdata"), text);
}

void CAnyTypeNode::AddProcessingInstruction(CSchemaString name, CSchemaString text)
{
	InternalAppend(ProcessingInstruction, _T(""), name, text);
}


} // namespace altova