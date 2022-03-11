[call GenerateFileHeader("Condition.h")]
#ifndef __ALTOVATEXT_CONDITION_H
#define __ALTOVATEXT_CONDITION_H

#include "AltovaTextAPI.h"

namespace altova 
{
namespace text
{
namespace edi
{	

class CTextDocument;

// base condition type. concrete conditions listed below
class ALTOVATEXT_DECLSPECIFIER CCondition
{
public:
	CCondition( bool negate = false ) : m_Negate(negate) {}
	virtual ~CCondition() {}
	virtual bool Evaluate(const CTextDocument& rhs) const= 0;
protected:
	bool m_Negate;
};

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CConditionSeparator : public CCondition
{
public:
	CConditionSeparator(const tstring& separator, bool negate = false);
	virtual bool Evaluate(const CTextDocument& rhs) const;

private:
	tstring	m_Separator;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CConditionValue : public CCondition
{
public:
	CConditionValue(const tstring& value, bool negate = false);
	virtual bool Evaluate(const CTextDocument& rhs) const;

private:
	tstring	m_Value;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CConditionFollowCharacter : public CCondition
{
public:
	CConditionFollowCharacter(const tstring& value, bool negate = false);
	virtual bool Evaluate(const CTextDocument& rhs) const;

private:
	tstring	m_Value;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CConditionCurrentContext : public CCondition
{
public:
	CConditionCurrentContext(const tstring& name, bool negate = false);
	virtual bool Evaluate(const CTextDocument& rhs) const;

private:
	tstring	m_Name;
};

//////////////////////////////////////////////////////////////////////////

class ALTOVATEXT_DECLSPECIFIER CConditionSiblingContext : public CCondition
{
public:
	CConditionSiblingContext(const tstring& name, bool negate = false);
	virtual bool Evaluate(const CTextDocument& rhs) const;

private:
	tstring	m_Name;
};

} // namespace edi
} // namespace text
} // namespace altova

#endif 
