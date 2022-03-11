////////////////////////////////////////////////////////////////////////
//
// Lang.h
//
// This file was generated by [=$Host].
//
// YOU SHOULD NOT MODIFY THIS FILE, BECAUSE IT WILL BE
// OVERWRITTEN WHEN YOU RE-RUN CODE GENERATION.
//
// Refer to the [=$HostShort] Documentation for further details.
// [=$HostURL]
//
////////////////////////////////////////////////////////////////////////


#ifndef ALTOVAFUNCTIONS_LANG_H_INCLUDED
#define ALTOVAFUNCTIONS_LANG_H_INCLUDED

#if _MSC_VER > 1000
	#pragma once
#endif // _MSC_VER > 1000

#include "Core.h"	// template definitions and utility-functions

#define M_PI 3.14159265358979323846

typedef std::map< long, long >	TMapLongToLong;


namespace altova {

class ALTOVAFUNCTIONS_DECLSPECIFIER Lang
{
public:
	Lang() {};

////////////////////////////////////////////////////////////////////////
//
//  Logical functions
//
////////////////////////////////////////////////////////////////////////

	static CSchemaBoolean	LogicalXor(const CSchemaType& rObj1, const CSchemaType& rObj2)	
		{ return CSchemaBoolean( CSchemaType::CompareNotEqual(rObj1, rObj2) ); }
	static CSchemaBoolean	Positive(const CSchemaTypeNumber& rObject)
		{ return CSchemaBoolean( rObject.ToDouble() >= 0.0 ); }
	static CSchemaBoolean	Negative(const CSchemaTypeNumber& rObject)
		{ return CSchemaBoolean( rObject.ToDouble() < 0.0 ); }
	static CSchemaBoolean	Numeric(const CSchemaType& rObject)
		{ 
			return CSchemaBoolean( 
						(CSchemaString( (tstring)rObject ).NumericType() != CSchemaType::k_unknown)
							&&
						(CSchemaString( (tstring)rObject ).NumericType() != CSchemaType::k_bool)
				); 
		}

////////////////////////////////////////////////////////////////////////
//
//  Mathematical functions
//
////////////////////////////////////////////////////////////////////////

	// DivideInteger
	template <class A, class B>
	static typename SelectType< IsTypeGreater<A,B>::value, A, B>::Result DivideInteger(const A& a, const B& b)
	{		
		SelectType< IsTypeGreater<A,B>::value, A, B>::Result::calctype result = (ALTOVA_INT64)a.ToCalcValue() / (ALTOVA_INT64)b.ToCalcValue();
		return SelectType< IsTypeGreater<A,B>::value, A, B>::Result(result);
	}

	// UnaryMinus
	template <class A>
	static A UnaryMinus(const A& a)
		{ return A(-a.ToCalcValue()); }

	// Max
	template <class A, class B>
	static typename SelectType< IsTypeGreater<A,B>::value, A, B>::Result Max(const A& a, const B& b)
	{		
		SelectType< IsTypeGreater<A,B>::value, A, B>::Result::calctype result 
			= (a.ToCalcValue() >= b.ToCalcValue() ? a.ToCalcValue() : b.ToCalcValue() );
		return SelectType< IsTypeGreater<A,B>::value, A, B>::Result(result);
	}

	// Min
	template <class A, class B>
	static typename SelectType< IsTypeGreater<A,B>::value, A, B>::Result Min(const A& a, const B& b)
	{		
		SelectType< IsTypeGreater<A,B>::value, A, B>::Result::calctype result 
			= (a.ToCalcValue() <= b.ToCalcValue() ? a.ToCalcValue() : b.ToCalcValue() );
		return SelectType< IsTypeGreater<A,B>::value, A, B>::Result(result);
	}

	// Pi
	static CSchemaDouble	Pi()
		{ return CSchemaDouble( M_PI );	}

	// Sin
	static CSchemaDouble	Sin(const CSchemaTypeNumber& rNum);
	// Cos
	static CSchemaDouble	Cos(const CSchemaTypeNumber& rNum);
	// Tan
	static CSchemaDouble	Tan(const CSchemaTypeNumber& rNum);
	// ASin
	static CSchemaDouble	Asin(const CSchemaTypeNumber& rNum);
	// ACos
	static CSchemaDouble	Acos(const CSchemaTypeNumber& rNum);
	// ATan
	static CSchemaDouble	Atan(const CSchemaTypeNumber& rNum);
	// Radians
	static CSchemaDouble	Radians(const CSchemaTypeNumber& rNum);
	// Degrees
	static CSchemaDouble	Degrees(const CSchemaTypeNumber& rNum);

	// Abs
	template <class A>
	static A Abs(const A& a)
		{ return A((a.ToCalcValue()<0 ? -a.ToCalcValue() : a.ToCalcValue()) ); }
	// Exp
	static CSchemaDouble	Exp(const CSchemaTypeNumber& rNum);
	// Log (natural base)
	static CSchemaDouble	Log(const CSchemaTypeNumber& rNum);
	// Log (10 base)
	static CSchemaDouble	Log10(const CSchemaTypeNumber& rNum);
	// Pow
	static CSchemaDouble	Pow(const CSchemaTypeNumber& rNumBase, const CSchemaTypeNumber& rNumExp);
	// Random
	static CSchemaDouble	Random();
	// Sqrt
	static CSchemaDouble	Sqrt(const CSchemaTypeNumber& rNum);

////////////////////////////////////////////////////////////////////////
//
//  String functions
//
////////////////////////////////////////////////////////////////////////

	static CSchemaString	Uppercase(const CSchemaString& rStr);
	static CSchemaString	Lowercase(const CSchemaString& rStr);
	static CSchemaString	Capitalize(const CSchemaString& rStr);
	static CSchemaInt		CodeFromChar(const CSchemaString& rStr);
	static CSchemaString	CharFromCode(const CSchemaInt& rNum);
	static CSchemaInt		StringCompare(const CSchemaString& rStr1, const CSchemaString& rStr2);
	static CSchemaInt		StringCompareIgnoreCase(const CSchemaString& rStr1, const CSchemaString& rStr2);
	static CSchemaInt		CountSubstring(const CSchemaString& rStr, const CSchemaString& rSubStr);
	static CSchemaBoolean	MatchPattern(const CSchemaString& rStr, const CSchemaString& rPattern);
	static CSchemaInt		FindSubstring(const CSchemaString& rStr, const CSchemaString& rSubStr, const CSchemaTypeNumber& rStartPos);
	static CSchemaInt		ReversefindSubstring(const CSchemaString& rStr, const CSchemaString& rSubStr, const CSchemaTypeNumber& rEndPos);
	static CSchemaString	Left(const CSchemaString& rStr, CSchemaTypeNumber& rNum);
	static CSchemaString	LeftTrim(const CSchemaString& rStr);
	static CSchemaString	Right(const CSchemaString& rStr, CSchemaTypeNumber& rNum);
	static CSchemaString	RightTrim(const CSchemaString& rStr);
	static CSchemaString	Replace(const CSchemaString& rStr, const CSchemaString& rFind, const CSchemaString& rReplace);
	static CSchemaBoolean	Empty(const CSchemaString& rStr);
	static CSchemaString	FormatGuidString(const CSchemaString& rGuidStr);

////////////////////////////////////////////////////////////////////////
//
//  Datetime functions
//
////////////////////////////////////////////////////////////////////////
	static CSchemaDateTime	DatetimeAdd(const CSchemaDateTime& rDT, const CSchemaDuration& rDur);
	static CSchemaDuration	DatetimeDiff(const CSchemaDateTime& rDT1, const CSchemaDateTime& rDT2);

	// Datetime from parts
	static CSchemaDateTime	DatetimeFromParts(	const CSchemaTypeNumber& rYear, const CSchemaTypeNumber& rMonth,	const CSchemaTypeNumber& rDay,
												const CSchemaTypeNumber& rHour,	const CSchemaTypeNumber& rMinute,	const CSchemaTypeNumber& rSecond,
												const CSchemaTypeNumber& rMillisecond, const CSchemaTypeNumber& rTimezone );

	// Datetime from date and time
	static CSchemaDateTime	DatetimeFromDateAndTime( const CSchemaDate& rDate, const CSchemaTime& rTime );

	static CSchemaDate		DateFromDatetime( const CSchemaDateTime& rDT)
		{ return rDT; }
	static CSchemaTime		TimeFromDatetime( const CSchemaDateTime& rDT)
		{ return rDT; }

	static CSchemaInt		YearFromDatetime( const CSchemaDateTime& rDT)
		{ return CSchemaInt( rDT.GetValue().nYear ); }
	static CSchemaInt		MonthFromDatetime( const CSchemaDateTime& rDT)
		{ return CSchemaInt( rDT.GetValue().nMonth ); }
	static CSchemaInt		DayFromDatetime( const CSchemaDateTime& rDT)
		{ return CSchemaInt( rDT.GetValue().nDay ); }
	static CSchemaInt		HourFromDatetime( const CSchemaDateTime& rDT)
		{ return CSchemaInt( rDT.GetValue().nHour ); }
	static CSchemaInt		MinuteFromDatetime( const CSchemaDateTime& rDT)
		{ return CSchemaInt( rDT.GetValue().nMinute ); }
	static CSchemaInt		SecondFromDatetime( const CSchemaDateTime& rDT)
		{ return CSchemaInt( (long)rDT.GetValue().dSecond ); }
	static CSchemaDouble	MillisecondFromDatetime( const CSchemaDateTime& rDT)
		{ return CSchemaDouble( fmod( rDT.GetValue().dSecond * 1000.0, 1000.0 ) ); }

	static CSchemaDateTime	Now();
	static CSchemaBoolean	Leapyear(const CSchemaDateTime& rDT);
	static CSchemaInt		Timezone(const CSchemaTypeCalendar& rCal);
	static CSchemaInt		Weekday(const CSchemaDate& rDate);
	static CSchemaInt		Weeknumber(const CSchemaDate& rDate);

	static CSchemaDuration	DurationAdd(const CSchemaDuration& rDur1, const CSchemaDuration& rDur2);
	static CSchemaDuration	DurationSubtract(const CSchemaDuration& rDur1, const CSchemaDuration& rDur2);

	// duration from parts
	static CSchemaDuration	DurationFromParts(	const CSchemaTypeNumber& rYear, const CSchemaTypeNumber& rMonth, const CSchemaTypeNumber& rDay,
												const CSchemaTypeNumber& rHour,	const CSchemaTypeNumber& rMinute, const CSchemaTypeNumber& rSecond,
												const CSchemaTypeNumber& rMillisecond, const CSchemaType& rIsNegative );

	static CSchemaInt		YearFromDuration(	const CSchemaDuration& rDur )
		{ return CSchemaInt( rDur.GetValue().nYear); }
	static CSchemaInt		MonthFromDuration(	const CSchemaDuration& rDur )
		{ return CSchemaInt( rDur.GetValue().nMonth); }
	static CSchemaInt		DayFromDuration(	const CSchemaDuration& rDur )
		{ return CSchemaInt( rDur.GetValue().nDay); }
	static CSchemaInt		HourFromDuration(	const CSchemaDuration& rDur )
		{ return CSchemaInt( rDur.GetValue().nHour); }
	static CSchemaInt		MinuteFromDuration(	const CSchemaDuration& rDur )
		{ return CSchemaInt( rDur.GetValue().nMinute); }
	static CSchemaInt		SecondFromDuration(	const CSchemaDuration& rDur )
		{ return CSchemaInt( (long)rDur.GetValue().dSecond); }
	static CSchemaDouble	MillisecondFromDuration(	const CSchemaDuration& rDur )
		{ return CSchemaInt( (long)fmod( rDur.GetValue().dSecond * 1000.0, 1000.0 ) ); }

////////////////////////////////////////////////////////////////////////
//
//  Generator functions
//
////////////////////////////////////////////////////////////////////////
	static CSchemaString	CreateGuid();
	static CSchemaInt		AutoNumber( const long nComponentId, const CSchemaInt& rStartAt, const CSchemaInt& rIncrease );

protected:
	static TMapLongToLong	ms_AutoNumberValues;
};

} // namespace altova

#endif // ALTOVAFUNCTIONS_LANG_H_INCLUDED