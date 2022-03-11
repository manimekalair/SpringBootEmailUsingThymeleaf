[call GenerateFileHeader("Condition.cpp")]
#include "StdAfx.h"
#include "Condition.h"
#include "Generator.h"
#include "TextDocument.h"

namespace altova
{
namespace text
{
namespace edi
{

CConditionSeparator::CConditionSeparator(const tstring& separator, bool negate)
:	CCondition(negate)
,	m_Separator(separator)
{
}

bool CConditionSeparator::Evaluate (const CTextDocument& rhs) const
{
	bool bResult = (m_Separator == rhs.GetScanner().SeparatorToken());
	return m_Negate ? !bResult : bResult;
}

//////////////////////////////////////////////////////////////////////////

CConditionValue::CConditionValue(const tstring& value, bool negate)
:	CCondition(negate)
,	m_Value(value)
{
}

bool CConditionValue::Evaluate (const CTextDocument& rhs) const
{
	bool bResult = (m_Value == rhs.GetScanner().Value());
	return m_Negate ? !bResult : bResult;
}

//////////////////////////////////////////////////////////////////////////

CConditionFollowCharacter::CConditionFollowCharacter(const tstring& value, bool negate)
:	CCondition(negate)
,	m_Value(value)
{
}

bool CConditionFollowCharacter::Evaluate (const CTextDocument& rhs) const
{
	CScanner& scanner = const_cast<CScanner&>( rhs.GetScanner() );
	Indicator eScanChar = scanner.ScanChar();
	tstring sCheck = scanner.Separator();
	if( sCheck.empty() ) sCheck = scanner.Current();
	Indicator eBackChar = scanner.BackChar();
	bool bResult = sCheck == m_Value;
	return m_Negate ? !bResult : bResult;
}

//////////////////////////////////////////////////////////////////////////

CConditionCurrentContext::CConditionCurrentContext(const tstring& name, bool negate)
:	CCondition(negate)
,	m_Name(name)
{
}

bool CConditionCurrentContext::Evaluate (const CTextDocument& rhs) const
{
	bool bResult = rhs.GetGenerator().DoesCurrentsNameEqual(m_Name);
	return m_Negate ? !bResult : bResult;
}

//////////////////////////////////////////////////////////////////////////

CConditionSiblingContext::CConditionSiblingContext(const tstring& name, bool negate)
:	CCondition(negate)
,	m_Name(name)
{
}

bool CConditionSiblingContext::Evaluate (const CTextDocument& rhs) const
{
	bool bResult = rhs.GetGenerator().DoesHaveChildByName(m_Name);
	return m_Negate ? !bResult : bResult;
}

} // namespace edi
} // namespace text
} // namespace altova
