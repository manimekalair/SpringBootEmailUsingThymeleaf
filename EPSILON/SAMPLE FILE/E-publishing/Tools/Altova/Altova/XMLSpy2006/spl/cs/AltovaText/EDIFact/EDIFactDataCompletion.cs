[call GenerateFileHeader("EDIFactDataCompletion.cs")]
using System.Globalization;

namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Encapsulates auto completing data in a <see cref="ITextNode"/> hierarchy
	/// representing EDIFact data.
	/// </summary>
	public class EDIFactDataCompletion : DataCompletion
	{
		#region Implementation Detail:
		private EDIFactSettings mSettings = null;
		#endregion

		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="settings">the settings to use</param>
		/// <param name="structurename">the name of the EDIFact structure which will be completed with this instance</param>
		public EDIFactDataCompletion(EDIFactSettings settings, string structurename)
			: base(structurename)
		{
			mSettings = settings;
		}
		/// <summary>
		/// Completes/fills in missing data in a <see cref="ITextNode"/> hierarchy representing
		/// EDIFact data.
		/// </summary>
		/// <param name="dataroot">the root node of the hierarchy to complete</param>
		public override void CompleteData(ITextNode dataroot)
		{
			CompleteEnvelope(dataroot);
		}
		#endregion
		
		#region Implementation Detail

		/// <summary>
		/// Completes envelope
		/// </summary>
		protected void CompleteEnvelope (ITextNode envelope)
		{
			if (envelope.Name != "Envelope")
				throw new MappingException("CompleteEnvelope: root node is not an envelope");

			MakeSureHasChild.AsFirst(envelope, "Interchange");

			ITextNode\[\] interchanges = envelope.Children.FilterByName("Interchange");
			for (int i=0; i< interchanges.Length; ++i)
				CompleteInterchange(interchanges\[i\]);
		}

		/// <summary>
		/// Completes interchange
		/// </summary>
		protected void CompleteInterchange(ITextNode interchange)
		{
			ITextNode unb = MakeSureHasChild.AsFirst(interchange, "UNB");
			MakeSureHasChild.At(interchange, "Group", 1);
			ITextNode unz = MakeSureHasChild.AsLast (interchange, "UNZ");
			
			ITextNode\[\] groups = interchange.Children.FilterByName("Group");
			for (int i=0; i< groups.Length; ++i)
				CompleteGroup(groups\[i\]);
			
			CompleteInterchangeHeader(unb);
			CompleteInterchangeTrailer(unz);
		}

		/// <summary>
		/// Completes interchange header
		/// </summary>
		protected void CompleteInterchangeHeader(ITextNode unb)
		{
			ITextNode s001  = MakeSureHasChild.At(unb, "S001",  0);
			ITextNode s002  = MakeSureHasChild.At(unb, "S002",  1);
			ITextNode s003  = MakeSureHasChild.At(unb, "S003",  2);
			ITextNode s004  = MakeSureHasChild.At(unb, "S004",  3);
			ITextNode f0020 = MakeSureHasChild.At(unb, "F0020", 4);

			CompleteS001(s001);
			CompleteS004(s004);
		}

		/// <summary>
		/// Completes interchange trailer
		/// </summary>
		protected void CompleteInterchangeTrailer(ITextNode unz)
		{
			ITextNode f0036 = MakeSureHasChild.At(unz, "F0036", 0);
			ITextNode f0020 = MakeSureHasChild.At(unz, "F0020", 1);

			ConservativeSetValue(f0036, GetNumberOfFunctionGroupsOrMessages(unz.Parent).ToString());
			ITextNode unb = unz.Parent.Children.FilterByName("UNB")\[0\];
			ITextNode\[\] unbChildren = unb.Children.FilterByName("F0020");
			string ctrlRef = unbChildren\[unbChildren.Length-1\].Value;
			ConservativeSetValue(f0020, ctrlRef);
		}

		/// <summary>
		/// Completes Group
		/// </summary>
		protected void CompleteGroup(ITextNode group)
		{
			ITextNode ung = null;
			ITextNode une = null;

			if (HasKid(group, "UNG"))
			{
				MakeSureHasChild.At(group, "Message", 1);
				une = MakeSureHasChild.AsLast(group, "UNE");
			}
			else if (HasKid(group, "UNE"))
			{
				ung = MakeSureHasChild.AsFirst(group, "UNG");
				MakeSureHasChild.At(group, "Message", 1);
			}
			else
				MakeSureHasChild.AsFirst(group, "Message");

			ITextNode\[\] messages  = group.Children.FilterByName("Message");
			for(int i=0; i< messages.Length; ++i)
				CompleteMessage(messages\[i\]);

			CompleteGroupHeader(ung);
			CompleteGroupTrailer(une);
		}

		/// <summary>
		/// Completes Group header
		/// </summary>
		protected void CompleteGroupHeader(ITextNode ung)
		{
			if (ung == null)
				return;

			ITextNode f0038 = MakeSureHasChild.AsFirst(ung, "F0038");
			ITextNode s006 = MakeSureHasChild.At(ung, "S006", 1);
			ITextNode s007 = MakeSureHasChild.At(ung, "S007", 2);
			ITextNode s004 = MakeSureHasChild.At(ung, "S004", 3);
			ITextNode f0048 = MakeSureHasChild.At(ung, "F0048", 4);
			ITextNode f0051 = MakeSureHasChild.At(ung, "F0051", 5);
			ITextNode s008 = MakeSureHasChild.At(ung, "S008", 6);
			ITextNode f0058 = MakeSureHasChild.At(ung, "F0058", 7);
			
			ConservativeSetValue(f0038, mStructureName);
			CompleteS004(s004);
			ConservativeSetValue(f0048, ung.Parent.Children.FilterByName("UNE")\[0\].Children.FilterByName("F0048")\[0\].Value);
			ConservativeSetValue(f0051, mSettings.ControllingAgency.Substring(0,2));
		}

		/// <summary>
		/// Completes Group trailer
		/// </summary>
		protected void CompleteGroupTrailer(ITextNode une)
		{
			if (une == null)
				return;

			ITextNode f0060 = MakeSureHasChild.At(une, "F0060", 0);
			ITextNode f0048 = MakeSureHasChild.At(une, "F0048", 1);

			int nMsg = une.Parent.Children.FilterByName("Message").Length;
			ConservativeSetValue(f0060, nMsg.ToString());
			ConservativeSetValue(f0048, une.Parent.Children.FilterByName("UNG")\[0\].Children.FilterByName("F0048")\[0\].Value);
		}

		/// <summary>
		/// Completes Message
		/// </summary>
		protected void CompleteMessage(ITextNode message) 
		{
			ITextNode unh = MakeSureHasChild.AsFirst(message, "UNH");
			ITextNode unt = MakeSureHasChild.AsLast(message, "UNT");

			CompleteMessageHeader(unh);
			CompleteMessageTrailer(unt);
		}

		/// <summary>
		/// Completes Message header
		/// </summary>
		protected void CompleteMessageHeader(ITextNode unh) 
		{
			ITextNode f0062 = MakeSureHasChild.At(unh, "F0062", 0);
			ITextNode s009 = MakeSureHasChild.At(unh, "S009", 1);

			ConservativeSetValue(f0062, unh.Parent.Children.FilterByName("UNT")\[0\].Value);
			CompleteS009 (s009);
		}

		/// <summary>
		/// Completes message trailer
		/// </summary>
		protected void CompleteMessageTrailer(ITextNode unt) 
		{
			ITextNode f0074 = MakeSureHasChild.At(unt, "F0074", 0);
			ITextNode f0062 = MakeSureHasChild.At(unt, "F0062", 1);

			ConservativeSetValue(f0074, GetSegmentChildrenCount(unt.Parent).ToString());
			ConservativeSetValue(f0062, unt.Parent.Children.FilterByName("UNH")\[0\].Children.FilterByName("F0062")\[0\].Value.ToString());
		}

		/// <summary>
		/// Completes S001 segment
		/// </summary>
		protected void CompleteS001(ITextNode s001)
		{
			ITextNode f0001 = MakeSureHasChild.At(s001, "F0001", 0);
			ITextNode f0002 = MakeSureHasChild.At(s001, "F0002", 1);

			ConservativeSetValue(f0001, mSettings.ControllingAgency + mSettings.SyntaxLevel);
			ConservativeSetValue(f0002, mSettings.SyntaxVersionNumber.ToString());
		}

		/// <summary>
		/// Completes S004 segment
		/// </summary>
		protected void CompleteS004(ITextNode s004)
		{
			ITextNode f0017 = MakeSureHasChild.At(s004, "F0017", 0);
			ITextNode f0019 = MakeSureHasChild.At(s004, "F0019", 1);

			ConservativeSetValue(f0017, GetCurrentDateAsEDIString());
			ConservativeSetValue(f0019, GetCurrentTimeAsEDIString());
		}

		/// <summary>
		/// Completes S009 segment
		/// </summary>
		protected void CompleteS009(ITextNode s009)
		{
			ITextNode f0065 = MakeSureHasChild.At(s009, "F0065", 0);
			ITextNode f0052 = MakeSureHasChild.At(s009, "F0052", 1);
			ITextNode f0054 = MakeSureHasChild.At(s009, "F0054", 2);
			ITextNode f0051 = MakeSureHasChild.At(s009, "F0051", 3);
			
			ConservativeSetValue(f0065, mStructureName);
			ConservativeSetValue(f0051, mSettings.ControllingAgency.Substring(0, 2));
		}

		/// <summary>
		/// Returns number of messages or groups 
		/// </summary>
		long GetNumberOfFunctionGroupsOrMessages(ITextNode node)
		{
			int nUNH =0;
			int nUNT =0;
			int nUNG =0;
			int nUNE =0;

			ITextNode\[\] groups = node.Children.FilterByName("Group");
			for (int i=0; i< groups.Length; ++i)
			{
				nUNG += groups\[i\].Children.FilterByName("UNG").Length;
				nUNE += groups\[i\].Children.FilterByName("UNE").Length;

				ITextNode\[\] messages = groups\[i\].Children.FilterByName("Message");
				for (int j=0; j< messages.Length; ++j)
				{
					nUNH += messages\[j\].Children.FilterByName("UNH").Length;
					nUNT += messages\[j\].Children.FilterByName("UNT").Length;
				}
			}
			
			if (nUNH != nUNT)
				throw new MappingException("Message header-trailer mismatch");
			if (nUNG != nUNE)
				throw new MappingException("Group header-trailer mismatch");

			return nUNG == 0 ? nUNH : nUNG;
		}
		#endregion
	}
}