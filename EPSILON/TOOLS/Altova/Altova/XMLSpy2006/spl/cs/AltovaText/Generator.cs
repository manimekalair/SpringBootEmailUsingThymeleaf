[call GenerateFileHeader("Generator.cs")]
using System.IO;
namespace Altova.TextParser
{
	/// <summary>
	/// Encapsulates methods needed to build a tree of <see cref="TextNode"/>s,
	/// methods needed by some <see cref="Flex.Condition"/>s or <see cref="EDIFACT.ICondition"/>s and methods
	/// for saving the created tree to an XML file.
	/// </summary>
	public class Generator
	{
		#region Implementation Detail:
		ITextNode mCurrent = NullTextNode.Instance;

		void SwitchToParent()
		{
			if (!mCurrent.Parent.IsNull) mCurrent = mCurrent.Parent;
		}
		#endregion
		#region Public Interface:
		/// <summary>
		/// Initializes the generator.
		/// </summary>
		public void Init()
		{
			mCurrent = NullTextNode.Instance;
		}
		/// <summary>
		/// Resets the generator to the root node of the tree.
		/// </summary>
		public void ResetToRoot()
		{
			mCurrent = mCurrent.Root;
		}
		/// <summary>
		/// Adds a new node to the children of the current node and tries to assign it the specified name.
		/// </summary>
		/// <param name="name">the name to assign</param>
		/// <param name="eClass">the name of the node's class</param>
		/// <remarks>
		/// If the new node doesn't already have a name assigned, the current node will be set to
		/// the newly created.
		/// </remarks>
		public void EnterElement(string name, NodeClass eClass)
		{
			TextNode node = new TextNode(mCurrent, name, eClass);
			if (mCurrent.IsNull) node = new RootTextNode(node);
			mCurrent = node;
		}
		/// <summary>
		/// Leaves the current node by climbing upwards in the hierarchy.
		/// </summary>
		/// <param name="name">the name of the node to leave</param>
		/// <remarks>
		/// If name is an empty string, this instance climbs only one node.
		/// Otherwise, it searches the next node upwards the hierarchy matching the name.
		/// If found, it climbs to the <see cref="TextNode.Parent"/> of this node, otherwise
		/// it doesn't climb at all.
		/// </remarks>
		public void LeaveElement(string name)
		{
			// if the name is empty, just leave the current element, otherwise
			// move upwards inside the tree to the parent of the node with the specified name. 
			if (0 == name.Length) this.SwitchToParent();
			else
			{
				ITextNode namednode = mCurrent.SearchUpwardsByName(name);
				if (!namednode.IsNull)
				{
					mCurrent = namednode;
					this.SwitchToParent();
				}
			}
		}
		/// <summary>
		/// Inserts a new node into the hierarchy as the child of the current node and 
		/// assigns it the specified name and value.
		/// </summary>
		/// <param name="name">the name to assign</param>
		/// <param name="val">the value to assign</param>
		/// <param name="eClass">the name of the node's class</param>
		public void InsertElement(string name, string val, NodeClass eClass)
		{
			TextNode node = new TextNode(mCurrent, name, eClass);
			node.Value = val;
		}
		/// <summary>
		/// Checks whether the current node's name property equals the specified name.
		/// </summary>
		/// <param name="name">the name to compare to</param>
		/// <returns>true if the name matches, otherwise false</returns>
		public bool DoesNameEqual(string name)
		{
			return (name == mCurrent.Name);
		}
		/// <summary>
		/// Checks whether there is a node among the current node's children whose name
		/// matches a specified parameter. 
		/// </summary>
		/// <param name="name">the name to match</param>
		/// <returns>true if a child with matching name was found, otherwise false</returns>
		public bool DoesNamedChildExist(string name)
		{
			return (0 < mCurrent.Children.FilterByName(name).Length);
		}
		/// <summary>
		/// Gets the root node of the contained hierarchy. May be null.
		/// </summary>
		public RootTextNode RootNode
		{
			get
			{
				return mCurrent.Root as RootTextNode;
			}
		}
		/// <summary>
		/// Sets the root node of the contained hierarchy.
		/// </summary>
		/// <param name="rhs"></param>
		public void SetRootNode(ITextNode rhs)
		{
			mCurrent = new RootTextNode(rhs);
		}
		/// <summary>
		/// Gets the current node of the contained hierarchy. Maybe null.
		/// </summary>
		public ITextNode CurrentNode
		{
			get
			{
				return mCurrent;
			}
		}
		#endregion
		#region Internal interface:
		internal void Dump(string filename)
		{
			using (StreamWriter stream= new StreamWriter(filename))
			{
				TextNodeVisitorXML dumper= new TextNodeVisitorXML(stream);
				dumper.Serialize(RootNode);
			}
		}
		#endregion
	}
}