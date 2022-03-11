class [=$module]_DECLSPECIFIER [=$module]Document : public altova::text::tablelike::CTable
{
public:
	int Get[=$library.RootName]Count();
	C[=$library.RootName]Type Get[=$library.RootName]At(int index);
	void Add[=$library.RootName](C[=$library.RootName]Type& rhs);

protected:
	virtual altova::text::tablelike::ISerializer* CreateSerializer();
	virtual void InitHeader(altova::text::tablelike::CHeader& header);
};