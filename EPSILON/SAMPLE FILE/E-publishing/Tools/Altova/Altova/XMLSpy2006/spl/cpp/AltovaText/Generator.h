[call GenerateFileHeader("Generator.h")]
#ifndef __ALTOVATEXT_GENERATOR_H
#define __ALTOVATEXT_GENERATOR_H

#include "AltovaTextAPI.h"
#include "TextNode.h"

namespace altova
{
namespace text
{

class CTextNode;


class ALTOVATEXT_DECLSPECIFIER CGenerator
{
public:
	CGenerator();
	virtual ~CGenerator();
	
	void Init();
	void Done();
	void Save(const tstring& filename);
	void Exit();
		
	void EnterElement(const tstring& name, ENodeClass eClass);
	void LeaveElement(const tstring& name);
	void InsertElement(const tstring& name, const tstring& value, ENodeClass eClass);

	bool DoesCurrentsNameEqual(const tstring& name) const;
	bool DoesHaveChildByName(const tstring& name) const;
	
	tstring	GetRootName() const;
	CTextNode& GetRootNode() const;
	void SetRootNode(CTextNode&);
	CTextNode& GetCurrentNode() const;

private:					
	CTextNode& FindElementUpwardsByName(const tstring& name) const;

private:					
	CTextNode* m_pCurrent;
};

} // namespace text
} // namespace altova

#endif
