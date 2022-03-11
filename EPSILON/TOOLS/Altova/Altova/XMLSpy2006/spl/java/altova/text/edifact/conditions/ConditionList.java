[call GenerateFileHeader("ConditionList.java")]
package com.altova.text.edifact.conditions;

import java.util.ArrayList;
import java.util.Iterator;

import com.altova.text.edifact.TextDocument;

public class ConditionList implements ICondition {
    private short m_Operation = OR;

    private ArrayList m_Conditions = new ArrayList();

    private boolean evaluateOr(TextDocument doc) {
        Iterator it = m_Conditions.iterator();
        while (it.hasNext()) {
            ICondition condition = (ICondition) (it.next());
            if (condition.evaluate(doc))
                return true;
        }
        return false;
    }

    private boolean evaluateAnd(TextDocument doc) {
        Iterator it = m_Conditions.iterator();
        while (it.hasNext()) {
            ICondition condition = (ICondition) (it.next());
            if (!condition.evaluate(doc))
                return false;
        }
        return true;
    }

    final public static short OR = 0;

    final public static short AND = 1;

    public short getOperation() {
        return m_Operation;
    }

    public void setOperation(short operation) {
        m_Operation = operation;
    }

    public void addCondition(ICondition condition) {
        m_Conditions.add(condition);
    }

    public boolean evaluate(TextDocument doc) {
        boolean result = false;
        if (0 == m_Conditions.size()) {
            result = true;
        } else
            switch (m_Operation) {
            case OR:
                return this.evaluateOr(doc);
            case AND:
                return this.evaluateAnd(doc);
            }
        return result;
    }
}