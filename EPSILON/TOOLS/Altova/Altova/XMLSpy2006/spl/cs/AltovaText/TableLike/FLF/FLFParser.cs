[call GenerateFileHeader("FLFParser.cs")]
using System;

namespace Altova.TextParser.TableLike.FLF
{
	/// <summary>
	/// Encapsulates parsing a fixed length fields format.
	/// </summary>
	public class FLFParser : RecordBasedParser
	{
		#region Implementation Detail:
		FLFFormat mFormat = null;
		int mOffset = 0;
		int mMaxOffset = 0;
		string mBuffer = string.Empty;

		void ParseFields(string\[\] fields, int fieldcount)
		{
			if (mFormat.AssumeRecordDelimitersPresent)
			{
				int i=0;
				while (i < fieldcount)
				{
					int count = Header\[i\].Length;
					int recSepPos = mBuffer.IndexOf('\\r', mOffset, count);
					
					if (recSepPos != -1 && recSepPos-mOffset <= count)
					{
						count = recSepPos-mOffset;
						fields\[i\] = mBuffer.Substring(mOffset, count).TrimEnd(mFormat.FillCharacter);
						mOffset +=count;
						i++;
						break;
					}
					else
					{
						fields\[i\] = mBuffer.Substring(mOffset, count).TrimEnd(mFormat.FillCharacter);
						mOffset += count;
						i++;
					}
				}
				if (i < fieldcount)
					for (int j=i; j< fieldcount; j++)
						fields\[j\] = "";
			}
			else
			{
				for (int i = 0; i < fieldcount; ++i)
				{
					fields\[i\] = mBuffer.Substring(mOffset, Header\[i\].Length).TrimEnd(mFormat.FillCharacter);
					mOffset += Header\[i\].Length;
				}
			}
		}
		
		void ParseRecord()
		{
			string\[\] fields = new string\[Header.Count\];

			if (mFormat.AssumeRecordDelimitersPresent)
			{
				int maxfieldindex = Header.Count - 1;
				this.ParseFields(fields, maxfieldindex);
				int start = mOffset;
				this.MoveToNextRecordDelimiter();
				int len = Math.Min(mOffset - start, Header\[maxfieldindex\].Length);
				fields\[maxfieldindex\] = mBuffer.Substring(start, len).TrimEnd(mFormat.FillCharacter);
				this.SwallowTillNextRecord();
			}
			else this.ParseFields(fields, Header.Count);

			if (null != OnRecordFound) OnRecordFound(new Record(fields));
		}
		void MoveToNextNonRecordDelimiter()
		{
			while ((mOffset < mBuffer.Length) && (mFormat.IsRecordDelimiter(mBuffer\[mOffset\])))
				++mOffset;
		}
		void MoveToNextRecordDelimiter()
		{
			while ((mOffset < mBuffer.Length) && (!mFormat.IsRecordDelimiter(mBuffer\[mOffset\])))
				++mOffset;
		}
		void SwallowTillNextRecord()
		{
			this.MoveToNextRecordDelimiter();
			this.MoveToNextNonRecordDelimiter();
		}
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="format">the format information to be used by this instance</param>
		/// <param name="header">the header information to be used by this instance</param>
		public FLFParser(FLFFormat format, Header header) : base(header)
		{
			mFormat = format;
		}
		/// <summary>
		/// Gets the format specification the parser is using.
		/// </summary>
		public FLFFormat Format
		{
			get
			{
				return mFormat;
			}
		}
		#endregion
		#region Implementing RecordBasedParser:
		/// <summary>
		/// Parses a buffer as fixed length fields format.
		/// </summary>
		/// <param name="buffer">the buffer to parse</param>
		/// <returns>the number of records found</returns>
		public override int Parse(string buffer)
		{
			int result = 0;
			mBuffer = buffer;
			mMaxOffset = mBuffer.Length - Header.RecordLength;
			mOffset = 0;
			
			if (mFormat.AssumeRecordDelimitersPresent)
			{
				int minLength=0;
				for (int i = 0; i<Header.Count-1; i++)
					minLength += Header\[i\].Length;
				if (mBuffer.Length-2 < minLength)
					throw new FLFParserException("The input buffer is not long enough for even just one record.", mBuffer.Length);
			}
			else
				if (0 > mMaxOffset)
					throw new FLFParserException("The input buffer is not long enough for even just one record.", mBuffer.Length);
			do
			{
				this.ParseRecord();
				++result;
			}
			while (mOffset < mBuffer.Length);
			return result;
		}
		#endregion
	}
}