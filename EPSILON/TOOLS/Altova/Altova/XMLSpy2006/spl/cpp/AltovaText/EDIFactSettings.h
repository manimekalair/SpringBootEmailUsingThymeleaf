[call GenerateFileHeader("EDIFactSettings.h")]
#ifndef __EDIFACTSETTINGS_H
#define __EDIFACTSETTINGS_H

#include "EDISettings.h"

namespace altova
{
namespace text
{
namespace edi
{

class ALTOVATEXT_DECLSPECIFIER CEDIFactSettings : public CEDISettings
{
public:
	CEDIFactSettings();
	long GetSyntaxVersionNumber() const;
	TCHAR GetSyntaxLevel() const;
	const tstring& GetControllingAgency() const;
	bool GetWriteUNA() const;

	void SetSyntaxVersionNumber(long);
	void SetSyntaxLevel(TCHAR);
	void SetControllingAgency(const tstring&);
	void SetWriteUNA(bool);

private:
	long m_SyntaxVersionNumber;
	TCHAR m_SyntaxLevel;
	tstring m_ControllingAgency;
	bool m_WriteUNA;

};
} // namespace edi
} // namespace text
} // namespace altova

#endif