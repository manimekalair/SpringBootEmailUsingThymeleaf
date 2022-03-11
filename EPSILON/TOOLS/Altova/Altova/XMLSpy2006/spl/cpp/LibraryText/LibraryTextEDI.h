//////////////////////////////////////////////////////////////////////////

class [=$module]_DECLSPECIFIER [=$module]Document : public edi::CTextDocument
{
public:
	// construction and destruction
	[=$module]Document();
	virtual ~[=$module]Document();

	bool Parse(const tstring& filename);

	int Get[=$library.RootName]Count() const;
	C[=$library.RootName]Type Get[=$library.RootName]() const;
	C[=$library.RootName]Type Get[=$library.RootName]At(int index) const;
	void Add[=$library.RootName](C[=$library.RootName]Type& rhs);

public:
	void Save(const tstring& filename) const;


protected:
	virtual tstring GetStructureName() const;
	virtual const edi::CEDISettings& GetSettings() const;
	virtual edi::EDIStandard GetStandard() const;
	virtual bool ValidateSource(tstring&);
	virtual bool ValidateResult();

private:
	void InitScanner();
	void InitGeneral();
	// this construct with multiple InitHandler functions exists because of C1509 in MSVC++ 6.0
	[
	$countHandlerInitializers= 1 + $library.Handlers.Length / 500
	$i= 0
	while ($i<$countHandlerInitializers)
		write "\tvoid InitHandlers" & $i & "();\n"
		$i= $i + 1
	wend
	$countFunctionInitializers= 1 + $library.Functions.Length / 500
	$i= 0
	while ($i<$countFunctionInitializers)
		write "\tvoid InitFunctions" & $i & "();\n"
		$i= $i + 1
	wend
	]
	void InitHandlers();
	void InitFunctions();
	void InitSettings();

	void PrepareSource(tstring&);
	void RemoveAll(tstring&, TCHAR);

private:
	[switch ($library.EDIKind)
	   case 1:	$EDISettingsType= "CEDIFactSettings"
	   case 2:	$EDISettingsType= "CEDIX12Settings"
	   default:	$EDISettingsType= "UnknownSettings"
	 endswitch]
	edi::[=$EDISettingsType] m_Settings;

private:
	[=$module]Document(const [=$module]Document&);
	[=$module]Document& operator= (const [=$module]Document&);
};
