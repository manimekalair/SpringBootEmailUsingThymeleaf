[call GenerateFileHeader("CSVFormat.cs")]
namespace Altova.TextParser.TableLike.CSV
{
	/// <summary>
	/// Encapsulates the specification of a CSV format.
	/// </summary>
	public class CSVFormat
	{
		#region Implementation Detail:
		char mFieldDelimiter = ',';
		readonly char\[\] mRecordDelimiters = new char\[\]
			{
				'\\r',
				'\\n'
			};
		char mQuoteCharacter = '\\0';
		char\[\] mQuoteNeedingCharacters = new char\[4\];
		string mQuoteCharacterAsString = "";
		string mDoubleQuoteCharacterAsString = "";
		bool mAssumeFirstRowAsHeaders = true;
		bool mExpectQuoteCharacter = false;

		void UpdateQuoteNeedingCharacters()
		{
			mRecordDelimiters.CopyTo(mQuoteNeedingCharacters, 0);
			mQuoteNeedingCharacters\[2\] = mFieldDelimiter;
			mQuoteNeedingCharacters\[3\] = mQuoteCharacter;
			mQuoteCharacterAsString = new string(mQuoteCharacter, 1);
			mDoubleQuoteCharacterAsString = new string(mQuoteCharacter, 2);
		}
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		public CSVFormat()
		{
			this.UpdateQuoteNeedingCharacters();
		}
		/// <summary>
		/// Get/sets whether the first row of a file is interpreted as header row or whether
		/// a header row should be written.
		/// </summary>
		public bool AssumeFirstRowAsHeaders
		{
			get
			{
				return mAssumeFirstRowAsHeaders;
			}
			set
			{
				mAssumeFirstRowAsHeaders = value;
			}
		}
		/// <summary>
		/// Gets the record delimiters used by the parser.
		/// </summary>
		public char\[\] RecordDelimiters
		{
			get
			{
				return mRecordDelimiters;
			}
		}
		/// <summary>
		/// Get/sets the field delimiter to be used by the parser. Default is ','.
		/// </summary>
		public char FieldDelimiter
		{
			get
			{
				return mFieldDelimiter;
			}
			set
			{
				mFieldDelimiter = value;
				this.UpdateQuoteNeedingCharacters();
			}
		}
		/// <summary>
		/// Get/sets the quote character to be used by the parser. Default is '"'.
		/// </summary>
		public char QuoteCharacter
		{
			get
			{
				return mQuoteCharacter;
			}
			set
			{
				mExpectQuoteCharacter = true;
				mQuoteCharacter = value;
				this.UpdateQuoteNeedingCharacters();
			}
		}
		/// <summary>
		/// Checks whether a given character is a field delimiter.
		/// </summary>
		/// <param name="rhs">the character to check</param>
		/// <returns>true if rhs is a field delimiter, otherwise false</returns>
		public bool IsFieldDelimiter(char rhs)
		{
			return (mFieldDelimiter == rhs);
		}
		/// <summary>
		/// Checks whether a given character is a record delimiter.
		/// </summary>
		/// <param name="rhs">the character to check</param>
		/// <returns>true if rhs is a record delimiter, otherwise false</returns>
		public bool IsRecordDelimiter(char rhs)
		{
			foreach (char c in mRecordDelimiters)
				if (c == rhs) return true;
			return false;
		}
		/// <summary>
		/// Checks whether a given character is a quote character.
		/// </summary>
		/// <param name="rhs">the character to check</param>
		/// <returns>true if rhs is a quote character, otherwise false</returns>
		public bool IsQuoteCharacter(char rhs)
		{
			return (mExpectQuoteCharacter && (mQuoteCharacter == rhs));
		}
		/// <summary>
		/// Gets an array with all characters which, if found in a field value, make it necessary to
		/// quote the whole field.
		/// </summary>
		public char\[\] QuoteNeedingCharacters
		{
			get
			{
				return mQuoteNeedingCharacters;
			}
		}
		/// <summary>
		/// Brackets a string with <see cref="QuoteCharacter"/> and 
		/// escapes all occurrences inside the string.
		/// </summary>
		/// <param name="rhs">the string to quote</param>
		/// <returns>the quoted string</returns>
		public string QuoteString(string rhs)
		{
			if (!mExpectQuoteCharacter) return rhs;
			string result = "";
			result = rhs.Replace(mQuoteCharacterAsString, mDoubleQuoteCharacterAsString);
			result = mQuoteCharacter + result + mQuoteCharacter;
			return result;
		}
		#endregion
	}
}