[call GenerateFileHeader("BaseNode.h")]
#ifndef __ALTOVATEXT_BASENODE_H
#define __ALTOVATEXT_BASENODE_H

#include "AltovaTextAPI.h"
#include "../Altova/SchemaTypes.h"

namespace altova
{
namespace text
{

class CTextNode;

class ALTOVATEXT_DECLSPECIFIER CBaseType
{
public:
	CTextNode& GetNode() const;

protected:
	CTextNode* m_pNode;
	CBaseType();
	CBaseType(CTextNode*);
	tstring MakeDecimal();
	size_t GetChildCount(const tstring&) const;
	CTextNode* GetChildByName(const tstring&) const;
	CTextNode* GetChildByNameAt(const tstring&, size_t) const;
};

} // namespace text
} // namespace altova

#endif
