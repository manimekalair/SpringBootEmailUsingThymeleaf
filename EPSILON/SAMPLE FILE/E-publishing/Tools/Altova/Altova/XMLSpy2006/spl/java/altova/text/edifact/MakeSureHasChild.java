[call GenerateFileHeader("MakeSureHasChild.java")]
package com.altova.text.edifact;

import com.altova.text.*;

class MakeSureHasChild {
	public static ITextNode at(ITextNode parent, String name,
			int possiblepositions\[\]) {
		ITextNode result = NullTextNode.getInstance();
		ITextNodeList children = parent.getChildren();
		for (int i = 0; (i < possiblepositions.length) && (result.isNull()); ++i) {
			int pos = possiblepositions\[i\];
			if (pos > children.size())
				pos = children.size() - 1;
			ITextNode kid = children.getAt(pos);
			if (kid.getName() == name)
				result = kid;
		}
		if (result.isNull()) {
			int pos = possiblepositions\[0\];
			if (pos > children.size())
				pos = children.size();
			result = new TextNode(result, name);
			result.setNativeName(name);
			if (name.equals("GS") || name.equals("GE") || name.equals("ST") || name.equals("SE"))
				result.setNodeClass(ITextNode.Segment);
			else if (name.startsWith("F"))
				result.setNodeClass(ITextNode.DataElement);
			else if (name.startsWith("S"))
				result.setNodeClass(ITextNode.Composite);
			else if ((name.startsWith("U")) && (3 == name.length()))
				result.setNodeClass(ITextNode.Segment);
			else if ((name.startsWith("I")) && (3 == name.length()))
				result.setNodeClass(ITextNode.Segment);
			else
				result.setNodeClass(ITextNode.Group);
			children.insertAt(result, pos);
		}
		return result;
	}

	public static ITextNode at(ITextNode parent, String name, int index) {
		int positions\[\] = new int\[1\];
		positions\[0\] = index;
		return at(parent, name, positions);
	}

	public static ITextNode asFirst(ITextNode parent, String name) {
		return at(parent, name, 0);
	}

	public static ITextNode asLast(ITextNode parent, String name) {
		return at(parent, name, 1000000);
	}
}
