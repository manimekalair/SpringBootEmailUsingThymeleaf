////////////////////////////////////////////////////////////////////////
//	[=$module]Document
////////////////////////////////////////////////////////////////////////

[=$module]Document::[=$module]Document()
:	CTextDocument()
{
	this->InitScanner();
	this->InitGeneral();
	this->InitHandlers();
	this->InitFunctions();
	this->InitSettings();
}

[=$module]Document::~[=$module]Document()
{}

bool [=$module]Document::Parse(const tstring& filename)
{
	return (!ParseFile(filename).IsNull());
}
int [=$module]Document::Get[=$library.RootName]Count() const
{
	return 1;
}
C[=$library.RootName]Type [=$module]Document::Get[=$library.RootName]() const
{
	return C[=$library.RootName]Type(CTextDocument::GetRoot());
}

C[=$library.RootName]Type [=$module]Document::Get[=$library.RootName]At(int index) const
{
	return Get[=$library.RootName]();
}

void [=$module]Document::Add[=$library.RootName](C[=$library.RootName]Type& rhs)
{
	GetGenerator().SetRootNode(const_cast<CTextNode&>(rhs.GetNode()));
}

void [=$module]Document::InitScanner()
{
	CScanner& rScanner = GetScanner();
[foreach $separator in $library.Separators
]	rScanner.AddSeparator( _T('[=$separator.Character]'), _T("[=$separator.Symbol]") );
[next]
}

void [=$module]Document::InitGeneral()
{
	SetProlog( _T("[=$library.PrologName]") );
	SetEpilog( _T("[=$library.EpilogName]") );
}

void [=$module]Document::InitSettings()
{
	[switch ($library.EDIKind)
	case 1:]
	// EDIFact specific settings:
	[if $library.EDIFactSettings.SyntaxLevel<>""]
	m_Settings.SetSyntaxLevel(_T('[=$library.EDIFactSettings.SyntaxLevel]'));
	[endif]
	m_Settings.SetSyntaxVersionNumber([=$library.EDIFactSettings.SyntaxVersionNumber]);
	[if $library.EDIFactSettings.ControllingAgency<>""]
	m_Settings.SetControllingAgency(_T("[=$library.EDIFactSettings.ControllingAgency]"));
	[endif]
	m_Settings.SetWriteUNA([=$library.EDIFactSettings.WriteUNA]);
	[case 2:]
	// X12 specific settings:
[	 $subsep = $library.ToHexCode($library.EDIX12Settings.SubElementSeparator)
]	m_Settings.SetSubElementSeparator((TCHAR) 0x[=$subsep]); // [=$library.EDIX12Settings.SubElementSeparator]
	m_Settings.SetInterchangeControlVersionNumber(_T("[=$library.EDIX12Settings.InterchangeControlVersionNumber]"));
	m_Settings.SetRequestAcknowledgement([=$library.EDIX12Settings.RequestAcknowledgement]);
	[default:]
	// unknown EDI document type
	[endswitch]
	// general settings:
	m_Settings.SetTerminateSegmentsWithLinefeed([=$library.EDISettings.TerminateSegmentsWithLinefeed]);
	m_Settings.SetAutoCompleteData([=$library.EDISettings.AutoCompleteData]);
	CServiceStringAdvice& una= m_Settings.GetServiceStringAdvice();
	[
	 $compsep = $library.ToHexCode($library.EDISettings.ComponentDataElementSeparator)
	 $datasep = $library.ToHexCode($library.EDISettings.DataElementSeparator)
	 $decisep = $library.ToHexCode($library.EDISettings.DecimalNotation)
	 $escpsep = $library.ToHexCode($library.EDISettings.ReleaseIndicator)
	 $segmsep = $library.ToHexCode($library.EDISettings.SegmentTerminator)
	]
	una.SetComponentDataElementSeparator((TCHAR) 0x[=$compsep]); // [=$library.EDISettings.ComponentDataElementSeparator]
	una.SetDataElementSeparator((TCHAR) 0x[=$datasep]); // [=$library.EDISettings.DataElementSeparator]
	una.SetDecimalNotation((TCHAR) 0x[=$decisep]); // [=$library.EDISettings.DecimalNotation]
	una.SetReleaseIndicator((TCHAR) 0x[=$escpsep]); // [=$library.EDISettings.ReleaseIndicator]
	una.SetSegmentTerminator((TCHAR) 0x[=$segmsep]); // [=$library.EDISettings.SegmentTerminator]
}

tstring [=$module]Document::GetStructureName() const
{
	return _T("[=$library.StructureName]");
}

const CEDISettings& [=$module]Document::GetSettings() const
{
	return m_Settings;
}

EDIStandard [=$module]Document::GetStandard() const
{
	[switch ($library.EDIKind)
	   case 1:   $EDIKindSpecifier= "EDIFact"
	   case 2:   $EDIKindSpecifier= "EDIX12"
	   default:  $EDIKindSpecifier= "Unknown"
	 endswitch]
	return [=$EDIKindSpecifier];
}

bool [=$module]Document::ValidateSource(tstring& buffer)
{
	[switch ($library.EDIKind)
	   case 1:]
	tstring una = _T("UNA");
	if (buffer\[0\] == una\[0\] &&
		buffer\[1\] == una\[1\]	&&
		buffer\[2\] == una\[2\])
	{
		// 0: Component Separator
		// 1: Element Separator
		// 2: Decimal Notation Comma or full stop
		// 3: Release Indicator / Escape character
		// 4: Reserved for future use
		// 5: Segment Terminator

		TCHAR sep\[6\] =
		{
			buffer\[3+0\],
			buffer\[3+1\],
			buffer\[3+2\],
			buffer\[3+3\],
			buffer\[3+4\],
			buffer\[3+5\],
		};

		m_Settings.GetServiceStringAdvice().SetFromCharArray(sep);
		CScanner& scanner = GetScanner();
		scanner.AddSeparator(sep\[0\], _T("component"));
		scanner.AddSeparator(sep\[1\], _T("element"));
		scanner.AddSeparator(sep\[5\], _T("segment"));
		scanner.SetEscapeChar((sep\[3\]==_T(' ')) ? _T('\\0') : sep\[3\]);
		scanner.SetDecimalChar(sep\[2\]);

		// eat the "UNA" and the 6 following chars
		for (int i= 0; i<9; ++i) buffer\[i\]=_T('\\r');
	}
	[case 2:]
	tstring isa= _T("ISA");
	if (buffer\[0\] == isa\[0\] &&
	    buffer\[1\] == isa\[1\] &&
	    buffer\[2\] == isa\[2\])
	{
		CScanner& scanner = GetScanner();

		TCHAR separatorelement		= 0L;
		TCHAR separatorcomponent	= 0L;
		TCHAR separatorsegment		= 0L;

		size_t formatcharactercount = CountFormatCharacters(buffer, 105);
		if (formatcharactercount > 0)
		{
			tstring segmentisa= buffer.substr(0, 106 + formatcharactercount);
			RemoveCRLF(segmentisa);

			separatorelement= segmentisa\[3\];
			separatorcomponent= segmentisa\[104\];
			separatorsegment= segmentisa\[105\];
		}
		else
		{
			separatorelement= buffer\[3\];
			separatorcomponent= buffer\[104\];
			separatorsegment= buffer\[105\];
		}

		scanner.AddSeparator(separatorelement, _T("element"));
		scanner.AddSeparator(separatorcomponent, _T("component"));
		scanner.AddSeparator(separatorsegment, _T("segment"));
	}
	[endswitch]
	PrepareSource(buffer);
	return true;
}

bool [=$module]Document::ValidateResult()
{
	bool result = CTextDocument::ValidateResult();
	[if ($library.EDIKind=1)]RecordDecimalSeparator();[endif]
	return result;
}
void [=$module]Document::RemoveAll(tstring& buffer, TCHAR what)
{
	tstring tmp;
	for (tstring::size_type i = 0; i<buffer.size(); ++i)
	{
		if (what!=buffer\[i\])
			tmp+= buffer\[i\];
	}
	buffer= tmp;
}
void [=$module]Document::PrepareSource(tstring& buffer)
{
	CScanner& scanner= GetScanner();
	TCHAR segmentterminator= scanner.GetSeparator(_T("segment"));
	if (segmentterminator!=_T('\\r'))
		scanner.AddIgnorableCharacter(_T('\\r'));
	if (segmentterminator!=_T('\\n'))
		scanner.AddIgnorableCharacter(_T('\\n'));
}
void [=$module]Document::Save(const tstring& filename) const
{
	CTextNode* structureroot= CEnvelopeType::CreateStructureNode(CNullTextNode::GetInstance());
	CTextDocument::Save(*structureroot, filename);
	CTextNodeFactory::GetInstance().Delete(structureroot);
}

[
$countHandlerInitializers= 1 + $library.Handlers.Length / 500
$i= 0
while ($i<$countHandlerInitializers)
	call GenerateHandlerInitializer($i)
	$i= $i + 1
wend
$countFunctionInitializers= 1 + $library.Functions.Length / 500
$i= 0
while ($i<$countFunctionInitializers)
	call GenerateFunctionInitializer($i)
	$i= $i + 1
wend
]

void [=$module]Document::InitHandlers()
{
	// [=$library.Handlers.Length]
	[$i= 0
	while ($i<$countHandlerInitializers)]
	InitHandlers[=$i]();
	[$i = $i + 1
	wend]
}

void [=$module]Document::InitFunctions()
{
	// [=$library.Functions.Length]
	[$i= 0
	while ($i<$countFunctionInitializers)]
	InitFunctions[=$i]();
	[$i = $i + 1
	wend]
}
