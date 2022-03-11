[call GenerateFileHeader("EDIFactDataCompletion.cpp")]
#include "StdAfx.h"
#include "EDIFactDataCompletion.h"
#include "EDIFactSettings.h"
#include "TextNode.h"
#include "ServiceStringAdvice.h"
#include "MakeSureHasChild.h"
#include "TextException.h"

namespace altova
{
namespace text
{
namespace edi
{

CEDIFactDataCompletion::CEDIFactDataCompletion(const CEDIFactSettings& settings, const tstring &structurename)
		: CDataCompletion(structurename), m_Settings(settings)
{
}
	
void CEDIFactDataCompletion::CompleteData(CTextNode& dataroot)
{
	CompleteEnvelope(dataroot);
}
	
void CEDIFactDataCompletion::CompleteEnvelope (CTextNode& envelope)
{
	if (envelope.GetName() != _T("Envelope"))
		throw CTextException(CAltovaException::eError1, _T("CompleteEnvelope: root node is not an envelope"));

	MakeSureHasChild::AsFirst(envelope, _T("Interchange"));

	CTextNodeContainer interchanges; 
	envelope.GetChildren().FilterByName(_T("Interchange"), interchanges);
	for (size_t i=0; i< interchanges.GetCount(); ++i)
			CompleteInterchange(interchanges.GetAt(i));
}

void CEDIFactDataCompletion::CompleteInterchange(CTextNode& interchange)
{
	CTextNode& unb = MakeSureHasChild::AsFirst(interchange, _T("UNB"));
	MakeSureHasChild::At(interchange, _T("Group"), 1);
	CTextNode& unz = MakeSureHasChild::AsLast (interchange, _T("UNZ"));
	
	CTextNodeContainer groups;
	interchange.GetChildren().FilterByName(_T("Group"), groups);
	for (int i=0; i< groups.GetCount(); ++i)
		CompleteGroup(groups.GetAt(i));
	
	CompleteInterchangeHeader(unb);
	CompleteInterchangeTrailer(unz);
}

void CEDIFactDataCompletion::CompleteInterchangeHeader(CTextNode& unb)
{
	CTextNode& s001  = MakeSureHasChild::At(unb, _T("S001"),  0);
	CTextNode& s002  = MakeSureHasChild::At(unb, _T("S002"),  1);
	CTextNode& s003  = MakeSureHasChild::At(unb, _T("S003"),  2);
	CTextNode& s004  = MakeSureHasChild::At(unb, _T("S004"),  3);
	CTextNode& f0020 = MakeSureHasChild::At(unb, _T("F0020"), 4);

	CompleteS001(s001);
	CompleteS004(s004);
}

void CEDIFactDataCompletion::CompleteInterchangeTrailer(CTextNode& unz)
{
	CTextNode& f0036 = MakeSureHasChild::At(unz, _T("F0036"), 0);
	CTextNode& f0020 = MakeSureHasChild::At(unz, _T("F0020"), 1);

	ConservativeSetValue(f0036, GetNumberOfFunctionGroupsOrMessages(unz.GetParent()));
	const CTextNode* unb = unz.GetParent().GetChildren().GetFirstNodeByName(_T("UNB"));
	CTextNodeContainer unbChildren;
	unb->GetChildren().FilterByName(_T("F0020"), unbChildren);
	tstring ctrlRef = unbChildren.GetAt(unbChildren.GetCount()-1).GetValue();
	ConservativeSetValue(f0020, ctrlRef);
}

void CEDIFactDataCompletion::CompleteGroup(CTextNode& group)
{
	CTextNode& ung = CNullTextNode::GetInstance();
	CTextNode& une = CNullTextNode::GetInstance();

	if (HasKid(group, _T("UNG")))
	{
		MakeSureHasChild::At(group, _T("Message"), 1);
		MakeSureHasChild::AsLast(group, _T("UNE"));
	}
	else if (HasKid(group, _T("UNE")))
	{
		MakeSureHasChild::AsFirst(group, _T("UNG"));
		MakeSureHasChild::At(group, _T("Message"), 1);
	}
	else
		MakeSureHasChild::AsFirst(group, _T("Message"));

	CTextNodeContainer messages;
	group.GetChildren().FilterByName(_T("Message"), messages);
	for(size_t i=0; i< messages.GetCount(); ++i)
		CompleteMessage(messages.GetAt(i));

	CompleteGroupHeader(GetKid(group, _T("UNG")));
	CompleteGroupTrailer(GetKid(group, _T("UNE")));
}

void CEDIFactDataCompletion::CompleteGroupHeader(CTextNode& ung)
{
	if (ung.IsNull())
		return;

	CTextNode& f0038 = MakeSureHasChild::AsFirst(ung, _T("F0038"));
	CTextNode& s006 = MakeSureHasChild::At(ung, _T("S006"), 1);
	CTextNode& s007 = MakeSureHasChild::At(ung, _T("S007"), 2);
	CTextNode& s004 = MakeSureHasChild::At(ung, _T("S004"), 3);
	CTextNode& f0048 = MakeSureHasChild::At(ung, _T("F0048"), 4);
	CTextNode& f0051 = MakeSureHasChild::At(ung, _T("F0051"), 5);
	CTextNode& s008 = MakeSureHasChild::At(ung, _T("S008"), 6);
	CTextNode& f0058 = MakeSureHasChild::At(ung, _T("F0058"), 7);
	
	ConservativeSetValue(f0038, GetStructureName());
	CompleteS004(s004);
	ConservativeSetValue(f0048, ung.GetParent().GetChildren().GetFirstNodeByName(_T("UNE"))->GetChildren().GetFirstNodeByName(_T("F0048"))->GetValue());
	ConservativeSetValue(f0051, m_Settings.GetControllingAgency().substr(0,2));
}

void CEDIFactDataCompletion::CompleteGroupTrailer(CTextNode& une)
{
	if (une.IsNull())
		return;

	CTextNode& f0060 = MakeSureHasChild::At(une, _T("F0060"), 0);
	CTextNode& f0048 = MakeSureHasChild::At(une, _T("F0048"), 1);

	CTextNodeContainer messages;
	une.GetParent().GetChildren().FilterByName(_T("Message"), messages);
	ConservativeSetValue(f0060, (long) messages.GetCount());
	ConservativeSetValue(f0048, une.GetParent().GetChildren().GetFirstNodeByName(_T("UNG"))->GetChildren().GetFirstNodeByName(_T("F0048"))->GetValue());
}

void CEDIFactDataCompletion::CompleteMessage(CTextNode& message) 
{
	CTextNode& unh = MakeSureHasChild::AsFirst(message, _T("UNH"));
	CTextNode& unt = MakeSureHasChild::AsLast(message, _T("UNT"));

	CompleteMessageHeader(unh);
	CompleteMessageTrailer(unt);
}

void CEDIFactDataCompletion::CompleteMessageHeader(CTextNode& unh) 
{
	CTextNode& f0062 = MakeSureHasChild::At(unh, _T("F0062"), 0);
	CTextNode& s009 = MakeSureHasChild::At(unh, _T("S009"), 1);

	ConservativeSetValue(f0062, unh.GetParent().GetChildren().GetFirstNodeByName(_T("UNT"))->GetValue());
	CompleteS009 (s009);
}

void CEDIFactDataCompletion::CompleteMessageTrailer(CTextNode& unt) 
{
	CTextNode& f0074 = MakeSureHasChild::At(unt, _T("F0074"), 0);
	CTextNode& f0062 = MakeSureHasChild::At(unt, _T("F0062"), 1);

	ConservativeSetValue(f0074, GetSegmentChildrenCount(unt.GetParent()));
	ConservativeSetValue(f0062, unt.GetParent().GetChildren().GetFirstNodeByName(_T("UNH"))->GetChildren().GetFirstNodeByName(_T("F0062"))->GetValue());
}

void CEDIFactDataCompletion::CompleteS001(CTextNode& s001)
{
	CTextNode& f0001 = MakeSureHasChild::At(s001, _T("F0001"), 0);
	CTextNode& f0002 = MakeSureHasChild::At(s001, _T("F0002"), 1);

	ConservativeSetValue(f0001, m_Settings.GetControllingAgency() + m_Settings.GetSyntaxLevel());
	ConservativeSetValue(f0002, m_Settings.GetSyntaxVersionNumber());
}

void CEDIFactDataCompletion::CompleteS004(CTextNode& s004)
{
	CTextNode& f0017 = MakeSureHasChild::At(s004, _T("F0017"), 0);
	CTextNode& f0019 = MakeSureHasChild::At(s004, _T("F0019"), 1);

	ConservativeSetValue(f0017, GetCurrentDateAsEDIString());
	ConservativeSetValue(f0019, GetCurrentTimeAsEDIString());
}

void CEDIFactDataCompletion::CompleteS009(CTextNode& s009)
{
	CTextNode& f0065 = MakeSureHasChild::At(s009, _T("F0065"), 0);
	CTextNode& f0052 = MakeSureHasChild::At(s009, _T("F0052"), 1);
	CTextNode& f0054 = MakeSureHasChild::At(s009, _T("F0054"), 2);
	CTextNode& f0051 = MakeSureHasChild::At(s009, _T("F0051"), 3);
	
	ConservativeSetValue(f0065, GetStructureName());
	ConservativeSetValue(f0051, m_Settings.GetControllingAgency().substr(0, 2));
}

long CEDIFactDataCompletion::GetNumberOfFunctionGroupsOrMessages(CTextNode& node)
{
	size_t nUNH =0;
	size_t nUNT =0;
	size_t nUNG =0;
	size_t nUNE =0;

	CTextNodeContainer groups;
	node.GetChildren().FilterByName(_T("Group"), groups);
	for (size_t i=0; i< groups.GetCount(); ++i)
	{
		CTextNodeContainer ungs;
		groups.GetAt(i).GetChildren().FilterByName(_T("UNG"), ungs);
		nUNG += ungs.GetCount();
		CTextNodeContainer unes;
		groups.GetAt(i).GetChildren().FilterByName(_T("UNE"), unes);
		nUNE += unes.GetCount();

		CTextNodeContainer messages;
		groups.GetAt(i).GetChildren().FilterByName(_T("Message"), messages);
		for (size_t j=0; j< messages.GetCount(); ++j)
		{
			CTextNodeContainer unhs;
			messages.GetAt(j).GetChildren().FilterByName(_T("UNH"), unhs);
			nUNH +=  unhs.GetCount();
			CTextNodeContainer unts;
			messages.GetAt(j).GetChildren().FilterByName(_T("UNT"), unts);
			nUNT += unts.GetCount();
		}
	}
	
	if (nUNH != nUNT)
		throw CTextException(CAltovaException::eError1, _T("Message header-trailer mismatch"));
	if (nUNG != nUNE)
		throw CAltovaException(CAltovaException::eError1, _T("Group header-trailer mismatch"));

	return nUNG == 0 ? nUNH : nUNG;
}

} // namespace edi
} // namespace text
} // namespace altova
