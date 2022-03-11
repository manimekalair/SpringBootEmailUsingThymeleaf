[call GenerateFileHeader("FileIO.java")]
package com.altova.text;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;

public class FileIO {
    private String m_Filename = "";
    private String m_Encoding = "";
    private Charset m_Charset;

    private int m_BufferSize = 32 * 512; // avg readehead is 16-32 blocks

    public FileIO(String filename, String encoding) {
        m_Filename = filename;
        m_Encoding = encoding;
		
		// provide alternative charsets here
		m_Charset = Charset.forName(m_Encoding);
    }

    public StringBuffer readToEnd() throws IOException {
        char\[\] buffer = new char\[m_BufferSize\];
        
        // determine BOMs       
        FileInputStream fistream = new FileInputStream(m_Filename);
        byte\[\] header = new byte\[4\];
        fistream.read(header);
        fistream.close();
        fistream = new FileInputStream(m_Filename);
        if (isUTF8(header) == true) {
        	fistream.skip(3);
        	if (m_Encoding.compareToIgnoreCase("UTF-8") != 0 ) {
        		System.out.println("Warning: input encoding is UTF-8, not \'" + m_Encoding + "\'");
        		m_Encoding = "UTF-8";
				m_Charset = Charset.forName(m_Encoding);
        	}
        }
		
		StringBuffer result = new StringBuffer((int) fistream.getChannel().size());
		
        BufferedReader reader = new BufferedReader(new InputStreamReader(fistream, m_Charset));
        int read = reader.read(buffer);
        while (-1 < read) {
            result.append(buffer, 0, read);
            read = reader.read(buffer);
        }
        reader.close();
        fistream.close();
        return result; 
    }
        
	public OutputStreamWriter openWriteStream() throws IOException {
		FileOutputStream stream = new FileOutputStream(m_Filename);
		if (m_Encoding.compareToIgnoreCase("UTF-8") == 0) {
			stream.write(0xef);
			stream.write(0xbb);
			stream.write(0xbf);
		}
		
		return new OutputStreamWriter(stream, m_Charset);
	}
	
	public void writeToEnd(StringBuffer buff) throws IOException {
		OutputStreamWriter writer = openWriteStream();
		writer.write(buff.toString(), 0, buff.length());
		writer.close();
	}
	
    private boolean isUTF16BE(byte\[\] source) {
		boolean result = (((source\[0\] & 0xff) == 0xfe) && ((source\[1\] & 0xff) == 0xff));
		return result;
	}

	private boolean isUTF16LE(byte\[\] source) {
		boolean result = (((source\[0\] & 0xff) == 0xff) && ((source\[1\] & 0xff) == 0xfe));
		return result;
	}

	private boolean isUTF8(byte\[\] source) {
		boolean result = (((source\[0\] & 0xff) == 0xef) // & is because chars are signed!
				&& ((source\[1\] & 0xff) == 0xbb) && ((source\[2\] & 0xff) == 0xbf));
		return result;
	}
	
	
}