[call GenerateFileHeader("ICondition.java")]
package com.altova.text.edifact.conditions;

import com.altova.text.edifact.TextDocument;

public interface ICondition {
    boolean evaluate(TextDocument doc);
}