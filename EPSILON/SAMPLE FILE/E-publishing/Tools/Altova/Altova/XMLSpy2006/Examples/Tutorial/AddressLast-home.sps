<?xml version="1.0" encoding="UTF-8"?>
<structure version="2" schemafile="AddressLast-home.xsd" workingxmlfile="CompanyLast.xml" templatexmlfile="">
	<nspair prefix="n1" uri="http://my-company.com/namespace"/>
	<nspair prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
	<template>
		<match overwrittenxslmatch="/"/>
		<children>
			<table>
				<styles font-family="Arial" font-size="larger" font-weight="bold"/>
				<properties width="300"/>
				<children>
					<tablebody>
						<children>
							<tablerow>
								<children>
									<tablecol>
										<properties align="center" width="314"/>
										<children>
											<text fixtext="Your Company">
												<styles font-family="Arial" font-size="larger" font-weight="bold"/>
											</text>
											<newline/>
										</children>
									</tablecol>
								</children>
							</tablerow>
						</children>
					</tablebody>
				</children>
			</table>
			<newline/>
			<template>
				<match match="n1:Company"/>
				<children>
					<template>
						<match match="n1:Address"/>
						<children>
							<text fixtext="Address">
								<styles font-size="medium" font-weight="bold"/>
							</text>
							<table dynamic="1" topdown="0">
								<properties bgcolor="#FFDDCA" border="0" width="233"/>
								<children>
									<tablebody>
										<children>
											<tablerow>
												<properties bgcolor="#FFD7C4"/>
												<children>
													<tablecol>
														<properties width="54"/>
														<children>
															<text fixtext="Name "/>
														</children>
													</tablecol>
													<tablecol dynamic="1">
														<properties bgcolor="white"/>
														<children>
															<template>
																<match match="n1:Name"/>
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
														<properties width="54"/>
														<children>
															<text fixtext="Street"/>
														</children>
													</tablecol>
													<tablecol dynamic="1">
														<properties bgcolor="white"/>
														<children>
															<template>
																<match match="n1:Street"/>
																<children>
																	<xpath allchildren="1"/>
																</children>
															</template>
														</children>
													</tablecol>
												</children>
											</tablerow>
											<tablerow>
												<properties bgcolor="#FFD5BF"/>
												<children>
													<tablecol>
														<properties width="54"/>
														<children>
															<text fixtext="City"/>
														</children>
													</tablecol>
													<tablecol dynamic="1">
														<properties bgcolor="white"/>
														<children>
															<template>
																<match match="n1:City"/>
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
														<properties width="54"/>
														<children>
															<text fixtext="State"/>
														</children>
													</tablecol>
													<tablecol dynamic="1">
														<properties bgcolor="white"/>
														<children>
															<template>
																<match match="n1:State"/>
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
														<properties width="54"/>
														<children>
															<text fixtext="Zip"/>
														</children>
													</tablecol>
													<tablecol dynamic="1">
														<properties bgcolor="white"/>
														<children>
															<template>
																<match match="n1:Zip"/>
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
					<template>
						<match match="n1:Person"/>
						<children>
							<text fixtext="Employees">
								<styles font-size="medium" font-weight="bold"/>
							</text>
							<table dynamic="1">
								<properties width="600"/>
								<children>
									<tableheader>
										<children>
											<tablerow>
												<properties bgcolor="#E9E9E9"/>
												<children>
													<tablecol>
														<properties align="center"/>
														<children>
															<text fixtext="Manager">
																<styles font-weight="bold"/>
															</text>
														</children>
													</tablecol>
													<tablecol>
														<properties align="center"/>
														<children>
															<text fixtext="Programmer">
																<styles font-weight="bold"/>
															</text>
														</children>
													</tablecol>
													<tablecol>
														<properties align="center"/>
														<children>
															<text fixtext="Degree">
																<styles font-weight="bold"/>
															</text>
														</children>
													</tablecol>
													<tablecol>
														<properties align="center"/>
														<children>
															<text fixtext="First">
																<styles font-weight="bold"/>
															</text>
														</children>
													</tablecol>
													<tablecol>
														<properties align="center"/>
														<children>
															<text fixtext="Last">
																<styles font-weight="bold"/>
															</text>
														</children>
													</tablecol>
													<tablecol>
														<properties align="center"/>
														<children>
															<text fixtext="PhoneExt">
																<styles font-weight="bold"/>
															</text>
														</children>
													</tablecol>
													<tablecol>
														<properties align="center"/>
														<children>
															<text fixtext="Email">
																<styles font-weight="bold"/>
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
												<properties bgcolor="#9DCECE"/>
												<children>
													<tablecol>
														<children>
															<template>
																<match match="@Manager"/>
																<children>
																	<select ownvalue="1">
																		<properties size="0"/>
																		<selectoption description="true" value="true"/>
																		<selectoption description="false" value="false"/>
																	</select>
																</children>
															</template>
														</children>
													</tablecol>
													<tablecol>
														<children>
															<template>
																<match match="@Programmer"/>
																<children>
																	<select ownvalue="1">
																		<properties size="0"/>
																		<selectoption description="true" value="true"/>
																		<selectoption description="false" value="false"/>
																	</select>
																</children>
															</template>
														</children>
													</tablecol>
													<tablecol>
														<children>
															<template>
																<editorproperties adding="mandatory" autoaddname="1" editable="1" markupmode="hide" userinfo="Ph.D, MA or BA are the only valid values."/>
																<match match="@Degree"/>
																<children>
																	<xpath allchildren="1"/>
																</children>
															</template>
														</children>
													</tablecol>
													<tablecol>
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
														<children>
															<template>
																<match match="n1:Email"/>
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
			</template>
			<newline/>
		</children>
	</template>
	<pagelayout>
		<properties pagemultiplepages="0" pagenumberingformat="1" pagenumberingstartat="1" paperheight="11in" papermarginbottom="0.79in" papermarginleft="0.6in" papermarginright="0.6in" papermargintop="0.79in" paperwidth="8.5in"/>
	</pagelayout>
</structure>
