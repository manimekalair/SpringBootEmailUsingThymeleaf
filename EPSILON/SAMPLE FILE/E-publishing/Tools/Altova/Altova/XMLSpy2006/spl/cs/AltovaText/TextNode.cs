[call GenerateFileHeader("TextNode.cs")]
namespace Altova.TextParser
{
	/// <summary>
	/// Encapsulates a text node in a tree as needed by parsing text input files.
	/// </summary>
	public class TextNode : ITextNode
	{
		#region Implementation Detail:
		ITextNode mParent = NullTextNode.Instance;
		string mName = "";
		string mValue = "";
		ITextNodeCollection mChildren = null;
		NodeClass mClass = NodeClass.Undefined;
		bool mHasDecimalData = false;
		uint mMaximumLength = 0;
		string mNativeName = "";
		string mPrecedingSeparators= "";
		string mFollowingSeparators= "";
		uint mPositionInFather= 0;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="parent">the parent of this node</param>
		/// <param name="name">the name this instance should have</param>
		/// <remarks>
		/// Note that this instance will be automatically added to the children of the specified parent
		/// unless it's null.
		/// </remarks>
		public TextNode(ITextNode parent, string name): this(parent, name, NodeClass.Undefined)
		{
		}
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="parent">the parent of this node</param>
		/// <param name="name">the name this instance should have</param>
		/// <param name="eClass">the name of the node's class</param>
		/// <remarks>
		/// Note that this instance will be automatically added to the children of the specified parent
		/// unless it's null.
		/// </remarks>
		public TextNode(ITextNode parent, string name, NodeClass eClass)
		{
			mName= name;
			mChildren = new TextNodeCollection(this);
			mParent = parent;
			mParent.Children.Add(this);
			mClass = eClass;
		}
		/// <summary>
		/// Gets the root node of the hierarchy where this instance resides.
		/// If this instance has no parent (<see cref="Parent"/>==null),
		/// it's its own root node.
		/// </summary>
		public virtual ITextNode Root
		{
			get
			{
				if (mParent.IsNull) return this;
				else return mParent.Root;
			}
		}
		/// <summary>
		/// Gets the parent node of this instance. May return null if the node has no parent.
		/// </summary>
		public virtual ITextNode Parent
		{
			get
			{
				return mParent;
			}
			set
			{
				mParent = value;
			}
		}
		/// <summary>
		/// Searches for a node with the specfied name moving upwards in the tree.
		/// </summary>
		/// <param name="name">the name of the node to search for</param>
		/// <returns>the first node matching the specified name or null if no match was found</returns>
		public virtual ITextNode SearchUpwardsByName(string name)
		{
			if (name == mName) return this;
			return mParent.SearchUpwardsByName(name);
		}
		/// <summary>
		/// Gets the children of this instance.
		/// </summary>
		public virtual ITextNodeCollection Children
		{
			get
			{
				return mChildren;
			}
		}
		/// <summary>
		/// Get/sets the name of this instance.
		/// </summary>
		public virtual string Name
		{
			get
			{
				return mName;
			}
			set
			{
				mName = value;
			}
		}
		/// <summary>
		/// Get/sets the value of this instance.
		/// </summary>
		public virtual string Value
		{
			get
			{
				return mValue;
			}
			set
			{
				mValue = value;
			}
		}

		/// <summary>
		/// Gets whether this instance is a null object.
		/// </summary>
		public bool IsNull
		{
			get
			{
				return false;
			}
		}
		/// <summary>
		/// Get/sets the kind of this instance.
		/// </summary>
		public NodeClass Class
		{
			get
			{
				return mClass;
			}
			set
			{
				mClass = value;
			}
		}
		/// <summary>
		/// Get/sets whether this instance contains decimal data. Only makes sense if <see cref="ITextNode.Class"/> 
		/// returns <see cref="NodeClass.DataElement"/>.
		/// </summary>
		public bool HasDecimalData
		{
			get
			{
				return mHasDecimalData;
			}
			set
			{
				mHasDecimalData = value;
			}
		}
		/// <summary>
		/// Get/sets the maximum length the <see cref="Value"/> of this instance may have.
		/// </summary>
		public uint MaximumLength
		{
			get
			{
				return mMaximumLength;
			}
			set
			{
				mMaximumLength = value;
			}
		}
		/// <summary>
		/// Get/sets the native name of this instance.
		/// </summary>
		public string NativeName
		{
			get
			{
				return mNativeName;
			}
			set
			{
				mNativeName = value;
			}
		}
		/// <summary>
		/// Get/sets the separators that potentially could precede this instance.
		/// </summary>
		public string PrecedingSeparators
		{
			get
			{
				return mPrecedingSeparators;
			}
			set
			{
				mPrecedingSeparators= value;
			}
		}
		/// <summary>
		/// Get/sets the separators that potentially could follow this instance.
		/// </summary>
		public string FollowingSeparators
		{
			get
			{
				return mFollowingSeparators;
			}
			set
			{
				mFollowingSeparators= value;
			}
		}
		/// <summary>
		/// Get/sets the position of this instance in its father's children.
		/// </summary>
		public uint PositionInFather
		{
			get
			{
				return mPositionInFather;
			}
			set
			{
				mPositionInFather= value;
			}
		}
		#endregion
	}

}