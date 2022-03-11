[call GenerateFileHeader("EDIX12DataCompletion.cpp")]
#include "StdAfx.h"
#include "EDIX12DataCompletion.h"
#include "TextNode.h"
#include "EDIX12Settings.h"
#include "MakeSureHasChild.h"

namespace altova
{
namespace text
{
namespace edi
{

CEDIX12DataCompletion::CEDIX12DataCompletion(const CEDIX12Settings& settings,
											 const tstring& structurename)
:	CDataCompletion(structurename)
,	m_Settings(settings)
,	m_Root(&CNullTextNode::GetInstance())
,	m_GroupRoot(&CNullTextNode::GetInstance())
,	m_MessageRoot(&CNullTextNode::GetInstance())
{
}

void CEDIX12DataCompletion::CompleteData(CTextNode& dataroot)
{
    m_Root = &MakeSureHasChild::AsFirst(dataroot, _T("Interchange"));
    MakeSureHasChild::AsFirst(m_Root, _T("ISA"));
    m_GroupRoot = &MakeSureHasChild::At(m_Root, _T("Group"), 1);
    MakeSureHasChild::AsLast(m_Root, _T("IEA"));
    CompleteInterchange();
}

namespace Functors
{
	class PaddingFunctor
	{
	public:
		void operator() (CTextNode& node)
		{
			tstring value= node.GetValue();
			UINT desired= node.GetMaximumLength();
			if (node.HasDecimalData())
			{
				while (value.length()<desired)
					value= _T('0') + value;
			}
			else
			{
				while (value.length()<desired)
					value+= _T(' ');
			}
			node.SetValue(value);
		}
	};
}

void CEDIX12DataCompletion::CompleteInterchange()
{
    CTextNode& isa = GetKid(*m_Root, _T("ISA"));
    CTextNode& iea = GetKid(*m_Root, _T("IEA"));

	Functors::PaddingFunctor paddingfunctor;
	isa.GetChildren().ApplyToAll(paddingfunctor);

    CTextNode& FI01 = MakeSureHasChild::AsFirst(isa, _T("FI01"));
    ConservativeSetValue(FI01, _T("00"));
    CTextNode& FI02 = MakeSureHasChild::At(isa, _T("FI02"), 1);
    ConservativeSetValue(FI02, _T("          "));
    CTextNode& FI03 = MakeSureHasChild::At(isa, _T("FI03"), 2);
    ConservativeSetValue(FI03, _T("00"));
    CTextNode& FI04 = MakeSureHasChild::At(isa, _T("FI04"), 3);
    ConservativeSetValue(FI04, _T("          "));
    CTextNode& FI05_1 = MakeSureHasChild::At(isa, _T("FI05_1"), 4);
    ConservativeSetValue(FI05_1, _T("ZZ"));
    CTextNode& FI05_2 = MakeSureHasChild::At(isa, _T("FI05_2"), 6);
    ConservativeSetValue(FI05_2, _T("ZZ"));
    CTextNode& FI08 = MakeSureHasChild::At(isa, _T("FI08"), 8);
    ConservativeSetValue(FI08, GetCurrentDateAsEDIString());
    CTextNode& FI09 = MakeSureHasChild::At(isa, _T("FI09"), 9);
    ConservativeSetValue(FI09, GetCurrentTimeAsEDIString());
    CTextNode& FI65 = MakeSureHasChild::At(isa, _T("FI65"), 10);
    ConservativeSetValue(FI65, m_Settings.GetSubElementSeparator());
    CTextNode& FI11 = MakeSureHasChild::At(isa, _T("FI11"), 11);
    ConservativeSetValue(FI11, m_Settings.GetInterchangeControlVersionNumber());
    CTextNode& FI12 = MakeSureHasChild::At(isa, _T("FI12"), 12);
    CTextNode& FI13 = MakeSureHasChild::At(isa, _T("FI13"), 13);
    ConservativeSetValue(FI13, m_Settings.GetRequestAcknowledgement() ? _T("1") : _T("0"));
    CTextNode& FI14 = MakeSureHasChild::At(isa, _T("FI14"), 14);
    ConservativeSetValue(FI14, _T("P"));
    CTextNode& FI15 = MakeSureHasChild::At(isa, _T("FI15"), 15);
    ConservativeSetValue(FI15, m_Settings.GetServiceStringAdvice().GetComponentDataElementSeparator());


	CTextNodeContainer groups;
	m_Root->GetChildren().FilterByName(_T("Group"), groups);
	for (size_t i= 0; i<groups.GetCount(); ++i)
	{
		m_GroupRoot= &groups.GetAt(i);
		MakeSureHasChild::AsFirst(m_GroupRoot, _T("GS"));
       	MakeSureHasChild::AsLast(m_GroupRoot, _T("GE"));
		CompleteGroup();
	}


    CTextNode& IEAFI16 = MakeSureHasChild::AsFirst(iea, _T("FI16"));
    ConservativeSetValue(IEAFI16, GetNamedChildrenCount(*m_Root, _T("Group")));
    CTextNode& IEAFI12 = MakeSureHasChild::AsLast(iea, _T("FI12"));
    ConservativeSetValue(IEAFI12, FI12.GetValue());
}

void CEDIX12DataCompletion::CompleteGroup()
{
    CTextNode& GS = GetKid(*m_GroupRoot, _T("GS"));
    if (!GS.IsNull())
	{
		CTextNode& GE = GetKid(*m_GroupRoot, _T("GE"));
		CTextNode& GSF373 = MakeSureHasChild::At(GS, _T("F373"), 3);
		ConservativeSetValue(GSF373, GetCurrentDateAsEDIString());
		CTextNode& GSF337 = MakeSureHasChild::At(GS, _T("F337"), 4);
		ConservativeSetValue(GSF337, GetCurrentTimeAsEDIString());
		CTextNode& GSF28 = GetKid(GS, _T("F28"));
		CTextNode& GEF97 = MakeSureHasChild::AsFirst(GE, _T("F97"));
		ConservativeSetValue(GEF97, GetNamedChildrenCount(GS.GetParent(), _T("Message")));
		CTextNode& GEF28 = MakeSureHasChild::AsLast(GE, _T("F28"));
		ConservativeSetValue(GEF28, GSF28.GetValue());
	}

	size_t possiblepositions\[\] = {0, 1};
    m_MessageRoot = &MakeSureHasChild::At(m_GroupRoot, _T("Message"), possiblepositions, 2);

	CTextNodeContainer messages;
	m_GroupRoot->GetChildren().FilterByName(_T("Message"), messages);
	for (size_t i= 0; i<messages.GetCount(); ++i)
	{
		m_MessageRoot= &messages.GetAt(i);
		MakeSureHasChild::AsFirst(m_MessageRoot, _T("ST"));
		MakeSureHasChild::AsLast(m_MessageRoot, _T("SE"));
		CompleteMessage();
	}
}

void CEDIX12DataCompletion::CompleteMessage()
{
    CTextNode& ST = GetKid(*m_MessageRoot, _T("ST"));
    CTextNode& SE = GetKid(*m_MessageRoot, _T("SE"));
    CTextNode& STF143 = MakeSureHasChild::AsFirst(ST, _T("F143"));
    ConservativeSetValue(STF143, GetStructureName());
    CTextNode& SEF96 = MakeSureHasChild::AsFirst(SE, _T("F96"));
    long segmentcount = GetSegmentChildrenCount(ST.GetParent());
    ConservativeSetValue(SEF96, segmentcount);
    CTextNode& STF329 = MakeSureHasChild::At(ST, _T("F329"), 1);
    CTextNode& SEF329 = MakeSureHasChild::AsLast(SE, _T("F329"));
    ConservativeSetValue(SEF329, STF329.GetValue());
}


} // namespace edi
} // namespace text
} // namespace altova