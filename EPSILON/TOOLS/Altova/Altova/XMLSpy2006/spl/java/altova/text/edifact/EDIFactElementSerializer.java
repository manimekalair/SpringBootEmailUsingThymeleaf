[call GenerateFileHeader("EDIFactElementSerializer.java")]
package com.altova.text.edifact;

import com.altova.text.*;

import java.io.IOException;
import java.io.Writer;
import java.lang.StringBuffer;

public class EDIFactElementSerializer {
	private ServiceStringAdvice m_ServiceStringAdvice = null;

	private Writer m_Stream;

	private boolean m_TerminateSegmentsWithExtraLinefeed = true;

	private void serializeDataElementAsString(String value) throws IOException {
		if (m_ServiceStringAdvice.getReleaseCharacter() == ' ')
			serializeString(value);
		else {
			StringBuffer escapedvalue = new StringBuffer();
			for (int i = 0; i < value.length(); ++i) {
				char c = value.charAt(i);
				if ((c == m_ServiceStringAdvice.getComponentSeparator())
						|| (c == m_ServiceStringAdvice
								.getDataElementSeparator())
						|| (c == m_ServiceStringAdvice.getReleaseCharacter())
						|| (c == m_ServiceStringAdvice.getSegmentTerminator()))
					escapedvalue.append(m_ServiceStringAdvice.
							getReleaseCharacter());
				escapedvalue.append(c);
			}
			serializeString(escapedvalue.toString());
		}
	}

	private static String removeUnneededZeroes(String value) {
		boolean negative = value.startsWith("-");
		int start = negative ? 1 : 0;
		int last = value.length() - 1;
		while ((start < last) && (value.charAt(start) == '0') && (value.charAt(start+1) != '.'))
			++start;
		if (value.indexOf('.', start) > 0) {
			while ((last > start) && (value.charAt(last) == '0'))
				--last;
			if (value.charAt(last) == '.')
				--last;
		}
		return (negative ? "-" : "") + value.substring(start, last+1);
	}

	private void serializeDataElementAsDecimal(String value) throws IOException {
		String decimalvalue = removeUnneededZeroes(value);
		decimalvalue = decimalvalue.replace('.', m_ServiceStringAdvice.getDecimalSeparator());
		serializeString(decimalvalue);
	}

	private void serializeString(String value) throws IOException {
		m_Stream.write(value);
	}

	private void serializeGenericDataElement(ITextNode node) throws IOException {
		if (node.hasDecimalData())
			serializeDataElementAsDecimal(node.getValue());
		else if (!node.getName().equals("FI15"))
			serializeDataElementAsString(node.getValue());
		else
			serializeString(node.getValue());
	}

	private void serializeGenericComposite(ITextNode node) throws IOException {
		serializeGenericGroup(node);
	}

	private void serializeGenericSegment(ITextNode node) throws IOException {
		serializeString(node.getNativeName());
		if (0 < node.getChildren().size()) {
			m_Stream.write(m_ServiceStringAdvice.getDataElementSeparator());
			serializeGenericGroup(node);
		}
		m_Stream.write(m_ServiceStringAdvice.getSegmentTerminator());
		if (m_TerminateSegmentsWithExtraLinefeed)
			m_Stream.write('\\n');
	}

	private void serializeGenericGroup(ITextNode node) throws IOException {
		ITextNodeList children = node.getChildren();
		int size = children.size();
		if (0 == size)
			return;

		int firstposition = children.getAt(0).getPositionInFather();
		if (0 != firstposition) {
			String separators = children.getAt(0).getPrecedingSeparators();
			int separatorlength = separators.length();
			int count = Math.min(separatorlength, firstposition);
			if (0 < count) {
				String tmp = "";
				for (int i = 0; i < count; ++i) {
					tmp += translateSeparator(separators.charAt(i));
				}
				m_Stream.write(tmp);
			}
		}
		for (int i = 0; i < size - 1; ++i) {
			ITextNode first = children.getAt(i);
			ITextNode next = children.getAt(i + 1);
			serializeNode(first);
			writeSeparatorsInBetween(first, next);
		}
		serializeNode(children.getAt(size - 1));

	}

	private void writeSeparatorsInBetween(ITextNode left, ITextNode right)
			throws IOException {
		int posleft = left.getPositionInFather();
		int posright = right.getPositionInFather();
		String separators = left.getFollowingSeparators();

		if( 0 == separators.length()
		&&  left.getName().equals(right.getName())
		&&  left.getNodeClass() == ITextNode.Composite
		&&  right.getNodeClass() == ITextNode.Composite )
		{
			separators = "0";
			posright = posleft + 1;
		}

		if( 0 == separators.length()
		&&  left.getName().equals(right.getName())
		&&  left.getNodeClass() == ITextNode.DataElement
		&&  right.getNodeClass() == ITextNode.DataElement )
		{
			if( left .getParent().getNodeClass() == ITextNode.Composite
			&&  right.getParent().getNodeClass() == ITextNode.Composite)
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
		&&	left.getName().equals(right.getName())
		&&  left.getNodeClass() == ITextNode.DataElement
		&&  right.getNodeClass() == ITextNode.DataElement )
		{
			posright = posleft + 1;
		}

		if (0 == separators.length())
			return;

		for (int i = posleft; i < posright; ++i) {
			char separator = translateSeparator(separators.charAt(i - posleft));
			m_Stream.write(separator);
		}

	}

	private char translateSeparator(char rhs) {
		char result = rhs;
		switch (rhs) {
		case '0':
			result = m_ServiceStringAdvice.getDataElementSeparator();
			break;
		case '1':
			result = m_ServiceStringAdvice.getComponentSeparator();
			break;
		}
		return result;
	}

	public EDIFactElementSerializer(Writer stream,
			ServiceStringAdvice servicestringadvice,
			boolean terminatesegmentswithextralinefeed) {
		m_ServiceStringAdvice = servicestringadvice;
		m_Stream = stream;
		m_TerminateSegmentsWithExtraLinefeed = terminatesegmentswithextralinefeed;
	}

	public void serializeNode(ITextNode node) throws IOException {
		switch (node.getNodeClass()) {
		case ITextNode.DataElement:
			serializeGenericDataElement(node);
			break;
		case ITextNode.Composite:
			serializeGenericComposite(node);
			break;
		case ITextNode.Segment:
			serializeGenericSegment(node);
			break;
		default:
			serializeGenericGroup(node);
			break;
		}
	}
}
