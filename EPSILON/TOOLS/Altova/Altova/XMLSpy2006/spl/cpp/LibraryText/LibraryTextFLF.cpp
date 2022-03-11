[$format= $library.FormatFLF]

ISerializer* [=$module]Document::CreateSerializer()
{
	altova::text::tablelike::CFLFSerializer* result= new altova::text::tablelike::CFLFSerializer(*this);
	result->GetFormat().SetAssumeRecordDelimiters([=$format.AssumeRecordDelimitersPresent]);
	result->GetFormat().SetFillCharacter(_T('[=$format.FillCharacter]'));
	result->SetCodePage([=$library.InputEncodingCodePage]);
	return result;
}
void [=$module]Document::InitHeader(CHeader& header)
{
	TColumnSpecificationArray& columns= header.GetColumns();
	[foreach $field in $format.FieldDescriptions]
	columns.push_back(new CColumnSpecification(_T("[=$field.Name]"), [=$field.Length]));
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
