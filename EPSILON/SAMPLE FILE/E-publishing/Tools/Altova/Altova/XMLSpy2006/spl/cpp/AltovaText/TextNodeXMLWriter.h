[call GenerateFileHeader("TextNodeXMLWriter.h")]
#ifndef __ALTOVATEXT_TEXTNODEXMLWRITER_H
#define __ALTOVATEXT_TEXTNODEXMLWRITER_H

#include "TextNode.h"

namespace altova
{
namespace text
{

class ALTOVATEXT_DECLSPECIFIER CTextNodeXMLWriter
{
public:
	
	CTextNodeXMLWriter(tstringstream& stream);	
	void Visit(const CTextNode& node);

private:
	void WriteStartTag(const tstring& tag);
	void WriteEndTag(const tstring& tag);

private:
	tstringstream&	m_Stream;
};

} // namespace text
} // namespace altova

#endif 
