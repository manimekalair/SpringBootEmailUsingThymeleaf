[call GenerateFileHeader("EDIX12Settings.h")]
#ifndef __EDIX12SETTINGS_H
#define __EDIX12SETTINGS_H

#include "EDISettings.h"

namespace altova
{
namespace text
{
namespace edi
{

class ALTOVATEXT_DECLSPECIFIER CEDIX12Settings : public CEDISettings
{
public:
	CEDIX12Settings();
    TCHAR GetSubElementSeparator() const;
    const tstring& GetInterchangeControlVersionNumber() const;
    bool GetRequestAcknowledgement() const;
    void SetSubElementSeparator(TCHAR);
    void SetInterchangeControlVersionNumber(const tstring&);
    void SetRequestAcknowledgement(bool);

private:
    TCHAR m_SubElementSeparator;
    tstring m_InterchangeControlVersionNumber;
    bool m_RequestAcknowledgement;

};


} // namespace edi
} // namespace text
} // namespace altova

#endif