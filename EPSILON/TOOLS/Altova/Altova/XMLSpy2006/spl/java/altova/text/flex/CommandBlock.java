[call GenerateFileHeader("CommandBlock.java")]
package com.altova.text.flex;

import com.altova.text.*;

public class CommandBlock extends Command {
	public CommandBlock(String name) {
		super(name);
	}
	
	public boolean readText(DocumentReader doc) {
		doc.getOutputTree().enterElement(getName(), ITextNode.Group);
		super.readText(doc);
		doc.getOutputTree().leaveElement(getName());
		return true;
	}
	
	public boolean writeText(DocumentWriter doc) {
		TextNodeList children = doc.getCurrentNode().getChildren().filterByName(getName());
		for (int i = 0; i < children.size(); ++i)
		{
			StringBuffer restStr = new StringBuffer();
			DocumentWriter restDoc = new DocumentWriter(children.getAt(i), restStr);
			super.writeText(doc);
			doc.appendText(restStr);
		}
		return true;
	}
}
