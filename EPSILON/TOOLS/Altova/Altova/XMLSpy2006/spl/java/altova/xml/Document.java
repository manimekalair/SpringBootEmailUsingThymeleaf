/**
 * Document.java
 *
 * This file was generated by [=$Host].
 *
 * YOU SHOULD NOT MODIFY THIS FILE, BECAUSE IT WILL BE
 * OVERWRITTEN WHEN YOU RE-RUN CODE GENERATION.
 *
 * Refer to the [=$HostShort] Documentation for further details.
 * [=$HostURL]
 */


package com.altova.xml;

import java.util.*;


public abstract class Document implements java.io.Serializable {
	protected static javax.xml.parsers.DocumentBuilderFactory	factory		= null;
	protected static javax.xml.parsers.DocumentBuilder			builder		= null;
[if $CompatibilityMode <= "2005"]
	protected static org.w3c.dom.Document						tmpDocument	= null;
	protected static org.w3c.dom.DocumentFragment				tmpFragment	= null;
	protected static int										tmpNameCounter = 0;
[endif]
	protected static boolean									validation = false;

	protected org.w3c.dom.Document		domDocument;
	protected String encoding			= "UTF-8";
[if $CompatibilityMode <= "2005"]
	protected String rootElementName	= null;
	protected String namespaceURI		= null;
[endif]
	protected String schemaLocation		= null;
	protected String dtdLocation				= null;

	public Document() {
	}

	public static void enableValidation(boolean enable) {
		validation = enable;
	}

	protected static synchronized javax.xml.parsers.DocumentBuilder getDomBuilder() {
		try {
			if (builder == null) {
				if (factory == null) {
					factory = javax.xml.parsers.DocumentBuilderFactory.newInstance();
					factory.setIgnoringElementContentWhitespace(true);
					factory.setNamespaceAware(true);
					if (validation) {
						factory.setAttribute("http://java.sun.com/xml/jaxp/properties/schemaLanguage", "http://www.w3.org/2001/XMLSchema");
						factory.setValidating(true);
					}
				}
				builder = factory.newDocumentBuilder();

				builder.setErrorHandler(new org.xml.sax.ErrorHandler() {
					public void warning(org.xml.sax.SAXParseException e) {
					}
					public void error(org.xml.sax.SAXParseException e) throws XmlException {
						throw new XmlException(e);
					}
					public void fatalError(org.xml.sax.SAXParseException e) throws XmlException {
						throw new XmlException(e);
					}
				});
			}
			return builder;
		} catch (javax.xml.parsers.ParserConfigurationException e) {
			throw new XmlException(e);
		}
	}

[if $CompatibilityMode <= "2005"]
	protected static synchronized org.w3c.dom.Document getTemporaryDocument() {
		if (tmpDocument == null)
			tmpDocument = getDomBuilder().newDocument();
		return tmpDocument;
	}

	protected static synchronized org.w3c.dom.Node createTemporaryDomNode() {
		String tmpName = "_" + tmpNameCounter++;
		if (tmpFragment == null) {
			tmpFragment = getTemporaryDocument().createDocumentFragment();
			tmpDocument.appendChild(tmpFragment);
		}
		org.w3c.dom.Node node = getTemporaryDocument().createElement(tmpName);
		tmpFragment.appendChild(node);
		return node;
	}
[endif]
	public synchronized org.w3c.dom.Document getDomDocument() {
		if (domDocument == null)
			domDocument = getDomBuilder().newDocument();
		return domDocument;
	}

	public org.w3c.dom.Element createRootElement(String namespaceURI, String name) {
		org.w3c.dom.Element rootElement = null;
		if (dtdLocation != null && dtdLocation.length() != 0) {
			org.w3c.dom.DocumentType docType = getDomBuilder().getDOMImplementation().createDocumentType(name, null, dtdLocation);
			domDocument = getDomBuilder().getDOMImplementation().createDocument(namespaceURI, name, docType);
			rootElement = domDocument.getDocumentElement();
		}
		else {
			rootElement = getDomDocument().createElementNS(namespaceURI, name);
			domDocument.appendChild(rootElement);
	
			rootElement.setAttribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
			if (schemaLocation != null && schemaLocation.length() != 0) {
				if (namespaceURI == null || namespaceURI.equals("")) {
					rootElement.setAttribute("xsi:noNamespaceSchemaLocation", schemaLocation);
				} else {
					rootElement.setAttribute("xsi:schemaLocation", namespaceURI + " " + schemaLocation);
				}
			}
		}
		return rootElement;
	}

	public void setEncoding(String encoding) {
		this.encoding = encoding;
	}

[if $CompatibilityMode <= "2005"]
	public void setRootElementName(String namespaceURI, String rootElementName) {
		this.namespaceURI		= namespaceURI;
		this.rootElementName	= rootElementName;
	}
[endif]
	public void setSchemaLocation(String schemaLocation) {
		this.schemaLocation = schemaLocation;
	}
	
	public void setDTDLocation(String dtdLocation) {
		this.dtdLocation = dtdLocation;
	}

	public org.w3c.dom.Node load(String filename) {
		try {
			return getDomBuilder().parse(new java.io.File(filename)).getDocumentElement();
		} catch (org.xml.sax.SAXException e) {
			throw new XmlException(e);
		} catch (java.io.IOException e) {
			throw new XmlException(e);
		}
	}

	public org.w3c.dom.Node load(java.io.InputStream istream) {
		try {
			return getDomBuilder().parse(istream).getDocumentElement();
		} catch (org.xml.sax.SAXException e) {
			throw new XmlException(e);
		} catch (java.io.IOException e) {
			throw new XmlException(e);
		}
	}

	public org.w3c.dom.Node loadFromString(String xml) {
		try {
			return getDomBuilder().parse(new java.io.ByteArrayInputStream(xml.getBytes())).getDocumentElement();
		} catch (org.xml.sax.SAXException e) {
			throw new XmlException(e);
		} catch (java.io.IOException e) {
			throw new XmlException(e);
		}
	}

	public void save(String filename, Node node) {
[if $CompatibilityMode <= "2005"]
		finalizeRootElement(node);
[endif]

		Node.internalAdjustPrefix(node.domNode, true);
		node.adjustPrefix();

		internalSave(
				new javax.xml.transform.stream.StreamResult(
						new java.io.File(filename)
						),
				node.domNode.getOwnerDocument(),
				encoding
				);
	}

	public void save(java.io.OutputStream ostream, Node node) {
[if $CompatibilityMode <= "2005"]
		finalizeRootElement(node);
[endif]
		Node.internalAdjustPrefix(node.domNode, true);
		node.adjustPrefix();

		internalSave(
				new javax.xml.transform.stream.StreamResult(ostream),
				node.domNode.getOwnerDocument(),
				encoding
				);
	}

	public String saveToString(Node node) {
[if $CompatibilityMode <= "2005"]
		finalizeRootElement(node);
[endif]
		Node.internalAdjustPrefix(node.domNode, true);
		node.adjustPrefix();

		java.io.StringWriter sw = new java.io.StringWriter();
		internalSave(
				  new javax.xml.transform.stream.StreamResult(sw),
				  node.domNode.getOwnerDocument(),
				  encoding
				  );
		return sw.toString();
	}

	protected static void internalSave(javax.xml.transform.Result result, org.w3c.dom.Document doc, String encoding) {
		try {
			javax.xml.transform.Source source
					= new javax.xml.transform.dom.DOMSource(doc);
			javax.xml.transform.Transformer transformer
					= javax.xml.transform.TransformerFactory.newInstance().newTransformer();
			if (encoding != null)
				transformer.setOutputProperty("encoding", encoding);
			if (doc.getDoctype() != null) {
				if (doc.getDoctype().getPublicId() != null)
					transformer.setOutputProperty(javax.xml.transform.OutputKeys.DOCTYPE_PUBLIC, doc.getDoctype().getPublicId());
				if (doc.getDoctype().getSystemId() != null)
					transformer.setOutputProperty(javax.xml.transform.OutputKeys.DOCTYPE_SYSTEM, doc.getDoctype().getSystemId());
			}
			transformer.transform(source, result);
		} catch (javax.xml.transform.TransformerConfigurationException e) {
			throw new XmlException(e);
		} catch (javax.xml.transform.TransformerException e) {
			throw new XmlException(e);
		}
	}

	public org.w3c.dom.Node transform(Node node, String xslFilename) {
		try {
			javax.xml.transform.TransformerFactory factory = javax.xml.transform.TransformerFactory.newInstance();
			javax.xml.transform.Transformer transformer = factory.newTransformer(
					new javax.xml.transform.stream.StreamSource(xslFilename)
					);

			javax.xml.transform.dom.DOMResult result = new javax.xml.transform.dom.DOMResult();
			transformer.transform(
					new javax.xml.transform.dom.DOMSource(node.domNode),
					result
					);

			return result.getNode();
		} catch (javax.xml.transform.TransformerException e) {
			throw new XmlException(e);
		}
	}

[if $CompatibilityMode <= "2005"]
	protected void finalizeRootElement(Node root) {
		if (root.domNode.getParentNode().getNodeType() != org.w3c.dom.Node.DOCUMENT_FRAGMENT_NODE)
			return;

		if (rootElementName == null || rootElementName.equals(""))
			throw new XmlException("Call setRootElementName first");

		org.w3c.dom.Document doc = getDomBuilder().newDocument();
		org.w3c.dom.Element newRootElement = doc.createElementNS(namespaceURI, rootElementName);
		root.cloneInto(newRootElement);
		doc.appendChild(newRootElement);

		newRootElement.setAttribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
		if (namespaceURI == null || namespaceURI.equals("")) {
			if (schemaLocation != null && schemaLocation.length() != 0)
				newRootElement.setAttribute("xsi:noNamespaceSchemaLocation", schemaLocation);
		} else {
			if (schemaLocation != null && schemaLocation.length() != 0)
				newRootElement.setAttribute("xsi:schemaLocation", namespaceURI + " " + schemaLocation);
		}

		root.domNode = newRootElement;
		declareNamespaces(root);
	}
[endif]
	public abstract void declareNamespaces(Node node);

	protected void declareNamespace(Node node, String prefix, String URI) {
		node.declareNamespace(prefix, URI);
	}
}