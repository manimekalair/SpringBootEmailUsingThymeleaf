[call GenerateFileHeader("EDIFactDataCompletion.java")]
package com.altova.text.edifact;

import com.altova.text.*;

public class EDIFactDataCompletion extends DataCompletion {
		private EDIFactSettings mSettings = null;
		

		public EDIFactDataCompletion(EDIFactSettings settings, String structurename) {
			super(structurename);
			mSettings = settings;
		}

		public void completeData(TextNode dataroot) {
			completeEnvelope(dataroot);
		}
		
		protected void completeEnvelope (TextNode envelope) {
			if (envelope.getName() != "Envelope")
				throw new com.altova.AltovaException("completeEnvelope: root node is not an envelope");

			MakeSureHasChild.asFirst(envelope, "Interchange");

			TextNodeList interchanges = envelope.getChildren().filterByName("Interchange");
			for (int i=0; i< interchanges.size(); ++i)
				completeInterchange(interchanges.getAt(i));
		}

		protected void completeInterchange(ITextNode interchange) {
			ITextNode unb = MakeSureHasChild.asFirst(interchange, "UNB");
			MakeSureHasChild.at(interchange, "Group", 1);
			ITextNode unz = MakeSureHasChild.asLast (interchange, "UNZ");
			
			ITextNodeList groups = interchange.getChildren().filterByName("Group");
			for (int i=0; i< groups.size(); ++i)
				completeGroup(groups.getAt(i));
			
			completeInterchangeHeader(unb);
			completeInterchangeTrailer(unz);
		}

		protected void completeInterchangeHeader(ITextNode unb) {
			ITextNode s001  = MakeSureHasChild.at(unb, "S001",  0);
			ITextNode s002  = MakeSureHasChild.at(unb, "S002",  1);
			ITextNode s003  = MakeSureHasChild.at(unb, "S003",  2);
			ITextNode s004  = MakeSureHasChild.at(unb, "S004",  3);
			ITextNode f0020 = MakeSureHasChild.at(unb, "F0020", 4);

			completeS001(s001);
			completeS004(s004);
		}

		protected void completeInterchangeTrailer(ITextNode unz) {
			ITextNode f0036 = MakeSureHasChild.at(unz, "F0036", 0);
			ITextNode f0020 = MakeSureHasChild.at(unz, "F0020", 1);

			conservativeSetValue(f0036, GetNumberOfFunctionGroupsOrMessages(unz.getParent()));
			ITextNode unb = unz.getParent().getChildren().getFirstNodeByName("UNB");
			ITextNodeList unbChildren = unb.getChildren().filterByName("F0020");
			String ctrlRef = unbChildren.getAt(unbChildren.size()-1).getValue();
			conservativeSetValue(f0020, ctrlRef);
		}

		protected void completeGroup(ITextNode group) {
			ITextNode ung = null;
			ITextNode une = null;

			if (hasKid(group, "UNG")) {
				MakeSureHasChild.at(group, "Message", 1);
				une = MakeSureHasChild.asLast(group, "UNE");
			}
			else if (hasKid(group, "UNE")) {
				ung = MakeSureHasChild.asFirst(group, "UNG");
				MakeSureHasChild.at(group, "Message", 1);
			}
			else
				MakeSureHasChild.asFirst(group, "Message");

			ITextNodeList messages  = group.getChildren().filterByName("Message");
			for(int i=0; i< messages.size(); ++i)
				completeMessage(messages.getAt(i));

			completeGroupHeader(ung);
			completeGroupTrailer(une);
		}

		protected void completeGroupHeader(ITextNode ung) {
			if (ung == null)
				return;

			ITextNode f0038 = MakeSureHasChild.asFirst(ung, "F0038");
			ITextNode s006 = MakeSureHasChild.at(ung, "S006", 1);
			ITextNode s007 = MakeSureHasChild.at(ung, "S007", 2);
			ITextNode s004 = MakeSureHasChild.at(ung, "S004", 3);
			ITextNode f0048 = MakeSureHasChild.at(ung, "F0048", 4);
			ITextNode f0051 = MakeSureHasChild.at(ung, "F0051", 5);
			ITextNode s008 = MakeSureHasChild.at(ung, "S008", 6);
			ITextNode f0058 = MakeSureHasChild.at(ung, "F0058", 7);
			
			conservativeSetValue(f0038, m_StructureName);
			completeS004(s004);
			conservativeSetValue(f0048, ung.getParent().getChildren().getFirstNodeByName("UNE").getChildren().getFirstNodeByName("F0048").getValue());
			conservativeSetValue(f0051, mSettings.getControllingAgency().substring(0,2));
		}

		protected void completeGroupTrailer(ITextNode une) {
			if (une == null)
				return;

			ITextNode f0060 = MakeSureHasChild.at(une, "F0060", 0);
			ITextNode f0048 = MakeSureHasChild.at(une, "F0048", 1);

			int nMsg = une.getParent().getChildren().filterByName("Message").size();
			conservativeSetValue(f0060, nMsg);
			conservativeSetValue(f0048, une.getParent().getChildren().getFirstNodeByName("UNG").getChildren().getFirstNodeByName("F0048").getValue());
		}

		protected void completeMessage(ITextNode message) {
			ITextNode unh = MakeSureHasChild.asFirst(message, "UNH");
			ITextNode unt = MakeSureHasChild.asLast(message, "UNT");

			completeMessageHeader(unh);
			completeMessageTrailer(unt);
		}

		protected void completeMessageHeader(ITextNode unh) {
			ITextNode f0062 = MakeSureHasChild.at(unh, "F0062", 0);
			ITextNode s009 = MakeSureHasChild.at(unh, "S009", 1);

			conservativeSetValue(f0062, unh.getParent().getChildren().getFirstNodeByName("UNT").getValue());
			completeS009 (s009);
		}

		protected void completeMessageTrailer(ITextNode unt) {
			ITextNode f0074 = MakeSureHasChild.at(unt, "F0074", 0);
			ITextNode f0062 = MakeSureHasChild.at(unt, "F0062", 1);

			conservativeSetValue(f0074, getSegmentChildrenCount(unt.getParent()));
			conservativeSetValue(f0062, unt.getParent().getChildren().getFirstNodeByName("UNH").getChildren().getFirstNodeByName("F0062").getValue());
		}

		protected void completeS001(ITextNode s001) {
			ITextNode f0001 = MakeSureHasChild.at(s001, "F0001", 0);
			ITextNode f0002 = MakeSureHasChild.at(s001, "F0002", 1);

			conservativeSetValue(f0001, mSettings.getControllingAgency() + mSettings.getSyntaxLevel());
			conservativeSetValue(f0002, mSettings.getSyntaxVersionNumber());
		}

		protected void completeS004(ITextNode s004) {
			ITextNode f0017 = MakeSureHasChild.at(s004, "F0017", 0);
			ITextNode f0019 = MakeSureHasChild.at(s004, "F0019", 1);

			conservativeSetValue(f0017, getCurrentDateAsEDIString());
			conservativeSetValue(f0019, getCurrentTimeAsEDIString());
		}

		protected void completeS009(ITextNode s009) {
			ITextNode f0065 = MakeSureHasChild.at(s009, "F0065", 0);
			ITextNode f0052 = MakeSureHasChild.at(s009, "F0052", 1);
			ITextNode f0054 = MakeSureHasChild.at(s009, "F0054", 2);
			ITextNode f0051 = MakeSureHasChild.at(s009, "F0051", 3);
			
			conservativeSetValue(f0065, m_StructureName);
			conservativeSetValue(f0051, mSettings.getControllingAgency().substring(0, 2));
		}

		long GetNumberOfFunctionGroupsOrMessages(ITextNode node) {
			int nUNH =0;
			int nUNT =0;
			int nUNG =0;
			int nUNE =0;

			ITextNodeList groups = node.getChildren().filterByName("Group");
			for (int i=0; i< groups.size(); ++i) 	{
				nUNG += groups.getAt(i).getChildren().filterByName("UNG").size();
				nUNE += groups.getAt(i).getChildren().filterByName("UNE").size();

				ITextNodeList messages = groups.getAt(i).getChildren().filterByName("Message");
				for (int j=0; j< messages.size(); ++j) {
					nUNH += messages.getAt(j).getChildren().filterByName("UNH").size();
					nUNT += messages.getAt(j).getChildren().filterByName("UNT").size();
				}
			}
			
			if (nUNH != nUNT)
				throw new com.altova.AltovaException("Message header-trailer mismatch");
			if (nUNG != nUNE)
				throw new com.altova.AltovaException("Group header-trailer mismatch");

			return nUNG == 0 ? nUNH : nUNG;
		}
}
