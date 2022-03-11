[call GenerateFileHeader("TextNodeCollection.cs")]
using System.Collections;

namespace Altova.TextParser
{
	/// <summary>
	/// Enumerates over a <see cref="TextNodeCollection"/>.
	/// </summary>
	public class TextNodeCollectionEnumerator : IEnumerator
	{
		#region Implementation Detail:
		IEnumerator mInternalEnumerator = null;
		#endregion
		#region Package Interface:
		internal TextNodeCollectionEnumerator(IEnumerator internalenumerator)
		{
			mInternalEnumerator = internalenumerator;
		}
		#endregion
		#region IEnumerator Members
		/// <summary>
		/// See <see cref="IEnumerator.Reset"/>().
		/// </summary>
		public void Reset()
		{
			mInternalEnumerator.Reset();
		}
		/// <summary>
		/// See <see cref="IEnumerator.Current"/>.
		/// </summary>
		object IEnumerator.Current
		{
			get
			{
				return mInternalEnumerator.Current;
			}
		}
		/// <summary>
		/// See <see cref="IEnumerator.MoveNext"/>().
		/// </summary>
		public bool MoveNext()
		{
			return mInternalEnumerator.MoveNext();
		}
		#endregion
		#region Public Interface:
		/// <summary>
		/// Gets the current text node.
		/// </summary>
		public ITextNode Current
		{
			get
			{
				return this.Current;
			}
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a strongly typed collection of <see cref="TextNode"/> objects.
	/// </summary>
	public class TextNodeCollection : ITextNodeCollection
	{
		#region Implementation Detail:
		ArrayList mList = new ArrayList();
		ITextNode mOwner = null;
		Hashtable mNameToNamedNodes= new Hashtable();

		void AddToTable(ITextNode rhs)
		{
			string name = rhs.NativeName;
			if (name.Length == 0)
				name = rhs.Name;

			if (!mNameToNamedNodes.ContainsKey(name))
				mNameToNamedNodes.Add(name, new ArrayList());
			ArrayList listofnamednodes= mNameToNamedNodes\[name\] as ArrayList;
			listofnamednodes.Add(rhs);
		}
		void RemoveFromTable(ITextNode rhs)
		{
			string name = rhs.NativeName;
			if (name.Length == 0)
				name = rhs.Name;
			
			ArrayList listofnamednodes= mNameToNamedNodes\[name\] as ArrayList;
			listofnamednodes.Remove(rhs);
		}
		#endregion
		#region Package Interface:
		internal TextNodeCollection(ITextNode owner)
		{
			mOwner = owner;
		}
		#endregion
		#region ITextNodeCollection Members:
		/// <summary>
		/// Gets the number of nodes directly contained in this instance.
		/// </summary>
		public virtual int Count
		{
			get
			{
				return mList.Count;
			}
		}
		/// <summary>
		/// Get/sets a node contained in this instance per index.
		/// </summary>
		public virtual ITextNode this\[int index\]
		{
			get
			{
				if ((0 > index) || (index >= mList.Count))
					return NullTextNode.Instance;
				return (ITextNode) mList\[index\];
			}
			set
			{
				if ((0 <= index) || (index < mList.Count))
					mList\[index\] = value;
			}
		}
		/// <summary>
		/// Gets all direct children matching the specified name.
		/// </summary>
		/// <param name="name">the name to match</param>
		/// <returns>a collection of nodes matching the name</returns>
		public virtual ITextNode\[\] FilterByName(string name)
		{
			ArrayList namedlist= mNameToNamedNodes\[name\] as ArrayList;
			if (null==namedlist) return new ITextNode\[0\];
			
			ITextNode\[\] result= new ITextNode\[namedlist.Count\];
			namedlist.CopyTo(result, 0);
			return result;
		}
		/// <summary>
		/// Tries to add a node to this instance.
		/// </summary>
		/// <param name="rhs">the node to add</param>
		/// <returns>true if the node was added, otherwise false</returns>
		/// <remarks>
		/// If rhs is null, it won't be added.
		/// If rhs is already contained in the instance or somewhere in the tree formed by all
		/// the contained nodes and their descendants, it won't be added (in order to avoid cyclic
		/// references).
		/// Adding a node will automatically set its <see cref="TextNode.Parent"/> to the owner of this
		/// instance.
		/// </remarks>
		public virtual bool Add(ITextNode rhs)
		{
			if (null == rhs) return false;
			mList.Add(rhs);
			AddToTable(rhs);
			rhs.Parent = mOwner;
			return true;
		}
		/// <summary>
		/// Inserts a node at a given position.
		/// </summary>
		/// <param name="rhs">the node to be inserted</param>
		/// <param name="index">the position where to insert the node</param>
		public virtual void Insert(ITextNode rhs, int index)
		{
			mList.Insert(index, rhs);
			AddToTable(rhs);
			rhs.Parent = mOwner;
		}
		/// <summary>
		/// Checks whether a node is already contained, either directly or as a child, grandchild etc.
		/// of one of the contained nodes.
		/// </summary>
		/// <param name="rhs">the node to check for</param>
		/// <returns>true if the node is already contained, otherwise false</returns>
		public virtual bool Contains(ITextNode rhs)
		{
			foreach (ITextNode n in this)
			{
				if (n.Equals(rhs)) return true;
				if (n.Children.Contains(rhs)) return true;
			}
			return false;
		}
		/// <summary>
		/// Removes the node at the specified index from this instance.
		/// </summary>
		/// <param name="index">the index</param>
		public void RemoveAt(int index)
		{
			RemoveFromTable(this\[index\]);
			mList.RemoveAt(index);
		}
		#endregion
		#region IEnumerable Members
		/// <summary>
		/// See <see cref="IEnumerable.GetEnumerator"/>().
		/// </summary>
		/// <returns>See <see cref="IEnumerable.GetEnumerator"/>().</returns>
		public IEnumerator GetEnumerator()
		{
			return new TextNodeCollectionEnumerator(mList.GetEnumerator());
		}
		#endregion
	}
}