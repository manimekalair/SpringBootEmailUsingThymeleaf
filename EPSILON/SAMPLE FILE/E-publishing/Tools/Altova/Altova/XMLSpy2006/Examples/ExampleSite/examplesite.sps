<?xml version="1.0" encoding="UTF-8"?>
<structure version="2" schemafile="site.xsd" workingxmlfile="introduction.xml" templatexmlfile="introduction.xml">
	<xmltablesupport standard="HTML"/>
	<nspair prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
	<template>
		<match overwrittenxslmatch="/"/>
		<children>
			<template>
				<match match="main"/>
				<children>
					<template>
						<match match="pagetitle"/>
						<children>
							<table>
								<properties width="100%"/>
								<children>
									<tablebody>
										<children>
											<tablerow>
												<children>
													<tablecol>
														<styles border-top-color="black" border-top-style="dashed" border-top-width="thin" font-family="@Arial Unicode MS" font-size="large" text-transform="capitalize"/>
														<properties height="32"/>
														<children>
															<xpath allchildren="1">
																<styles font-weight="bold"/>
															</xpath>
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
					<table>
						<properties width="100%"/>
						<children>
							<tablebody>
								<children>
									<tablerow>
										<children>
											<tablecol>
												<styles color="white"/>
												<properties bgColor="black" width="146"/>
												<children>
													<text fixtext="NAVIGATION">
														<styles font-weight="bold"/>
													</text>
													<text>
														<styles font-weight="bold"/>
													</text>
												</children>
											</tablecol>
											<tablecol>
												<styles border-top-color="black" border-top-style="solid" border-top-width="thin"/>
												<properties width="502"/>
												<children>
													<text fixtext="CONTENT">
														<styles font-weight="bold"/>
													</text>
												</children>
											</tablecol>
											<tablecol>
												<styles border-right-color="black" border-right-style="solid" border-right-width="thin" border-top-color="black" border-top-style="solid" border-top-width="thin"/>
												<children>
													<text fixtext="BANNERS">
														<styles font-weight="bold"/>
													</text>
												</children>
											</tablecol>
										</children>
									</tablerow>
									<tablerow>
										<children>
											<tablecol>
												<properties bgColor="black" height="380" valign="top" width="146"/>
												<children>
													<template>
														<styles color="white"/>
														<editorproperties adding="mandatory" autoaddname="1" editable="0" markupmode="hide"/>
														<match match="dictionaries"/>
														<children>
															<template>
																<styles color="white"/>
																<match match="navigation"/>
																<children>
																	<template>
																		<styles color="white"/>
																		<match match="menu"/>
																		<children>
																			<template>
																				<styles color="white"/>
																				<match match="menu"/>
																				<children>
																					<template>
																						<styles color="white"/>
																						<match match="title"/>
																						<children>
																							<xpath allchildren="1"/>
																							<newline/>
																						</children>
																					</template>
																					<template>
																						<styles color="white"/>
																						<match match="menu"/>
																						<children>
																							<template>
																								<styles color="white"/>
																								<match match="title"/>
																								<children>
																									<text fixtext="  -  "/>
																									<xpath allchildren="1"/>
																									<newline/>
																								</children>
																							</template>
																						</children>
																					</template>
																				</children>
																			</template>
																		</children>
																	</template>
																</children>
															</template>
														</children>
													</template>
												</children>
											</tablecol>
											<tablecol>
												<styles border-bottom-color="black" border-bottom-style="solid" border-bottom-width="thin"/>
												<properties height="380" valign="top" width="502"/>
												<children>
													<template>
														<editorproperties adding="mandatory" autoaddname="1" editable="0" markupmode="hide"/>
														<match match="dictionaries"/>
														<children>
															<template>
																<match match="blocks"/>
																<children>
																	<template>
																		<match match="block_instance"/>
																		<children>
																			<template>
																				<match match="pagefragment"/>
																				<children>
																					<xpath allchildren="1"/>
																					<newline/>
																				</children>
																			</template>
																		</children>
																	</template>
																</children>
															</template>
														</children>
													</template>
													<newline/>
													<newline/>
													<newline/>
													<newline/>
													<template>
														<match match="content"/>
														<children>
															<xpath allchildren="1"/>
														</children>
													</template>
												</children>
											</tablecol>
											<tablecol>
												<styles border-bottom-color="black" border-bottom-style="solid" border-bottom-width="thin" border-right-color="black" border-right-style="solid" border-right-width="thin"/>
												<properties height="380"/>
												<children>
													<text fixtext=" "/>
												</children>
											</tablecol>
										</children>
									</tablerow>
								</children>
							</tablebody>
						</children>
					</table>
					<newline/>
					<newline/>
					<newline/>
					<newline/>
					<newline/>
					<newline/>
					<newline/>
					<newline/>
					<table>
						<properties width="100%"/>
						<children>
							<tablebody>
								<children>
									<tablerow>
										<children>
											<tablecol/>
											<tablecol>
												<properties width="361"/>
											</tablecol>
											<tablecol/>
										</children>
									</tablerow>
									<tablerow>
										<children>
											<tablecol>
												<styles border-top-color="black" border-top-style="dashed" border-top-width="thin"/>
												<properties bgColor="silver"/>
												<children>
													<text fixtext="idref:  "/>
													<template>
														<match match="idref"/>
														<children>
															<xpath allchildren="1"/>
														</children>
													</template>
												</children>
											</tablecol>
											<tablecol>
												<styles border-top-color="black" border-top-style="dashed" border-top-width="thin"/>
												<properties bgColor="silver" width="361"/>
												<children>
													<text fixtext="titlepage:  "/>
													<template>
														<match match="pagetitle"/>
														<children>
															<xpath allchildren="1"/>
														</children>
													</template>
												</children>
											</tablecol>
											<tablecol>
												<styles border-top-color="black" border-top-style="dashed" border-top-width="thin"/>
												<properties bgColor="silver"/>
												<children>
													<text fixtext="stylesheet:  Altova Build 2"/>
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
	<template>
		<match match="br"/>
		<children>
			<newline/>
		</children>
	</template>
	<template>
		<match match="img"/>
		<children>
			<image>
				<properties border="0"/>
				<imagesource>
					<xpath value="@src"/>
				</imagesource>
			</image>
		</children>
	</template>
	<template>
		<match match="links"/>
		<children>
			<xpath allchildren="1"/>
		</children>
	</template>
	<template>
		<match match="list"/>
		<children>
			<list>
				<styles marginBottom="0" marginTop="0"/>
				<children>
					<listrow>
						<children>
							<xpath allchildren="1"/>
						</children>
					</listrow>
				</children>
			</list>
		</children>
	</template>
	<template>
		<match match="menu"/>
		<children>
			<table>
				<properties border="1" width="50%"/>
				<children>
					<tablebody>
						<children>
							<tablerow>
								<children>
									<tablecol>
										<properties align="left" colspan="5" valign="top" width="243"/>
										<children>
											<table>
												<properties bgcolor="silver" width="50%"/>
												<children>
													<tablebody>
														<children>
															<tablerow>
																<children>
																	<tablecol>
																		<styles border-bottom-color="black" border-bottom-style="double" border-bottom-width="thin"/>
																		<properties align="center" colspan="2" width="384"/>
																		<children>
																			<text fixtext="MENU LINK"/>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="159"/>
																	</tablecol>
																</children>
															</tablerow>
															<tablerow>
																<children>
																	<tablecol>
																		<styles white-space="pre"/>
																		<properties width="224"/>
																		<children>
																			<text fixtext="TITLE:"/>
																			<template>
																				<match match="title"/>
																				<children>
																					<xpath allchildren="1"/>
																				</children>
																			</template>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="288"/>
																		<children>
																			<text fixtext="URL:"/>
																			<template>
																				<match match="url"/>
																				<children>
																					<xpath allchildren="1"/>
																				</children>
																			</template>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="159"/>
																	</tablecol>
																</children>
															</tablerow>
															<tablerow>
																<children>
																	<tablecol>
																		<properties width="224"/>
																		<children>
																			<text fixtext="IDREF"/>
																			<template>
																				<match match="idref"/>
																				<children>
																					<xpath allchildren="1"/>
																				</children>
																			</template>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="288"/>
																	</tablecol>
																	<tablecol>
																		<properties width="159"/>
																	</tablecol>
																</children>
															</tablerow>
															<tablerow>
																<children>
																	<tablecol>
																		<properties align="center" width="224"/>
																		<children>
																			<text fixtext="TITLE2"/>
																			<template>
																				<match match="title"/>
																				<children>
																					<xpath allchildren="1"/>
																				</children>
																			</template>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties align="center" width="288"/>
																	</tablecol>
																	<tablecol>
																		<properties align="center" width="159"/>
																	</tablecol>
																</children>
															</tablerow>
															<tablerow>
																<children>
																	<tablecol>
																		<properties width="224"/>
																		<children>
																			<text fixtext="ID"/>
																			<template>
																				<match match="id"/>
																				<children>
																					<xpath allchildren="1"/>
																				</children>
																			</template>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="288"/>
																		<children>
																			<text fixtext="LINKIDREF"/>
																			<template>
																				<match match="link_idref"/>
																				<children>
																					<xpath allchildren="1"/>
																				</children>
																			</template>
																		</children>
																	</tablecol>
																	<tablecol>
																		<properties width="159"/>
																	</tablecol>
																</children>
															</tablerow>
														</children>
													</tablebody>
												</children>
											</table>
										</children>
									</tablecol>
									<tablecol>
										<styles vertical-Align="super"/>
										<properties align="left" valign="top" width="552"/>
										<children>
											<template>
												<match match="menu"/>
												<children>
													<list>
														<styles marginBottom="0" marginTop="0"/>
														<children>
															<listrow>
																<styles vertical-Align="super"/>
																<children>
																	<table>
																		<properties border="1"/>
																		<children>
																			<tablebody>
																				<children>
																					<tablerow>
																						<children>
																							<tablecol>
																								<styles vertical-Align="super"/>
																								<children>
																									<xpath/>
																								</children>
																							</tablecol>
																						</children>
																					</tablerow>
																				</children>
																			</tablebody>
																		</children>
																	</table>
																</children>
															</listrow>
														</children>
													</list>
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
	<template>
		<match match="navigation"/>
		<children>
			<xpath allchildren="1"/>
		</children>
	</template>
	<template>
		<match match="para"/>
		<children>
			<paragraph paragraphtag="p">
				<children>
					<xpath allchildren="1"/>
				</children>
			</paragraph>
		</children>
	</template>
</structure>
