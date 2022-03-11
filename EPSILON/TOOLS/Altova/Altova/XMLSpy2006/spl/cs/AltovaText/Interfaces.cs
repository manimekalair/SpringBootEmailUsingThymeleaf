[call GenerateFileHeader("Interfaces.cs")]
using System.Collections;

namespace Altova.TextParser
{
	/// <summary>
	/// Encapsulates the kind a <see cref="ITextNode"/> has.
	/// </summary>
	public enum NodeClass
	{
		/// <summary>
		/// The class has not been initialized.
		/// </summary>
		Undefined,
		/// <summary>
		/// The <see cref="ITextNode"/> represents a data element.
		/// </summary>
		DataElement,
		/// <summary>
		/// The <see cref="ITextNode"/> represents a composite.
		/// </summary>
		Composite,
		/// <summary>
		/// The <see cref="ITextNode"/> represents a segment.
		/// </summary>
		Segment,
		/// <summary>
		/// The <see cref="ITextNode"/> represents a group.
		/// </summary>
		Group
	}

	/// <summary>
	/// Defines the properties and methods making up a text node.
	/// </summary>
	public interface ITextNode
	{
		/// <summary>
		/// Gets the root node of this instance.
		/// </summary>
		ITextNode Root { get; }
		/// <summary>
		/// Get/sets the parent node of this instance.
		/// </summary>
		ITextNode Parent { get; set; }
		/// <summary>
		/// Looks for a node with a specified name in the ancestry of this instance.
		/// </summary>
		/// <param name="name">the name to find a node for</param>
		/// <returns>the node found</returns>
		ITextNode SearchUpwardsByName(string name);
		/// <summary>
		/// Gets a collection containing all the child nodes of this instance.
		/// </summary>
		ITextNodeCollection Children { get; }
		/// <summary>
		/// Get/sets the name of this instance.
		/// </summary>
		string Name { get; set; }
		/// <summary>
		/// Get/sets the value of this instance.
		/// </summary>
		string Value { get; set; }
		/// <summary>
		/// Gets whether this instance is a null object.
		/// </summary>
		bool IsNull { get; }
		/// <summary>
		/// Get/sets the kind of this instance.
		/// </summary>
		NodeClass Class { get; set; }
		/// <summary>
		/// Get/sets whether this instance contains decimal data. Only makes sense if <see cref="Class"/> 
		/// returns <see cref="NodeClass.DataElement"/>.
		/// </summary>
		bool HasDecimalData { get; set; }
		/// <summary>
		/// Get/sets the maximum length the <see cref="Value"/> of this instance may have. Only makes sense
		/// if <see cref="Class"/> returns <see cref="NodeClass.DataElement"/>.
		/// </summary>
		uint MaximumLength { get; set; }
		/// <summary>
		/// Get/sets the native name of this instance. The native name is the name used in
		/// the EDI specifications.
		/// </summary>
		string NativeName { get; set; }
		/// <summary>
		/// Get/sets the separators that potentially could follow this instance.
		/// </summary>
		string FollowingSeparators { get; set;}
		/// <summary>
		/// Get/sets the separators that potentially could precede this instance.
		/// </summary>
		string PrecedingSeparators { get; set;}
		/// <summary>
		/// Get/sets the position of this instance in its father's children.
		/// </summary>
		uint PositionInFather {get; set;}
	}

	/// <summary>
	/// Defines the properties and methods making up a container of <see cref="ITextNode"/>s.
	/// </summary>
	public interface ITextNodeCollection : IEnumerable
	{
		/// <summary>
		/// Gets the number of contained <see cref="ITextNode"/>s.
		/// </summary>
		int Count { get; }
		/// <summary>
		/// Get/sets contained <see cref="ITextNode"/>s per index.
		/// </summary>
		ITextNode this\[int index\] { get; set; }
		/// <summary>
		/// Filters the contained nodes by their name.
		/// </summary>
		/// <param name="name">nodes whose name not equals this parameter will be filtered out</param>
		/// <returns>a new collection containing all the nodes not filtered out</returns>
		ITextNode\[\] FilterByName(string name);
		/// <summary>
		/// Adds a new <see cref="ITextNode"/> to the collection.
		/// </summary>
		/// <param name="rhs">the node to be added</param>
		/// <returns>
		/// true if successful, false if the node is already contained in the collection or in the
		/// children of one of the contained nodes
		/// </returns>
		bool Add(ITextNode rhs);
		/// <summary>
		/// Inserts a node at a given position.
		/// </summary>
		/// <param name="rhs">the node to be inserted</param>
		/// <param name="index">the position where to insert the node</param>
		void Insert(ITextNode rhs, int index);
		/// <summary>
		/// Checks whether a node is already contained, either directly or as a child, grandchild etc.
		/// of one of the contained nodes.
		/// </summary>
		/// <param name="rhs">the node to check for</param>
		/// <returns>true if the node is already contained, otherwise false</returns>
		bool Contains(ITextNode rhs);
		/// <summary>
		/// Removes the node at the specified index from this instance.
		/// </summary>
		/// <param name="index">the index</param>
		void RemoveAt(int index);
	}
}