[call GenerateFileHeader("CSVSerializer.cs")]
namespace Altova.TextParser.TableLike.CSV
{
	/// <summary>
	/// Implements <see cref="ISerializer"/> for a CSV format.
	/// </summary>
	public class CSVSerializer : Serializer
	{
		#region Implementation Detail:
		CSVFormat mFormat = new CSVFormat();
		bool mWaitingForHeader = false;

		void SaveHeaders()
		{
			int maximalindex = Table.Header.Count;
			for (int i = 0; i < maximalindex; ++i)
			{
				string name = Table.Header\[i\].Name;
				name = this.AssureCorrectFieldFormat(name);
				Stream.Write(name);
				if (i < maximalindex - 1) this.WriteFieldEnd();
			}
			this.WriteRecordEnd();
		}
		void SaveRecord(Record record)
		{
			int maximalindex = Table.Header.Count;
			for (int i = 0; i < maximalindex; ++i)
			{
				string val = record\[i\];
				val = this.AssureCorrectFieldFormat(val);
				Stream.Write(val);
				if (i < maximalindex - 1) this.WriteFieldEnd();
			}
			this.WriteRecordEnd();
		}
		void WriteFieldEnd()
		{
			Stream.Write(mFormat.FieldDelimiter);
		}
		void WriteRecordEnd()
		{
			Stream.Write(mFormat.RecordDelimiters);
		}
		static bool StartsOrEndsWithWhiteSpace(string rhs)
		{
			return (rhs != rhs.Trim());
		}
		string AssureCorrectFieldFormat(string rhs)
		{
			string result = rhs;
			if (null != result)
			{
				if ((StartsOrEndsWithWhiteSpace(result)) ||
					(0 <= result.IndexOfAny(mFormat.QuoteNeedingCharacters)))
					result = mFormat.QuoteString(rhs);
			}
			return result;
		}
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="table">the table to use for de/serializing</param>
		public CSVSerializer(Table table) : base(table)
		{}
		/// <summary>
		/// Gets the format information used by this instance.
		/// </summary>
		public CSVFormat Format
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
			if (mFormat.AssumeFirstRowAsHeaders) this.SaveHeaders();
			foreach (Record record in Table)
				this.SaveRecord(record);
		}
		/// <summary>
		/// See <see cref="Serializer.CreateParser"/>().
		/// </summary>
		/// <returns>See <see cref="Serializer.CreateParser"/>().</returns>
		protected override RecordBasedParser CreateParser()
		{
			mWaitingForHeader = mFormat.AssumeFirstRowAsHeaders;
			return new CSVParser(mFormat, Table.Header);
		}
		/// <summary>
		/// See <see cref="Serializer.DoStoreRecord"/>().
		/// </summary>
		/// <param name="record">See <see cref="Serializer.DoStoreRecord"/>().</param>
		/// <returns>See <see cref="Serializer.DoStoreRecord"/>().</returns>
		protected override bool DoStoreRecord(Record record)
		{
			if (mWaitingForHeader)
			{
				mWaitingForHeader = false;
				return false;
			}
			else return true;
		}
		#endregion
	}
}