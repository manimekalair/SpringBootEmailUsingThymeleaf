[call GenerateFileHeader("DocumentFragment.cs")]
using Altova.TextParser;
using System;
using System.Text;

namespace Altova.TextParser.Flex
{
	/// <summary>
	/// document reader context
	/// </summary>
	public class DocumentReader
	{
		private Range range;
		private Generator outputGenerator;
		
		/// <summary>
		/// constructor
		/// </summary>
		public  DocumentReader(string content, Generator generator)
		{
			outputGenerator = generator;
			range = new Range(content);
		}
		
		/// <summary>
		/// copy constructor
		/// </summary>
		public DocumentReader(DocumentReader doc)
		{
			range = new Range(doc.GetRange());
			outputGenerator = doc.GetOutputTree();
		}
		
		/// <summary>
		/// constructs new document reader from given document reader and given range
		/// </summary>
		public DocumentReader(DocumentReader doc, Range range)
		{
			this.range = new Range(range);
			outputGenerator = doc.GetOutputTree();
		}
		
		/// <summary>
		/// returns output generator
		/// </summary>
		public Generator GetOutputTree() 
		{
			return outputGenerator;
		}
		
		/// <summary>
		/// returns document's range
		/// </summary>
		public Range GetRange() 
		{
			return range;
		}
	}
		
	/// <summary>
	///  document writer context
	/// </summary>
	public class DocumentWriter : Appender
	{
		private ITextNode tree;
		private ITextNode currentNode;
		private StringBuilder content;
			
		/// <summary>
		///  constructor
		/// </summary>
		public DocumentWriter(ITextNode tree, StringBuilder buff)
		{
			this.tree = tree;
			this.content = buff;
			this.currentNode = tree;
		}
			
		/// <summary>
		///  returns input tree (node)
		/// </summary>
		public ITextNode GetInputTree()
		{
			return tree;
		}
	
		/// <summary>
		///  returns current node
		/// </summary>
		public ITextNode GetCurrentNode()
		{
			return currentNode;
		}
	
		/// <summary>
		///  appends text to content
		/// </summary>
		public void AppendText(string text)
		{
			content.Append(text);
		}
	}
}
