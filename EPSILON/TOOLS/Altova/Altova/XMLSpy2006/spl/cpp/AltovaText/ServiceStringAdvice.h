[call GenerateFileHeader("ServiceStringAdvice.h")]
#ifndef __SERVICESTRINGADVICE_H
#define __SERVICESTRINGADVICE_H

#include "AltovaTextAPI.h"

namespace altova
{
namespace text
{
namespace edi
{

class ALTOVATEXT_DECLSPECIFIER CServiceStringAdvice
{
public:
	CServiceStringAdvice();

	TCHAR GetComponentDataElementSeparator() const;
	void SetComponentDataElementSeparator( TCHAR );
	TCHAR GetDataElementSeparator() const;
	void SetDataElementSeparator( TCHAR );
	TCHAR GetDecimalNotation() const;
	void SetDecimalNotation( TCHAR );
	TCHAR GetReleaseIndicator() const;
	void SetReleaseIndicator( TCHAR );
	TCHAR GetSegmentTerminator() const;
	void SetSegmentTerminator( TCHAR );
	void SetFromCharArray( TCHAR\[6\] );

	void Serialize( tostream& ) const;

private:
	TCHAR m_chComponentDataElementSeparator;
	TCHAR m_chDataElementSeparator;
	TCHAR m_chDecimalNotation;
	TCHAR m_chReleaseIndicator;
	TCHAR m_chSegmentTerminator;
};

} // namespace edi
} // namespace text
} // namespace altova


#endif