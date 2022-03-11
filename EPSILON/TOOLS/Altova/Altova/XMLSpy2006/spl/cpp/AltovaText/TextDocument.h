[call GenerateFileHeader("TextDocument.h")]
#ifndef __ALTOVATEXT_TEXTDOCUMENT_H
#define __ALTOVATEXT_TEXTDOCUMENT_H

#include "Parser.h"
#include "Generator.h"
#include "Functions.h"

#include <memory>

namespace altova
{
namespace text
{

class CTextNode;


namespace flex
{

class CFlexCommandProject;

class ALTOVATEXT_DECLSPECIFIER CTextDocument
{
public:
	CTextDocument() : m_pFlexProject(NULL) {}

	CGenerator&	GetGenerator();
	const CGenerator& GetGenerator() const;
	CTextNode& GetRoot() const;

	void SetByteOrder(int bo) {m_nByteorder = bo;}
	void SetEncoding(unsigned enc) {m_nEncoding = enc;}
	void SetWriteBOM(bool bom) {m_bBom = bom;}
		
protected:
	const CTextNode& ParseFile(const tstring& filename);
	virtual const CTextNode& ParseString(const tstring& str);

	void SaveFile(const tstring& filename) const;
	virtual void SaveString(tstring &str) const;

	CFlexCommandProject* m_pFlexProject;

private:
	CGenerator m_Generator;
	unsigned m_nEncoding;
	int m_nByteorder;
	bool m_bBom;
};

} // namespace flex


////////////////////////////////////////////////////////////////////////

namespace edi
{

class CEDISettings;
class CDataCompletion;

enum EDIStandard
{
	EDIFact,
	EDIX12
};

class ALTOVATEXT_DECLSPECIFIER CTextDocument : public CParser
{
public:
	CGenerator&	GetGenerator();
	const CGenerator& GetGenerator() const;
	CStringToFunctionMap& GetFunctions();
	const CStringToFunctionMap&	GetFunctions() const;
	CStringToFunctionMap& GetHandlers();
	const CStringToFunctionMap& GetHandlers() const;
	CTextNode& GetRoot() const;
	void Save(const CTextNode& structureroot, const tstring&) const;

	void SetByteOrder(int bo) {m_nByteorder = bo;}
	void SetEncoding(unsigned enc) {m_nEncoding = enc;}
	void SetWriteBOM(bool bom) {m_bBom = bom; }

protected:
	const CTextNode& ParseFile(const tstring& filename);

protected:

protected:
	void SetProlog(const tstring& rhs);
	void SetEpilog(const tstring& rhs);
	void RecordDecimalSeparator();

protected:
	virtual void Prolog();
	virtual void Epilog();
	virtual void ProcessToken(const tstring& token);

protected:
	virtual tstring GetStructureName() const = 0;
	virtual const CEDISettings& GetSettings() const = 0;
	virtual EDIStandard GetStandard() const = 0;
	virtual bool ValidateSource(tstring& buffer) = 0;
	virtual bool ValidateResult();

private:
	void ProcessFunction(const tstring& name);
	std::auto_ptr<CDataCompletion> GetDataCompletion() const;
	void AdjustDataToStructure(const CTextNode&, CTextNode&) const;
	void RemoveEmptyNodes(CTextNode&) const;
	bool IsEmptyDataElement(const CTextNode&) const;
	bool IsContainerNodeWithoutChildren(const CTextNode&) const;

private:
	tstring	m_Prolog;
	tstring	m_Epilog;
	CGenerator m_Generator;
	CStringToFunctionMap m_Functions;
	CStringToFunctionMap m_Handlers;
	unsigned m_nEncoding;
	int m_nByteorder;
	bool m_bBom;
};

} // namespace edi
} // namespace text
} // namespace altova

#endif
