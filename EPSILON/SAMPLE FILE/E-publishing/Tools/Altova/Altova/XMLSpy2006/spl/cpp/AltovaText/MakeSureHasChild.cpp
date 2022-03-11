[call GenerateFileHeader("MakeSureHasChild.cpp")]
#include "StdAfx.h"
#include "MakeSureHasChild.h"
#include "TextNode.h"

namespace altova
{
namespace text
{
namespace edi
{
namespace MakeSureHasChild
{

CTextNode& At(CTextNode& parent, const tstring& name, size_t possiblepositions\[\], int positioncount)
{
	CTextNode* result= &CNullTextNode::GetInstance();
	CTextNodeContainer& children= parent.GetChildren();
	for (int i= 0; (i<positioncount) && (result->IsNull()); ++i )
	{
		size_t pos= possiblepositions\[i\];
		if (pos>children.GetCount()) pos= children.GetCount()-1;
		CTextNode& kid= children.GetAt(pos);
		if (kid.GetName()==name)
				result= &kid;
	}
	if (result->IsNull())
	{
		size_t pos= possiblepositions\[0\];
		if (pos>children.GetCount())
				pos= children.GetCount();
		result= CTextNodeFactory::GetInstance().Create(*result, name);

        if ((name == _T("GS")) ||
			(name == _T("GE")) ||
			(name == _T("ST")) ||
			(name == _T("SE")))
            result->SetClass(Segment);
        else if ((3 == name.length()) && (name\[0\]==_T('I')))
                result->SetClass(Segment);
		else if (name\[0\]==_T('F'))
			result->SetClass(DataElement);
		else if (name\[0\]==_T('S'))
			result->SetClass(Composite);
		else if ((name\[0\]==_T('U')) && (3==name.size()))
			result->SetClass(Segment);
		else
			result->SetClass(Group);
		children.Insert(result, pos);
	}
	return *result;

}

CTextNode& At(CTextNode& parent, const tstring& name, size_t index)
{
	size_t positions\[\]= {index};
	return At(parent, name, positions, 1);
}

CTextNode& AsFirst(CTextNode& parent, const tstring& name)
{
	return At(parent, name, 0);
}

CTextNode& AsLast(CTextNode& parent, const tstring& name)
{
	return At(parent, name, 1000000);
}

CTextNode& At(CTextNode* parent, const tstring& name, size_t possiblepositions\[\], int positioncount)
{
	return At(*parent, name, possiblepositions, positioncount);
}

CTextNode& At(CTextNode* parent, const tstring& name, size_t index)
{
	return At(*parent, name, index);
}

CTextNode& AsFirst(CTextNode* parent, const tstring& name)
{
	return AsFirst(*parent, name);
}

CTextNode& AsLast(CTextNode* parent, const tstring& name)
{
	return AsLast(*parent, name);
}

} // namespace MakeSureHasChild
} // namespace edi
} // namespace text
} // namespace altova
