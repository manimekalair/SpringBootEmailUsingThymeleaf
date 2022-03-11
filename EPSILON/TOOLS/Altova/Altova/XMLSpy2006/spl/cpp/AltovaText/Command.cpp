[call GenerateFileHeader("Command.cpp")]
#include "StdAfx.h"
#include "Command.h"
#include "Generator.h"
#include "Functions.h"
#include "Function.h"
#include "TextDocument.h"

namespace altova
{
namespace text
{
namespace edi
{

void CCommand::AddCondition(CCondition* pCondition)
{
	m_Conditions.AddCondition(pCondition);
}

void CCommand::AddOtherwise(CCommand* pCommand)
{
	m_Otherwise.AddCommand(pCommand);
}

CConditions& CCommand::GetContitions()
{
	return m_Conditions;
}

const CConditions& CCommand::GetContitions() const
{
	return m_Conditions;
}

CCommands& CCommand::GetOtherwise()
{
	return m_Otherwise;
}

const CCommands& CCommand::GetOtherwise() const
{
	return m_Otherwise;
}

bool CCommand::Execute(CTextDocument& document)
{
	if( m_Conditions.Evaluate(document) )
		return this->DoExecute(document);
	else
		m_Otherwise.Execute(document);
	return false;
}
//////////////////////////////////////////////////////////////////////////

CNameApplyingCommand::CNameApplyingCommand()
:	m_Name(_T(""))
{
}
CNameApplyingCommand::CNameApplyingCommand(const tstring& name)
:	m_Name(name)
{
}
const tstring& CNameApplyingCommand::GetName() const
{
	return m_Name;
}
void CNameApplyingCommand::SetName(const tstring& rhs)
{
	m_Name= rhs;
}
//////////////////////////////////////////////////////////////////////////

CCommandEnter::CCommandEnter(const tstring& name, ENodeClass eClass)
:	CNameApplyingCommand(name)
,	m_eClass(eClass)
{
}
bool CCommandEnter::DoExecute(CTextDocument& document)
{
	document.GetGenerator().EnterElement(CNameApplyingCommand::GetName(), m_eClass);
	return true;
}
//////////////////////////////////////////////////////////////////////////

CCommandLeave::CCommandLeave(const tstring& name)
:	CNameApplyingCommand(name)
{
}
bool CCommandLeave::DoExecute(CTextDocument& document)
{
	document.GetGenerator().LeaveElement(CNameApplyingCommand::GetName());
	return true;
}
//////////////////////////////////////////////////////////////////////////

CCommandCallFunction::CCommandCallFunction(const tstring& name)
:	CNameApplyingCommand(name)
{
}
bool CCommandCallFunction::DoExecute(CTextDocument& document)
{
	CFunction* function= document.GetFunctions().Get(CNameApplyingCommand::GetName());
	if (NULL==function) return false;
	return function->Execute(document);
}
//////////////////////////////////////////////////////////////////////////

CCommandStoreValue::CCommandStoreValue(const tstring& name)
:	CNameApplyingCommand(name)
{
}
bool CCommandStoreValue::DoExecute(CTextDocument& document)
{
	Indicator indicator = document.GetScanner().Scan();
	tstring  value	= document.GetScanner().Value();
	document.GetGenerator().InsertElement(CNameApplyingCommand::GetName(), value, DataElement);
	return (kEnd!=indicator);
}
//////////////////////////////////////////////////////////////////////////

CCommandStoreChar::CCommandStoreChar(const tstring& name)
:	CNameApplyingCommand(name)
{
}
bool CCommandStoreChar::DoExecute(CTextDocument& document)
{
	document.GetScanner().ScanChar();
	const tstring& value= document.GetScanner().Value();
	document.GetGenerator().InsertElement(CNameApplyingCommand::GetName(), value, DataElement);
	return true;
}
//////////////////////////////////////////////////////////////////////////

bool CCommandIgnoreValue::DoExecute(CTextDocument& document)
{
	document.GetScanner().Scan();
	return true;
}
//////////////////////////////////////////////////////////////////////////

bool CCommandIgnoreChar::DoExecute(CTextDocument& document)
{
	document.GetScanner().ScanChar();
	return true;
}
//////////////////////////////////////////////////////////////////////////

bool CCommandBackChar::DoExecute(CTextDocument& document)
{
	document.GetScanner().BackChar();
	return true;
}
//////////////////////////////////////////////////////////////////////////

bool CCommandEscapeChar::DoExecute(CTextDocument& document)
{
	document.GetScanner().ScanChar();
	const tstring& value= document.GetScanner().Value();
	document.GetScanner().SetEscapeChar(value\[0\]);
	return true;
}
//////////////////////////////////////////////////////////////////////////

CCommandSeparatorChar::CCommandSeparatorChar(const tstring& name)
:	CNameApplyingCommand(name)
{
}
bool CCommandSeparatorChar::DoExecute(CTextDocument& document)
{
	document.GetScanner().ScanChar();
	const tstring& value = document.GetScanner().Value();
	document.GetScanner().AddSeparator(value\[0\], CNameApplyingCommand::GetName());
	return true;
}
//////////////////////////////////////////////////////////////////////////

CCommandWhileLoop::CCommandWhileLoop()
:	m_Count(-1)
{
}
void CCommandWhileLoop::AddCommand(CCommand* rhs)
{
	m_Commands.AddCommand(rhs);
}
void CCommandWhileLoop::DoWhileLoop(CTextDocument& document)
{
	bool noteof= true;
	bool continuewhile= true;
	while (continuewhile && noteof)
	{
		continuewhile= m_Commands.Execute(document);
		noteof= !document.GetScanner().EndOfText();
	}
}
void CCommandWhileLoop::DoCountedLoop(CTextDocument& document)
{
	for (int i= 0; i<m_Count; ++i)
		m_Commands.Execute(document);
}

bool CCommandWhileLoop::Execute(CTextDocument& document)
{
	if (-1==m_Count) this->DoWhileLoop(document);
	else this->DoCountedLoop(document);
	return true;
}

} // namespace edi
} // namespace text
} // namespace altova
