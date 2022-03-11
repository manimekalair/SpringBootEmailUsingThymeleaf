[call GenerateFileHeader("EDIX12DataCompletion.cs")]
using System.Globalization;

namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Encapsulates auto completing data in a <see cref="ITextNode"/> hierarchy
	/// representing EDIX12 data.
	/// </summary>
	public class EDIX12DataCompletion : DataCompletion
	{
		#region Implementation detail:
		EDIX12Settings mSettings = null;
		ITextNode mRoot = NullTextNode.Instance;
		ITextNode mGroupRoot = NullTextNode.Instance;
		ITextNode mMessageRoot = NullTextNode.Instance;

		void PadNode(ITextNode node)
		{
			uint desired = node.MaximumLength;
			string newvalue = node.Value;
			if (node.HasDecimalData)
			{
				while (newvalue.Length < desired) newvalue = '0' + newvalue;
			}
			else
			{
				while (newvalue.Length < desired) newvalue += ' ';
			}
			node.Value = newvalue;
		}

		void CompleteInterchange()
		{
			ITextNode isa = GetKid(mRoot, "ISA");
			ITextNode iea = GetKid(mRoot, "IEA");
			foreach (ITextNode n in isa.Children)
				PadNode(n);

			ITextNode FI01 = MakeSureHasChild.AsFirst(isa, "FI01");
			ConservativeSetValue(FI01, "00");
			ITextNode FI02 = MakeSureHasChild.At(isa, "FI02", 1);
			ConservativeSetValue(FI02, "          ");
			ITextNode FI03 = MakeSureHasChild.At(isa, "FI03", 2);
			ConservativeSetValue(FI03, "00");
			ITextNode FI04 = MakeSureHasChild.At(isa, "FI04", 3);
			ConservativeSetValue(FI04, "          ");
			ITextNode FI05_1 = MakeSureHasChild.At(isa, "FI05_1", 4);
			ConservativeSetValue(FI05_1, "ZZ");
			ITextNode FI05_2 = MakeSureHasChild.At(isa, "FI05_2", 6);
			ConservativeSetValue(FI05_2, "ZZ");
			ITextNode FI08 = MakeSureHasChild.At(isa, "FI08", 8);
			ConservativeSetValue(FI08, GetCurrentDateAsEDIString());
			ITextNode FI09 = MakeSureHasChild.At(isa, "FI09", 9);
			ConservativeSetValue(FI09, GetCurrentTimeAsEDIString());
			ITextNode FI65 = MakeSureHasChild.At(isa, "FI65", 10);
			ConservativeSetValue(FI65, mSettings.SubElementSeparator.ToString(CultureInfo.InvariantCulture));
			ITextNode FI11 = MakeSureHasChild.At(isa, "FI11", 11);
			ConservativeSetValue(FI11, mSettings.InterchangeControlVersionNumber);
			ITextNode FI12 = MakeSureHasChild.At(isa, "FI12", 12);
			ITextNode FI13 = MakeSureHasChild.At(isa, "FI13", 13);
			ConservativeSetValue(FI13, mSettings.RequestAcknowledgement ? "1" : "0");
			ITextNode FI14 = MakeSureHasChild.At(isa, "FI14", 14);
			ConservativeSetValue(FI14, "P");
			ITextNode FI15 = MakeSureHasChild.At(isa, "FI15", 15);
			ConservativeSetValue(FI15, mSettings.ServiceStringAdvice.ComponentSeparator.ToString(CultureInfo.InvariantCulture));

			ITextNode\[\] groups= mRoot.Children.FilterByName("Group");
			foreach (ITextNode group in groups)
			{
				mGroupRoot= group;
				MakeSureHasChild.AsFirst(mGroupRoot, "GS");
				MakeSureHasChild.AsLast(mGroupRoot, "GE");
				CompleteGroup();
			}

			ITextNode IEAFI16 = MakeSureHasChild.AsFirst(iea, "FI16");
			ConservativeSetValue(IEAFI16, mRoot.Children.FilterByName("Group").Length.ToString(CultureInfo.InvariantCulture));
			ITextNode IEAFI12 = MakeSureHasChild.AsLast(iea, "FI12");
			ConservativeSetValue(IEAFI12, FI12.Value.Trim());
		}
		void CompleteGroup()
		{
			ITextNode GS = GetKid(mGroupRoot, "GS");
			if (!GS.IsNull) 
			{
				ITextNode GE = GetKid(mGroupRoot, "GE");
				ITextNode GSF373 = MakeSureHasChild.At(GS, "F373", 3);
				ConservativeSetValue(GSF373, GetCurrentDateAsEDIString());
				ITextNode GSF337 = MakeSureHasChild.At(GS, "F337", 4);
				ConservativeSetValue(GSF337, GetCurrentTimeAsEDIString());
				ITextNode GSF28 = GetKid(GS, "F28");
				ITextNode GEF97 = MakeSureHasChild.AsFirst(GE, "F97");
				ConservativeSetValue(GEF97, GS.Parent.Children.FilterByName("Message").Length.ToString(CultureInfo.InvariantCulture));
				ITextNode GEF28 = MakeSureHasChild.AsLast(GE, "F28");
				ConservativeSetValue(GEF28, GSF28.Value);
			}
			mMessageRoot = MakeSureHasChild.At(mGroupRoot, "Message", new int\[\] {0, 1});
			ITextNode\[\] messages= mGroupRoot.Children.FilterByName("Message");
			foreach (ITextNode message in messages)
			{
				mMessageRoot= message;
				MakeSureHasChild.AsFirst(mMessageRoot, "ST");
				MakeSureHasChild.AsLast(mMessageRoot, "SE");
				CompleteMessage();
			}
		}
		void CompleteMessage()
		{
			ITextNode ST = GetKid(mMessageRoot, "ST");
			ITextNode SE = GetKid(mMessageRoot, "SE");
			ITextNode STF143 = MakeSureHasChild.AsFirst(ST, "F143");
			ConservativeSetValue(STF143, StructureName);
			ITextNode SEF96 = MakeSureHasChild.AsFirst(SE, "F96");
			long segmentcount = GetSegmentChildrenCount(ST.Parent);
			ConservativeSetValue(SEF96, segmentcount.ToString());
			ITextNode STF329 = MakeSureHasChild.At(ST, "F329", 1);
			ITextNode SEF329 = MakeSureHasChild.AsLast(SE, "F329");
			ConservativeSetValue(SEF329, STF329.Value);
		}
		#endregion
		#region Implementing DataCompletion:
		/// <summary>
		/// Completes the hierarchy of nodes rooted in the passed node.
		/// </summary>
		/// <param name="dataroot">the root of the nodes to be completed</param>
		public override void CompleteData(ITextNode dataroot)
		{
			mRoot = MakeSureHasChild.AsFirst(dataroot, "Interchange");
			MakeSureHasChild.AsFirst(mRoot, "ISA");
			mGroupRoot = MakeSureHasChild.At(mRoot, "Group", 1);
			MakeSureHasChild.AsLast(mRoot, "IEA");
			CompleteInterchange();
		}
		#endregion
		#region Public interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="settings">the settings to use</param>
		/// <param name="structurename">the name of the structure this instance will complete</param>
		public EDIX12DataCompletion(EDIX12Settings settings, string structurename)
			: base(structurename)
		{
			mSettings = settings;
		}
		#endregion
	}
}