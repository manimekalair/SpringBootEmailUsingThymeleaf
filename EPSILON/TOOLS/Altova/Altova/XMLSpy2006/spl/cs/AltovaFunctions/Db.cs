//
// Db.cs
//
// This file was generated by [=$Host].
//
// YOU SHOULD NOT MODIFY THIS FILE, BECAUSE IT WILL BE
// OVERWRITTEN WHEN YOU RE-RUN CODE GENERATION.
//
// Refer to the [=$HostShort] Documentation for further details.
// [=$HostURL]
//

using System;
using Altova.Types;

namespace Altova.Functions 
{
	public class Db
	{
		// private static Hashtable _s_InstanceIDs = new Hashtable();	// not used at the moment

		#region null processing functions

		/// <summary> 
		/// result = setNull( )
		/// Result is a NULLed string
		/// </summary>
		public static SchemaString SetNull() 
		{
			SchemaString sRes = new  SchemaString();
			sRes.SetNull( true ); 
			return sRes;
		}

		#endregion 

	}
}