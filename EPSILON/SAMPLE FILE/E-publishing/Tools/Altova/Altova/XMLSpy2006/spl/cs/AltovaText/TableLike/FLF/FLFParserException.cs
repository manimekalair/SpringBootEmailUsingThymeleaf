[call GenerateFileHeader("FLFParserException.cs")]
namespace Altova.TextParser.TableLike.FLF
{
	/// <summary>
	/// Encapsulates an exception thrown by <see cref="FLFParser.Parse"/>() if
	/// there was a problem with the input format.
	/// </summary>
	/// <remarks>
	/// Check the <see cref="Offset"/> property to find out at which offset of the 
	/// input data the problem was encountered.
	/// </remarks>
	public class FLFParserException : MappingException
	{
		#region Implementation Detail:
		int mOffset = -1;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Gets the offset of where the exception was triggered inside the input data.
		/// </summary>
		public int Offset
		{
			get
			{
				return mOffset;
			}
		}
		internal FLFParserException(string message, int offset)
			: base(message + " at offset #" + offset.ToString())
		{
			mOffset = offset;
		}
		#endregion
	}
}