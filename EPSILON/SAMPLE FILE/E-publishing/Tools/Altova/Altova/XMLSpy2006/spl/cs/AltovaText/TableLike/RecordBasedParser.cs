[call GenerateFileHeader("RecordBasedParser.cs")]
namespace Altova.TextParser.TableLike
{
	/// <summary>
	/// A delegate for reporting about records found by the parser.
	/// </summary>
	/// <param name="record">the record found</param>
	public delegate void RecordFoundDelegate(Record record);

	/// <summary>
	/// Serves as a base class for all record based parsers.
	/// </summary>
	public abstract class RecordBasedParser
	{
		#region Implementation Detail:
		RecordFoundDelegate mOnRecordFound = null;
		Header mHeader = null;
		#endregion
		#region Protected Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="header">the header to use</param>
		protected RecordBasedParser(Header header)
		{
			mHeader = header;
		}
		#endregion
		#region Public Interface:
		/// <summary>
		/// Get/sets the callback called whenever the parser has parsed a complete record.
		/// </summary>
		public RecordFoundDelegate OnRecordFound
		{
			get
			{
				return mOnRecordFound;
			}
			set
			{
				mOnRecordFound = value;
			}
		}
		/// <summary>
		/// Gets the header specification the parser is using.
		/// </summary>
		public Header Header
		{
			get
			{
				return mHeader;
			}
		}
		#endregion
		#region Descendant Obligations:
		/// <summary>
		/// Parses a buffer.
		/// </summary>
		/// <param name="buffer">the buffer to be parsed</param>
		/// <returns>the number of records found</returns>
		public abstract int Parse(string buffer);
		#endregion
	}
}