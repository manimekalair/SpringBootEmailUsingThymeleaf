[call GenerateFileHeader("IDataElement.cs")]
using System;
using System.Collections;

namespace Altova.TextParser
{
	/// <summary>
	/// Common interface for all generated types.
	/// </summary>
	public interface IDataElement
	{
		/// <summary>
		/// Gets the name of this instance.
		/// </summary>
		string Name {get;}
		/// <summary>
		/// Gets the value of this instance.
		/// </summary>
		string Value {get;}
		/// <summary>
		/// Gets all child elements of this instance.
		/// </summary>
		IEnumerable Children {get;}
	}
}
