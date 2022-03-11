[call GenerateFileHeader("DataCompletion.cs")]
using System;

namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Encapsulates completing data.
	/// </summary>
	public abstract class DataCompletion
	{
		#region Implementation Detail:
		protected string mStructureName = "";
		#endregion
		#region Descendant interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="structurename">the name of the structure to complete</param>
		protected DataCompletion(string structurename)
		{
			mStructureName = structurename;
		}
		/// <summary>
		/// Checks whether a node has a kid by a certain name.
		/// </summary>
		/// <param name="node">the node to check</param>
		/// <param name="name">the name to check for</param>
		/// <returns>true if the node has a kid named as specified, otherwise false</returns>
		protected static bool HasKid(ITextNode node, string name)
		{
			return (0 < node.Children.FilterByName(name).Length);
		}
		/// <summary>
		/// Returns a kid of a node by name.
		/// </summary>
		/// <param name="node">the node</param>
		/// <param name="name">the name of the kid to be returned</param>
		/// <returns>the named kid or (NEW!) NullNode if none was found</returns>
		protected static ITextNode GetKid(ITextNode node, string name)
		{
			ITextNode\[\]  kids = node.Children.FilterByName(name);
			if (kids.Length == 0)
				return NullTextNode.Instance;
			return kids\[0\];
		}
		/// <summary>
		/// Sets the value of a node if it is yet empty.
		/// </summary>
		/// <param name="node">the node whose value is to be set</param>
		/// <param name="value">the new value</param>
		protected static void ConservativeSetValue(ITextNode node, string value)
		{
			if (0 == node.Value.Length)
				node.Value = value;
		}
		/// <summary>
		/// Gets the name of the structure this instance will complete.
		/// </summary>
		protected string StructureName
		{
			get
			{
				return mStructureName;
			}
		}
		/// <summary>
		/// Formats the current data in a way suitable for EDI messages.
		/// </summary>
		/// <returns>the formatted date string</returns>
		protected static string GetCurrentTimeAsEDIString()
		{
			return DateTime.Now.ToString("HHmm");
		}
		/// <summary>
		/// Formats the current time in a way suitable for EDI messages.
		/// </summary>
		/// <returns>the formatted time string</returns>
		protected static string GetCurrentDateAsEDIString()
		{
			return DateTime.Now.ToString("yyMMdd");
		}
		/// <summary>
		/// Counts (recursively) all children of a node which are segment nodes.
		/// </summary>
		/// <param name="node">the node whose children to count</param>
		/// <returns>the number of children being segment nodes</returns>
		protected long GetSegmentChildrenCount(ITextNode node)
		{
			long result = (NodeClass.Segment == node.Class) ? 1 : 0;
			foreach (ITextNode kid in node.Children)
				result += GetSegmentChildrenCount(kid);
			return result;
		}
		#endregion
		#region Descendant obligations:
		/// <summary>
		/// Completes the hierarchy of nodes rooted in the passed node.
		/// </summary>
		/// <param name="dataroot">the root of the nodes to be completed</param>
		public abstract void CompleteData(ITextNode dataroot);
		#endregion
	}
}