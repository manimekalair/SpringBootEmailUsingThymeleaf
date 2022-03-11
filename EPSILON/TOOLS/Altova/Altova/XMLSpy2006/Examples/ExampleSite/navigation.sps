<?xml version="1.0" encoding="UTF-8"?>
<structure version="2" schemafile="site.xsd" workingxmlfile="navigation.xml" templatexmlfile="navigation.xml">
	<nspair prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
	<template>
		<match overwrittenxslmatch="/"/>
		<children>
			<table>
				<properties width="90%"/>
				<children>
					<tablebody>
						<children>
							<tablerow>
								<children>
									<tablecol>
										<children>
											<xpath allchildren="1"/>
										</children>
									</tablecol>
									<tablecol>
										<properties valign="top"/>
										<children>
											<table>
												<properties border="1" width="100%"/>
												<children>
													<tablebody>
														<children>
															<tablerow>
																<children>
																	<tablecol>
																		<properties valign="top"/>
																		<children>
																			<text fixtext="This is a graphical layout of the navigation of the the site. This is not to be an editable file, rather an guide to create valid documents.  The &quot;top&quot; elements are strictly the root elements that contains the structure of each branch.  They represent the menu items that contain the links to each page.  Each page is reprensented with an html icon, for visual reference."/>
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
		<editorproperties adding="mandatory" autoaddname="1" editable="0" markupmode="hide"/>
		<match match="menu"/>
		<children>
			<table>
				<properties width="75%"/>
				<children>
					<tablebody>
						<children>
							<tablerow>
								<children>
									<tablecol>
										<styles border-bottom-color="black" border-bottom-style="solid" border-bottom-width="thin"/>
										<properties align="left" colspan="2" width="201"/>
										<children>
											<table>
												<properties width="100%"/>
												<children>
													<tablebody>
														<children>
															<tablerow>
																<children>
																	<tablecol>
																		<properties align="center" valign="top"/>
																		<children>
																			<template>
																				<match match="url"/>
																				<children>
																					<image>
																						<properties border="0"/>
																						<imagesource>
																							<fixtext value="html_icon.bmp"/>
																						</imagesource>
																					</image>
																				</children>
																			</template>
																			<newline/>
																			<template>
																				<match match="url"/>
																				<children>
																					<xpath allchildren="1"/>
																				</children>
																			</template>
																			<newline/>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties align="right" width="176"/>
																		<children>
																			<table>
																				<properties width="100%"/>
																				<children>
																					<tablebody>
																						<children>
																							<tablerow>
																								<children>
																									<tablecol>
																										<properties width="51"/>
																										<children>
																											<text fixtext="Title"/>
																										</children>
																									</tablecol>
																									<tablecol>
																										<children>
																											<template>
																												<match match="title"/>
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
																										<properties width="51"/>
																										<children>
																											<text fixtext="ID"/>
																										</children>
																									</tablecol>
																									<tablecol>
																										<children>
																											<template>
																												<match match="id"/>
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
																										<properties width="51"/>
																										<children>
																											<text fixtext="URL"/>
																										</children>
																									</tablecol>
																									<tablecol>
																										<children>
																											<template>
																												<match match="url"/>
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
									</tablecol>
								</children>
							</tablerow>
							<tablerow>
								<children>
									<tablecol>
										<properties width="201"/>
									</tablecol>
									<tablecol>
										<properties width="176"/>
										<children>
											<xpath restofcontents="1"/>
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
</structure>
