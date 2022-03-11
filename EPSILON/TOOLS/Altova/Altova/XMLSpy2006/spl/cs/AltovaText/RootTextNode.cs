[call GenerateFileHeader("RootTextNode.cs")]
namespace Altova.TextParser
{
	/// <summary>
	/// Encapsulates the root node of a <see cref="TextNode"/> hierarchy.
	/// </summary>
	public class RootTextNode : TextNode
	{
		#region Implementation Detail:
		ITextNode mInnerNode = NullTextNode.Instance;
		char mDecimalSeparator = '.';
		#endregion
		#region Public Interface:
		/// <summary>
		/// Get/sets the decimal separator to be used by the nodes in this hierarchy.
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
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="innernode">the node this instance should wrap</param>
		public RootTextNode(ITextNode innernode) : base(NullTextNode.Instance, innernode.Name)
		{
			mInnerNode = innernode;
			mInnerNode.Parent = this;
		}
		#endregion
		#region Overriding TextNode:
		/// <summary>
		/// See <see cref="TextNode.Name"/>.
		/// </summary>
		public override string Name
		{
			get
			{
				return mInnerNode.Name;
			}
			set
			{
				mInnerNode.Name = value;
			}
		}
		/// <summary>
		/// See <see cref="TextNode.Value"/>.
		/// </summary>
		public override string Value
		{
			get
			{
				return mInnerNode.Value;
			}
			set
			{
				mInnerNode.Value = value;
			}
		}
		/// <summary>
		/// See <see cref="TextNode.Children"/>.
		/// </summary>
		public override ITextNodeCollection Children
		{
			get
			{
				return mInnerNode.Children;
			}
		}
		/// <summary>
		/// See <see cref="TextNode.Parent"/>.
		/// </summary>
		public override ITextNode Parent
		{
			get
			{
				return null;
			}
			set
			{} // no-op
		}
		/// <summary>
		/// See <see cref="TextNode.Root"/>.
		/// </summary>
		public override ITextNode Root
		{
			get
			{
				return this;
			}
		}
		#endregion
	}
}