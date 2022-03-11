[call GenerateFileHeader("Command.h")]
#ifndef __ALTOVATEXT_COMMAND_H
#define __ALTOVATEXT_COMMAND_H

#include "Conditions.h"
#include "Commands.h"
#include "TextNode.h"

namespace altova 
{
namespace text
{
namespace edi
{	


class CCondition;

class ALTOVATEXT_DECLSPECIFIER CCommand
{
public:
	virtual ~CCommand() {}
	virtual bool Execute(CTextDocument& document);
	
	void AddCondition(CCondition* condition);
	void AddOtherwise(CCommand* command);

	CConditions& GetContitions();
	const CConditions& GetContitions() const;
	CCommands& GetOtherwise();
	const CCommands& GetOtherwise() const;
protected:
	virtual bool DoExecute(CTextDocument& document)= 0;
	
private:
	CConditions	m_Conditions;
	CCommands	m_Otherwise;
};
//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CNameApplyingCommand : public CCommand
{
public:
	const tstring& GetName() const;
	void SetName(const tstring& rhs);

protected:
	CNameApplyingCommand();
	CNameApplyingCommand(const tstring& name);

private:
	tstring	m_Name;
};
//////////////////////////////////////////////////////////////////////////

// command to create a new hierarchy
// level in the generator output.
class ALTOVATEXT_DECLSPECIFIER CCommandEnter : public CNameApplyingCommand
{
	ENodeClass m_eClass;
public:
	CCommandEnter();
	CCommandEnter(const tstring& name, ENodeClass eClass);
protected:
	virtual bool DoExecute(CTextDocument& document);
};

// command to finalize the current 
// output generator hierarchy level
class ALTOVATEXT_DECLSPECIFIER CCommandLeave : public CNameApplyingCommand
{
public:
	CCommandLeave();
	CCommandLeave(const tstring& name);
protected:
	virtual bool DoExecute(CTextDocument& document);
};

// command to call a function defined in the
// document's function list
class ALTOVATEXT_DECLSPECIFIER CCommandCallFunction : public CNameApplyingCommand
{
public:
	CCommandCallFunction();
	CCommandCallFunction(const tstring& name);
protected:
	virtual bool DoExecute(CTextDocument& document);
};

// command to parse a value from the input file 
// and store it in the generator
class ALTOVATEXT_DECLSPECIFIER CCommandStoreValue : public CNameApplyingCommand
{
public:
	CCommandStoreValue();
	CCommandStoreValue(const tstring& name);
protected:	
	virtual bool DoExecute(CTextDocument& document);
};

// command to parse and store a single char
class ALTOVATEXT_DECLSPECIFIER CCommandStoreChar : public CNameApplyingCommand
{
public:
	CCommandStoreChar();
	CCommandStoreChar(const tstring& name);
protected:
	virtual bool DoExecute(CTextDocument& document);
};

// command to parse a value and ignore it
class ALTOVATEXT_DECLSPECIFIER CCommandIgnoreValue : public CCommand
{
protected:
	virtual bool DoExecute(CTextDocument& document);
};

// command to parse a char and ignore it
class ALTOVATEXT_DECLSPECIFIER CCommandIgnoreChar : public CCommand
{
protected:	
	virtual bool DoExecute(CTextDocument& document);
};

// command to step back one character
class ALTOVATEXT_DECLSPECIFIER CCommandBackChar : public CCommand
{
protected:	
	virtual bool DoExecute(CTextDocument& document);
};

// command to apply the escape character
class ALTOVATEXT_DECLSPECIFIER CCommandEscapeChar : public CCommand
{
protected:
	virtual bool DoExecute(CTextDocument& document);
};

// command to append a separator character
struct ALTOVATEXT_DECLSPECIFIER CCommandSeparatorChar : public CNameApplyingCommand
{
public:
	CCommandSeparatorChar(const tstring& name);
protected:
	virtual bool DoExecute(CTextDocument& document);
};

// command to execute a loop
class ALTOVATEXT_DECLSPECIFIER CCommandWhileLoop : public CCommand
{
public:
	CCommandWhileLoop();
	virtual bool Execute(CTextDocument& document);
	void AddCommand(CCommand* pCommand);

protected:
	virtual bool DoExecute(CTextDocument&) {return true;} // NO-OP

private:
	void DoWhileLoop(CTextDocument& document);
	void DoCountedLoop(CTextDocument& document);

private:
	int m_Count;
	CCommands m_Commands;
};

} // namespace edi
} // namespace text
} // namespace altova

#endif
