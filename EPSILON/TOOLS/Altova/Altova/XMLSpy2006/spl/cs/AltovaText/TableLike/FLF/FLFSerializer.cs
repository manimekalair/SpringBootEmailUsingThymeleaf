[call GenerateFileHeader("FLFSerializer.cs")]
namespace Altova.TextParser.TableLike.FLF
{
	/// <summary>
	/// Implements <see cref="ISerializer"/> for a FLF format.
	/// </summary>
	public class FLFSerializer : Serializer
	{
		#region Implementation Detail:
		FLFFormat mFormat = new FLFFormat();

		string AssureCorrectFieldFormat(string rhs, int len)
		{
			if (rhs == null)
				return new string(mFormat.FillCharacter, len);
			
			if (rhs.Length > len)
				throw new MappingException("Field too long: is " + rhs.Length.ToString() + " characters, should be " + len.ToString() + ".");
			return rhs.PadRight(len, mFormat.FillCharacter);
		}
		void SaveRecord(Record record)
		{
			int fieldcount = Table.Header.Count;
			for (int i = 0; i < fieldcount; ++i)
			{
				ColumnSpecification cs = Table.Header\[i\];
				string val = record\[i\];
				val = this.AssureCorrectFieldFormat(val, cs.Length);
				Stream.Write(val);
			}
			if (mFormat.AssumeRecordDelimitersPresent)
				Stream.Write("\\r\\n");
		}
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="table">the table this instance should operate on</param>
		public FLFSerializer(Table table) : base(table)
		{}
		/// <summary>
		/// Gets the format specification this instance uses.
		/// </summary>
		public FLFFormat Format
		{
			get
			{
				return mFormat;
			}
		}
		#endregion
		#region Serializer Members:
		/// <summary>
		/// See <see cref="Serializer.DoSerialize"/>().
		/// </summary>
		protected override void DoSerialize()
		{
			foreach (Record record in Table)
				this.SaveRecord(record);
		}
		/// <summary>
		/// See <see cref="Serializer.CreateParser"/>().
		/// </summary>
		/// <returns>See <see cref="Serializer.CreateParser"/>().</returns>
		protected override RecordBasedParser CreateParser()
		{
			return new FLFParser(mFormat, Table.Header);
		}
		/// <summary>
		/// See <see cref="Serializer.DoStoreRecord"/>().
		/// </summary>
		/// <param name="record">See <see cref="Serializer.DoStoreRecord"/>().</param>
		/// <returns>See <see cref="Serializer.DoStoreRecord"/>().</returns>
		protected override bool DoStoreRecord(Record record)
		{
			return true;
		}
		#endregion
	}
}