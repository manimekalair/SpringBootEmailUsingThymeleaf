[call GenerateFileHeader("CommandCSV.java")]
package com.altova.text.flex;

import java.util.ArrayList;
import com.altova.text.*;

public class CommandCSV extends Command {
	private ColumnDelimited\[\] columns;
	private boolean columnHeaders;
	private String rowDelimiter;
	private String colDelimiter;
	private char quoteChar;
	private char escapeChar;
	private char rowSep0;
	private char colSep0;
	
	public CommandCSV(String name, ColumnDelimited\[\] columns, boolean headers, String rowSep, String colSep, char quote, char escape) {
		super(name);
		this.columns = columns;
		this.columnHeaders = headers;
		this.rowDelimiter = rowSep;
		this.colDelimiter = colSep;
		this.quoteChar = quote;
		this.escapeChar = escape;
		this.rowSep0 = this.rowDelimiter.charAt(0);
		this.colSep0 = this.colDelimiter.charAt(0);
	}
	
	public boolean readText(DocumentReader doc) {
		Range range = new Range(doc.getRange());
		int nColumns = columns.length;
		
		if (columnHeaders) {
			SplitAtDelimiter splitAtFirstLine = new SplitAtDelimiter(rowDelimiter);
			Range firstLine = splitAtFirstLine.split(range);
		}
				
		while (range.isValid()) {
			ArrayList values = readNextRow(range);
			
			doc.getOutputTree().enterElement(getName(), ITextNode.Group);
			for (int col = 0; col < Math.min(nColumns, values.size()); ++col) {
				if (col >= 0 && col < nColumns && columns\[col\].next != null) {
					DocumentReader cell = new DocumentReader(values.get(col).toString(), doc.getOutputTree());
					columns\[col\].next.readText(cell);
				}
			}
			doc.getOutputTree().leaveElement(getName());
		}
		return true;
	}
	
	public boolean writeText(DocumentWriter doc) {
		if (columnHeaders) {
			for (int col = 0; col < columns.length; ++col) {
				if (col != 0)
					doc.appendText(colDelimiter);
				doc.appendText(quoteIfNeeded(columns\[col\].name));
			}
			doc.appendText(rowDelimiter);
		}

		TextNodeList children = doc.getCurrentNode().getChildren().filterByName(getName());
		for (int row = 0; row < children.size(); ++row) {
			ITextNode rowNode = children.getAt(row);

			for (int col = 0; col < columns.length; ++col) {
				if (col != 0)
					doc.appendText(colDelimiter);

				if (columns\[col\].next != null) {
					StringBuffer cellString = new StringBuffer();
					DocumentWriter cellDoc = new DocumentWriter(rowNode, cellString);
					columns\[col\].next.writeText(cellDoc);
					doc.appendText(quoteIfNeeded(cellString.toString()));
				}
			}
			doc.appendText(rowDelimiter);
		}
		return true;
	}

	private ArrayList readNextRow(Range range) {
		ArrayList result = new ArrayList();
		
		boolean moreColumns = true;
		while (moreColumns && range.isValid()) {
			StringBuffer value = new StringBuffer();
			moreColumns = readNextCell(range, value);
			result.add(value);
		}
		return result;
	}
	
	private boolean readNextCell(Range range, StringBuffer value) {
		boolean insideQuotes = false;
		boolean escaped = false;
		value.setLength(0);
		int p = range.start;
		
		for (; p!= range.end; ++p) {
			if (range.charAt(p) == rowSep0 && !insideQuotes && delimiterMatches(range, p, rowDelimiter)) {
				range.start = p + rowDelimiter.length();
				return false; // last column
			}
			
			if (range.charAt(p) == colSep0 && !insideQuotes && delimiterMatches(range, p, colDelimiter)) {
				range.start = p + colDelimiter.length();
				return true; // more columns follow
			}
			
			if (range.charAt(p) == escapeChar && !escaped && insideQuotes) {
				escaped = true;
				continue;
			}
			
			if (range.charAt(p)  == quoteChar && !escaped) {
				insideQuotes = !insideQuotes;
				continue;
			}
			
			value.append(range.charAt(p));
			escaped = false;
		}
		
		range.start = p;
		return false; // incomplete row, no more columns
	}

	private boolean delimiterMatches(Range range, int p, String delimiter) {
		return delimiter.length() <= (range.end - p) && range.getContent().regionMatches(p, delimiter, 0, delimiter.length());
	}
	
	private String quoteIfNeeded(String str) {
		if (quoteChar == '\\0')
			return str;
		int p = str.indexOf(quoteChar);
		if (p == -1)
			p = str.indexOf(colDelimiter);
		if (p == -1)
			p = str.indexOf(rowDelimiter);
		if (p != -1)
		{
			StringBuffer result = new StringBuffer();
			result.append(quoteChar);
			result.append(str.substring(0, p));
			for (; p != str.length(); ++p)
			{
				if (str.charAt(p) == quoteChar || str.charAt(p) == escapeChar)
					result.append(escapeChar == '\\0' ? quoteChar : escapeChar);
				result.append(str.charAt(p));
			}
			result.append(quoteChar);
			return result.toString();
		}
		return str;
	}
}
