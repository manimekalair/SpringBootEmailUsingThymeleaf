[call GenerateFileHeader("Conditions.h")]
#ifndef __ALTOVATEXT_CONDITIONS_H
#define __ALTOVATEXT_CONDITIONS_H

#include "Condition.h"

namespace altova 
{
namespace text
{
namespace edi
{	

class CTextDocument;

// Collection of specific condition objects
class ALTOVATEXT_DECLSPECIFIER CConditions : public CCondition
{
public:
	CConditions( void );
	virtual	~CConditions( void );
	
	enum EBooleanOperator { k_OR, k_AND };

	EBooleanOperator GetOperator() const;
	void SetOperator(EBooleanOperator rhs);
	void AddCondition(CCondition* rhs);
	virtual bool Evaluate(const CTextDocument& rhs) const;
	
private:
	typedef std::vector<CCondition*> CConditionPtrVector;
	CConditionPtrVector	m_Conditions;
	EBooleanOperator m_Operator;
};

} // namespace edi
} // namespace text
} // namespace altova

#endif
