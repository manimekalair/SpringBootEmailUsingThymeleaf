[
$wsdlReturnNode=""
foreach $AlgorithmGroup in $AlgorithmGroups
	$AlgorithmGroupClass = $application.Name & $AlgorithmGroup.Name
	$Args = ""
	if $application.IsWebService
]	try 
	{
	[endif]
			[=$AlgorithmGroupClass] [=$AlgorithmGroupClass]Object = new [=$AlgorithmGroupClass]();

[
	' register classes
	foreach $SourceLibrary in $AlgorithmGroup.SourceLibraryList
		if $SourceLibrary.Kind = 2 ' Database Library
]			Class.forName("[=$SourceLibrary.JDBCDriver]");
[		endif
		if $SourceLibrary.Kind = 5 ' WS librrary
			call OpenSourceLibraryWSDLfromElements ($SourceLibrary, "",  $lInstance)
		endif
	next
	if $AlgorithmGroup.TargetLibrary.Kind = 2 ' Database Library
]			Class.forName("[=$AlgorithmGroup.TargetLibrary.JDBCDriver]");
[	endif
	if $AlgorithmGroup.TargetLibrary.Kind = 5 ' WS Library
			call OpenTargetLibraryWSDL ($AlgorithmGroup.TargetContext.UniqueName, "")
	endif
]
			[=$AlgorithmGroupClass]Object.registerTraceTarget(ttc);
	
			[=$AlgorithmGroupClass]Object.run(
																[ 
	' Source Libraries
	foreach $SourceLibrary in $AlgorithmGroup.SourceLibraryList

		if $SourceLibrary.Kind = 1 ' XML Library
			]"[=$SourceLibrary.InputInstanceName]"[
		endif

		if $SourceLibrary.Kind = 2 ' Database Library
			]java.sql.DriverManager.getConnection(
							"[=$SourceLibrary.JDBCURL]",
							"[=$SourceLibrary.DBUser]",
							"[=$SourceLibrary.DBPassword]")[
		endif

		if $SourceLibrary.Kind = 3 ' Text Library
			]"[=$SourceLibrary.InputFileName]"[
		endif

		if $SourceLibrary.Kind = 4 ' Parameter Library
			]( mapArguments.containsKey( \"[=$SourceLibrary.Name]\" ) ? new [=$SourceLibrary.DataType]( ( String )mapArguments.get( \"[=$SourceLibrary.Name]\" ) ) : new [=$SourceLibrary.DataType]() )[
		endif

		if $SourceLibrary.Kind = 5 ' WS Library
			$lSource = $SourceLibrary.Message.UniqueName
			][=$lSource]SourceObject[
		endif
		
		],
						[
	next

	' Target Library
	if $AlgorithmGroup.TargetLibrary.Kind = 1 ' XML Library
		]"[=$AlgorithmGroup.TargetLibrary.OutputInstanceName]"[
	endif

	if $AlgorithmGroup.TargetLibrary.Kind = 2 ' DB Library
		]java.sql.DriverManager.getConnection(
							"[=$AlgorithmGroup.TargetLibrary.JDBCURL]",
							"[=$AlgorithmGroup.TargetLibrary.DBUser]",
							"[=$AlgorithmGroup.TargetLibrary.DBPassword]")[	
	endif
	
	if $AlgorithmGroup.TargetLibrary.Kind = 3	' Text Library
		]"[=$AlgorithmGroup.TargetLibrary.OutputFileName]"[
	endif
	
	if $AlgorithmGroup.TargetLibrary.Kind = 5 ' WS Library
		$lTarget = $AlgorithmGroup.TargetContext.UniqueName
			]										[=$lTarget]TargetObject[
		$wsdlReturnNode = $lTarget & "TargetObject"
		$WSDLTargetNamespace = $AlgorithmGroup.TargetParentContext.NamespaceURI
	else
		$wsdlReturnNode = ""
	endif
]
															);
[if $application.IsWebService
	if $wsdlReturnNode <> ""]
			responseNode = [=$wsdlReturnNode].getDomNode();[
	endif]
	}
	catch (com.altova.UserException ue)
	{
		if (ue.getNode() == null)
			throw ue;
		org.w3c.dom.Node faultNode = ue.getNode().getDomNode();
		org.w3c.dom.NodeList children = faultNode.getChildNodes();
		int numChildren = children.getLength();
[		if $BindingStyle="rpc" and $BindingUse="encoded"
	]		org.w3c.dom.NamedNodeMap attrs = faultNode.getAttributes();[
		endif]
		org.w3c.dom.Element\[\] faultElements = new org.w3c.dom.Element\[numChildren\];
		for (int i=0; i<numChildren; ++i)
		{
			faultElements\[i\] = (org.w3c.dom.Element) children.item(i);
[		if $BindingStyle="rpc" and $BindingUse="encoded"
]			for (int j = 0; j<attrs.getLength(); ++j)
			{
				org.w3c.dom.Attr attr = (org.w3c.dom.Attr)attrs.item(j);
				faultElements\[i\].setAttribute(attr.getName(), attr.getValue());
			}[
		endif]
		}
		String faultCode = "soapenv:Server.userException";
		String faultString = "MapForce user exception: " + ue.getMessage();
		String faultActor = "[=$application.WSDLPort.Address]";
		org.apache.axis.AxisFault axisFault = new org.apache.axis.AxisFault(faultCode,  faultString, faultActor, faultElements);
		throw axisFault;
	}
[endif
next]
[if $application.IsWebService  = 1 ' WS Library
]			if (responseNode == null)
				return new org.w3c.dom.Element\[1\];
[		if $BindingStyle="document" and $BindingUse="literal"
]			org.w3c.dom.NodeList parts= responseNode.getChildNodes();
			int partsCount = parts.getLength();
			org.w3c.dom.Element\[\] responseElements = new org.w3c.dom.Element\[partsCount\];
			for (int i=0;i<partsCount;i++)
				responseElements\[i\] = (org.w3c.dom.Element)parts.item(i);[
		endif
		if $BindingStyle="rpc" and $BindingUse="encoded"
			$operationName = $mapping.WSDLBindingOperation.Name
]			org.w3c.dom.Document responseDoc = responseNode.getOwnerDocument();
			org.w3c.dom.Element rpcEnvElement;
			rpcEnvElement=responseDoc.createElementNS("[=$WSDLTargetNamespace]", "m:[=$operationName]Response");
			org.w3c.dom.NamedNodeMap attrs = responseNode.getAttributes();
			for (int i = 0; i<attrs.getLength(); i++)
			{
				String attrName = ((org.w3c.dom.Attr)attrs.item(i)).getName();
				rpcEnvElement.setAttribute(attrName, ((org.w3c.dom.Attr)attrs.item(i)).getValue());
			}
			org.w3c.dom.Element\[\] responseElements = new org.w3c.dom.Element\[1\];
			while (responseNode.hasChildNodes())
				rpcEnvElement.appendChild(responseNode.getFirstChild());
			responseElements\[0\] = rpcEnvElement;[
		endif]
			return responseElements;
[endif]