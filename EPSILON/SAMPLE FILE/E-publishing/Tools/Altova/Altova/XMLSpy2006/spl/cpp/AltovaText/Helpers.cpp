[call GenerateFileHeader("Helpers.cpp")]
#include "StdAfx.h"
#include "Helpers.h"
#include "TextException.h"
#include <atlbase.h>
#include <atlconv.h>
#include "CodePageInformation.h"

namespace altova
{
namespace text
{

bool IsBigEndian(const char* source)
{
	bool result= (0xfe== (unsigned char) source\[0\]) && (0xff== (unsigned char) source\[1\]);
	return result;
}

bool IsLittleEndian(const char* source)
{
	bool result= (0xff== (unsigned char) source\[0\]) && (0xfe== (unsigned char) source\[1\]);
	return result;
}

bool IsUTF8(const char* source)
{
	bool result= (0xef== (unsigned char) source\[0\]) && (0xbb== (unsigned char) source\[1\]) && (0xbf== (unsigned char) source\[2\]);
	return result;
}

bool IsBigEndian(const wchar_t* source)
{
	bool result= (0xfe==source\[0\]) && (0xff==source\[1\]);
	return result;
}

bool IsLittleEndian(const wchar_t* source)
{
	bool result= (0xff==source\[0\]) && (0xfe==source\[1\]);
	return result;
}

bool IsUTF8(const wchar_t* source)
{
	bool result= (0xef==source\[0\]) && (0xbb==source\[1\]) && (0xbf==source\[2\]);
	return result;
}

void ThrowWindowsErrorTextException(const tstring& messagehead)
{
	tstring errortext= GetLastWindowsErrorAsString();
	errortext= messagehead + errortext;
	throw CTextException(0, errortext);
}

class CodePageEnumerator
{
public:
	void LoadInstalledCodePages()
	{
		Enumerate(CP_INSTALLED);
	}
	void LoadSupportedCodePages()
	{
		Enumerate(CP_SUPPORTED);
	}
	tstring GetCodePageListAsString()
	{
		return m_CodePageListAsString;
	}

private:
	void Enumerate(DWORD type)
	{
		m_CodePageListAsString= _T("");
		if (!::EnumSystemCodePages(EnumCodePagesCallback, type))
			ThrowWindowsErrorTextException(_T("Could not enumerate codepages:"));
	}
	static BOOL CALLBACK EnumCodePagesCallback(LPTSTR pCodePageString)
	{
		m_CodePageListAsString+= pCodePageString;
		m_CodePageListAsString+= _T("\\n");
		return TRUE;
	}

private:
	static tstring m_CodePageListAsString;
};
tstring CodePageEnumerator::m_CodePageListAsString;



typedef unsigned long UCS4;

enum UCS4encodings
{
	UnicodeUCS4 = 12000
};

enum UCS4ByteOrder
{
	UCS4ByteOrderLittleEndian = 1,
	UCS4ByteOrderBigEndian = 2
};

const UCS4 unicodeUCS4ByteOrderMark = 0xFFFE0000UL;

const UCS4 kReplacementCharacter = 0x0000FFFDUL;
const UCS4 kMaximumUCS2          = 0x0000FFFFUL;
const UCS4 kMaximumUTF16         = 0x0010FFFFUL;
const UCS4 kMaximumUCS4          = 0x7FFFFFFFUL;

const int  halfShift             = 10;
const UCS4 halfBase              = 0x0010000UL;
const UCS4 halfMask              = 0x3FFUL;
const UCS4 kSurrogateHighStart   = 0xD800UL;
const UCS4 kSurrogateHighEnd     = 0xDBFFUL;
const UCS4 kSurrogateLowStart    = 0xDC00UL;
const UCS4 kSurrogateLowEnd      = 0xDFFFUL;

inline UCS4 ReverseByteOrder(UCS4 ch)
{
	register unsigned char b0, b1, b2, b3;
	b0 = (byte) ((ch & 0x000000FF) >>  0);
	b1 = (byte) ((ch & 0x0000FF00) >>  8);
	b2 = (byte) ((ch & 0x00FF0000) >> 16);
	b3 = (byte) ((ch & 0xFF000000) >> 24);
	return (((UCS4) b0) << 24) | (((UCS4) b1) << 16) | (((UCS4) b2) << 8) | (((UCS4) b3) << 0);
}

// if originallen == 0, the string will be supposed to end by ((UCS4) 0)
// returns length of the target string
DWORD UCS4ToUTF16(const char *source, DWORD originallen, wchar_t * &target, bool isbigendian)
{
	register UCS4 *src = (UCS4 *) source;

	// count the space required for target
	register UCS4 ch;
	DWORD dstsurrogates = 0;
	DWORD srclen = originallen;
	do
	{
		ch = *src++;

		if (isbigendian)
		{
			ch = ReverseByteOrder(ch);
		}

		if (! (ch <= kMaximumUCS2 || ch > kReplacementCharacter))
		{
			dstsurrogates++;
		}

		if (originallen)
		{
			// converting only first originallen chars of source
			if (--srclen == 0)
			{
				srclen = originallen;
				break;
			}
		}
		else
		{
			// converting whole source (and counting its length)
			srclen++;
			if (ch == 0) break;
		}
	}
	while (true);

	src = (UCS4 *) source;
	ch = *src;
	if (ch == unicodeUCS4ByteOrderMark || ReverseByteOrder(ch) == unicodeUCS4ByteOrderMark)
	{
		src++;
		srclen--;
	}

	DWORD dstlen = srclen + dstsurrogates;

	// now that we have both lengths, allocate memory and perform the conversion
	target = new wchar_t \[dstlen\];
	if (target == NULL)
	{
		throw CTextException(0, _T("Not enough memory."));
	}

	register wchar_t *dst = target;
	for (DWORD i = 0; i < srclen; i++)
	{
		ch = *src++;
		if (isbigendian)
		{
			ch = ReverseByteOrder(ch);
		}

		if (ch <= kMaximumUTF16)
		{
			*dst++ = static_cast< wchar_t >( ch );
		}
		else if (ch > kMaximumUTF16)
		{
			*dst++ = kReplacementCharacter;
		}
		else
		{
			ch -= halfBase;
			*dst++ = static_cast< wchar_t >( (ch >> halfShift) + kSurrogateHighStart );
			*dst++ = static_cast< wchar_t >( (ch & halfMask) + kSurrogateLowStart );
		}
	}

	return srclen;
}

void ConvertToWideString(const char* source, DWORD originallen, tstring& target, unsigned encoding, int byteorder)
{
	wchar_t *tmp;

	// Unicode UCS-4 not supported by Microsoft Layer for Unicode => needs special treatment
	if (encoding == UnicodeUCS4)
	{
		UCS4ToUTF16(source, originallen / sizeof(UCS4), tmp, byteorder == UCS4ByteOrderBigEndian);
#ifdef UNICODE
		target = tmp;
#else
		ConvertWideStringToString(tmp, target);
#endif
	}
	else
	{
		if( IsBigEndian(source) )
		{
			source +=2;
			originallen -= 2;
			if (encoding != 1201)
			{
				encoding = 1201; // UTF-16 BE
				cerr << "Warning: input encoding set to UTF-16BE" << endl;
			}
		}			
		else if (IsLittleEndian(source))
		{
			source += 2;
			originallen -= 2;
			if (encoding != 1200)
			{
				encoding = 1200; // UTF-16 LE
				cerr << "Warning: input encoding set to UTF-16LE" << endl;
			}
		}
		else if( IsUTF8(source))
		{
			source += 3;
			originallen -= 3;
			if (encoding != 65001)
			{
				encoding = 65001; // UTF-8
				cerr << "Warning: input encoding set to UTF-8" << endl;
			}
		}
		
		if (encoding == 1200)
		{
			size_t intCount = originallen / 2;
			tmp = new wchar_t\[intCount+1\];
			memcpy(tmp, source, originallen);
			tmp\[intCount\]= 0;
		}

		else if (encoding == 1201)
		{
			size_t intCount = originallen / 2;
			tmp = new wchar_t\[intCount+1\];
			_swab((char*) source, (char*) tmp, originallen);
			tmp\[intCount\]= 0;
		}
		
		else if (!::IsValidCodePage(encoding))
		{
			tstringstream tmp;
			tmp << _T("The specified codepage is not available on this system. Information about the available codepages:") << std::endl;
			const TCodePagePointerMap& codepages= CodePageInformation::Instance().CodePages();
			TCodePagePointerMap::const_iterator i= codepages.begin(), e= codepages.end();
			for ( ; i!=e; ++i) 
			{
				const CodePage* codepage= i->second;
				if (codepage->IsInstalled())
					tmp << codepage->LocalizedName() << _T(" is available and installed");
				else
					tmp << codepage->Number() << _T(" is available, but not installed");
				tmp << std::endl;
			}

			throw CTextException(0, tmp.str());
		}
		else
		{
			int targetsize= ::MultiByteToWideChar(encoding, 0, source, originallen, NULL, 0);
			if (0==targetsize) ThrowWindowsErrorTextException(_T("Could not convert text to unicode:"));
	
			tmp= new wchar_t\[targetsize+1\];
			if (NULL==tmp) throw CTextException(0, _T("Not enough memory."));
	
			if (0==::MultiByteToWideChar(encoding, 0, source, originallen, tmp, targetsize))
			{
				delete \[\] tmp;
				ThrowWindowsErrorTextException(_T("Could not convert text to unicode:"));
			}
			tmp\[targetsize\]= 0;
		}

#ifdef UNICODE
		target= tmp;
#else
		ConvertWideStringToString(tmp, target);
#endif
	}
	delete \[\] tmp;
}

void ConvertWideStringToString(const wchar_t* source, std::string& target)
{
	int targetsize= ::WideCharToMultiByte(CP_ACP, 0, source, -1, NULL, 0, NULL, NULL);
	char* tmp= new char\[targetsize+1\];
	if (NULL==tmp)
		throw CTextException(0, _T("Not enough memory."));
	if (!::WideCharToMultiByte(CP_ACP, 0, source, -1, tmp, targetsize, NULL, NULL))
	{
		delete\[\] tmp;
		throw CTextException(0, _T("Could not convert text to ansi."));
	}
	tmp\[targetsize\]= 0;
	target= tmp;
	delete \[\] tmp;
}

void ConvertToString(const TCHAR* source, std::string& target, unsigned encoding)
{
#ifdef UNICODE
	ConvertWideStringToString(source, target);
#else
	target= source;
#endif
}

std::wstring ConvertStringToWideString(const tstring& src)
{
#ifdef UNICODE
	return src;
#else
	size_t size = src.size();
	std::wstring result;
	result.reserve(size);
	for (register size_t i = 0; i< size; ++i)
		result += src\[i\];
	result\[size\] = 0;
	return result;
#endif
}

bool SaveFileFromBuffer(const tstring& filename, const tstring& buffer, unsigned encoding, int byteorder, bool WriteBOM)
{
	bool cleanBuffUp = false;
	
	std::wstring wBuffer = ConvertStringToWideString(buffer);
	const wchar_t* source = wBuffer.c_str();
	
	size_t srcLength = buffer.size(); // even if I convert ANSI to UTF16, length remains the same, or?
	char* buffOut=0;
	size_t buffLen = 0;
	
	if (encoding == 1200) // LE, leave it
	{
		buffOut = (char*) source;
		buffLen = srcLength*2;
	}

	else if (encoding == 1201) // BE, swap it
	{
		size_t byteLen = srcLength * 2;
		buffOut = new char\[byteLen+2\];
		cleanBuffUp = true;
		_swab((char*) source, buffOut, byteLen);
		buffOut\[byteLen\]= 0;
		buffOut\[byteLen+1\]= 0;
		buffLen = byteLen;
	}
	else // change it
	{
		buffLen = WideCharToMultiByte(encoding, 0, source, srcLength, buffOut, 0, NULL, NULL);
		if (!buffLen && !buffer.empty())
			throw CTextException(0, _T("Could not convert text to desired encoding."));
		
		buffOut = new char\[buffLen\];
		cleanBuffUp = true;
		WideCharToMultiByte(encoding, 0, source, srcLength, buffOut, buffLen, NULL, NULL);
	}
	
	std::string ansifilename;
	ConvertToString(filename.c_str(), ansifilename);
	FILE *f = fopen(ansifilename.c_str(), "wb");
	if (!f)
	{
		if (cleanBuffUp)
			delete\[\] buffOut;
		throw CTextException(0, _T("Could not write to output file."));
	}
	
	if (WriteBOM)
	{
		if (encoding == 1200)
			fwrite("\\xff\\xfe", 1, 2, f);
		else if (encoding == 1201)
			fwrite("\\xfe\\xff", 1, 2, f);
		else if (encoding == 65001)
			fwrite("\\xef\\xbb\\xbf", 1, 3, f);
	}
	
	fwrite(buffOut, buffLen, 1, f);
	fclose(f); 
	if (cleanBuffUp)
		delete\[\] buffOut;
	return true;
}

bool LoadFileIntoBuffer(const tstring& filename, tstring& buffer, unsigned encoding, int byteorder)
{
	bool result= false;

	HANDLE file= ::CreateFile(filename.c_str(),
		GENERIC_READ,
		FILE_SHARE_READ,
		NULL,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_READONLY,
		NULL);
	if (INVALID_HANDLE_VALUE!=file)
	{
		DWORD size= ::GetFileSize(file, NULL);
		if (0xFFFFFFFF==size) size= 0;

		if (0<size)
		{
			char* tmp = new char\[size+1\];
			memset(tmp, 0, (size+1)*sizeof(char));

			DWORD read= 0L;
			if (::ReadFile(file, tmp, size, &read, NULL))
			{
				buffer.reserve(read+1);
				ConvertToWideString(tmp, read, buffer, encoding, byteorder);
				result= true;
			}

			delete \[\] tmp;
		}
		::CloseHandle(file);
	}
	else
	{
		tstring msg= _T("Unable to open file '");
		msg+= filename;
		msg+= _T("'.");
		throw CTextException(altova::CAltovaException::eError1, msg);
	}

	return result;
}

void TrimStart(tstring& buffer)
{
	size_t i = 0;
	while (::_istspace(buffer\[i\])) ++i;
	if (i>0)
		buffer.erase(0, i);
}

size_t CountFormatCharacters(const tstring& buffer, size_t numberofchars)
{
	size_t charcount= 0L;
	size_t buffercount;
	for (buffercount= 0L; charcount!=numberofchars; ++buffercount)
	{
		if ((buffer\[buffercount\]!=_T('\\r')) && (buffer\[buffercount\]!=_T('\\n')))
			++charcount;
	}

	return buffercount - charcount;

}

void RemoveCRLF(tstring& buffer)
{
	int i= 0;
	while ( i < static_cast< int >( buffer.length() ) )
	{
		TCHAR c= buffer\[i\];
		switch (c)
		{
		case _T('\\n'):
		case _T('\\r'):
			buffer.erase(i, 1);
			break;
		default:
			++i;
			break;
		}
	}
}

tstring GetLastWindowsErrorAsString()
{
	DWORD lasterrorcode= GetLastError();
	LPVOID pBuffer= NULL;
	::FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
		            NULL,
					lasterrorcode,
					0,
					(LPTSTR) &pBuffer,
					0,
					NULL);
	tstring result= (LPTSTR) pBuffer;
	::LocalFree(pBuffer);
	return result;
}

} // namespace text
} // namespace altova
