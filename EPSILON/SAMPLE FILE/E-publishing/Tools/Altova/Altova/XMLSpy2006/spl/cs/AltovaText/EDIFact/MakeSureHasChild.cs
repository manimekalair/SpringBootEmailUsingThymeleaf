[call GenerateFileHeader("MakeSureHasChild.cs")]
namespace Altova.TextParser.EDIFACT
{
	internal class MakeSureHasChild
	{
		public static ITextNode At(ITextNode parent, string name, int\[\] possiblepositions)
		{
			ITextNode result = NullTextNode.Instance;
			ITextNodeCollection children = parent.Children;
			for (int i = 0; (i < possiblepositions.Length) && (result.IsNull); ++i)
			{
				int pos = possiblepositions\[i\];
				if (pos > children.Count) pos = children.Count - 1;
				ITextNode kid = children\[pos\];
				if (kid.Name == name)
					result = kid;
			}
			if (result.IsNull)
			{
				int pos = possiblepositions\[0\];
				if (pos > children.Count)
					pos = children.Count;
				result = new TextNode(result, name);
				result.NativeName = name;
				if ((name == "GS") || (name == "GE") || (name == "ST")
					|| (name == "SE"))
					result.Class = NodeClass.Segment;
				else if (name.StartsWith("F"))
					result.Class = NodeClass.DataElement;
				else if (name.StartsWith("S"))
					result.Class = NodeClass.Composite;
				else if ((name.StartsWith("U")) && (3 == name.Length))
					result.Class = NodeClass.Segment;
				else if ((name.StartsWith("I")) && (3 == name.Length))
					result.Class = NodeClass.Segment;
				else
					result.Class = NodeClass.Group;
				children.Insert(result, pos);
			}
			return result;
		}
		public static ITextNode At(ITextNode parent, string name, int index)
		{
			int\[\] positions = new int\[1\];
			positions\[0\] = index;
			return At(parent, name, positions);
		}
		public static ITextNode AsFirst(ITextNode parent, string name)
		{
			return At(parent, name, 0);
		}
		public static ITextNode AsLast(ITextNode parent, string name)
		{
			return At(parent, name, 1000000);
		}
	}
}