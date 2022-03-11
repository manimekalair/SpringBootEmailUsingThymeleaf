[call GenerateFileHeader("FLFFormat.cs")]
namespace Altova.TextParser.TableLike.FLF
{
	/// <summary>
	/// Encapsulates the specification of a fixed length fields format.
	/// </summary>
	public class FLFFormat
	{
		#region Implementation Detail:
		bool mAssumeRecordDelimitersPresent = false;
		char mFillCharacter = ' ';
		char\[\] mRecordDelimiters = new char\[\]
			{
				'\\n',
				'\\r'
			};
		#endregion
		/// <summary>
		/// Get/sets whether record delimiters are used.
		/// </summary>
		public bool AssumeRecordDelimitersPresent
		{
			get
			{
				return mAssumeRecordDelimitersPresent;
			}
			set
			{
				mAssumeRecordDelimitersPresent = value;
			}
		}
		/// <summary>
		/// Get/sets the character used to fill fields up to their specified length.
		/// </summary>
		public char FillCharacter
		{
			get
			{
				return mFillCharacter;
			}
			set
			{
				mFillCharacter = value;
			}
		}
		/// <summary>
		/// Checks whether a given character is a record delimiter (\\n or \\r).
		/// </summary>
		/// <param name="rhs">the character to check</param>
		/// <returns>true if the character is a record delimiter, otherwise false</returns>
		public bool IsRecordDelimiter(char rhs)
		{
			foreach (char c in mRecordDelimiters)
				if (c == rhs) return true;
			return false;
		}
	}
}