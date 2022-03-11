[call GenerateFileHeader("ICommand.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.TextDocument;

public interface ICommand {
    boolean execute(TextDocument doc);
}