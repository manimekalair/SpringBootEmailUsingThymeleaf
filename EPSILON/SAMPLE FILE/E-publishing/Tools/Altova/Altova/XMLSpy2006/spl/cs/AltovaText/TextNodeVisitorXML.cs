[call GenerateFileHeader("TextNodeVisitorXML.cs")]
using System.IO;

namespace Altova.TextParser
{
	/// <summary>
	/// Encapsulates dumping a tree of <see cref="ITextNode"/>s as XML to a <see cref="TextWriter"/>.
	/// </summary>
	public class TextNodeVisitorXML
	{
		#region Implementation Detail:
		TextWriter mStream = null;

		void WriteStartTag(string sName)
		{
			mStream.Write("<" + sName + ">");
		}
		void WriteValue(string sValue)
		{
			mStream.Write(sValue);
		}
		void WriteEndTag(string sName)
		{
			mStream.Write("</" + sName + ">");
		}
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="stream">the stream to write to</param>
		public TextNodeVisitorXML(TextWriter stream)
		{
			mStream = stream;
			mStream.Write("<?xml version=\\"1.0\\" encoding=\\"UTF-8\\"?>");
		}
		/// <summary>
		/// Serializes a <see cref="ITextNode"/> and its children.
		/// </summary>
		/// <param name="node">the node to be serialized</param>
		public void Serialize(ITextNode node)
		{
			string name = node.Name;
			if (null != name)
			{
				this.WriteStartTag(name);
				string val = node.Value;
				if (null != val) this.WriteValue(val);
				foreach (ITextNode child in node.Children)
					Serialize(child);
				this.WriteEndTag(name);
			}
		}
		#endregion
	}
}