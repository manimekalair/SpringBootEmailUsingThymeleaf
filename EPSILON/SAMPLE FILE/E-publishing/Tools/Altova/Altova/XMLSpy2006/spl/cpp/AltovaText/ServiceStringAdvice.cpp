[call GenerateFileHeader("ServiceStringAdvice.cpp")]
#include "StdAfx.h"
#include "ServiceStringAdvice.h"

namespace altova
{
namespace text
{
namespace edi
{


CServiceStringAdvice::CServiceStringAdvice()
:	m_chComponentDataElementSeparator(_T(':'))
,	m_chDataElementSeparator(_T('+'))
,	m_chDecimalNotation(_T('.'))
,	m_chReleaseIndicator(_T('?'))
,	m_chSegmentTerminator(_T('\\''))
{}

TCHAR 
CServiceStringAdvice::GetComponentDataElementSeparator() const
{
	return m_chComponentDataElementSeparator;
}

void 
CServiceStringAdvice::SetComponentDataElementSeparator(TCHAR chRhs)
{
	m_chComponentDataElementSeparator = chRhs;
}

TCHAR 
CServiceStringAdvice::GetDataElementSeparator() const
{
	return m_chDataElementSeparator;
}

void 
CServiceStringAdvice::SetDataElementSeparator(TCHAR chRhs)
{
	m_chDataElementSeparator = chRhs;
}

TCHAR 
CServiceStringAdvice::GetDecimalNotation() const
{
	return m_chDecimalNotation;
}

void 
CServiceStringAdvice::SetDecimalNotation(TCHAR chRhs)
{
	m_chDecimalNotation = chRhs;
}

TCHAR 
CServiceStringAdvice::GetReleaseIndicator() const
{
	return m_chReleaseIndicator;
}

void 
CServiceStringAdvice::SetReleaseIndicator(TCHAR chRhs)
{
	m_chReleaseIndicator = chRhs;
}

TCHAR	
CServiceStringAdvice::GetSegmentTerminator() const
{
	return m_chSegmentTerminator;
}

void 
CServiceStringAdvice::SetSegmentTerminator(TCHAR chRhs)
{
	m_chSegmentTerminator = chRhs;
}

void 
CServiceStringAdvice::SetFromCharArray( TCHAR aRhs\[6\] )
{
	m_chComponentDataElementSeparator = aRhs\[ 0 \];
	m_chDataElementSeparator = aRhs\[ 1 \];
	m_chDecimalNotation = aRhs\[ 2 \];
	m_chReleaseIndicator = aRhs\[ 3 \];
	m_chSegmentTerminator = aRhs\[ 5 \];
}

void CServiceStringAdvice::Serialize( tostream& rStream ) const
{
	rStream << _T("UNA");
	rStream.put( m_chComponentDataElementSeparator );
	rStream.put( m_chDataElementSeparator );
	rStream.put( m_chDecimalNotation );
	rStream.put( m_chReleaseIndicator );
	rStream.put( _T(' ') );
	rStream.put( m_chSegmentTerminator );
}

} // namespace edi
} // namespace text
} // namespace altova

