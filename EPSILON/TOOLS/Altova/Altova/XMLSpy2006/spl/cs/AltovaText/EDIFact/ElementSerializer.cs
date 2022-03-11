[call GenerateFileHeader("ElementSerializer.cs")]
using System;
using System.IO;

namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Encapsulates serializing to EDIFact.
	/// </summary>
	public class ElementSerializer
	{
		#region Implementation Detail:
		ServiceStringAdvice mUNA;
		TextWriter mStream;
		bool mTerminateSegmentsWithExtraLinefeeds= true;

		void SerializeDataElementAsString(string value)
		{
			if (mUNA.ReleaseCharacter==' ')
				SerializeString(value);
			else
			{
				string escapedvalue = "";
				foreach (char c in value)
				{
					if ((c == mUNA.ComponentSeparator) ||
						(c == mUNA.DataElementSeparator) ||
						(c == mUNA.ReleaseCharacter) ||
						(c == mUNA.SegmentTerminator))
						escapedvalue += mUNA.ReleaseCharacter;
					escapedvalue += c;
				}
				SerializeString(escapedvalue);
			}
		}

		void SerializeDataElementAsDecimal(string value)
		{
			string decimalvalue = value.Replace('.', mUNA.DecimalSeparator);
			SerializeString(decimalvalue);
		}

		void SerializeString(string value)
		{
			mStream.Write(value);
		}

		void SerializeGenericDataElement(ITextNode node)
		{
			if (node.HasDecimalData)
				SerializeDataElementAsDecimal(node.Value);
			else if (node.Name!="FI15")
				SerializeDataElementAsString(node.Value);
			else SerializeString(node.Value);
		}

		void SerializeGenericComposite(ITextNode node)
		{
			SerializeGenericGroup(node);
		}

		void SerializeGenericSegment(ITextNode node)
		{
			SerializeString(node.NativeName);
			if (0<node.Children.Count)
			{
				mStream.Write(mUNA.DataElementSeparator);
				SerializeGenericGroup(node);
			}
			mStream.Write(mUNA.SegmentTerminator);
			if (mTerminateSegmentsWithExtraLinefeeds) mStream.Write('\\n');
		}

		void SerializeGenericGroup(ITextNode node)
		{
			ITextNodeCollection children = node.Children;
			int size = children.Count;
			if (0 == size) return;
			uint firstposition= children\[0\].PositionInFather;
			if (0!=firstposition)
			{
				string separators= children\[0\].PrecedingSeparators;
				int separatorlength= separators.Length;
				int count= Math.Min(separatorlength, (int) firstposition);
				if (0<count)
				{
					string tmp= separators.Substring(0, count); 
					tmp= tmp.Replace('0', mUNA.DataElementSeparator).Replace('1', mUNA.ComponentSeparator);
					SerializeString(tmp);
				}
			}
			for (int i= 0; i<size-1; ++i)
			{
				ITextNode first= children\[i\];
				ITextNode next= children\[i+1\];
				SerializeNode(first);
				WriteSeparatorsInBetween(first, next);
			}
			SerializeNode(children\[size-1\]);
		}
		void WriteSeparatorsInBetween(ITextNode left, ITextNode right)
		{
			int posleft= (int) left.PositionInFather;
			int posright= (int) right.PositionInFather;
			string separators= left.FollowingSeparators;

			if( separators.Length == 0
			&&  left.Name == right.Name 
			&&  left.Class == NodeClass.Composite
			&&  right.Class == NodeClass.Composite )
			{
				separators = "0";
				posright = posleft + 1;
			}

			if( separators.Length == 0
			&&  left.Name == right.Name
			&&  left.Class == NodeClass.DataElement
			&&  right.Class == NodeClass.DataElement )
			{
				if( left .Parent.Class == NodeClass.Composite
				&&  right.Parent.Class == NodeClass.Composite)
				{
					separators = "1";	// insert the composite separator
				}
				else
				{
					separators = "0";	// insert the data element separator
				}
				posright = posleft + 1;
			}

			if( posleft == posright
			&&	left.Name == right.Name
			&&  left.Class == NodeClass.DataElement
			&&  right.Class == NodeClass.DataElement )
			{
				posright = posleft + 1;
			}

			if (0==separators.Length) return;

			for (int i= posleft; i<posright; ++i)
			{
				char separator= TranslateSeparator(separators\[i-posleft\]);
				mStream.Write(separator);
			}
		}
		char TranslateSeparator(char rhs)
		{
			char result= rhs;
			switch (rhs)
			{
				case '0':
					result= mUNA.DataElementSeparator;
					break;
				case '1':
					result= mUNA.ComponentSeparator;
					break;
			}
			return result;
		}

		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="stream">the streamt to serialize to</param>
		/// <param name="una">the service string advice to use</param>
		/// <param name="mterminatesegmentswithextralinefeeds">whether to terminate
		/// segments with an extra linefeed for better human readability or not</param>
		public ElementSerializer(TextWriter stream, ServiceStringAdvice una,
			bool mterminatesegmentswithextralinefeeds)
		{
			mStream = stream;
			mUNA = una;
			mTerminateSegmentsWithExtraLinefeeds = mterminatesegmentswithextralinefeeds;
		}
		/// <summary>
		/// Serializes a node and its children to EDIFact format.
		/// </summary>
		/// <param name="node">the node to be serialized</param>
		public void SerializeNode(ITextNode node)
		{
			switch (node.Class)
			{
				case NodeClass.DataElement:
					SerializeGenericDataElement(node);
					break;
				case NodeClass.Composite:
					SerializeGenericComposite(node);
					break;
				case NodeClass.Segment:
					SerializeGenericSegment(node);
					break;
				default:
					SerializeGenericGroup(node);
					break;
			}
		}
		#endregion
	}
}