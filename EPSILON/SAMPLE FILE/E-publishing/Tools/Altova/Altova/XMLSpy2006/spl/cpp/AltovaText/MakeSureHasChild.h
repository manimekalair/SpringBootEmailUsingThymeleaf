[call GenerateFileHeader("MakeSureHasChild.h")]
#ifndef __MAKESUREHASCHILD_H
#define __MAKESUREHASCHILD_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{

class CTextNode;


namespace edi
{

namespace MakeSureHasChild
{

CTextNode& At(CTextNode&, const tstring&, size_t\[\], int);
CTextNode& At(CTextNode&, const tstring&, size_t);
CTextNode& AsFirst(CTextNode&, const tstring&);
CTextNode& AsLast(CTextNode&, const tstring&);
CTextNode& At(CTextNode*, const tstring&, size_t\[\], int);
CTextNode& At(CTextNode*, const tstring&, size_t);
CTextNode& AsFirst(CTextNode*, const tstring&);
CTextNode& AsLast(CTextNode*, const tstring&);

} // namespace MakeSureHasChild
} // namespace edi
} // namespace text
} // namespace altova


#endif