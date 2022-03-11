[call GenerateFileHeader("Commands.cpp")]
#include "StdAfx.h"
#include "Commands.h"
#include "Command.h"
#include "TextDocument.h"

namespace altova
{
namespace text
{
namespace edi
{

CCommands::CCommands() {}

CCommands::~CCommands( void )
{
	CCommandPtrVector::iterator iCommand, iCommandEnd = m_Commands.end();
	for( iCommand = m_Commands.begin(); iCommand != iCommandEnd; ++iCommand )
	{
		delete *iCommand;
		*iCommand = NULL;
	}
}

bool CCommands::Execute ( CTextDocument& rDocument )
{
	CCommandPtrVector::iterator iCommand, iCommandEnd = m_Commands.end();
	for( iCommand = m_Commands.begin(); iCommand != iCommandEnd && !(rDocument.GetScanner().EndOfText()); ++iCommand )
		(*iCommand)->Execute( rDocument ); // invoke the handler

	return true;
}

void CCommands::AddCommand ( CCommand* pCommand )
{
	m_Commands.push_back( pCommand );
}

size_t CCommands::GetCommandCount ( void ) const
{
	return m_Commands.size();
}

} // namespace edi
} // namespace text
} // namespace altova
