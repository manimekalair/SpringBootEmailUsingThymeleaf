[call GenerateFileHeader("TextDocument.cs")]
using Altova.TextParser;
using System;
using System.IO;
using System.Text;

namespace Altova.TextParser.Flex
{
	/// <summary>
	/// Encapsulates parsing a complex text format file.
	/// </summary>
	public abstract class TextDocument
	{
		#region Implementation Detail:
		Generator generator = new Generator();
		string codePage = "UTF-8";
		/// <summary>
		/// root command
		/// </summary>
		protected CommandProject rootCommand;
		
		void LoadFileIntoBuffer(string filename, out string buffer)
		{
			try
			{
				if (File.Exists(filename))
				{
					Encoding encoding = System.Text.Encoding.GetEncoding(codePage);
					using (StreamReader sr = new StreamReader(filename, encoding))
						buffer = sr.ReadToEnd();
				}
				else
					throw new AltovaException("The file " + filename + " doesn't exist.");

			}
			catch (Exception x)
			{
				throw new AltovaException(x);
			}
		}
		
		void ParseString(string buffer)
		{
			if (rootCommand == null)
				throw new AltovaException("No syntax definition");
			DocumentReader doc  = new DocumentReader(buffer, generator);
			rootCommand.ReadText(doc);
		}

		#endregion
		#region Public Interface:
		
		/// <summary>
		/// Get/sets the encoding used by this instance.
		/// </summary>
		public string Encoding
		{
			get
			{
				return codePage;
			}
			set
			{
				codePage = value;
			}
		}
		
		/// <summary>
		/// Get/sets the generator used by this instance.
		/// </summary>
		public Generator Generator
		{
			get
			{
				return generator;
			}
		}
		/// <summary>
		/// Loads and parses the file specified.
		/// </summary>
		/// <param name="filename">the name of the file to read</param>
		/// <returns>the root node of the parsed hierarchy</returns>
		/// <exception cref="AltovaException">thrown when there is a problem with loading/reading the file</exception>
		/// <exception cref="MappingException">thrown when the file could not be parsed</exception>
		public virtual void Parse(string filename)
		{
			string content;
			this.LoadFileIntoBuffer(filename, out content);
			this.ParseString(content);
			if (null == generator.RootNode)
				throw new MappingException("File could not be parsed.");
		}
		/// <summary>
		/// Saves the text document
		/// </summary>
		/// <param name="filename">the file to save to</param>
		public void Save(string filename)
		{ 
			if (rootCommand == null)
				throw new AltovaException("No syntax definition");
			
			StringBuilder text = new StringBuilder();
			DocumentWriter doc = new DocumentWriter(generator.RootNode, text);
			rootCommand.WriteText(doc);
			
			StreamWriter writer;
			try
			{
				System.Text.Encoding encoding = System.Text.Encoding.GetEncoding(codePage);
				writer = new StreamWriter(filename, false, encoding);
			}
			catch (NotSupportedException x)
			{
				throw new MappingException("Codepage " + codePage.ToString() +
					" is not supported on this system. Saving '" + filename + "' failed.", x);
			}
			catch (Exception x)
			{
				throw new MappingException("'" + filename + "' could not be saved.", x);
			}
			writer.Write(text);
			writer.Close();
		}
		#endregion
	}
}
