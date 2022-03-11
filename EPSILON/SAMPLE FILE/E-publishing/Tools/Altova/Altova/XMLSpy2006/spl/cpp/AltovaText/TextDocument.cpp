[call GenerateFileHeader("TextDocument.cpp")]
#include "StdAfx.h"
#include "TextDocument.h"
#include "TextException.h"
#include "Functions.h"
#include "Function.h"
#include "Generator.h"
#include "Helpers.h"
#include "TextNode.h"
#include "EDIFactSerializer.h"
#include "EDIFactDataCompletion.h"
#include "EDIX12DataCompletion.h"
#include "EDIFactSettings.h"
#include "EDIX12Settings.h"
#include "FlexCommand.h"



namespace altova
{
namespace text
{


namespace flex
{

const CTextNode& CTextDocument::ParseFile(const tstring& filename)
{
	
	tstring buffer;
	if (LoadFileIntoBuffer(filename, buffer, m_nEncoding, m_nByteorder))
	{
		return ParseString(buffer);
	}
	return CNullTextNode::GetInstance();
}
const CTextNode& CTextDocument::ParseString(const tstring& str)
{
	if (!m_pFlexProject)
		throw CTextException(CAltovaException::eError1, _T("Parse error: No syntax definition."));
	CTextDocumentReader doc(str, &GetGenerator());
	m_pFlexProject->ReadText(doc);
	return GetGenerator().GetRootNode();
}
void CTextDocument::SaveFile(const tstring& filename) const
{
	tstring str;
	SaveString(str);
	SaveFileFromBuffer(filename, str, m_nEncoding, m_nByteorder, m_bBom);
}
void CTextDocument::SaveString(tstring& str) const
{
	if (!m_pFlexProject)
		throw CTextException(CAltovaException::eError1, _T("Save error: No syntax definition."));

	CTextDocumentWriter doc(GetRoot(), str);
	m_pFlexProject->WriteText(doc);
}
CGenerator&	CTextDocument::GetGenerator()
{
	return m_Generator;
}
const CGenerator& CTextDocument::GetGenerator() const
{
	return m_Generator;
}
CTextNode& CTextDocument::GetRoot() const
{
	return m_Generator.GetRootNode();
}

} // namespace flex


////////////////////////////////////////////////////////////////////////

namespace edi
{

const CTextNode& CTextDocument::ParseFile(const tstring& filename)
{
	tstring buffer;
	if (LoadFileIntoBuffer(filename, buffer, m_nEncoding, m_nByteorder))
	{
		TrimStart(buffer);
		if (this->ValidateSource(buffer))
		{
			CParser::Parse(buffer.c_str());
			m_Generator.Done();
			this->ValidateResult();
			return m_Generator.GetRootNode();
		}
	}
	return CNullTextNode::GetInstance();
}
CGenerator&	CTextDocument::GetGenerator()
{
	return m_Generator;
}
const CGenerator& CTextDocument::GetGenerator() const
{
	return m_Generator;
}
CStringToFunctionMap& CTextDocument::GetFunctions()
{
	return m_Functions;
}
const CStringToFunctionMap&	CTextDocument::GetFunctions() const
{
	return m_Functions;
}
CStringToFunctionMap& CTextDocument::GetHandlers()
{
	return m_Handlers;
}
const CStringToFunctionMap& CTextDocument::GetHandlers() const
{
	return m_Handlers;
}
CTextNode& CTextDocument::GetRoot() const
{
	return m_Generator.GetRootNode();
}
void CTextDocument::SetProlog(const tstring& rhs)
{
	m_Prolog= rhs;
}
void CTextDocument::SetEpilog(const tstring& rhs)
{
	m_Epilog= rhs;
}
void CTextDocument::Prolog()
{
	if (!m_Prolog.empty()) this->ProcessFunction(m_Prolog);
}
void CTextDocument::Epilog()
{
	if (!m_Epilog.empty()) this->ProcessFunction(m_Epilog);
}
void CTextDocument::ProcessToken(const tstring& token)
{
	CFunction* handler= m_Handlers.Get(token);
	if (NULL==handler)
		throw CTextException(CAltovaException::eError1, _T("Parse Error: handler not found."));

	handler->Execute(*this);
	// while the scanner is not at the end of the segment,
	// ignore the extra content and move to the next
	// segment token. store the ignored text and
	// build an error entry for later processing
	CScanner& scanner= GetScanner();
	if (scanner.EndOfText()) return;
	TCHAR segmentseparator= scanner.GetSeparator(_T("segment"));
	while ((segmentseparator!=scanner.Current()) && (scanner.ScanChar()!=kEnd));
}
void CTextDocument::ProcessFunction(const tstring& name)
{
	CFunction* function = m_Functions.Get(name);
	if (NULL==function)
		throw CTextException(CAltovaException::eError1, _T("Parse Error: Function not found."));

	function->Execute(*this);
}
void CTextDocument::RecordDecimalSeparator()
{
	CRootTextNode& root= (CRootTextNode&) GetGenerator().GetRootNode();
	root.SetDecimalSeparator(GetSettings().GetServiceStringAdvice().GetDecimalNotation());
}
std::auto_ptr<CDataCompletion> CTextDocument::GetDataCompletion() const
{
	CDataCompletion* datacompletion= NULL;
	switch (GetStandard())
	{
	case EDIFact:
		datacompletion= new CEDIFactDataCompletion((const CEDIFactSettings&) GetSettings(), GetStructureName());
		break;
	case EDIX12:
		datacompletion= new CEDIX12DataCompletion((const CEDIX12Settings&) GetSettings(), GetStructureName());
		break;
	}
	return std::auto_ptr<CDataCompletion>(datacompletion);
}
void CTextDocument::Save(const CTextNode& structureroot, const tstring& filename) const
{
	CTextNode& root= m_Generator.GetRootNode();

	if (GetSettings().GetAutoCompleteData())
	{
		std::auto_ptr<CDataCompletion> datacompletion= GetDataCompletion();
		datacompletion->CompleteData(root);
	}

	tstringstream str;
	if (EDIFact==GetStandard())
	{
		if (((const CEDIFactSettings&) GetSettings()).GetWriteUNA())
		{
			GetSettings().GetServiceStringAdvice().Serialize(str);
			if (GetSettings().GetTerminateSegmentsWithLinefeed()) str << std::endl;
		}
	}
	RemoveEmptyNodes(root);
	AdjustDataToStructure(structureroot, root);
	CEDIFactSerializer serializer(GetSettings().GetServiceStringAdvice(), str, GetSettings().GetTerminateSegmentsWithLinefeed());
	serializer.SerializeNode(root);
	SaveFileFromBuffer(filename, str.str(), m_nEncoding, m_nByteorder, m_bBom);
}
bool CTextDocument::IsEmptyDataElement(const CTextNode& node) const
{
	return ((DataElement==node.GetClass()) &&
	        (0==node.GetValue().size())
	       );
}
bool CTextDocument::IsContainerNodeWithoutChildren(const CTextNode& node) const
{
	ENodeClass eClass = node.GetClass();
	return (eClass == Composite || eClass == Group) && (node.GetChildren().GetCount() == 0);
}
void CTextDocument::RemoveEmptyNodes(CTextNode& node) const
{
	CTextNodeContainer& children= node.GetChildren();
	size_t i = 0;
	size_t n = children.GetCount();
	while (i<n)
	{
		CTextNode& kid= children.GetAt(i);
		RemoveEmptyNodes(kid);
		if ((IsEmptyDataElement(kid)) || (IsContainerNodeWithoutChildren(kid)))
		{
			children.RemoveAt(i);
			CTextNode* ptr= &kid;
			CTextNodeFactory::GetInstance().Delete(ptr);
			--n;
		}
		else
			++i;
	}

}
void CTextDocument::AdjustDataToStructure(const CTextNode& structureroot, CTextNode& dataroot) const
{
	dataroot.SetPositionInFather(structureroot.GetPositionInFather());
	dataroot.SetFollowingSeparators(structureroot.GetFollowingSeparators());
	dataroot.SetPrecedingSeparators(structureroot.GetPrecedingSeparators());
	CTextNodeContainer& datachildren= dataroot.GetChildren();
	const CTextNodeContainer& structurechildren= structureroot.GetChildren();
	size_t dataindex= 0;
	size_t structureindex= 0;
	while (dataindex<datachildren.GetCount())
	{
		CTextNode& datakid= datachildren.GetAt(dataindex);
		while ((structureindex<structurechildren.GetCount()) &&
			   (structurechildren.GetAt(structureindex).GetName()!=datakid.GetName()))
			++structureindex;
		ASSERT(structureindex<structurechildren.GetCount());
		AdjustDataToStructure(structurechildren.GetAt(structureindex), datachildren.GetAt(dataindex));
		++dataindex;
	}
}
bool CTextDocument::ValidateResult()
{
	RemoveEmptyNodes(m_Generator.GetRootNode());
	return true;
}

} // namespace edi
} // namespace text
} // namespace altova
