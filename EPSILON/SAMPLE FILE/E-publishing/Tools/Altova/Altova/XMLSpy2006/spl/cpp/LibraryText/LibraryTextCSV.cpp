[$format= $library.FormatCSV]

ISerializer* [=$module]Document::CreateSerializer()
{
	altova::text::tablelike::CCSVSerializer* result= new altova::text::tablelike::CCSVSerializer(*this);
	result->GetFormat().SetFieldDelimiter(_T('[=$format.FieldSeparator]'));
	[if $format.QuoteCharacter <> ""]
	result->GetFormat().SetQuoteCharacter(_T('[=$format.QuoteCharacter]'));
	[endif]
	result->GetFormat().SetAssumeFirstRowAsHeaders([=$format.UseFirstRowNames]);
	result->SetCodePage([=$library.InputEncodingCodePage]);
	return result;
}
void [=$module]Document::InitHeader(CHeader& header)
{
	TColumnSpecificationArray& columns= header.GetColumns();
	[foreach $field in $format.Fields]
	columns.push_back(new CColumnSpecification(_T("[=$field.Name]")));
	[next]
}
int [=$module]Document::Get[=$library.RootName]Count()
{
	return CTable::GetRecordCount();
}
C[=$library.RootName]Type [=$module]Document::Get[=$library.RootName]At(int index)
{
	C[=$library.RootName]Type result(CTable::GetRecordAt(index));
	return result;
}
void [=$module]Document::Add[=$library.RootName](C[=$library.RootName]Type& rhs)
{
	CTable::AddRecord(rhs);
}
