<?xml version="1.0" encoding="UTF-8"?>
<structure version="2" schemafile="HTML-OrgChart.xsd" workingxmlfile="Html-OrgChart.xml" templatexmlfile="">
	<xmltablesupport standard="HTML"/>
	<nspair prefix="n1" uri="http://www.xmlspy.com/schemas/orgchart"/>
	<nspair prefix="ipo" uri="http://www.altova.com/IPO"/>
	<nspair prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
	<template>
		<match overwrittenxslmatch="/"/>
		<children>
			<template>
				<match match="n1:OrgChart"/>
				<children>
					<template>
						<match match="n1:Name"/>
						<children>
							<xpath allchildren="1">
								<styles font-size="large" font-weight="bold"/>
							</xpath>
						</children>
					</template>
					<newline/>
					<template>
						<match match="n1:Office"/>
						<children>
							<template>
								<match match="n1:Name"/>
								<children>
									<paragraph>
										<children>
											<xpath allchildren="1">
												<styles color="red" font-size="medium"/>
											</xpath>
										</children>
									</paragraph>
								</children>
							</template>
							<table>
								<properties width="60%"/>
								<children>
									<tablebody>
										<children>
											<tablerow>
												<properties valign="top"/>
												<children>
													<tablecol>
														<properties width="50%"/>
														<children>
															<template>
																<match match="n1:Address"/>
																<children>
																	<table dynamic="1" topdown="0">
																		<properties border="1" cellspacing="0" width="100%"/>
																		<children>
																			<tablebody>
																				<children>
																					<tablerow>
																						<children>
																							<tablecol>
																								<properties width="25%"/>
																								<children>
																									<text fixtext="street"/>
																								</children>
																							</tablecol>
																							<tablecol dynamic="1">
																								<properties width="75%"/>
																								<children>
																									<template>
																										<match match="ipo:street"/>
																										<children>
																											<xpath allchildren="1"/>
																										</children>
																									</template>
																								</children>
																							</tablecol>
																						</children>
																					</tablerow>
																					<tablerow>
																						<children>
																							<tablecol>
																								<properties height="26" width="25%"/>
																								<children>
																									<text fixtext="city"/>
																								</children>
																							</tablecol>
																							<tablecol dynamic="1">
																								<properties height="26" width="75%"/>
																								<children>
																									<template>
																										<match match="ipo:city"/>
																										<children>
																											<select ownvalue="1">
																												<properties size="0"/>
																												<selectoption description="Athens" value="1"/>
																												<selectoption description="Paris" value="2"/>
																											</select>
																										</children>
																									</template>
																								</children>
																							</tablecol>
																						</children>
																					</tablerow>
																					<tablerow>
																						<children>
																							<tablecol>
																								<properties width="25%"/>
																								<children>
																									<text fixtext="state/zip"/>
																								</children>
																							</tablecol>
																							<tablecol dynamic="1">
																								<properties width="75%"/>
																								<children>
																									<template>
																										<match match="ipo:state"/>
																										<children>
																											<xpath allchildren="1"/>
																										</children>
																									</template>
																									<text fixtext="/"/>
																									<template>
																										<match match="ipo:zip"/>
																										<children>
																											<xpath allchildren="1"/>
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
															<newline/>
														</children>
													</tablecol>
													<tablecol>
														<properties valign="top" width="50%"/>
														<children>
															<table>
																<properties border="1" cellspacing="0" width="100%"/>
																<children>
																	<tablebody>
																		<children>
																			<tablerow>
																				<children>
																					<tablecol>
																						<properties width="35%"/>
																						<children>
																							<text fixtext="Phone"/>
																						</children>
																					</tablecol>
																					<tablecol>
																						<properties width="65%"/>
																						<children>
																							<template>
																								<match match="n1:Phone"/>
																								<children>
																									<xpath allchildren="1"/>
																								</children>
																							</template>
																						</children>
																					</tablecol>
																				</children>
																			</tablerow>
																			<tablerow>
																				<children>
																					<tablecol>
																						<properties height="26" width="35%"/>
																						<children>
																							<text fixtext="Fax"/>
																						</children>
																					</tablecol>
																					<tablecol>
																						<properties height="26" width="65%"/>
																						<children>
																							<template>
																								<match match="n1:Fax"/>
																								<children>
																									<xpath allchildren="1"/>
																								</children>
																							</template>
																						</children>
																					</tablecol>
																				</children>
																			</tablerow>
																			<tablerow>
																				<children>
																					<tablecol>
																						<properties width="35%"/>
																						<children>
																							<text fixtext="Email"/>
																						</children>
																					</tablecol>
																					<tablecol>
																						<properties width="65%"/>
																						<children>
																							<template>
																								<match match="n1:EMail"/>
																								<children>
																									<xpath allchildren="1"/>
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
													</tablecol>
												</children>
											</tablerow>
										</children>
									</tablebody>
								</children>
							</table>
						</children>
					</template>
					<template>
						<match match="n1:Office"/>
						<children>
							<newline/>
							<template>
								<match match="n1:Desc"/>
								<children>
									<template>
										<match match="n1:para"/>
										<children>
											<paragraph>
												<children>
													<xpath allchildren="1"/>
												</children>
											</paragraph>
										</children>
									</template>
								</children>
							</template>
							<newline/>
							<template>
								<match match="n1:Department"/>
								<children>
									<newline/>
									<template>
										<match match="n1:Name"/>
										<children>
											<paragraph>
												<children>
													<xpath allchildren="1">
														<styles font-weight="bold"/>
													</xpath>
												</children>
											</paragraph>
										</children>
									</template>
									<template>
										<match match="n1:Person"/>
										<children>
											<table dynamic="1">
												<properties bgcolor="white" width="60%"/>
												<children>
													<tableheader>
														<children>
															<tablerow>
																<properties bgcolor="silver"/>
																<children>
																	<tablecol>
																		<properties width="12%"/>
																		<children>
																			<text fixtext="First"/>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="18%"/>
																		<children>
																			<text fixtext="Last"/>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="28%"/>
																		<children>
																			<text fixtext="Title"/>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="10%"/>
																		<children>
																			<text fixtext="PhoneExt"/>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="32%"/>
																		<children>
																			<text fixtext="EMail"/>
																		</children>
																	</tablecol>
																</children>
															</tablerow>
														</children>
													</tableheader>
													<tablebody>
														<children>
															<tablerow>
																<properties bgcolor="yellow"/>
																<children>
																	<tablecol>
																		<properties width="12%"/>
																		<children>
																			<template>
																				<match match="n1:First"/>
																				<children>
																					<xpath allchildren="1"/>
																				</children>
																			</template>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="18%"/>
																		<children>
																			<template>
																				<match match="n1:Last"/>
																				<children>
																					<xpath allchildren="1"/>
																				</children>
																			</template>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="28%"/>
																		<children>
																			<template>
																				<match match="n1:Title"/>
																				<children>
																					<xpath allchildren="1"/>
																				</children>
																			</template>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="10%"/>
																		<children>
																			<template>
																				<match match="n1:PhoneExt"/>
																				<children>
																					<xpath allchildren="1"/>
																				</children>
																			</template>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="32%"/>
																		<children>
																			<template>
																				<match match="n1:EMail"/>
																				<children>
																					<xpath allchildren="1"/>
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
						</children>
					</template>
					<newline/>
					<newline/>
					<newline/>
				</children>
			</template>
		</children>
	</template>
	<pagelayout>
		<properties pagemultiplepages="0" pagenumberingformat="1" pagenumberingstartat="1" paperheight="11in" papermarginbottom="0.79in" papermarginleft="0.6in" papermarginright="0.6in" papermargintop="0.79in" paperwidth="8.5in"/>
	</pagelayout>
</structure>
