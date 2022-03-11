[call GenerateFileHeader("NullTextNode.cs")]
namespace Altova.TextParser
{
	/// <summary>
	/// Encapsulates a null version of <see cref="TextNode"/>.
	/// </summary>
	public class NullTextNode : ITextNode
	{
		#region Implementation Detail:
		static NullTextNode sInstance = new NullTextNode();
		AlwaysEmptyTextNodeCollection mChildren = new AlwaysEmptyTextNodeCollection();
		string mName = "";
		string mValue = "";

		NullTextNode()
		{}
		#endregion
		#region Implementing ITextNode:
		/// <summary>
		/// Gets the root node of this instance.
		/// </summary>
		public ITextNode Root
		{
			get
			{
				return this;
			}
		}
		/// <summary>
		/// Get/sets the parent node of this instance.
		/// </summary>
		public ITextNode Parent
		{
			get
			{
				return this;
			}
			set
			{} // no-op
		}
		/// <summary>
		/// Looks for a node with a specified name in the ancestry of this instance.
		/// </summary>
		/// <param name="name">the name to find a node for</param>
		/// <returns>the node found</returns>
		public ITextNode SearchUpwardsByName(string name)
		{
			return this;
		}
		/// <summary>
		/// Gets a collection containing all the child nodes of this instance.
		/// </summary>
		public ITextNodeCollection Children
		{
			get
			{
				return mChildren;
			}
		}
		/// <summary>
		/// Get/sets the name of this instance.
		/// </summary>
		public string Name
		{
			get
			{
				return mName;
			}
			set
			{} // no-op
		}
		/// <summary>
		/// Get/sets the value of this instance.
		/// </summary>
		public string Value
		{
			get
			{
				return mValue;
			}
			set
			{} // no-op
		}

		/// <summary>
		/// Gets whether this instance is a null object.
		/// </summary>
		public bool IsNull
		{
			get
			{
				return true;
			}
		}
		/// <summary>
		/// Get/sets the kind of this instance.
		/// </summary>
		public NodeClass Class
		{
			get
			{
				return NodeClass.Undefined;
			}
			set
			{} // no-op
		}
		/// <summary>
		/// Get/sets whether this instance contains decimal data. Only makes sense if <see cref="ITextNode.Class"/> 
		/// returns <see cref="NodeClass.DataElement"/>.
		/// </summary>
		public bool HasDecimalData
		{
			get
			{
				return false;
			}
			set
			{} // no-op
		}
		/// <summary>
		/// Get/sets the maximum length the <see cref="ITextNode.Value"/> of this instance may have. Only makes sense
		/// if <see cref="ITextNode.Class"/> returns <see cref="NodeClass.DataElement"/>.
		/// </summary>
		public uint MaximumLength
		{
			get
			{
				return 0;
			}
			set
			{} // no-op
		}
		/// <summary>
		/// Get/sets the native name of this instance.
		/// </summary>
		public string NativeName
		{
			get
			{
				return mName;
			}
			set
			{} // no-op
		}
		/// <summary>
		/// Get/sets the separators that potentially could follow this instance.
		/// </summary>
		public string FollowingSeparators
		{
			get
			{
				return "";
			}
			set
			{} // no-op
		}
		/// <summary>
		/// Get/sets the separators that potentially could precede this instance.
		/// </summary>
		public string PrecedingSeparators
		{
			get
			{
				return "";
			}
			set
			{} // no-op
		}
		/// <summary>
		/// Get/sets the position of this instance in its father's children.
		/// </summary>
		public uint PositionInFather
		{
			get
			{
				return 0;
			}
			set
			{} // no-op
		}
		#endregion
		#region Public Interface:
		/// <summary>
		/// Gets the GOF-singleton instance of this class.
		/// </summary>
		public static NullTextNode Instance
		{
			get
			{
				return sInstance;
			}
		}
		#endregion
	}
}