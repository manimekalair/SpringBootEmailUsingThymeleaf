[call GenerateFileHeader("BaseType.cs")]
using System.Collections;

namespace Altova.TextParser
{
	/// <summary>
	/// Serves as a base type for the generated types.
	/// </summary>
	public class BaseType : IDataElement
	{
		#region Implementation Detail:
		ITextNode mNode = NullTextNode.Instance;
		#endregion
		#region Descendant Interface:
		/// <summary>
		/// The node this instance represents.
		/// </summary>
		public ITextNode Node
		{
			get
			{
				return mNode;
			}
		}
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="node">the node this class should represent</param>
		protected BaseType(ITextNode node)
		{
			mNode = node;
		}
		/// <summary>
		/// Converts the value of a <see cref="TextNode"/> containing a EDIFact decimal separator
		/// to a string suitable for representing decimals in code.
		/// </summary>
		/// <param name="rhs">the node whose value to convert</param>
		/// <returns>the result of the conversion</returns>
		protected static string MakeDecimal(ITextNode rhs)
		{
			RootTextNode root = (RootTextNode) rhs.Root;
			return rhs.Value.Replace(root.DecimalSeparator, '.');
		}
		#endregion
		#region IDataElement Members
		/// <summary>
		/// Implementing <see cref="IDataElement.Name"/>.
		/// </summary>
		public string Name
		{
			get
			{
				return mNode.Name;
			}
		}
		/// <summary>
		/// Implementing <see cref="IDataElement.Value"/>.
		/// </summary>
		public string Value
		{
			get
			{
				return mNode.Value;
			}
		}
		/// <summary>
		/// Implementing <see cref="IDataElement.Children"/>.
		/// </summary>
		public IEnumerable Children
		{
			get
			{
				BaseType\[\] result= new BaseType\[mNode.Children.Count\];
				int i= 0;
				foreach (ITextNode node in mNode.Children)
				{
					result\[i++\]= new BaseType(node);
				}
				return result;
			}
		}
		#endregion
	}
}