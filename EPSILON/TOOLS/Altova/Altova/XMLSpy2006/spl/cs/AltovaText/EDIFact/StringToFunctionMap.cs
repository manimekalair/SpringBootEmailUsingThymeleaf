[call GenerateFileHeader("StringToFunctionMap.cs")]
using System;
using System.Collections;
using System.Diagnostics;

namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Encapsulates a mapping of strings to <see cref="BaseFunction"/>s or their derivatives.
	/// </summary>
	public class StringToFunctionMap
	{
		#region Implementation Detail:
		Hashtable mStringToFunctionsMap = new Hashtable();
		#endregion
		#region Public Interface:
		/// <summary>
		/// Adds a new mapping.
		/// </summary>
		/// <param name="name">the string to which the function should be mapped</param>
		/// <param name="function">the function being mapped to the string</param>
		public void Add(string name, BaseFunction function)
		{
			try
			{
				mStringToFunctionsMap.Add(name, function);
			}
			catch (ArgumentException)
			{
				/* TODO: discuss whether such a warning is enough; before it was written to the console which
				 * definitely is not a good idea because the library doesn't need to be used in a context where
				 * a console is available. But, besides, just writing out a warning is probably not enough
				 * to really alert a user of this library that somethings going wrong.
				*/
				Trace.WriteLine("Warning: Redefinition of BaseFunction '" + name + "'");
			}
		}
		/// <summary>
		/// Gets the function mapped to a given name.
		/// </summary>
		/// <remarks>
		/// If the name is empty or if the name contains just a newline or a carriage return character,
		/// a new function is returned which has the type <see cref="BaseFunction"/>.
		/// </remarks>
		public BaseFunction this\[string name\]
		{
			get
			{
				if (0 == name.Length) return new BaseFunction();
				if (("\\n" == name) || ("\\r" == name)) return new BaseFunction();
				return (BaseFunction) mStringToFunctionsMap\[name\];
			}
		}
		/// <summary>
		/// Clears all contained mappings.
		/// </summary>
		public void Clear()
		{
			mStringToFunctionsMap.Clear();
		}
		#endregion
	}
}