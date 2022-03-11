//////////////////////////////////////////////////////////////////////////

class [=$module]_DECLSPECIFIER [=$module]Document : public flex::CTextDocument
{
public:
	// construction and destruction
	[=$module]Document();
	virtual ~[=$module]Document();

	bool Parse(const tstring& filename);
	void Save(const tstring& filename) const;

	int Get[=$library.RootName]Count() const;
	C[=$library.RootName]Type Get[=$library.RootName]() const;
	C[=$library.RootName]Type Get[=$library.RootName]At(int index) const;
	void Add[=$library.RootName](C[=$library.RootName]Type& rhs);

private:
	[=$module]Document(const [=$module]Document&);
	[=$module]Document& operator= (const [=$module]Document&);
};
