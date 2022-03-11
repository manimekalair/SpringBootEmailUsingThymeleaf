[call GenerateFileHeader("DataCompletion.java")]
package com.altova.text.edifact;

import com.altova.text.*;

import java.text.SimpleDateFormat;
import java.util.Date;

import javax.print.attribute.standard.DateTimeAtCompleted;

public abstract class DataCompletion {
	protected String m_StructureName = "";

	protected boolean hasKid(ITextNode node, String name) {
		return (0 < node.getChildren().filterByName(name).size());
	}

	protected ITextNode getKid(ITextNode node, String name) {
		return node.getChildren().filterByName(name).getAt(0);
	}

	protected void conservativeSetValue(ITextNode node, String value) {
		if (0 == node.getValue().length())
			node.setValue(value);
	}

	protected void conservativeSetValue(ITextNode node, char value) {
		if (0 == node.getValue().length()) {
			StringBuffer tmp = new StringBuffer();
			tmp.append(value);
			node.setValue(tmp.toString());
		}
	}

	protected void conservativeSetValue(ITextNode node, int value) {
		if (0 == node.getValue().length()) {
			StringBuffer tmp = new StringBuffer();
			tmp.append(value);
			node.setValue(tmp.toString());
		}
	}

	protected void conservativeSetValue(ITextNode node, long value) {
		if (0 == node.getValue().length()) {
			StringBuffer tmp = new StringBuffer();
			tmp.append(value);
			node.setValue(tmp.toString());
		}
	}

	protected String getStructureName() {
		return m_StructureName;
	}

	protected DataCompletion(String structurename) {
		m_StructureName = structurename;
	}

	public abstract void completeData(TextNode dataroot);

	protected String getCurrentDateAsEDIString() {
		Date now = new Date();
		SimpleDateFormat formatter = new SimpleDateFormat("yyMMdd");
		return formatter.format(now);
	}

	protected String getCurrentTimeAsEDIString() {
		Date now = new Date();
		SimpleDateFormat formatter = new SimpleDateFormat("HHmm");
		return formatter.format(now);
	}

	protected long getSegmentChildrenCount(ITextNode node) {
		long result = (ITextNode.Segment == node.getNodeClass()) ? 1 : 0;
		ITextNodeList children = node.getChildren();
		for (int i = 0; i < children.size(); ++i)
			result += getSegmentChildrenCount(children.getAt(i));
		return result;
	}
}
