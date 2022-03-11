<?xml version="1.0" encoding="UTF-8"?>
<structure version="3" xsltversion="1">
	<database>
		<database_connection>
			<connect database-kind="Access" import-kind="Access">
				<connection_type>
					<connection_string>Provider=Microsoft.Jet.OLEDB.4.0;Data Source=Import\altova.mdb</connection_string>
				</connection_type>
				<map_xml_settings>
					<use_mapped_names>true</use_mapped_names>
					<map_primary_keys>false</map_primary_keys>
					<map_foreign_keys>false</map_foreign_keys>
					<map_unique_keys>false</map_unique_keys>
					<attributes_only>true</attributes_only>
					<extension>None</extension>
					<mode>Hierarchical</mode>
				</map_xml_settings>
			</connect>
			<server name="altova.mdb">
				<database name="altova">
					<schema name="">
						<table name="Address" kind="UserTable"/>
						<table name="Altova" kind="UserTable"/>
						<table name="Department" kind="UserTable"/>
						<table name="Office" kind="UserTable"/>
						<table name="Person" kind="UserTable"/>
					</schema>
				</database>
			</server>
		</database_connection>
	</database>
	<nspair prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
	<template>
		<match overwrittenxslmatch="/"/>
		<children>
			<template>
				<match match="DB"/>
				<children>
					<template>
						<editorproperties adding="mandatory" autoaddname="1" editable="1" elementstodisplay="1" markupmode="hide"/>
						<match match="Office"/>
						<children>
							<dbcontrols button="first" button1="prev" button2="next" button3="last"/>
							<text fixtext=" "/>
							<dbcontrols/>
							<newline/>
							<template>
								<editorproperties adding="mandatory" autoaddname="1" editable="1" markupmode="hide"/>
								<match match="Row"/>
								<children>
									<template>
										<match match="@Name"/>
										<children>
											<xpath allchildren="1">
												<styles color="#0588BA" font-family="Arial" font-size="20pt" font-weight="bold"/>
											</xpath>
										</children>
									</template>
									<template>
										<match match="Address"/>
										<children>
											<newline/>
											<newline/>
											<template>
												<editorproperties adding="mandatory" autoaddname="1" editable="1" markupmode="hide"/>
												<match match="Row"/>
												<children>
													<table>
														<properties border="0"/>
														<children>
															<tablebody>
																<children>
																	<tablerow>
																		<children>
																			<tablecol>
																				<children>
																					<text fixtext="City:"/>
																				</children>
																			</tablecol>
																			<tablecol>
																				<children>
																					<template>
																						<match match="@city"/>
																						<children>
																							<field ownvalue="1">
																								<styles font-weight="bold"/>
																								<properties size="40" value=""/>
																							</field>
																						</children>
																					</template>
																				</children>
																			</tablecol>
																		</children>
																	</tablerow>
																	<tablerow>
																		<children>
																			<tablecol>
																				<children>
																					<text fixtext="State:"/>
																				</children>
																			</tablecol>
																			<tablecol>
																				<children>
																					<template>
																						<match match="@state"/>
																						<children>
																							<field ownvalue="1">
																								<styles font-weight="bold"/>
																								<properties size="40" value=""/>
																							</field>
																						</children>
																					</template>
																				</children>
																			</tablecol>
																		</children>
																	</tablerow>
																	<tablerow>
																		<children>
																			<tablecol>
																				<children>
																					<text fixtext="Street:"/>
																				</children>
																			</tablecol>
																			<tablecol>
																				<children>
																					<template>
																						<match match="@street"/>
																						<children>
																							<field ownvalue="1">
																								<styles font-weight="bold"/>
																								<properties size="40" value=""/>
																							</field>
																						</children>
																					</template>
																				</children>
																			</tablecol>
																		</children>
																	</tablerow>
																	<tablerow>
																		<children>
																			<tablecol>
																				<children>
																					<text fixtext="Zip Code:"/>
																				</children>
																			</tablecol>
																			<tablecol>
																				<children>
																					<template>
																						<match match="@zip"/>
																						<children>
																							<field ownvalue="1">
																								<styles font-weight="bold"/>
																								<properties size="40" value=""/>
																							</field>
																						</children>
																					</template>
																				</children>
																			</tablecol>
																		</children>
																	</tablerow>
																</children>
															</tablebody>
														</children>
													</table>
												</children>
											</template>
										</children>
									</template>
									<newline/>
									<newline/>
									<template>
										<editorproperties adding="mandatory" autoaddname="1" editable="1" elementstodisplay="all" markupmode="hide"/>
										<match match="Department"/>
										<children>
											<template>
												<editorproperties adding="mandatory" autoaddname="1" editable="1" markupmode="hide"/>
												<match match="Row"/>
												<children>
													<template>
														<match match="@Name"/>
														<children>
															<xpath allchildren="1">
																<styles color="#D39658" font-family="Arial" font-weight="bold"/>
															</xpath>
														</children>
													</template>
													<text fixtext=" "/>
													<template>
														<editorproperties adding="mandatory" autoaddname="1" editable="1" elementstodisplay="2" markupmode="hide"/>
														<match match="Person"/>
														<children>
															<dbcontrols button="first" button1="prev" button2="goto" button3="next" button4="last"/>
															<template>
																<editorproperties adding="mandatory" autoaddname="1" editable="1" markupmode="hide"/>
																<match match="Row"/>
																<children>
																	<table dynamic="1">
																		<properties border="1"/>
																		<children>
																			<tableheader>
																				<children>
																					<tablerow>
																						<properties bgcolor="#D2C8AE"/>
																						<children>
																							<tablecol>
																								<properties align="center" height="32" width="100"/>
																								<children>
																									<text fixtext="First">
																										<styles color="#606060" font-family="Arial" font-weight="bold"/>
																									</text>
																								</children>
																							</tablecol>
																							<tablecol>
																								<properties align="center" height="32" width="100"/>
																								<children>
																									<text fixtext="Last">
																										<styles color="#606060" font-family="Arial" font-weight="bold"/>
																									</text>
																								</children>
																							</tablecol>
																							<tablecol>
																								<properties align="center" height="32" width="120"/>
																								<children>
																									<text fixtext="Title">
																										<styles color="#606060" font-family="Arial" font-weight="bold"/>
																									</text>
																								</children>
																							</tablecol>
																							<tablecol>
																								<properties align="center" height="32" width="80"/>
																								<children>
																									<text fixtext="Ext">
																										<styles color="#606060" font-family="Arial" font-weight="bold"/>
																									</text>
																								</children>
																							</tablecol>
																							<tablecol>
																								<properties align="center" height="32" width="150"/>
																								<children>
																									<text fixtext="EMail">
																										<styles color="#606060" font-family="Arial" font-weight="bold"/>
																									</text>
																								</children>
																							</tablecol>
																						</children>
																					</tablerow>
																				</children>
																			</tableheader>
																			<tablebody>
																				<children>
																					<tablerow>
																						<children>
																							<tablecol>
																								<properties width="100"/>
																								<children>
																									<template>
																										<match match="@First"/>
																										<children>
																											<xpath allchildren="1">
																												<styles font-size="10pt"/>
																											</xpath>
																										</children>
																									</template>
																								</children>
																							</tablecol>
																							<tablecol>
																								<properties width="100"/>
																								<children>
																									<template>
																										<match match="@Last"/>
																										<children>
																											<xpath allchildren="1">
																												<styles font-size="10pt"/>
																											</xpath>
																										</children>
																									</template>
																								</children>
																							</tablecol>
																							<tablecol>
																								<properties width="120"/>
																								<children>
																									<template>
																										<match match="@Title"/>
																										<children>
																											<xpath allchildren="1">
																												<styles font-size="10pt"/>
																											</xpath>
																										</children>
																									</template>
																								</children>
																							</tablecol>
																							<tablecol>
																								<properties width="80"/>
																								<children>
																									<template>
																										<match match="@PhoneExt"/>
																										<children>
																											<xpath allchildren="1">
																												<styles font-size="10pt"/>
																											</xpath>
																										</children>
																									</template>
																								</children>
																							</tablecol>
																							<tablecol>
																								<properties width="150"/>
																								<children>
																									<template>
																										<match match="@EMail"/>
																										<children>
																											<link>
																												<hyperlink>
																													<fixtext value="mailto:"/>
																													<xpath value="."/>
																												</hyperlink>
																												<children>
																													<xpath allchildren="1">
																														<styles font-size="10pt"/>
																													</xpath>
																												</children>
																											</link>
																										</children>
																									</template>
																								</children>
																							</tablecol>
																						</children>
																					</tablerow>
																				</children>
																			</tablebody>
																		</children>
																	</table>
																</children>
															</template>
														</children>
													</template>
													<newline/>
												</children>
											</template>
										</children>
									</template>
									<newline/>
								</children>
							</template>
							<newline/>
							<newline withpagebreak="1">
								<styles page-break-after="always"/>
							</newline>
						</children>
					</template>
				</children>
			</template>
		</children>
	</template>
	<pagelayout>
		<properties pagemultiplepages="0" pagenumberingformat="1" pagenumberingstartat="1" paperheight="11in" papermarginbottom="0.79in" papermarginleft="0.6in" papermarginright="0.6in" papermargintop="0.79in" paperwidth="8.5in"/>
	</pagelayout>
</structure>
