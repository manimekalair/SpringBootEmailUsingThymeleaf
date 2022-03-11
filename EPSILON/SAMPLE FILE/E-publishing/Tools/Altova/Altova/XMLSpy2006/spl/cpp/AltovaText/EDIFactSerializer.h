[call GenerateFileHeader("EDIFactSerializer.h")]
#ifndef __EDIFACTSERIALIZER_H
#define __EDIFACTSERIALIZER_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{


class CTextNode;

namespace edi
{

class CServiceStringAdvice;

class ALTOVATEXT_DECLSPECIFIER CEDIFactSerializer
{
public:
	CEDIFactSerializer(const CServiceStringAdvice&, tostream&, bool);
	void SerializeNode(const CTextNode&);

private:
	void SerializeDataElement(const CTextNode&);
	void SerializeComposite(const CTextNode&);
	void SerializeSegment(const CTextNode&);
	void SerializeGroup(const CTextNode&);
	void SerializeAsText(const tstring&);
	void SerializeAsDecimal(const tstring&);
	void WriteString(const tstring&);
	void WriteChar(TCHAR);
	TCHAR TranslateSeparator(TCHAR) const;
	void WriteSeparatorsBetween(const CTextNode&, const CTextNode&);

private:
	const CServiceStringAdvice& m_UNA;
	bool m_TerminateSegmentsWithExtraLineFeed;
	tostream& m_Stream;
};

} // namespace edi
} // namespace text
} // namespace altova

#endif