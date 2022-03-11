[call GenerateFileHeader("TextNodeXMLWriter.cpp")]
#include "StdAfx.h"
#include "TextNodeXMLWriter.h"

namespace altova
{
namespace text
{

CTextNodeXMLWriter::CTextNodeXMLWriter(tstringstream& stream)
:	m_Stream(stream)
{
	m_Stream << _T("<?xml version=\\"1.0\\" encoding=\\"UTF-8\\"?>");
}
void CTextNodeXMLWriter::WriteStartTag(const tstring& tag)
{
	m_Stream << _T("<") << tag.c_str() << _T(">");
}
void CTextNodeXMLWriter::WriteEndTag(const tstring& tag)
{
	m_Stream << _T("</") << tag.c_str() << _T(">");
}

namespace Internal
{
	class XmlVisitorFunctor
	{
	public:
		XmlVisitorFunctor(CTextNodeXMLWriter& visitor)
			:	m_Visitor(visitor)
		{}

		void operator() (CTextNode& node)
		{
			m_Visitor.Visit(node);
		}

	private:
		CTextNodeXMLWriter& m_Visitor;
	};
}
void CTextNodeXMLWriter::Visit(const CTextNode& node)
{
	this->WriteStartTag(node.GetName());
	
	m_Stream << node.GetValue().c_str();
	
	Internal::XmlVisitorFunctor functor(*this);
	node.GetChildren().ApplyToAll(functor);

	this->WriteEndTag(node.GetName());
}


} // namespace text
} // namespace altova
