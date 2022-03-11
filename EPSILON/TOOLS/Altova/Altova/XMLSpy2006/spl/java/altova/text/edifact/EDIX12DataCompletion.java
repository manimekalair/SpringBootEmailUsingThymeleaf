[call GenerateFileHeader("EDIX12DataCompletion.java")]
package com.altova.text.edifact;

import com.altova.text.*;

public class EDIX12DataCompletion extends DataCompletion {
	private EDIX12Settings m_Settings = null;

	private ITextNode m_Root = NullTextNode.getInstance();

	private ITextNode m_GroupRoot = NullTextNode.getInstance();

	private ITextNode m_MessageRoot = NullTextNode.getInstance();

	private void PadNode(ITextNode node) {
		int desired = node.getMaximumLength();
		StringBuffer buffer = new StringBuffer(node.getValue());
		while (buffer.length() < desired)
			buffer.append(' ');
		if (node.hasDecimalData()) {
			while (buffer.length() < desired)
				buffer.insert(0, '0');
		} else {
			while (buffer.length() < desired)
				buffer.append(' ');
		}
		node.setValue(buffer.toString());
	}

	private void completeInterchange() {
		ITextNode isa = getKid(m_Root, "ISA");
		ITextNode iea = getKid(m_Root, "IEA");
		TextNodeListIterator i = isa.getChildren().iterator();
		while (i.hasNext())
			PadNode(i.nextTextNode());

		ITextNode FI01 = MakeSureHasChild.asFirst(isa, "FI01");
		conservativeSetValue(FI01, "00");
		ITextNode FI02 = MakeSureHasChild.at(isa, "FI02", 1);
		conservativeSetValue(FI02, "          ");
		ITextNode FI03 = MakeSureHasChild.at(isa, "FI03", 2);
		conservativeSetValue(FI03, "00");
		ITextNode FI04 = MakeSureHasChild.at(isa, "FI04", 3);
		conservativeSetValue(FI04, "          ");
		ITextNode FI05_1 = MakeSureHasChild.at(isa, "FI05_1", 4);
		conservativeSetValue(FI05_1, "ZZ");
		ITextNode FI05_2 = MakeSureHasChild.at(isa, "FI05_2", 6);
		conservativeSetValue(FI05_2, "ZZ");
		ITextNode FI08 = MakeSureHasChild.at(isa, "FI08", 8);
		conservativeSetValue(FI08, getCurrentDateAsEDIString());
		ITextNode FI09 = MakeSureHasChild.at(isa, "FI09", 9);
		conservativeSetValue(FI09, getCurrentTimeAsEDIString());
		ITextNode FI65 = MakeSureHasChild.at(isa, "FI65", 10);
		conservativeSetValue(FI65, m_Settings.getSubElementSeparator());
		ITextNode FI11 = MakeSureHasChild.at(isa, "FI11", 11);
		conservativeSetValue(FI11, m_Settings
				.getInterchangeControlVersionNumber());
		ITextNode FI12 = MakeSureHasChild.at(isa, "FI12", 12);
		ITextNode FI13 = MakeSureHasChild.at(isa, "FI13", 13);
		conservativeSetValue(FI13, m_Settings.getRequestAcknowledgement() ? "1"
				: "0");
		ITextNode FI14 = MakeSureHasChild.at(isa, "FI14", 14);
		conservativeSetValue(FI14, "P");
		ITextNode FI15 = MakeSureHasChild.at(isa, "FI15", 15);
		conservativeSetValue(FI15, m_Settings.getServiceStringAdvice()
				.getComponentSeparator());

		ITextNodeList groups = m_Root.getChildren().filterByName("Group");
		for (int j = 0; j < groups.size(); ++j) {
			m_GroupRoot = groups.getAt(j);
			MakeSureHasChild.asFirst(m_GroupRoot, "GS");
			MakeSureHasChild.asLast(m_GroupRoot, "GE");
			completeGroup();
		}

		ITextNode IEAFI16 = MakeSureHasChild.asFirst(iea, "FI16");
		conservativeSetValue(IEAFI16, m_Root.getChildren()
				.filterByName("Group").size());
		ITextNode IEAFI12 = MakeSureHasChild.asLast(iea, "FI12");
		conservativeSetValue(IEAFI12, FI12.getValue().trim());

	}

	private void completeGroup() {
		ITextNode GS = m_GroupRoot.getChildren().filterByName("GS").getAt(0);
		if (!GS.isNull()) {
			ITextNode GE = m_GroupRoot.getChildren().filterByName("GE")
					.getAt(0);
			ITextNode GSF373 = MakeSureHasChild.at(GS, "F373", 3);
			conservativeSetValue(GSF373, getCurrentDateAsEDIString());
			ITextNode GSF337 = MakeSureHasChild.at(GS, "F337", 4);
			conservativeSetValue(GSF337, getCurrentTimeAsEDIString());
			ITextNode GSF28 = GS.getChildren().filterByName("F28").getAt(0);
			ITextNode GEF97 = MakeSureHasChild.asFirst(GE, "F97");
			conservativeSetValue(GEF97, GS.getParent().getChildren()
					.filterByName("Message").size());
			ITextNode GEF28 = MakeSureHasChild.asLast(GE, "F28");
			conservativeSetValue(GEF28, GSF28.getValue());
		}
		m_MessageRoot = MakeSureHasChild.at(m_GroupRoot, "Message", new int\[\] {
				0, 1 });
		ITextNodeList messages = m_GroupRoot.getChildren().filterByName(
				"Message");
		for (int i = 0; i < messages.size(); ++i) {
			m_MessageRoot = messages.getAt(i);
			MakeSureHasChild.asFirst(m_MessageRoot, "ST");
			MakeSureHasChild.asLast(m_MessageRoot, "SE");
			completeMessage();
		}

	}

	private void completeMessage() {
		ITextNode ST = m_MessageRoot.getChildren().filterByName("ST").getAt(0);
		ITextNode SE = m_MessageRoot.getChildren().filterByName("SE").getAt(0);
		ITextNode STF143 = MakeSureHasChild.asFirst(ST, "F143");
		conservativeSetValue(STF143, getStructureName());
		ITextNode SEF96 = MakeSureHasChild.asFirst(SE, "F96");
		long segmentcount = getSegmentChildrenCount(ST.getParent());
		conservativeSetValue(SEF96, segmentcount);
		ITextNode STF329 = MakeSureHasChild.at(ST, "F329", 1);
		ITextNode SEF329 = MakeSureHasChild.asLast(SE, "F329");
		conservativeSetValue(SEF329, STF329.getValue());
	}

	public EDIX12DataCompletion(EDIX12Settings settings, String structurename) {
		super(structurename);
		m_Settings = settings;
	}

	public void completeData(TextNode dataroot) {
		m_Root = MakeSureHasChild.asFirst(dataroot, "Interchange");
		MakeSureHasChild.asFirst(m_Root, "ISA");
		m_GroupRoot = MakeSureHasChild.at(m_Root, "Group", 1);
		MakeSureHasChild.asLast(m_Root, "IEA");
		completeInterchange();
	}

}
