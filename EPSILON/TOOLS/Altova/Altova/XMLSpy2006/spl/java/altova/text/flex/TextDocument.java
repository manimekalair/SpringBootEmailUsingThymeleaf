[call GenerateFileHeader("TextDocument.java")]
package com.altova.text.flex;

import java.io.IOException;

import com.altova.text.*;
import com.altova.AltovaException;

public abstract class TextDocument  {
	private Generator generator = new Generator();
	protected CommandProject rootCommand;
	private String  m_Charset = "";

	public void parseString(String buffer) {
		if (rootCommand == null)
			throw new AltovaException("No syntax definition");
		DocumentReader doc  = new DocumentReader(buffer, generator);
		rootCommand.readText(doc);
	}

	public Generator getGenerator() {
		return generator;
	}

	public void setEncoding(String enc)	{
		m_Charset = enc;
	}
	
	public void parse(String filename) throws Exception {
		FileIO io = new FileIO(filename, m_Charset);
		parseString(io.readToEnd().toString());
	}

	public void save(String filename) throws Exception {
		if (rootCommand == null)
			throw new AltovaException("No syntax definition");
		
		StringBuffer text = new StringBuffer();
		
		DocumentWriter doc = new DocumentWriter(generator.getRootNode(), text);
		rootCommand.writeText(doc);
		try
		{
			FileIO io = new FileIO(filename, m_Charset);
			io.writeToEnd(text);
		} 
		catch (IOException x) 
		{
            throw new AltovaException(x);
        }
	}
}
