[call GenerateFileHeader("TextDocument.java")]
package com.altova.text.edifact;

import com.altova.text.*;

import java.io.OutputStreamWriter;
import java.io.IOException;

import com.altova.AltovaException;

public abstract class TextDocument {
	private String m_sProlog;

	private String m_sEpilog;

	private Generator m_Generator = new Generator();

	private StringToFunctionMap m_Functions = new StringToFunctionMap();

	private StringToFunctionMap m_Handlers = new StringToFunctionMap();

	private Scanner m_Scanner = new Scanner();

	private String m_StructureName = "";
		
	private String m_Encoding = "";

	private void executeFunction(String name) {
		if (null == name)
			return;
		Function function = m_Functions.get(name);
		if (null != function)
			function.execute(this);
		else
			throw (new AltovaException("Cannot find function: " + name));
	}

	public void setEncoding(String encoding) {
		m_Encoding = encoding;
	}
	
	private StringBuffer loadBufferFromFile(String filename) {
		StringBuffer result;
		try {
			FileIO io = new FileIO(filename, m_Encoding);
			result = io.readToEnd();
		} catch (IOException x) {
			throw new AltovaException(x);
		}
		int i = 0;
		while (Character.isWhitespace(result.charAt(i)))
			++i;
		if (i > 0)
			result.delete(0, i - 1);
		return result;
	}

	private void parse(String buffer) {
		m_Scanner.init(buffer);
		this.executeFunction(m_sProlog);
		for (short indicator = m_Scanner.scanExpression(); indicator != Scanner.END; indicator = m_Scanner
				.scanExpression()) {
			this.processToken(m_Scanner.getToken());
		}
		this.executeFunction(m_sEpilog);
		m_Generator.resetToRoot();
	}

	public Generator getGenerator() {
		return m_Generator;
	}

	public Scanner getScanner() {
		return m_Scanner;
	}

	public StringToFunctionMap getFunctions() {
		return m_Functions;
	}

	public StringToFunctionMap getHandlers() {
		return m_Handlers;
	}

	public String getStructureName() {
		return m_StructureName;
	}

	public void setStructureName(String rhs) {
		m_StructureName = rhs;
	}

	public void parseFile(String filename) throws Exception {
		StringBuffer buffer = loadBufferFromFile(filename);
		if (this.validateSource(buffer)) {
			this.parse(buffer.toString());
			this.validateResult();
		}
		if (null == m_Generator.getRootNode())
			throw new Exception("File could not be parsed.");
	}

	final protected static short EDIFact = 1;

	final protected static short EDIX12 = 2;

	protected abstract short getEDIKind();

	protected abstract boolean validateSource(StringBuffer source);

	protected boolean validateResult() {
		this.removeEmptyNodes(m_Generator.getRootNode());
		return true;
	}

	protected abstract void processToken(String token);

	protected abstract EDISettings getSettings();

	protected void recordDecimalSeparator() {
		RootTextNode root = m_Generator.getRootNode();
		root.setDecimalSeparator(m_Scanner.getDecimalSeparator());
	}

	protected String removeCRLF(StringBuffer buffer) {
		StringBuffer tmp = new StringBuffer();
		for (int i = 0; i < buffer.length(); ++i) {
			char c = buffer.charAt(i);
			switch (c) {
			case '\\r':
			case '\\n':
				break;
			default:
				tmp.append(c);
				break;
			}
		}
		return tmp.toString();
	}

	protected void removeAll(StringBuffer buffer, char what) {
		StringBuffer tmp= new StringBuffer();
		tmp.append(what);
		String lookfor = tmp.toString();
		int i = buffer.indexOf(lookfor);
		while (i>-1)
		{
			buffer.deleteCharAt(i);
			i = buffer.indexOf(lookfor);
		}
	}

	protected int countFormatCharacters(StringBuffer buffer, int numberofchars) {
		int charcount = 0;
		int buffercount;
		for (buffercount = 0; charcount != numberofchars; ++buffercount) {
			if ((buffer.charAt(buffercount) != '\\r')
					&& (buffer.charAt(buffercount) != '\\n'))
				++charcount;
		}

		return buffercount - charcount;
	}

	protected void prepareSource(StringBuffer buffer) {
		Scanner scanner = getScanner();
		char segmentterminator = scanner.getSeparatorMap()
				.getSeparatorForSymbolicName("segment");
		if (segmentterminator != '\\r')
			removeAll(buffer, '\\r');
		if (segmentterminator != '\\n')
			removeAll(buffer, '\\n');
	}

	protected void setProlog(String name) {
		m_sProlog = name;
	}

	protected void setEpilog(String name) {
		m_sEpilog = name;
	}

	public void save(ITextNode structureroot, String filename) throws Exception {
		TextNode root = m_Generator.getRootNode();

		if (getSettings().getAutoCompleteData()) {
			DataCompletion datacompletion = null;
			switch (getEDIKind()) {
			case EDIFact:
				datacompletion = new EDIFactDataCompletion(
						(EDIFactSettings) getSettings(), m_StructureName);
				break;
			case EDIX12:
				datacompletion = new EDIX12DataCompletion(
						(EDIX12Settings) getSettings(), m_StructureName);
				break;
			}
			datacompletion.completeData(root);
		}
		FileIO io = new FileIO (filename, m_Encoding);
		OutputStreamWriter writer = io.openWriteStream();
		if (EDIFact == getEDIKind()) {
			EDIFactSettings edifactsettings = (EDIFactSettings) getSettings();
			if (edifactsettings.getWriteUNA()) {
				getSettings().getServiceStringAdvice().serialize(writer);
				if (getSettings().getTerminateSegmentsWithLinefeed())
					writer.write('\\n');
			}
		}
		removeEmptyNodes(root);
		adjustDataToStructure(structureroot, root);
		EDIFactElementSerializer serializer = new EDIFactElementSerializer(
				writer, getSettings().getServiceStringAdvice(), getSettings()
						.getTerminateSegmentsWithLinefeed());
		serializer.serializeNode(root);
		writer.close();
	}

	private void adjustDataToStructure(ITextNode structureroot,
			ITextNode dataroot) {
		dataroot.setPositionInFather(structureroot.getPositionInFather());
		dataroot.setPrecedingSeparators(structureroot.getPrecedingSeparators());
		dataroot.setFollowingSeparators(structureroot.getFollowingSeparators());
		int dataindex = 0;
		int structureindex = 0;
		while (dataindex < dataroot.getChildren().size()) {
			ITextNode datakid = dataroot.getChildren().getAt(dataindex);
			while ((structureindex < structureroot.getChildren().size())
					&& (!structureroot.getChildren().getAt(structureindex).getName().equals(datakid.getName())))
				++structureindex;
			adjustDataToStructure(structureroot.getChildren().getAt(
					structureindex), dataroot.getChildren().getAt(dataindex));
			++dataindex;
		}
	}

	private boolean isEmptyDataElement(ITextNode node) {
		return ((ITextNode.DataElement == node.getNodeClass()) && (0 == node
				.getValue().length()));
	}

	private boolean isNodeContainerWithoutChildren(ITextNode node) {
		byte nodeClass = node.getNodeClass();
		return (nodeClass == ITextNode.Composite ||
				nodeClass == ITextNode.Group) &&
				(node.getChildren().size() == 0);
	}

	private void removeEmptyNodes(ITextNode node) {
		int i = 0;
		while (i < node.getChildren().size()) {
			ITextNode kid = node.getChildren().getAt(i);
			removeEmptyNodes(kid);
			if ((isEmptyDataElement(kid))
					|| (isNodeContainerWithoutChildren(kid)))
				node.getChildren().removeAt(i);
			else
				++i;
		}
	}
}
