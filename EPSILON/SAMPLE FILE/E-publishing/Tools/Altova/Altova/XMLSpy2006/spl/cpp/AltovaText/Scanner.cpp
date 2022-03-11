[call GenerateFileHeader("Scanner.cpp")]
#include "StdAfx.h"
#include "Scanner.h"


namespace altova
{
namespace text
{
namespace edi
{

CScanner::CScanner()
:	m_Current(NULL)
{
	AddSeparator(_T('\\0'), _T("terminate") );
	AddSeparator(_T('\\r'), _T("return") );
	AddSeparator(_T('\\n'), _T("linefeed") );
	m_EscapeChar = _T('\\0');
	m_DecimalChar= _T(',');
}

CScanner::~CScanner()
{
}

void CScanner::Init( const TCHAR* szBuffer )
{
	m_Current = szBuffer;
}

const tstring& CScanner::Token() const
{
	return m_Token;
}

const tstring& CScanner::Value() const
{
	return Token();
}

Indicator CScanner::Scan()
{
	tstring tokentext;

	// quick exit when reached eof
	if( EndOfText() ) return kEnd;

	if( Expression() ) { tokentext = Current(); }

	for( Next(); Expression(); Next() )
		tokentext += Current();

	m_Token = tokentext;
	Tokenize( m_Token );

	// store the current separator token so that we can depend on it in a rule.
	m_SeparatorToken = Separator();

	return EndOfText() ? kEnd : (Token().empty()) ? kEmpty : kValue;
}

Indicator CScanner::ScanChar()
{
	Next(); // move to the next char
	m_Token = Current();
	return EndOfText() ? kEnd : kValue;
}

Indicator CScanner::BackChar()
{
	Prev(); // move to the prev char
	m_Token = Current();
	return EndOfText() ? kEnd : kValue;
}

TCHAR CScanner::Current( size_t shift) const
{
	// check for end of text when reading the current pointer
	size_t validshift;
	for( validshift = 0; (*m_Current+validshift != '\\0') && validshift < shift; ++validshift );
	// return the content of the current pointer position
	return (TCHAR)(*m_Current+validshift);
}

const tstring& CScanner::Separator() const
{
	static const tstring k_Empty(_T("")); // avoid reference of an temporary object
	SeparatorMap::const_iterator iFoundSeparator = m_SeparatorMap.find(Current());
	return iFoundSeparator != m_SeparatorMap.end() ? iFoundSeparator->second : k_Empty;
}

const tstring& CScanner::SeparatorToken() const
{
	return m_SeparatorToken;
}

bool CScanner::EndOfText() const
{
	return Current() == TCHAR('\\0');
}

void CScanner::AddSeparator( TCHAR ch, const tstring& sName )
{
	typedef std::vector<TCHAR> CharVector;
	CharVector toRemove;
	SeparatorMap::iterator im, em = m_SeparatorMap.end();
	for( im = m_SeparatorMap.begin(); im != em; ++im )
		if( im->second == sName )
			toRemove.push_back(im->first);

	CharVector::iterator iv, ev = toRemove.end();
	for( iv = toRemove.begin(); iv != ev; ++iv )
		m_SeparatorMap.erase( *iv );

	m_SeparatorMap\[ch\] = sName;
}
TCHAR CScanner::GetSeparator(const tstring& name)
{
	SeparatorMap::const_iterator i= m_SeparatorMap.begin(), e= m_SeparatorMap.end();
	for (; i!=e; ++i)
	{
		if (i->second==name)
			return i->first;
	}
	return _T('\\0');
}
void CScanner::SetEscapeChar( TCHAR ch )
{
	m_EscapeChar = ch;
}

void CScanner::Next()
{
	++m_Current;
	while (m_IgnorableCharacter.end()!=m_IgnorableCharacter.find(*m_Current))
		++m_Current;
}

void CScanner::Prev()
{
	--m_Current;
	while (m_IgnorableCharacter.end()!=m_IgnorableCharacter.find(*m_Current))
		--m_Current;
}

bool CScanner::Delimiter() const
{
	return m_SeparatorMap.find(Current()) != m_SeparatorMap.end();
}

bool CScanner::Tokenize( const tstring& test )
{
	TokenMap::const_iterator iFoundToken = m_TokenMap.find( test );
	if( iFoundToken != m_TokenMap.end() )
	{
		m_TokenizerToken = iFoundToken->second;
		return true;
	}
	return false;
}

bool CScanner::Expression ( void )
{
	// 1st pass: the expression is definitely false when the end of the text stream has reached
	bool bIsZeroTerminator = EndOfText();
	if( bIsZeroTerminator ) return false;

	// 2nd pass: on a release indicator skip the next char and proceed with the expression
	bool bIsReleaseIndicator = Current() == m_EscapeChar;
	if( bIsReleaseIndicator ) { Next(); return true; }

	// 3rd pass: check whether a defined delimiter has been reached
	bool bIsDefinedDelimiter = Delimiter();
	return !bIsZeroTerminator
		&& !bIsReleaseIndicator
		&& !bIsDefinedDelimiter;
}

TCHAR CScanner::GetDecimalChar() const
{
	return m_DecimalChar;
}
void CScanner::SetDecimalChar(TCHAR rhs)
{
	m_DecimalChar= rhs;
}
void CScanner::AddIgnorableCharacter(TCHAR rhs)
{
	m_IgnorableCharacter.insert(rhs);
}

} // namespace edi
} // namespace text
} // namespace altova
