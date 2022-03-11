[call GenerateFileHeader("TextDocument.cs")]
using Altova.TextParser;

using System;
using System.IO;
using System.Text;

namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Encapsulates the different EDI standards.
	/// </summary>
	public enum EDIStandard
	{
		/// <summary>
		/// UN/EDIFact standard
		/// </summary>
		EDIFact,
		/// <summary>
		/// The American EDI/X12 standard.
		/// </summary>
		EDIX12
	}

	/// <summary>
	/// Encapsulates parsing a complex text format file.
	/// </summary>
	public abstract class TextDocument
	{
		#region Implementation Detail:
		string mProlog;
		string mEpilog;
		Generator mGenerator = new Generator();
		StringToFunctionMap mFunctions = new StringToFunctionMap();
		StringToFunctionMap mHandlers = new StringToFunctionMap();
		Scanner mScanner = new Scanner();
		string mCodePage = "UTF-8";
		string mStructureName = "";

		string RemoveAll(string buffer, char what)
		{
			StringBuilder result= new StringBuilder();
			foreach (char c in buffer)
			{
				if (c!=what) result.Append(c);
			}
			return result.ToString();
		}
		void ExecuteFunction(string name)
		{
			if (null == name) return;
			BaseFunction function = mFunctions\[name\];
			if (null != function)
				function.Execute(this);
			else
				throw new AltovaException("Cannot find function: " + name);
		}
		void LoadFileIntoBuffer(string filename, out string buffer)
		{
			try
			{
				System.Text.Encoding encoding = System.Text.Encoding.GetEncoding(mCodePage);
				if (File.Exists(filename))
				{
					using (StreamReader sr = new StreamReader(filename, encoding))
						buffer = sr.ReadToEnd();
					return;
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
		void Parse(string buffer)
		{
			mScanner.Init(buffer);
			this.ExecuteFunction(mProlog);
			for (Scanner.Indicator indicator = mScanner.Scan();
				indicator != Altova.TextParser.EDIFACT.Scanner.Indicator.End; // using full name to prevent CS0572 in .Net Studio 2002
				indicator = mScanner.Scan())
				this.ProcessToken(mScanner.Token);
			this.ExecuteFunction(mEpilog);
			mGenerator.ResetToRoot();
		}
		void AdjustDataToStructure(ITextNode structureroot, ITextNode dataroot)
		{
			dataroot.PositionInFather= structureroot.PositionInFather;
			dataroot.PrecedingSeparators= structureroot.PrecedingSeparators;
			dataroot.FollowingSeparators= structureroot.FollowingSeparators;
			int dataindex= 0;
			int structureindex= 0;
			while (dataindex<dataroot.Children.Count)
			{
				ITextNode datakid= dataroot.Children\[dataindex\];
				while ((structureindex<structureroot.Children.Count) && 
					   (structureroot.Children\[structureindex\].Name!=datakid.Name))
					++structureindex;
				System.Diagnostics.Debug.Assert(structureindex<structureroot.Children.Count);
				AdjustDataToStructure(structureroot.Children\[structureindex\], dataroot.Children\[dataindex\]);
				++dataindex;
			}
		}
		bool IsEmptyDataElement(ITextNode node)
		{
			return ((NodeClass.DataElement==node.Class) && (0==node.Value.Length));
		}
		bool IsContainerNodeWithoutChildren(ITextNode node)
		{
			return (node.Class == NodeClass.Composite || node.Class == NodeClass.Group) && (node.Children.Count == 0);
		}
		void RemoveEmptyNodes(ITextNode node)
		{
			int i = 0;
			while (i<node.Children.Count)
			{
				ITextNode kid= node.Children\[i\];
				RemoveEmptyNodes(kid);
				if ((IsEmptyDataElement(kid)) || (IsContainerNodeWithoutChildren(kid)))
					node.Children.RemoveAt(i);
				else
					++i;
			}
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
				return mCodePage;
			}
			set
			{
				mCodePage = value;
			}
		}
		/// <summary>
		/// Get/sets the name of the EDIFact structure represented by this instance.
		/// </summary>
		public string StructureName
		{
			get
			{
				return mStructureName;
			}
			set
			{
				mStructureName = value;
			}
		}
		/// <summary>
		/// Gets the scanner used by this instance.
		/// </summary>
		public Scanner Scanner
		{
			get
			{
				return mScanner;
			}
		}
		/// <summary>
		/// Gets the generator used by this instance.
		/// </summary>
		public Generator Generator
		{
			get
			{
				return mGenerator;
			}
		}
		/// <summary>
		/// Gets the functions used by this instance.
		/// </summary>
		public StringToFunctionMap Functions
		{
			get
			{
				return mFunctions;
			}
		}
		/// <summary>
		/// Gets the handlers used by this instance.
		/// </summary>
		public StringToFunctionMap Handlers
		{
			get
			{
				return mHandlers;
			}
		}
		/// <summary>
		/// Loads and parses the file specified.
		/// </summary>
		/// <param name="filename">the name of the file to read</param>
		/// <returns>the root node of the parsed hierarchy</returns>
		/// <exception cref="AltovaException">thrown when there is a problem with loading/reading the file</exception>
		/// <exception cref="MappingException">thrown when the file could not be parsed</exception>
		public virtual void ParseFile(string filename)
		{
			string content;
			this.LoadFileIntoBuffer(filename, out content);
			if (this.ValidateSource(ref content))
			{
				this.Parse(content);
				this.ValidateResult();
			}
			if (null == mGenerator.RootNode)
				throw new MappingException("File could not be parsed.");
		}
		/// <summary>
		/// Saves the document in EDIFact format.
		/// </summary>
		/// <param name="filename">the file to save to</param>
		/// <param name="structureroot">the root node of the structure tree</param>
		public void Save(ITextNode structureroot, string filename)
		{
			RootTextNode root = mGenerator.RootNode;
			
			if (this.Settings.AutoCompleteData)
			{
				DataCompletion datacompletion = null;
				switch (this.Standard)
				{
				case EDIStandard.EDIFact:
					datacompletion = new EDIFactDataCompletion((EDIFactSettings) this.Settings, mStructureName);
					break;
				case EDIStandard.EDIX12:
					datacompletion = new EDIX12DataCompletion((EDIX12Settings) this.Settings, mStructureName);
					break;
				}
				datacompletion.CompleteData(root);
			}

			
			StreamWriter writer;
			try
			{
				System.Text.Encoding encoding = System.Text.Encoding.GetEncoding(mCodePage);
				writer = new StreamWriter(filename, false, encoding);
			}
			catch (NotSupportedException x)
			{
				throw new MappingException("Codepage " + mCodePage.ToString() +
					" is not supported on this system. Saving '" + filename + "' failed.", x);
			}
			catch (Exception x)
			{
				throw new MappingException("'" + filename + "' could not be saved.", x);
			}
			
			if (EDIStandard.EDIFact == this.Standard)
			{
				EDIFactSettings edifactsettings= (EDIFactSettings) this.Settings;
				if (edifactsettings.WriteUNA)
				{
					this.Settings.ServiceStringAdvice.Serialize(writer);
					if (this.Settings.TerminateSegmentsWithLinefeed) writer.Write('\\n');
				}
			}
			RemoveEmptyNodes(root);
			AdjustDataToStructure(structureroot, root);
			ElementSerializer serializer = new ElementSerializer(writer, this.Settings.ServiceStringAdvice, this.Settings.TerminateSegmentsWithLinefeed);
			serializer.SerializeNode(root);
			writer.Close();
		}
		#endregion
		/// <summary>
		/// Validates the results of parsing.
		/// </summary>
		/// <returns>true if validation was sucessful, otherwise false</returns>
		protected virtual bool ValidateResult()
		{
			RemoveEmptyNodes(mGenerator.RootNode);
			return true;
		}
		#region Descendant Obligations:
		/// <summary>
		/// Validates and, possibly, changes the buffer read from an input file.
		/// </summary>
		/// <param name="buffer">the buffer</param>
		/// <returns>true if the buffer could successfully be validated, otherwise false</returns>
		protected abstract bool ValidateSource(ref string buffer);
		/// <summary>
		/// Processes each token as it is found by the scanner.
		/// </summary>
		/// <param name="token">the token found</param>
		protected abstract void ProcessToken(string token);
		/// <summary>
		/// Gets the settings to be used by this instance.
		/// </summary>
		protected abstract EDISettings Settings { get; }
		/// <summary>
		/// Gets the standard this instance uses.
		/// </summary>
		protected abstract EDIStandard Standard { get; }
		#endregion
		#region Descendant Interface:
		/// <summary>
		/// Get/sets the name of the prolog function.
		/// </summary>
		/// <remarks>
		/// The prolog function is executed before scanning the input for tokens. <seealso cref="Epilog"/>
		/// </remarks>
		protected string Prolog
		{
			get
			{
				return mProlog;
			}
			set
			{
				mProlog = value;
			}
		}
		/// <summary>
		/// Get/sets the name of the epilog function.
		/// </summary>
		/// <remarks>
		/// The epilog function is executed after scanning the input for tokens <seealso cref="Prolog"/>
		/// </remarks>
		protected string Epilog
		{
			get
			{
				return mEpilog;
			}
			set
			{
				mEpilog = value;
			}
		}
		/// <summary>
		/// Removes all carriage return and all line feed characters from a string.
		/// </summary>
		/// <param name="buffer">the source string</param>
		/// <returns>a version of buffer without any CR/LF characters</returns>
		protected static string RemoveCRLF(string buffer)
		{
			StringBuilder result = new StringBuilder(buffer.Length);
			foreach (char c in buffer)
			{
				switch(c)
				{
					case '\\n':
					case '\\r':
						break;
					default:
						result.Append(c);
						break;
				}
			}
			return result.ToString();
		}
		/// <summary>
		/// Counts all carriage return and linefeed characters in a buffer.
		/// </summary>
		/// <param name="buffer">the buffer for which to count</param>
		/// <param name="numberofchars">how many non-CR/LFs to expect</param>
		/// <returns>the number of CR/LFs</returns>
		protected static int CountFormatCharacters(string buffer, int numberofchars)
		{
			int charcount= 0;
			int buffercount;
			for (buffercount= 0; charcount!=numberofchars; ++buffercount)
			{
				if ((buffer\[buffercount\]!='\\r') && (buffer\[buffercount\]!='\\n'))
					++charcount;
			}
			return buffercount - charcount;
		}
		/// <summary>
		/// Removes all carriage return and line feed characters if they are not used as separators.
		/// </summary>
		/// <param name="buffer">the buffer from which to remove</param>
		/// <returns>a changed version of buffer</returns>
		protected String PrepareSource(String buffer)
		{
			char segmentterminator= mScanner.GetSeparatorByName("segment");
			if ((segmentterminator=='\\r') || (segmentterminator=='\\n'))
				return buffer;
			else
				return RemoveCRLF(buffer);
			/*
			string result= buffer;
			if (segmentterminator != '\\r') 
				result= RemoveAll(buffer, '\\r');
			if (segmentterminator != '\\n')
				result = RemoveAll(buffer, '\\n');
			return result;
			*/
		}
		#endregion
	}
}