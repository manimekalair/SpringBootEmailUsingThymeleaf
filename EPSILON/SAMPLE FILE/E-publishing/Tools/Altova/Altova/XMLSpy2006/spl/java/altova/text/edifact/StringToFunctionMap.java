[call GenerateFileHeader("StringToFunctionMap.java")]
package com.altova.text.edifact;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class StringToFunctionMap {
	private Map m_Map = new HashMap();

	public void add(String name, Function function) {
		if (function == m_Map.put(name, function)) {
			Logger logger = Logger.getLogger("com.altova.text");
			logger
					.log(Level.WARNING, "Redefinition of function '" + name
							+ "'");
		}
	}

	public Function get(String name) {
		if (name.length() == 0)
			return new Function();

		char\[\] sNameChars = name.toCharArray(); // convert the string to a
		if (sNameChars.length == 1
				&& (sNameChars\[0\] == '\\r' || sNameChars\[0\] == '\\n'))
			return new Function();

		return (Function) (m_Map.get(name));
	}

	public void clear() {
		m_Map.clear();
	}
}