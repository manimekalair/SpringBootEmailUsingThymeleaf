[
sub GenerateCommand(byref $command)
	$lParams = ""
]
// [=$command.Kind] [=$command.Name]
[
	if $command.Kind = "Project"
		$lParams = $lParams & ", " & $command.TabSize
	endif

	' ----------

	if $command.Kind = "SplitSingle" or $command.Kind = "SplitMultiple"
		$lParams = $lParams & ", &Splitter_" & $command.Name
		if $command.IsDelimited
			$classname = "CSplitAtDelimiter"
			if $command.IsLineBased
				$classname = $classname & "LineBased"
				if $command.Kind = "SplitMultiple"
					$classname = $classname & "Multiple"
				endif
			endif
		][=$classname] Splitter_[=$command.Name](_T("[=$command.Separator.AsCppStringConstant]")[
			if $command.Kind = "SplitSingle"
				if $command.SplitBase = 1], true[else], false[endif
			endif
		]);
[		else ' fixed (counted)
			if $command.IsVertical
				$classname = "CSplitAtPosition"
			else ' horizontal
				$classname = "CSplitLines"
			endif
			$lOffset = $command.Offset
			if $command.Kind = "SplitSingle"
				if $command.SplitBase = 1 ' from end
					$lOffset = -$lOffset
				endif
			endif
			$lParams = $lParams & ", " & $command.Orientation & ", " & $lOffset
			][=$classname] Splitter_[=$command.Name]([=$lOffset]);
[		endif
	endif

	' ----------

	if $command.Kind = "Store"
		$lParams = $lParams & ", " & $command.TrimSide & ", _T(\"" & $command.TrimCharSet.AsCppStringConstant & "\")"
	endif

	' ----------

	if $command.Kind = "CSV" or $command.Kind = "FLF"
		$lParams = $lParams & ", " & $command.Columns.Length & ", Columns_" & $command.Name
		$lParams = $lParams & ", " & $command.UseFirstRowNames
		' generate store commands
		foreach $column in $command.Columns
			]CFlexCommandStore Store_[=$command.Name]_[=$column.Name](_T("[=$column.OriginalName.AsCppStringConstant]")[
		 	if $command.Kind = "FLF"
				], [=$column.Alignment], _T("[=$column.FillCharacter.AsCppStringConstant]"));
[			else
				], 0, _T(""));
[			endif
		next
	endif

	' generate column list
	if $command.Kind = "CSV"
		]CFlexColumnDelimited Columns_[=$command.Name]\[\] = {
[
		foreach $column in $command.Columns
			]	{ &Store_[=$command.Name]_[=$column.Name], _T("[=$column.OriginalName.AsCppStringConstant]") },
[		next
		]};
[
		$lParams = $lParams & ", _T(\"" & $command.RecordSeparator.AsCppStringConstant & "\")" & ", _T(\"" & $command.FieldSeparator.AsCppStringConstant & "\")"
		if $command.QuoteCharacter = ""
			$lParams = $lParams & ", _T('\\0')" 
		else
			$lParams = $lParams & ", _T('" & $command.QuoteCharacter.AsCppStringConstant & "')" 
		endif
		if $command.EscapeCharacter = ""
			$lParams = $lParams & ", _T('\\0')" 
		else
			$lParams = $lParams & ", _T('" & $command.EscapeCharacter.AsCppStringConstant & "')"
		endif
	endif

	if $command.Kind = "FLF"
		]CFlexColumnFixed Columns_[=$command.Name]\[\] = {
[
		foreach $column in $command.Columns
			]	{ &Store_[=$command.Name]_[=$column.Name], [=$column.Size], _T('[=$column.FillCharacter.AsCppStringConstant]'), [=$column.Alignment], _T("[=$column.OriginalName.AsCppStringConstant]") },
[		next
		]};
[
		if $command.HasRecordDelimiter
			]CSplitLines Splitter_[=$command.Name](1, true);
[		else
			]CSplitAtPosition Splitter_[=$command.Name]([=$command.RecordSize]);
[		endif
		$lParams = $lParams & ", &Splitter_" & $command.Name
	endif

	if $command.Kind = "Switch"
		$lParams = $lParams & ", " & ($command.Conditions.Length-1) & ", conditions_" & $command.Name & ", " & $command.Mode
		' generate conditions
		]		CFlexCondition conditions_[=$command.Name]\[\] = {
[					foreach $condition in $command.Conditions
						if $condition.Mode <> "Default"
						]			CFlexCondition(_T(""), CFlexCondition::[=$condition.Mode], _T("[=$condition.Value.AsCppStringConstant]")),
[						endif
					next
					]		};
[	endif
	
	]CFlexCommand[=$command.Kind] Command_[=$command.Name](_T("[=$command.OriginalName.AsCppStringConstant]")[=$lParams]);
[
	foreach $connector in $command.Connectors
		foreach $subcommand in $connector.Commands
			call GenerateCommand($subcommand)
		next ' subcommand
	next ' connector
	
	if $command.Kind = "Switch"
		foreach $condition in $command.Conditions
			foreach $connector in $condition.Connectors
				foreach $subcommand in $connector.Commands
					call GenerateCommand($subcommand)
				next ' command
			next ' connector
		next ' condition
	endif
endsub

	
sub ConnectChildren(byref $functioncall, byref $connector)
	foreach $subcommand in $connector.Commands
		]	Command_[=$functioncall](&Command_[=$subcommand.Name]);
[			
		call LinkCommandChildren($subcommand)
	next ' command
endsub


sub LinkCommandChildren(byref $command)

	if $command.Kind = "SplitSingle"
		$functioncall = $command.Name & ".SetFirst"
		call ConnectChildren($functioncall, $command.Connector.0)
		$functioncall = $command.Name & ".SetNext"
		call ConnectChildren($functioncall, $command.Connector.1)
	else
		if $command.Kind = "Switch"
			foreach $condition in $command.Conditions
				if $condition.Mode = "Default"
					$functioncall = $command.Name & ".SetNext"
					foreach $connector in $condition.Connectors
						if $connector.IsFirst
							call ConnectChildren($functioncall, $connector)
						endif
					next
				else
					$functioncall = $command.Name & ".GetCondition(" & $condition.Index & ").SetNext"
					foreach $connector in $condition.Connectors
						if $connector.IsFirst
							call ConnectChildren($functioncall, $connector)
						endif
					next
				endif
			next
		else
			foreach $connector in $command.Connectors
				if $connector.IsFirst
					$functioncall = $command.Name & ".SetNext"
					call ConnectChildren($functioncall, $connector)
				endif
			next
		endif
	endif
endsub


call GenerateCommand($library.FlexProject)

]

////////////////////////////////////////////////////////////////////////
//	[=$module]Document
////////////////////////////////////////////////////////////////////////

[=$module]Document::[=$module]Document()
:	flex::CTextDocument()
{
	m_pFlexProject = &Command_[=$library.FlexProject.Name];

[call LinkCommandChildren($library.FlexProject)
]
}

[=$module]Document::~[=$module]Document()
{}

bool [=$module]Document::Parse(const tstring& filename)
{
	return (!ParseFile(filename).IsNull());
}

void [=$module]Document::Save(const tstring& filename) const
{
	CTextDocument::SaveFile(filename);
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
