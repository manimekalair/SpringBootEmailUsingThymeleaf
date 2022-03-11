[call GenerateFileHeader("Conditions.cpp")]
#include "StdAfx.h"
#include "TextException.h"
#include "Conditions.h"
#include "Helpers.h"

namespace altova
{
namespace text
{
namespace edi
{

CConditions::CConditions()
:	m_Operator(k_OR)
{}
CConditions::~CConditions()
{
	DeleteContainedPointers(m_Conditions);
}
CConditions::EBooleanOperator CConditions::GetOperator() const
{
	return m_Operator;
}
void CConditions::SetOperator(EBooleanOperator rhs)
{
	m_Operator= rhs;
}
void CConditions::AddCondition(CCondition* rhs)
{
	m_Conditions.push_back(rhs);
}
bool CConditions::Evaluate(const CTextDocument& rhs) const
{
	if(m_Conditions.empty())  return true;

	for (CConditionPtrVector::const_iterator it= m_Conditions.begin();
		 it!=m_Conditions.end(); ++it)
	{
		bool subresult= (*it)->Evaluate(rhs);
		switch (m_Operator)
		{
			case k_OR:
				if (subresult) return true;
				break;
			case k_AND:
				if (!subresult) return false;
				break;

		}
	}
	return (k_AND==m_Operator);
}

} // namespace edi
} // namespace text
} // namespace altova
