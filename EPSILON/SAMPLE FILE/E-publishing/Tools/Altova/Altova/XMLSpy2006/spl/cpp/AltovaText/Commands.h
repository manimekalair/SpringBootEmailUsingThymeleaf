[call GenerateFileHeader("Commands.h")]
#ifndef __ALTOVATEXT_COMMANDS_H
#define __ALTOVATEXT_COMMANDS_H

#include "AltovaTextAPI.h"

namespace altova 
{
namespace text
{
namespace edi
{	

class CCommand;
class CTextDocument;

class ALTOVATEXT_DECLSPECIFIER CCommands
{
public:
	CCommands();
	virtual	~CCommands();
	
public://	overrides
	virtual bool			Execute			( CTextDocument& rDocument );
	
public://	command handling
	void					AddCommand		( CCommand* pCommand );
	size_t					GetCommandCount	( void ) const;
private://	types
	typedef std::vector<CCommand*> CCommandPtrVector;
private:
	CCommandPtrVector		m_Commands;
};

} // namespace edi
} // namespace text
} // namespace altova

#endif
