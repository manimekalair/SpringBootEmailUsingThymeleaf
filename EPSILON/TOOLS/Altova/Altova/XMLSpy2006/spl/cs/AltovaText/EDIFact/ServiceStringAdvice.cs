[call GenerateFileHeader("ServiceStringAdvice.cs")]
using System.IO;

namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Encapsulates a service string advice (UNA) segment.
	/// </summary>
	public class ServiceStringAdvice
	{
		#region Implementation Detail:
		char mComponentSeparator = ':';
		char mDataElementSeparator = '+';
		char mSegmentTerminator = '\\'';
		char mReleaseCharacter = '?';
		char mDecimalSeparator = '.';
		#endregion
		#region Public Interface:
		/// <summary>
		/// Get/sets the composite data element separator.
		/// </summary>
		public char ComponentSeparator
		{
			get
			{
				return mComponentSeparator;
			}
			set
			{
				mComponentSeparator = value;
			}
		}
		/// <summary>
		/// Get/sets the data element separator.
		/// </summary>
		public char DataElementSeparator
		{
			get
			{
				return mDataElementSeparator;
			}
			set
			{
				mDataElementSeparator = value;
			}
		}
		/// <summary>
		/// Get/sets the segment terminator.
		/// </summary>
		public char SegmentTerminator
		{
			get
			{
				return mSegmentTerminator;
			}
			set
			{
				mSegmentTerminator = value;
			}
		}
		/// <summary>
		/// Get/sets the release character.
		/// </summary>
		public char ReleaseCharacter
		{
			get
			{
				return mReleaseCharacter;
			}
			set
			{
				mReleaseCharacter = value;
			}
		}
		/// <summary>
		/// Get/sets the decimal separator.
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
		/// <summary>
		/// Sets all members from a character array.
		/// </summary>
		/// <param name="rhs">the character array to set from</param>
		public void SetFromCharArray(char\[\] rhs)
		{
			mComponentSeparator = rhs\[0\];
			mDataElementSeparator = rhs\[1\];
			mDecimalSeparator = rhs\[2\];
			mReleaseCharacter = rhs\[3\];
			mSegmentTerminator = rhs\[5\];
		}
		/// <summary>
		/// Serializes this instance in EDIFact format to a stream.
		/// </summary>
		/// <param name="stream">the stream to serialize to</param>
		public void Serialize(TextWriter stream)
		{
			stream.Write("UNA");
			stream.Write(mComponentSeparator);
			stream.Write(mDataElementSeparator);
			stream.Write(mDecimalSeparator);
			stream.Write(mReleaseCharacter);
			stream.Write(' ');
			stream.Write(mSegmentTerminator);
		}
		#endregion
	}
}