[call GenerateFileHeader("Exceptions.cs")]
using System;

namespace Altova.TextParser
{
	/// <summary>
	/// Encapsulates the base exception of all exceptions used by the parsing and mapping code.
	/// </summary>
	public class MappingException : ApplicationException
	{
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="msg">the message of the exception</param>
		public MappingException(string msg) : base(msg)
		{}
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="msg">the message of the exception</param>
		/// <param name="innerexception">the inner exception</param>
		public MappingException(string msg, Exception innerexception) : base(msg, innerexception)
		{}
	}
}