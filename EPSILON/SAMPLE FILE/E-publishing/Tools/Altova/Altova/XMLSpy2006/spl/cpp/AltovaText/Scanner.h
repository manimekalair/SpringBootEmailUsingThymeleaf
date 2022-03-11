[call GenerateFileHeader("Scanner.h")]
#ifndef __ALTOVATEXT_SCANNER_H
#define __ALTOVATEXT_SCANNER_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{
namespace edi
{

enum Indicator
{
	kValue,
	kEmpty,
	kEnd,
};

typedef std::map<TCHAR,tstring>		SeparatorMap;
typedef std::map<tstring,tstring>		TokenMap;
typedef std::set<TCHAR>				CharacterSet;

class ALTOVATEXT_DECLSPECIFIER CScanner
{
public:
	CScanner( void );
	virtual ~CScanner();

	// initialize the scanner with an plain text buffer
	void				Init ( const TCHAR* szBuffer );

	// retrieve the current value / token 
	const tstring&		Token() const;
	const tstring&		Value() const;

	// read the next value 'till separator 
	Indicator			Scan();

	// read the next character value
	Indicator			ScanChar();
		
	// move to the prev character value
	Indicator			BackChar();

	// retrieve the symbolic name for the follow - separator
	const tstring&		Separator() const;
	const tstring&		SeparatorToken() const;

	// receive the current character value
	TCHAR				Current(size_t shift=0) const;

	// check for end of file buffer
	bool				EndOfText() const;

	void				AddSeparator(TCHAR, const tstring&);
	void				SetEscapeChar(TCHAR);
	TCHAR				GetDecimalChar() const;
	void				SetDecimalChar(TCHAR);
	TCHAR				GetSeparator(const tstring&);
	void				AddIgnorableCharacter(TCHAR);

private:
	// move to the next token value
	void				Next();
	// move to the next token value
	void				Prev();
	// check whether current is a delimiter
	bool				Delimiter() const;
	// assign the separator token 
	bool				Tokenize( const tstring& test);
	// helper to find the next valid delimiter
	bool				Expression ( void );
private:
	const TCHAR*		m_Current;			// complete buffer
	tstring				m_Token;			// token value
	tstring				m_SeparatorToken;	// current separator
	tstring				m_TokenizerToken;	// sep. symbolic name
	TCHAR				m_EscapeChar;		// the escape/release char
	TCHAR				m_DecimalChar;
public://temp
	SeparatorMap		m_SeparatorMap;
	TokenMap			m_TokenMap;
	CharacterSet		m_IgnorableCharacter;
};

} // namespace edi
} // namespace text
} // namespace altova

#endif
