[call GenerateFileHeader("Scanner.cs")]
using System;
using System.Collections;
using System.Text;

namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Encapsulates scanning a string buffer for tokens and delimiters.
	/// </summary>
	public class Scanner
	{
		#region Implementation Detail:
		string mCurrent; // complete buffer
		int mPosition; // current position
		string mToken; // current token value
		string mSeparatorToken; // current separator
		char mEscapeChar = '\\0';
		char mQuoteChar = '\\0';
		char mDecimalSeparator = ',';
		Hashtable mSeparatorMap = new Hashtable();
		Hashtable mTokenMap = new Hashtable();
		string mTokenizerToken = "";
		StringBuilder mTokenBuilder = new StringBuilder();

		void MoveNext()
		{
			++mPosition;
		}
		void MoveBack()
		{
			--mPosition;
		}
		void MapToken(string rhs)
		{
			if (mTokenMap.ContainsKey(rhs))
				mTokenizerToken = (string) mTokenMap\[rhs\];
		}
		bool IsInsideExpression
		{
			get
			{
				if (this.IsEndOfText) return false;
				if (mEscapeChar == this.CurrentChar)
				{
					this.MoveNext();
					return true;
				}
				return !mSeparatorMap.ContainsKey(this.CurrentChar);
			}
		}
		void EraseAllSeparatorMappingsForString(string name)
		{
			string keys = "";
			foreach (DictionaryEntry entry in mSeparatorMap)
			{
				if (name == (string) entry.Value)
					keys += (char) entry.Key;
			}
			foreach (char c in keys)
				mSeparatorMap.Remove(c);
		}
		#endregion
		#region Nested Types:
		/// <summary>
		/// Encapsulates the possible results of a call to <see cref="Scanner.Scan"/>().
		/// </summary>
		public enum Indicator
		{
			/// <summary>a token has been found</summary>
			Value,
			/// <summary>an empty token has been found</summary>
			Empty,
			/// <summary>the end of the buffer has been encountered</summary>
			End,
		}
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		public Scanner()
		{
			this.AddSeparator('\\0', "terminate");
			/*
			this.AddSeparator('\\r', "return");
			this.AddSeparator('\\n', "linefeed");
			*/
		}
		/// <summary>
		/// Initializes this instance for scanning a new buffer.
		/// </summary>
		/// <param name="buffer">the new buffer to scan</param>
		public void Init(string buffer)
		{
			mCurrent = buffer;
			mPosition = 0;
		}
		/// <summary>
		/// Gets the current token.
		/// </summary>
		public string Token
		{
			get
			{
				return mToken;
			}
		}
		/// <summary>
		/// Gets the current value - alias for <see cref="Token"/>.
		/// </summary>
		public string Value
		{
			get
			{
				return mToken;
			}
		}
		/// <summary>
		/// Scans forward inside the buffer until a complete token can be mapped or
		/// a separator is found.
		/// </summary>
		/// <returns>a value indicating what has been found</returns>
		public Indicator Scan()
		{
			if (this.IsEndOfText) return Indicator.End;

			mTokenBuilder.Remove(0, mTokenBuilder.Length);

			if (this.IsInsideExpression)
				mTokenBuilder.Append(this.CurrentChar);
			for (this.MoveNext(); this.IsInsideExpression; this.MoveNext())
				mTokenBuilder.Append(this.CurrentChar);
			mToken = mTokenBuilder.ToString();
			this.MapToken(mToken);

			// store the current separator token so that we can depend on it in a rule.
			mSeparatorToken = this.Separator;

			if (this.IsEndOfText)
				return Indicator.End;
			else if (0 == mToken.Length)
				return Indicator.Empty;
			else
				return Indicator.Value;
		}
		/// <summary>
		/// Scans ahead one character.
		/// </summary>
		/// <returns>a value indicating what has been found</returns>
		public Indicator ScanChar()
		{
			this.MoveNext();
			mToken = string.Empty;
			mToken += this.CurrentChar;
			return this.IsEndOfText ? Indicator.End : Indicator.Value;
		}
		/// <summary>
		/// Scans back one character.
		/// </summary>
		/// <returns>a value indicating what has been found</returns>
		public Indicator BackChar()
		{
			this.MoveBack();
			mToken = string.Empty;
			mToken += this.CurrentChar;
			return this.IsEndOfText ? Indicator.End : Indicator.Value;
		}
		/// <summary>
		/// Gets the current char in the buffer.
		/// </summary>
		public char CurrentChar
		{
			get
			{
				if (mPosition >= mCurrent.Length) return '\\0';
				return mCurrent\[mPosition\];
			}
		}
		/// <summary>
		/// Gets the separator for the current char.
		/// </summary>
		public string Separator
		{
			get
			{
				return (string) mSeparatorMap\[this.CurrentChar\];
			}
		}
		/// <summary>
		/// Gets the current separator token.
		/// </summary>
		public string SeparatorToken
		{
			get
			{
				return mSeparatorToken;
			}
		}
		/// <summary>
		/// Gets whether scanning has arrived at the end of the buffer.
		/// </summary>
		public bool IsEndOfText
		{
			get
			{
				return (mPosition >= mCurrent.Length);
			}
		}
		/// <summary>
		/// Maps a character to a separator token.
		/// </summary>
		/// <param name="ch">the character</param>
		/// <param name="name">the separator token</param>
		/// <remarks>
		/// If the separator token is already mapped to some character,
		/// all these existing mappings will be erased.
		/// </remarks>
		public void AddSeparator(char ch, string name)
		{
			this.EraseAllSeparatorMappingsForString(name);
			mSeparatorMap\[ch\] = name;
		}
		/// <summary>
		/// Gets a separator by its symbolic name.
		/// </summary>
		/// <param name="name">the symbolic name</param>
		/// <returns>the separator</returns>
		public char GetSeparatorByName(string name)
		{
			foreach (DictionaryEntry entry in mSeparatorMap)
				if (entry.Value.ToString()==name)
					return (char) entry.Key;
			return '\\0';
		}
		/// <summary>
		/// Get/sets the escape character used by this instance.
		/// </summary>
		public char EscapeChar
		{
			get
			{
				return mEscapeChar;
			}
			set
			{
				mEscapeChar = value;
			}
		}
		/// <summary>
		/// Get/sets the quote character used by this instance.
		/// </summary>
		public char QuoteChar
		{
			get
			{
				return mQuoteChar;
			}
			set
			{
				mQuoteChar = value;
			}
		}
		/// <summary>
		/// Get/sets the character used by instance as decimal separator.
		/// </summary>
		public char DecimalSeparator
		{
			get
			{
				return mDecimalSeparator;
			}
			set
			{
				mDecimalSeparator = value;
			}
		}
		#endregion
	}
}