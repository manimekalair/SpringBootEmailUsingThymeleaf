[call GenerateFileHeader("DataCompletion.cpp")]
#include "StdAfx.h"
#include "DataCompletion.h"
#include "TextNode.h"

namespace altova
{
namespace text
{
namespace edi
{


CDataCompletion::CDataCompletion(const tstring& structurename)
:	m_StructureName(structurename)
{}

CTextNode& CDataCompletion::GetKid(const CTextNode& parent, tstring name)
{
	CTextNodeContainer tmp;
	parent.GetChildren().FilterByName(name, tmp);
	return tmp.GetAt(0);
}
bool CDataCompletion::HasKid(const CTextNode& parent, tstring name)
{
	CTextNodeContainer tmp;
	parent.GetChildren().FilterByName(name, tmp);
	return (0<tmp.GetCount());
}
void CDataCompletion::ConservativeSetValue(CTextNode& node, tstring value)
{
	if (0==node.GetValue().length())
		node.SetValue(value);
}
void CDataCompletion::ConservativeSetValue(CTextNode& node, TCHAR value)
{
	if (0==node.GetValue().length())
	{
		tstring newvalue= node.GetValue();
		newvalue+= value;
		node.SetValue(newvalue);
	}
}
void CDataCompletion::ConservativeSetValue(CTextNode& node, long value)
{
	if (0==node.GetValue().length())
	{
		tstringstream tmp;
		tmp << value;
		node.SetValue(tmp.str());
	}
}
namespace Functors
{
	class SegmentCountingFunctor
	{
	public:
		SegmentCountingFunctor()
			:	m_Count(0)
		{}
		long GetCount() const
		{
			return m_Count;
		}
	public:
		void operator() (CTextNode& node)
		{
			if (Segment==node.GetClass())
				++m_Count;
			node.GetChildren().ApplyToAll(*this);
		}
	private:
		long m_Count;
	};
}

long CDataCompletion::GetSegmentChildrenCount(const CTextNode& node)
{
	Functors::SegmentCountingFunctor functor;
	node.GetChildren().ApplyToAll(functor);
	return functor.GetCount();
}

long CDataCompletion::GetNamedChildrenCount(const CTextNode& node, const tstring& name)
{
	CTextNodeContainer tmp;
	node.GetChildren().FilterByName(name, tmp);
	return tmp.GetCount();
}

tstring CDataCompletion::GetCurrentDateAsEDIString()
{
	SYSTEMTIME now;
	GetSystemTime(&now);
	TCHAR buffer\[10\];
	GetDateFormat(LOCALE_SYSTEM_DEFAULT, 0, &now, _T("yyMMdd"), buffer, 10);
	return buffer;
}

tstring CDataCompletion::GetCurrentTimeAsEDIString()
{
	SYSTEMTIME now;
	GetSystemTime(&now);
	TCHAR buffer\[10\];
	GetTimeFormat(LOCALE_SYSTEM_DEFAULT, 0, &now, _T("HHmm"), buffer, 10);
	return buffer;
}

const tstring& CDataCompletion::GetStructureName() const
{
	return m_StructureName;
}

} // namespace edi
} // namespace text
} // namespace altova
