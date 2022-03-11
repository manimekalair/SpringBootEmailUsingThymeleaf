//
// AnyTypeNode.cs
//
// This file was generated by [=$Host].
//
// YOU SHOULD NOT MODIFY THIS FILE, BECAUSE IT WILL BE
// OVERWRITTEN WHEN YOU RE-RUN CODE GENERATION.
//
// Refer to the [=$HostShort] Documentation for further details.
// [=$HostURL]
//


using System;
using System.Xml;
using Altova.Types;

namespace Altova.Xml
{
	/// <summary>
	/// class AnyTypeNode for xs:anyType
	/// </summary>
	public class AnyTypeNode : Node
	{
		#region Forward constructors

		public AnyTypeNode(XmlDocument doc) : base(doc) { SetCollectionParents(); }
		public AnyTypeNode(XmlNode node) : base(node) { SetCollectionParents(); }
		public AnyTypeNode(Node node) : base(node) { SetCollectionParents(); }
		public AnyTypeNode(Document doc, string namespaceURI, string prefix, string name) : base(doc, namespaceURI, prefix, name) { SetCollectionParents(); }
		#endregion // Forward constructors

		#region Value accessor methods
		public SchemaString GetValue()
		{
			return new SchemaString(GetDomNodeValue(domNode));
		}

		public void SetValue(ISchemaType newValue)
		{
			SetDomNodeValue(domNode, newValue.ToString());
		}

		public void Assign(ISchemaType newValue)
		{
			SetValue(newValue);
		}

		public SchemaString Value
		{
			get
			{
				return new SchemaString(GetDomNodeValue(domNode));
			}
			set
			{
				SetDomNodeValue(domNode, value.ToString());
			}
		}
		#endregion // Value accessor methods

		public override void AdjustPrefix()
		{
		}


		public void AddTextNode(SchemaString newValue)
		{
			AppendDomChild(NodeType.Text, "", "", newValue.ToString());
		}
		public void AddProcessingInstruction(SchemaString name, SchemaString newValue)
		{
			AppendDomChild(NodeType.ProcessingInstruction , "", name.ToString(), newValue.ToString());
		}
		public void AddCDataNode(SchemaString newValue)
		{
			AppendDomChild(NodeType.CData, "", "", newValue.ToString());
		}
		public void AddComment(SchemaString newValue)
		{
			AppendDomChild(NodeType.Comment, "", "", newValue.ToString());
		}
        private void SetCollectionParents()
        {
	}
}
}