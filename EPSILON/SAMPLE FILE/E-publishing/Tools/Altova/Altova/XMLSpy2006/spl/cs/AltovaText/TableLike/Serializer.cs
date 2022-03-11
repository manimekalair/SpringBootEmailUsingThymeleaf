[call GenerateFileHeader("Serializer.cs")]
using System;
using System.IO;
using System.Text;

namespace Altova.TextParser.TableLike
{
	/// <summary>
	/// Defines the methods expected from a class for de/serializing from/to a certain format.
	/// </summary>
	public interface ISerializer
	{
		/// <summary>
		/// Serializes to a file.
		/// </summary>
		/// <param name="filename">the path of the file to serialize to</param>
		void Serialize(string filename);
		/// <summary>
		/// Deserializes from a file.
		/// </summary>
		/// <param name="filename">the path of the file to deserialize from</param>
		void Deserialize(string filename);
		/// <summary>
		/// Get/sets the encoding to be used for de/serializing.
		/// </summary>
		string CodePage { get; set; }
	}

	/// <summary>
	/// Encapsulates common functionality needed by concrete implementations of <see cref="ISerializer"/>.
	/// </summary>
	public abstract class Serializer : ISerializer
	{
		#region Implementation Detail:
		Table mTable = null;
		TextWriter mStream = null;
		string mCodePage = "UTF-8";

		void OnRecordFound(Record record)
		{
			if (this.DoStoreRecord(record))
				mTable.Add(record);
		}
		string LoadFileContents(string filename)
		{
			try
			{
				Encoding encoding = Encoding.GetEncoding(mCodePage);
				if (File.Exists(filename))
				{
					using (StreamReader sr = new StreamReader(filename, encoding))
						return sr.ReadToEnd();
				}
				else
					throw new FileNotFoundException("File does not exist.", filename);
			}
			catch (NotSupportedException x)
			{
				throw new MappingException("Codepage " + mCodePage.ToString() +
					" is not supported on this system. Loading '" + filename + "' failed.", x);
			}
			catch (Exception x)
			{
				throw new MappingException("File contents could not be loaded.", x);
			}
		}
		#endregion
		#region Public Interface:
		#endregion
		#region Descendant Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="table">the table to be used for de/serializing</param>
		protected Serializer(Table table)
		{
			mTable = table;
		}
		/// <summary>
		/// Gets the table to be used for de/serializing.
		/// </summary>
		protected Table Table
		{
			get
			{
				return mTable;
			}
		}
		/// <summary>
		/// Gets the stream to be written to.
		/// </summary>
		protected TextWriter Stream
		{
			get
			{
				return mStream;
			}
		}
		#endregion
		#region Descendant Obligations:
		/// <summary>
		/// Does the actual serializing after the stream has already been opened and initialized.
		/// Does not need to catch exceptions as this will be done when calling this method.
		/// </summary>
		protected abstract void DoSerialize();
		/// <summary>
		/// Creates a concrete parser to be used.
		/// </summary>
		/// <returns>the concrete parser</returns>
		protected abstract RecordBasedParser CreateParser();
		/// <summary>
		/// Asks a descendant class whether a specific record should be stored in the table.
		/// </summary>
		/// <param name="record">the record in question</param>
		/// <returns>true if the record is to be stored in the table, otherwise false</returns>
		protected abstract bool DoStoreRecord(Record record);
		#endregion
		#region ISerializer Members:
		/// <summary>
		/// See <see cref="ISerializer.Serialize"/>().
		/// </summary>
		/// <param name="filename">See <see cref="ISerializer.Serialize"/>().</param>
		public void Serialize(string filename)
		{
			try
			{
				Encoding encoding = Encoding.GetEncoding(mCodePage);
				using (mStream = new StreamWriter(filename, false, encoding))
					this.DoSerialize();
			}
			catch (NotSupportedException x)
			{
				throw new MappingException("Codepage " + mCodePage.ToString() +
					" is not supported on this system. Saving '" + filename + "' failed.", x);
			}
			catch (Exception x)
			{
				throw new MappingException("'" + filename + "' could not be saved to CSV format.", x);
			}
		}
		/// <summary>
		/// See <see cref="ISerializer.Deserialize"/>().
		/// </summary>
		/// <param name="filename">See <see cref="ISerializer.Deserialize"/>().</param>
		public void Deserialize(string filename)
		{
			mTable.Clear();
			RecordBasedParser parser = this.CreateParser();
			parser.OnRecordFound = new RecordFoundDelegate(this.OnRecordFound);
			string buffer = this.LoadFileContents(filename);
			parser.Parse(buffer);
		}
		/// <summary>
		/// See <see cref="ISerializer.CodePage"/>.
		/// </summary>
		public string CodePage
		{
			get
			{
				return mCodePage;
			}
			set
			{
				mCodePage = value;
				if ("UTF-16" == mCodePage) mCodePage = "UTF-16BE";
			}
		}
		#endregion
	}

}