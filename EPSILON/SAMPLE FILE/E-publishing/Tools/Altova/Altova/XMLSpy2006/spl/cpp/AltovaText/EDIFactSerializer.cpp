[call GenerateFileHeader("EDIFactSerializer.cpp")]
#include "StdAfx.h"
#include "EDIFactSerializer.h"

#include "TextNode.h"
#include "ServiceStringAdvice.h"

namespace altova
{
namespace text
{
namespace edi
{

CEDIFactSerializer::CEDIFactSerializer(const CServiceStringAdvice& una, tostream& stream,
									   bool terminatesegmentswithextralinefeed)
:	m_UNA(una)
,	m_Stream(stream)
,	m_TerminateSegmentsWithExtraLineFeed(terminatesegmentswithextralinefeed)
{
}
void CEDIFactSerializer::SerializeNode(const CTextNode& node)
{
	switch (node.GetClass())
	{
	case DataElement:
		SerializeDataElement(node);
		break;
	case Composite:
		SerializeComposite(node);
		break;
	case Segment:
		SerializeSegment(node);
		break;
	default:
		SerializeGroup(node);
		break;
	}
}
void CEDIFactSerializer::SerializeDataElement(const CTextNode& node)
{
	if (node.HasDecimalData())
		SerializeAsDecimal(node.GetValue());
	else if (node.GetName()!=_T("FI15"))
		SerializeAsText(node.GetValue());
	else
		WriteString(node.GetValue());
}
void CEDIFactSerializer::SerializeComposite(const CTextNode& node)
{
	SerializeGroup(node);
}
void CEDIFactSerializer::SerializeSegment(const CTextNode& node)
{
	WriteString(node.GetNativeName());
	if (0<node.GetChildren().GetCount())
	{
		WriteChar(m_UNA.GetDataElementSeparator());
		SerializeGroup(node);
	}
	WriteChar(m_UNA.GetSegmentTerminator());
	if (m_TerminateSegmentsWithExtraLineFeed) WriteChar('\\n');
}
void CEDIFactSerializer::SerializeGroup(const CTextNode& node)
{
	const CTextNodeContainer& children= node.GetChildren();
	size_t size= children.GetCount();
	if (0==size) return;
	const UINT firstposition= children.GetAt(0).GetPositionInFather();
	if (0!=firstposition)
	{
		const tstring& separators= children.GetAt(0).GetPrecedingSeparators();
		UINT separatorlength= (UINT) separators.size();
		UINT count= (firstposition<separatorlength) ? firstposition : separatorlength;
		if (0<count)
		{
			tstring tmp;
			for (size_t i= 0; i<count; ++i)
			{
				tmp+= TranslateSeparator(separators\[i\]);
			}
			WriteString(tmp);
		}

	}
	for (size_t i= 0; i<size-1; ++i)
	{
		const CTextNode& first= children.GetAt(i);
		const CTextNode& next= children.GetAt(i+1);
		SerializeNode(first);
		WriteSeparatorsBetween(first, next);
	}
	SerializeNode(children.GetAt(size-1));

}
void CEDIFactSerializer::WriteSeparatorsBetween(const CTextNode& left, const CTextNode& right)
{
	UINT posLeft= left.GetPositionInFather();
	UINT posRight= right.GetPositionInFather();
	tstring separators = left.GetFollowingSeparators();

	if( separators.empty() 
	&&  left.GetName() == right.GetName()
	&&  left.GetClass() == Composite 
	&&  right.GetClass() == Composite )
	{
		separators += _T("0");
		posRight = posLeft + 1;
	}

	if( separators.empty() 
	&&  left.GetName() == right.GetName()
	&&  left.GetClass() == DataElement
	&&  right.GetClass() == DataElement )
	{
		if( left .GetParent().GetClass() == Composite
		&&  right.GetParent().GetClass() == Composite)
		{
			separators += _T("1");	// insert the composite separator
		}
		else
		{
			separators += _T("0");	// insert the data element separator
		}
		posRight = posLeft + 1;
	}

	if( posLeft == posRight
	&&	left.GetName() == right.GetName()
	&&  left.GetClass() == DataElement
	&&  right.GetClass() == DataElement )
	{
		posRight = posLeft + 1;
	}
	
	if (0==separators.size()) return;

	for (UINT i= posLeft; i<posRight; ++i)
	{
		TCHAR sep= separators\[(size_t) (i-posLeft)\];
		WriteChar(TranslateSeparator(sep));
	}
}
void CEDIFactSerializer::SerializeAsText(const tstring& rhs)
{
	if (m_UNA.GetReleaseIndicator()==_T(' '))
		WriteString(rhs);
	else
	{
		tstring escapedvalue;
		for (size_t i= 0; i<rhs.size(); ++i)
		{
			TCHAR c= rhs\[i\];
			if ((c==m_UNA.GetComponentDataElementSeparator()) ||
				(c==m_UNA.GetDataElementSeparator()) ||
				(c==m_UNA.GetReleaseIndicator()) ||
				(c==m_UNA.GetSegmentTerminator()))
				escapedvalue+= m_UNA.GetReleaseIndicator();
			escapedvalue+= c;
		}
		WriteString(escapedvalue);
	}
}
void CEDIFactSerializer::SerializeAsDecimal(const tstring& rhs)
{
	tstring decimalvalue;
	for (size_t i= 0; i<rhs.size(); ++i)
	{
		TCHAR c= rhs\[i\];
		if (c==_T('.'))
			decimalvalue+= m_UNA.GetDecimalNotation();
		else
			decimalvalue+= c;
	}
	WriteString(decimalvalue);
}
void CEDIFactSerializer::WriteString(const tstring& rhs)
{
	m_Stream.write(rhs.c_str(), rhs.size());
}
void CEDIFactSerializer::WriteChar(TCHAR rhs)
{
	m_Stream.put(rhs);
}
TCHAR CEDIFactSerializer::TranslateSeparator(TCHAR rhs) const
{
	TCHAR result= rhs;
	switch (rhs)
	{
	case _T('0'):
		result= m_UNA.GetDataElementSeparator();
		break;
	case _T('1'):
		result= m_UNA.GetComponentDataElementSeparator();
		break;
	}
	return result;
}


} // namespace edi
} // namespace text
} // namespace altova
