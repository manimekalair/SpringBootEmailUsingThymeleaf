[call GenerateFileHeader("Table.cs")]
using System;
using System.Collections;

namespace Altova.TextParser.TableLike
{
	/// <summary>
	/// Encapsulates a table-like text format and its contents.
	/// </summary>
	public abstract class Table : IEnumerable, IDataElement
	{
		#region Implementation Detail:
		Header mHeader = new Header();
		ArrayList mRecords = new ArrayList();
		ISerializer mSerializer = null;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Gets the header used by this instance.
		/// </summary>
		public Header Header
		{
			get
			{
				return mHeader;
			}
		}
		/// <summary>
		/// Gets the number of records stored in this instance.
		/// </summary>
		public int Count
		{
			get
			{
				return mRecords.Count;
			}
		}
		/// <summary>
		/// Get/sets the encoding to be used for reading/writing data.
		/// </summary>
		public string Encoding
		{
			get
			{
				return mSerializer.CodePage;
			}
			set
			{
				mSerializer.CodePage = value;
			}
		}
		/// <summary>
		/// Adds a record to this instance.
		/// </summary>
		/// <param name="rhs">the record to add</param>
		public void Add(Record rhs)
		{
			mRecords.Add(rhs);
			rhs.Owner= this;
		}
		/// <summary>
		/// Gets a record containe by this instance per index.
		/// </summary>
		/// <param name="index">the index</param>
		public Record this\[int index\]
		{
			get
			{
				return (Record) mRecords\[index\];
			}
		}
		/// <summary>
		/// Clears this instance from all records.
		/// </summary>
		public void Clear()
		{
			mRecords.Clear();
		}
		/// <summary>
		/// Parses a file and reads the contained records into this instance.
		/// </summary>
		/// <param name="filename">the file whose contents are to be parsed and loaded</param>
		/// <exception cref="AltovaException">
		/// thrown when there is a problem with opening the file or parsing it
		/// </exception>
		public void Parse(string filename)
		{
			try
			{
				mSerializer.Deserialize(filename);
			}
			catch (MappingException x)
			{
				string msg = "";
				Exception tmp = x;
				while (null != tmp)
				{
					msg += tmp.Message;
					tmp = tmp.InnerException;
				}
				throw new AltovaException(msg);
			}
		}
		/// <summary>
		/// Saves the records contained in this instance into a file.
		/// </summary>
		/// <param name="filename">the file where to save the records to</param>
		/// <exception cref="AltovaException">
		/// thrown when there is a problem with opening or writing the file.
		/// </exception>
		public void Save(string filename)
		{
			try
			{
				mSerializer.Serialize(filename);
			}
			catch (MappingException x)
			{
				string msg = "";
				Exception tmp = x;
				while (null != tmp)
				{
					msg += tmp.Message;
					tmp = tmp.InnerException;
				}
				throw new AltovaException(msg);
			}
		}
		#endregion
		#region Descendant Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		protected Table()
		{
			this.InitHeader(mHeader);
			mSerializer = this.CreateSerializer();
		}
		#endregion
		#region Descendant Obligations:
		/// <summary>
		/// Create a format-specific concrete implementation of <see cref="ISerializer"/>.
		/// </summary>
		/// <returns>the concrete instance</returns>
		protected abstract ISerializer CreateSerializer();
		/// <summary>
		/// Initialize the <see cref="Header"/> with needed information like the name of columns etc.
		/// </summary>
		/// <param name="header">
		/// the header to fill, provided for comfort reasons, as descendant could just access the header via
		/// the property <see cref="Header"/>.
		/// </param>
		protected abstract void InitHeader(Header header);
		#endregion
		#region IEnumerable Members
		/// <summary>
		/// See <see cref="IEnumerable.GetEnumerator"/>().
		/// </summary>
		/// <returns>See <see cref="IEnumerable.GetEnumerator"/>().</returns>
		public IEnumerator GetEnumerator()
		{
			return mRecords.GetEnumerator();
		}
		#endregion
		#region IDataElement Members
		/// <summary>
		/// Implements <see cref="IDataElement.Name"/>.
		/// </summary>
		public string Name
		{
			get
			{
				return "Table";
			}
		}
		/// <summary>
		/// Implements <see cref="IDataElement.Value"/>.
		/// </summary>
		public string Value
		{
			get
			{
				return "";
			}
		}
		/// <summary>
		/// Implements <see cref="IDataElement.Children"/>.
		/// </summary>
		public IEnumerable Children
		{
			get
			{
				return mRecords;
			}
		}
		#endregion
	}
}