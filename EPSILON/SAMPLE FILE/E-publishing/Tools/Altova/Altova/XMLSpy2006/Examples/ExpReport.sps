<?xml version="1.0" encoding="UTF-8"?>
<structure version="3" schemafile="ExpReport.xsd" workingxmlfile="ExpReport.xml" templatexmlfile="" xsltversion="2" encodinghtml="UTF-8" encodingrtf="UTF-8" encodingpdf="UTF-8">
	<nspair prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
	<template>
		<match overwrittenxslmatch="/"/>
		<children>
			<template>
				<match match="expense-report"/>
				<children>
					<table>
						<properties border="0" table-layout="fixed" width="100%"/>
						<children>
							<tablebody>
								<children>
									<tablerow>
										<children>
											<tablecol>
												<children>
													<table>
														<properties border="0" table-layout="fixed" width="100%"/>
														<children>
															<tablebody>
																<children>
																	<tablerow>
																		<children>
																			<tablecol>
																				<children>
																					<table>
																						<properties border="0" border-collapse="collapse" cellpadding="0" cellspacing="0" width="100%"/>
																						<children>
																							<tablebody>
																								<children>
																									<tablerow>
																										<children>
																											<tablecol>
																												<styles border-bottom-color="#0588BA" border-bottom-style="solid" border-bottom-width="medium"/>
																												<properties colspan="5"/>
																												<children>
																													<image>
																														<properties border="0"/>
																														<imagesource>
																															<fixtext value="http://www.nanonull.com/nanonull.gif"/>
																														</imagesource>
																													</image>
																												</children>
																											</tablecol>
																										</children>
																									</tablerow>
																								</children>
																							</tablebody>
																						</children>
																					</table>
																					<table>
																						<properties border="0" width="100%"/>
																						<children>
																							<tablebody>
																								<children>
																									<tablerow>
																										<children>
																											<tablecol>
																												<properties align="left" rowspan="2" valign="top" width="40%"/>
																												<children>
																													<text fixtext="Business Expense Report">
																														<styles font-size="20pt" font-weight="bold" margin-top="3pt"/>
																													</text>
																												</children>
																											</tablecol>
																											<tablecol>
																												<properties bgcolor="#D2FFFF" width="28%"/>
																												<children>
																													<text>
																														<styles font-family="Tahoma" font-size="10pt" font-weight="bold"/>
																													</text>
																													<template>
																														<match match="@currency"/>
																														<children>
																															<radiobutton ownvalue="1" checkedvalue="USD">
																																<styles font-family="Tahoma" font-size="10pt"/>
																																<properties type="radio"/>
																															</radiobutton>
																															<text fixtext="Dollars">
																																<styles font-family="Tahoma" font-size="10pt"/>
																															</text>
																														</children>
																													</template>
																													<text fixtext=" ">
																														<styles font-family="Tahoma" font-size="10pt"/>
																													</text>
																													<template>
																														<match match="@currency"/>
																														<children>
																															<radiobutton ownvalue="1" checkedvalue="Euro">
																																<styles font-family="Tahoma" font-size="10pt"/>
																																<properties type="radio"/>
																															</radiobutton>
																															<text fixtext="Euros">
																																<styles font-family="Tahoma" font-size="10pt"/>
																															</text>
																														</children>
																													</template>
																													<text fixtext=" ">
																														<styles font-family="Tahoma" font-size="10pt"/>
																													</text>
																													<template>
																														<match match="@currency"/>
																														<children>
																															<radiobutton ownvalue="1" checkedvalue="JPY">
																																<styles font-family="Tahoma" font-size="10pt"/>
																																<properties type="radio"/>
																															</radiobutton>
																															<text fixtext="Yen">
																																<styles font-family="Tahoma" font-size="10pt"/>
																															</text>
																														</children>
																													</template>
																												</children>
																											</tablecol>
																											<tablecol>
																												<properties bgcolor="#D2FFFF" width="12%"/>
																												<children>
																													<text fixtext="Total:  ">
																														<styles font-family="Tahoma" font-size="10pt" font-weight="bold"/>
																													</text>
																													<template>
																														<editorproperties adding="mandatory" autoaddname="1" editable="0" markupmode="hide"/>
																														<match match="@total-sum"/>
																														<children>
																															<xpath allchildren="1">
																																<styles font-family="Tahoma" font-size="10pt"/>
																																<format string="###,##0.00" xslt="1"/>
																															</xpath>
																														</children>
																													</template>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																</testexpression>
																																<children>
																																	<text fixtext="$">
																																		<styles font-size="10pt"/>
																																	</text>
																																</children>
																															</choiceoption>
																															<choiceoption>
																																<testexpression>
																																	<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																</testexpression>
																																<children>
																																	<text fixtext="€">
																																		<styles font-size="x-small"/>
																																	</text>
																																</children>
																															</choiceoption>
																															<choiceoption>
																																<testexpression>
																																	<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																</testexpression>
																																<children>
																																	<text fixtext="¥">
																																		<styles font-size="x-small"/>
																																	</text>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																												</children>
																											</tablecol>
																										</children>
																									</tablerow>
																									<tablerow>
																										<children>
																											<tablecol>
																												<properties bgcolor="#D2FFFF" colspan="2"/>
																												<children>
																													<template>
																														<match match="@detailed"/>
																														<children>
																															<checkbox ownvalue="1">
																																<styles font-size="10pt"/>
																																<properties type="checkbox"/>
																															</checkbox>
																														</children>
																													</template>
																													<text fixtext="Detailed report">
																														<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																													</text>
																												</children>
																											</tablecol>
																										</children>
																									</tablerow>
																								</children>
																							</tablebody>
																						</children>
																					</table>
																					<table>
																						<properties border="0" border-collapse="collapse" cellpadding="0" cellspacing="0" table-layout="fixed" width="100%"/>
																						<children>
																							<tablebody>
																								<children>
																									<tablerow>
																										<children>
																											<tablecol>
																												<styles border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1pt"/>
																												<properties bgcolor="#D2FFFF"/>
																												<children>
																													<text fixtext="Employee Information">
																														<styles font-family="Verdana" font-size="14pt"/>
																													</text>
																												</children>
																											</tablecol>
																										</children>
																									</tablerow>
																								</children>
																							</tablebody>
																						</children>
																					</table>
																					<template>
																						<match match="Person"/>
																						<children>
																							<table>
																								<properties border="0" border-collapse="collapse" cellpadding="0" cellspacing="0" width="100%"/>
																								<children>
																									<tablebody>
																										<children>
																											<tablerow>
																												<children>
																													<tablecol/>
																													<tablecol>
																														<children>
																															<table>
																																<properties border="0" width="100%"/>
																																<children>
																																	<tablebody>
																																		<children>
																																			<tablerow>
																																				<children>
																																					<tablecol>
																																						<styles border-color="#D3D3D3" border-style="solid" border-width="1pt"/>
																																						<properties bgcolor="#F3F3F3"/>
																																						<children>
																																							<template>
																																								<match match="First"/>
																																								<children>
																																									<xpath allchildren="1"/>
																																								</children>
																																							</template>
																																						</children>
																																					</tablecol>
																																					<tablecol>
																																						<styles border-color="#D3D3D3" border-style="solid" border-width="1pt"/>
																																						<properties bgcolor="#F3F3F3"/>
																																						<children>
																																							<template>
																																								<match match="Last"/>
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
																																						<properties width="50%"/>
																																						<children>
																																							<choice>
																																								<children>
																																									<choiceoption>
																																										<testexpression>
																																											<xpath value="string-length( First ) &gt; 0"/>
																																										</testexpression>
																																										<children>
																																											<text fixtext="First Name">
																																												<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																											</text>
																																										</children>
																																									</choiceoption>
																																									<choiceoption>
																																										<children>
																																											<text fixtext="First Name is required">
																																												<styles color="#FF0000" font-family="Arial" font-size="10pt" font-weight="bold"/>
																																											</text>
																																										</children>
																																									</choiceoption>
																																								</children>
																																							</choice>
																																						</children>
																																					</tablecol>
																																					<tablecol>
																																						<properties width="50%"/>
																																						<children>
																																							<choice>
																																								<children>
																																									<choiceoption>
																																										<testexpression>
																																											<xpath value="string-length( Last ) &gt; 0"/>
																																										</testexpression>
																																										<children>
																																											<text fixtext="Last Name">
																																												<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																											</text>
																																										</children>
																																									</choiceoption>
																																									<choiceoption>
																																										<children>
																																											<text fixtext="Last Name is required">
																																												<styles color="#FF0000" font-family="Arial" font-size="10pt" font-weight="bold"/>
																																											</text>
																																										</children>
																																									</choiceoption>
																																								</children>
																																							</choice>
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
																													<tablecol>
																														<children>
																															<table>
																																<properties border="0" width="100%"/>
																																<children>
																																	<tablebody>
																																		<children>
																																			<tablerow>
																																				<children>
																																					<tablecol>
																																						<styles border-color="#D3D3D3" border-style="solid" border-width="1pt"/>
																																						<properties bgcolor="#F3F3F3"/>
																																						<children>
																																							<template>
																																								<match match="Title"/>
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
																																						<children>
																																							<text fixtext="Title">
																																								<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																							</text>
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
																													<tablecol/>
																												</children>
																											</tablerow>
																											<tablerow>
																												<children>
																													<tablecol>
																														<properties width="2%"/>
																													</tablecol>
																													<tablecol>
																														<properties width="48%"/>
																														<children>
																															<table>
																																<properties border="0" width="100%"/>
																																<children>
																																	<tablebody>
																																		<children>
																																			<tablerow>
																																				<children>
																																					<tablecol>
																																						<styles border-color="#D3D3D3" border-style="solid" border-width="1pt"/>
																																						<properties bgcolor="#F3F3F3"/>
																																						<children>
																																							<template>
																																								<match match="Email"/>
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
																																						<children>
																																							<choice>
																																								<children>
																																									<choiceoption>
																																										<testexpression>
																																											<xpath value="string-length( Email ) &gt; 0"/>
																																										</testexpression>
																																										<children>
																																											<text fixtext="E-Mail">
																																												<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																											</text>
																																										</children>
																																									</choiceoption>
																																									<choiceoption>
																																										<children>
																																											<text fixtext="E-Mail is required">
																																												<styles color="#FF0000" font-family="Arial" font-size="10pt" font-weight="bold"/>
																																											</text>
																																										</children>
																																									</choiceoption>
																																								</children>
																																							</choice>
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
																													<tablecol>
																														<properties width="48%"/>
																														<children>
																															<table>
																																<properties border="0" width="100%"/>
																																<children>
																																	<tablebody>
																																		<children>
																																			<tablerow>
																																				<children>
																																					<tablecol>
																																						<styles border-color="#D3D3D3" border-style="solid" border-width="1pt"/>
																																						<properties bgcolor="#F3F3F3"/>
																																						<children>
																																							<template>
																																								<match match="Phone"/>
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
																																						<children>
																																							<text fixtext="Phone">
																																								<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																							</text>
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
																													<tablecol>
																														<properties width="2%"/>
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
																						<properties border="0" border-collapse="collapse" cellpadding="0" cellspacing="0" table-layout="fixed" width="100%"/>
																						<children>
																							<tablebody>
																								<children>
																									<tablerow>
																										<children>
																											<tablecol>
																												<styles border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1pt"/>
																												<properties bgcolor="#D2FFFF" height="24"/>
																												<children>
																													<text fixtext="Expense List">
																														<styles font-family="Verdana" font-size="14pt"/>
																													</text>
																												</children>
																											</tablecol>
																										</children>
																									</tablerow>
																								</children>
																							</tablebody>
																						</children>
																					</table>
																					<choice>
																						<children>
																							<choiceoption>
																								<testexpression>
																									<xpath value="contains(string(@detailed), &quot;true&quot;)"/>
																								</testexpression>
																								<children>
																									<template>
																										<match match="expense-item"/>
																										<children>
																											<table dynamic="1">
																												<properties border="0" width="100%"/>
																												<children>
																													<tableheader>
																														<children>
																															<tablerow>
																																<properties bgcolor="#C0C0C0"/>
																																<children>
																																	<tablecol>
																																		<properties width="10%"/>
																																		<children>
																																			<text fixtext="Type">
																																				<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																			</text>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<properties width="10%"/>
																																		<children>
																																			<text fixtext="Expense To">
																																				<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																			</text>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<children>
																																			<text fixtext="Date">
																																				<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																			</text>
																																			<text fixtext=" (">
																																				<styles font-family="Arial" font-size="9pt" font-weight="bold"/>
																																			</text>
																																			<text fixtext="mm/dd/yyyy">
																																				<styles font-family="Arial" font-size="9pt" font-style="italic" font-weight="bold"/>
																																			</text>
																																			<text fixtext=")">
																																				<styles font-family="Arial" font-size="9pt" font-weight="bold"/>
																																			</text>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<children>
																																			<text fixtext="Expense">
																																				<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																			</text>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<children>
																																			<text fixtext="Details">
																																				<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																			</text>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<children>
																																			<text fixtext="Description">
																																				<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
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
																																<properties bgcolor="#E0E0E0"/>
																																<children>
																																	<tablecol>
																																		<properties width="15%"/>
																																		<children>
																																			<template>
																																				<match match="@type"/>
																																				<children>
																																					<select ownvalue="1">
																																						<properties size="0"/>
																																						<selectoption description="Meal" value="Meal"/>
																																						<selectoption description="Lodging" value="Lodging"/>
																																						<selectoption description="Travel" value="Travel"/>
																																						<selectoption description="Parking" value="Parking"/>
																																						<selectoption description="Entertainment" value="Entertainment"/>
																																						<selectoption description="Misc" value="Misc"/>
																																					</select>
																																				</children>
																																			</template>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<properties width="15%"/>
																																		<children>
																																			<template>
																																				<match match="@expto"/>
																																				<children>
																																					<select ownvalue="1">
																																						<properties size="0"/>
																																						<selectoption description="Development" value="Development"/>
																																						<selectoption description="Marketing" value="Marketing"/>
																																						<selectoption description="Accounting" value="Accounting"/>
																																						<selectoption description="Sales" value="Sales"/>
																																						<selectoption description="Operations" value="Operations"/>
																																						<selectoption description="Support" value="Support"/>
																																						<selectoption description="IT" value="IT"/>
																																					</select>
																																				</children>
																																			</template>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<properties align="center" width="15%"/>
																																		<children>
																																			<template>
																																				<match match="Date"/>
																																				<children>
																																					<xpath allchildren="1">
																																						<styles white-space="nowrap"/>
																																						<format string="MM/DD/YYYY" xslt="1"/>
																																					</xpath>
																																					<text fixtext=" "/>
																																					<datepicker ownvalue="1" datatype="date"/>
																																				</children>
																																			</template>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<properties align="right" width="12%"/>
																																		<children>
																																			<template>
																																				<match match="expense"/>
																																				<children>
																																					<xpath allchildren="1">
																																						<format string="###,##0.00" xslt="1"/>
																																					</xpath>
																																				</children>
																																			</template>
																																			<text fixtext=" "/>
																																			<choice>
																																				<children>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																						</testexpression>
																																						<children>
																																							<text fixtext="$">
																																								<styles font-weight="bold"/>
																																							</text>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																						</testexpression>
																																						<children>
																																							<text fixtext="£">
																																								<styles font-weight="bold"/>
																																							</text>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																						</testexpression>
																																						<children>
																																							<text fixtext="€">
																																								<styles font-weight="bold"/>
																																							</text>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																						</testexpression>
																																						<children>
																																							<text fixtext="¥">
																																								<styles font-weight="bold"/>
																																							</text>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																						</testexpression>
																																						<children>
																																							<text fixtext="AU">
																																								<styles font-weight="bold"/>
																																							</text>
																																							<text fixtext="$">
																																								<styles font-weight="bold"/>
																																							</text>
																																						</children>
																																					</choiceoption>
																																				</children>
																																			</choice>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<properties width="18%"/>
																																		<children>
																																			<choice>
																																				<children>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" @type  = &quot;Meal&quot;"/>
																																						</testexpression>
																																						<children>
																																							<template>
																																								<match match="Meal"/>
																																								<children>
																																									<template>
																																										<match match="@mealtype"/>
																																										<children>
																																											<text fixtext="Meal Type: ">
																																												<styles font-family="Arial" font-size="11pt"/>
																																											</text>
																																											<select ownvalue="1">
																																												<styles font-family="Arial" font-size="11pt"/>
																																												<properties size="0"/>
																																												<selectoption description="dinner" value="dinner"/>
																																												<selectoption description="breakfast" value="breakfast"/>
																																												<selectoption description="lunch" value="lunch"/>
																																												<selectoption description="other" value="other"/>
																																											</select>
																																											<newline/>
																																										</children>
																																									</template>
																																									<template>
																																										<match match="Location"/>
																																										<children>
																																											<text fixtext="Location: ">
																																												<styles font-family="Arial" font-size="11pt"/>
																																											</text>
																																											<field ownvalue="1">
																																												<styles font-family="Arial" font-size="11pt"/>
																																												<properties value=""/>
																																											</field>
																																										</children>
																																									</template>
																																								</children>
																																							</template>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" @type  = &quot;Lodging&quot;"/>
																																						</testexpression>
																																						<children>
																																							<template>
																																								<match match="Lodging"/>
																																								<children>
																																									<template>
																																										<match match="Name"/>
																																										<children>
																																											<text fixtext="Lodging Name: ">
																																												<styles font-family="Arial" font-size="11pt"/>
																																											</text>
																																											<field ownvalue="1">
																																												<styles font-family="Arial" font-size="11pt"/>
																																												<properties value=""/>
																																											</field>
																																											<newline/>
																																										</children>
																																									</template>
																																									<template>
																																										<match match="Location"/>
																																										<children>
																																											<text fixtext="Location: ">
																																												<styles font-family="Arial" font-size="11pt"/>
																																											</text>
																																											<field ownvalue="1">
																																												<styles font-family="Arial" font-size="11pt"/>
																																												<properties value=""/>
																																											</field>
																																										</children>
																																									</template>
																																								</children>
																																							</template>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" @type  = &quot;Travel&quot;"/>
																																						</testexpression>
																																						<children>
																																							<template>
																																								<match match="Travel"/>
																																								<children>
																																									<template>
																																										<match match="@means"/>
																																										<children>
																																											<text fixtext="Means: ">
																																												<styles font-family="Arial" font-size="11pt"/>
																																											</text>
																																											<select ownvalue="1">
																																												<styles font-family="Arial" font-size="11pt"/>
																																												<properties size="0"/>
																																												<selectoption description="Taxi" value="Taxi"/>
																																												<selectoption description="CharterAir" value="CharterAir"/>
																																												<selectoption description="Airline" value="Airline"/>
																																												<selectoption description="Limo" value="Limo"/>
																																												<selectoption description="CharterSea" value="CharterSea"/>
																																												<selectoption description="Rail" value="Rail"/>
																																												<selectoption description="CharterLand" value="CharterLand"/>
																																												<selectoption description="Bus" value="Bus"/>
																																											</select>
																																											<newline/>
																																										</children>
																																									</template>
																																									<template>
																																										<match match="Destination"/>
																																										<children>
																																											<text fixtext="Destination: ">
																																												<styles font-family="Arial" font-size="11pt"/>
																																											</text>
																																											<field ownvalue="1">
																																												<styles font-family="Arial" font-size="11pt"/>
																																												<properties value=""/>
																																											</field>
																																											<newline/>
																																										</children>
																																									</template>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" @means = &quot;Taxi&quot;"/>
																																												</testexpression>
																																												<children>
																																													<template>
																																														<match match="Mileage"/>
																																														<children>
																																															<text fixtext="Mileage: ">
																																																<styles font-family="Arial" font-size="11pt"/>
																																															</text>
																																															<field ownvalue="1">
																																																<styles font-family="Arial" font-size="11pt"/>
																																																<properties value=""/>
																																															</field>
																																														</children>
																																													</template>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" @means  = &quot;Limo&quot;"/>
																																												</testexpression>
																																												<children>
																																													<template>
																																														<match match="Mileage"/>
																																														<children>
																																															<field ownvalue="1">
																																																<styles font-family="Arial" font-size="11pt"/>
																																																<properties value=""/>
																																															</field>
																																														</children>
																																													</template>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</template>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" @type  = &quot;Parking&quot;"/>
																																						</testexpression>
																																						<children>
																																							<template>
																																								<match match="Parking"/>
																																								<children>
																																									<template>
																																										<match match="Location"/>
																																										<children>
																																											<text fixtext="Location: ">
																																												<styles font-family="Arial" font-size="11pt"/>
																																											</text>
																																											<field ownvalue="1">
																																												<styles font-family="Arial" font-size="11pt"/>
																																												<properties value=""/>
																																											</field>
																																										</children>
																																									</template>
																																								</children>
																																							</template>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" @type = &quot;Entertainment&quot;"/>
																																						</testexpression>
																																						<children>
																																							<template>
																																								<match match="Entertainment"/>
																																								<children>
																																									<table dynamic="1">
																																										<properties border="0"/>
																																										<children>
																																											<tableheader>
																																												<children>
																																													<tablerow>
																																														<children>
																																															<tablecol>
																																																<styles border-bottom-color="black" border-bottom-style="solid" border-bottom-width="thin"/>
																																																<properties align="center"/>
																																																<children>
																																																	<text fixtext="Client-name">
																																																		<styles font-family="Arial" font-size="11pt"/>
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
																																																<properties bgcolor="#F3F3F3"/>
																																																<children>
																																																	<template>
																																																		<match match="Client-name"/>
																																																		<children>
																																																			<xpath allchildren="1">
																																																				<styles font-family="Arial" font-size="11pt"/>
																																																			</xpath>
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
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &quot;Misc&quot;"/>
																																						</testexpression>
																																						<children>
																																							<template>
																																								<match match="Misc"/>
																																								<children>
																																									<template>
																																										<match match="@misctype"/>
																																										<children>
																																											<text fixtext="Misc. Type: ">
																																												<styles font-family="Arial" font-size="11pt"/>
																																											</text>
																																											<select ownvalue="1">
																																												<styles font-family="Arial" font-size="11pt"/>
																																												<properties size="0"/>
																																												<selectoption description="TeamBuilding" value="TeamBuilding"/>
																																												<selectoption description="Tips" value="Tips"/>
																																												<selectoption description="Fines" value="Fines"/>
																																												<selectoption description="Rental" value="Rental"/>
																																												<selectoption description="EverythingElse" value="EverythingElse"/>
																																												<selectoption description="Tolls" value="Tolls"/>
																																												<selectoption description="Telephone" value="Telephone"/>
																																											</select>
																																										</children>
																																									</template>
																																								</children>
																																							</template>
																																						</children>
																																					</choiceoption>
																																				</children>
																																			</choice>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<properties width="25%"/>
																																		<children>
																																			<template>
																																				<match match="description"/>
																																				<children>
																																					<paragraph paragraphtag="div">
																																						<children>
																																							<xpath allchildren="1">
																																								<styles font-family="Arial" font-size="11pt"/>
																																							</xpath>
																																						</children>
																																					</paragraph>
																																				</children>
																																			</template>
																																		</children>
																																	</tablecol>
																																</children>
																															</tablerow>
																															<tablerow>
																																<children>
																																	<tablecol>
																																		<styles font-family="Arial Narrow" font-size="10PT"/>
																																		<properties bgcolor="#BBBBBB" colspan="6"/>
																																		<children>
																																			<text fixtext=" General Guidelines:"/>
																																			<choice>
																																				<children>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Meal&apos;"/>
																																						</testexpression>
																																						<children>
																																							<newline/>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="10PT"/>
																																										<children>
																																											<text fixtext="Meals should not be expensed to Development, IT, or Support"/>
																																										</children>
																																									</listrow>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="10PT"/>
																																										<children>
																																											<text fixtext="Meals expensed to Accounting reqire a Detailed report"/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type  = &apos;Lodging&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-size="10PT"/>
																																										<children>
																																											<text fixtext="Lodging should be expensed to Marketing and Sales only"/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Travel&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-size="10PT"/>
																																										<children>
																																											<text fixtext="Travel should be expensed to Marketing and Sales only"/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Parking&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-size="10PT"/>
																																										<children>
																																											<text fixtext="Parking should be expensed to the department of the vehicle&apos;s owner"/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Entertainment&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-size="10PT"/>
																																										<children>
																																											<text fixtext="Entertainment should not be expensed to Development "/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Misc&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-size="10PT"/>
																																										<children>
																																											<text fixtext="All Miscellaneous expenses require a detailed report"/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption/>
																																				</children>
																																			</choice>
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
																							</choiceoption>
																							<choiceoption>
																								<children>
																									<template>
																										<match match="expense-item"/>
																										<children>
																											<table dynamic="1">
																												<properties border="0" width="100%"/>
																												<children>
																													<tableheader>
																														<children>
																															<tablerow>
																																<properties bgcolor="#C0C0C0"/>
																																<children>
																																	<tablecol>
																																		<children>
																																			<text fixtext="Type">
																																				<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																			</text>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<children>
																																			<text fixtext="Expense To">
																																				<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																			</text>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<children>
																																			<text fixtext="Date">
																																				<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																			</text>
																																			<text fixtext=" (">
																																				<styles font-family="Arial" font-size="9pt" font-weight="bold"/>
																																			</text>
																																			<text fixtext="mm/dd/yyyy)">
																																				<styles font-family="Arial" font-size="9pt" font-style="italic" font-weight="bold"/>
																																			</text>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<children>
																																			<text fixtext="Expense">
																																				<styles font-family="Arial" font-size="10pt" font-weight="bold"/>
																																			</text>
																																		</children>
																																	</tablecol>
																																	<tablecol/>
																																</children>
																															</tablerow>
																														</children>
																													</tableheader>
																													<tablebody>
																														<children>
																															<tablerow>
																																<properties bgcolor="#E0E0E0"/>
																																<children>
																																	<tablecol>
																																		<properties width="15%"/>
																																		<children>
																																			<template>
																																				<match match="@type"/>
																																				<children>
																																					<select ownvalue="1">
																																						<properties size="0"/>
																																						<selectoption description="Meal" value="Meal"/>
																																						<selectoption description="Lodging" value="Lodging"/>
																																						<selectoption description="Travel" value="Travel"/>
																																						<selectoption description="Parking" value="Parking"/>
																																						<selectoption description="Entertainment" value="Entertainment"/>
																																						<selectoption description="Misc" value="Misc"/>
																																					</select>
																																				</children>
																																			</template>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<properties width="15%"/>
																																		<children>
																																			<template>
																																				<match match="@expto"/>
																																				<children>
																																					<select ownvalue="1">
																																						<properties size="0"/>
																																						<selectoption description="Development" value="Development"/>
																																						<selectoption description="Marketing" value="Marketing"/>
																																						<selectoption description="Accounting" value="Accounting"/>
																																						<selectoption description="Sales" value="Sales"/>
																																						<selectoption description="Operations" value="Operations"/>
																																						<selectoption description="Support" value="Support"/>
																																						<selectoption description="IT" value="IT"/>
																																					</select>
																																				</children>
																																			</template>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<properties align="center" width="15%"/>
																																		<children>
																																			<template>
																																				<match match="Date"/>
																																				<children>
																																					<xpath allchildren="1">
																																						<styles white-space="nowrap"/>
																																						<format string="MM/DD/YYYY" xslt="1"/>
																																					</xpath>
																																					<text fixtext=" "/>
																																					<datepicker ownvalue="1" datatype="date"/>
																																				</children>
																																			</template>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<properties align="right" width="12%"/>
																																		<children>
																																			<template>
																																				<match match="expense"/>
																																				<children>
																																					<xpath allchildren="1">
																																						<format string="###,##0.00" xslt="1"/>
																																					</xpath>
																																				</children>
																																			</template>
																																			<text fixtext=" "/>
																																			<choice>
																																				<children>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																						</testexpression>
																																						<children>
																																							<text fixtext="$">
																																								<styles font-weight="bold"/>
																																							</text>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																						</testexpression>
																																						<children>
																																							<text fixtext="£">
																																								<styles font-weight="bold"/>
																																							</text>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																						</testexpression>
																																						<children>
																																							<text fixtext="€">
																																								<styles font-weight="bold"/>
																																							</text>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																						</testexpression>
																																						<children>
																																							<text fixtext="¥">
																																								<styles font-weight="bold"/>
																																							</text>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																						</testexpression>
																																						<children>
																																							<text fixtext="AU">
																																								<styles font-weight="bold"/>
																																							</text>
																																							<text fixtext="$">
																																								<styles font-weight="bold"/>
																																							</text>
																																						</children>
																																					</choiceoption>
																																				</children>
																																			</choice>
																																		</children>
																																	</tablecol>
																																	<tablecol>
																																		<styles font-family="Arial Narrow" font-size="x-small" white-space="nowrap"/>
																																		<properties align="left" width="43%"/>
																																		<children>
																																			<choice>
																																				<children>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Misc&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="x-small"/>
																																										<children>
																																											<text fixtext="All Miscellaneous must be documented by a detailed report">
																																												<styles color="red" font-family="Arial Narrow" font-size="x-small"/>
																																											</text>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																				</children>
																																			</choice>
																																			<choice>
																																				<children>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type  = &apos;Meal&apos;  and  expense &gt; 500"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="x-small"/>
																																										<children>
																																											<text fixtext="All Meals expensed greater than 500 ">
																																												<styles color="red" font-family="Arial Narrow" font-size="x-small"/>
																																											</text>
																																											<choice>
																																												<children>
																																													<choiceoption>
																																														<testexpression>
																																															<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																														</testexpression>
																																														<children>
																																															<text fixtext="$">
																																																<styles color="red" font-family="Arial Narrow" font-size="x-small"/>
																																															</text>
																																														</children>
																																													</choiceoption>
																																													<choiceoption>
																																														<testexpression>
																																															<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																														</testexpression>
																																														<children>
																																															<text fixtext="£">
																																																<styles color="red" font-family="Arial Narrow" font-size="x-small" font-weight="bold"/>
																																															</text>
																																														</children>
																																													</choiceoption>
																																													<choiceoption>
																																														<testexpression>
																																															<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																														</testexpression>
																																														<children>
																																															<text fixtext="€">
																																																<styles color="red" font-family="Arial Narrow" font-size="x-small" font-weight="bold"/>
																																															</text>
																																														</children>
																																													</choiceoption>
																																													<choiceoption>
																																														<testexpression>
																																															<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																														</testexpression>
																																														<children>
																																															<text fixtext="¥">
																																																<styles color="red" font-family="Arial Narrow" font-size="x-small" font-weight="bold"/>
																																															</text>
																																														</children>
																																													</choiceoption>
																																													<choiceoption>
																																														<testexpression>
																																															<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																														</testexpression>
																																														<children>
																																															<text fixtext="AU">
																																																<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																															</text>
																																															<text fixtext="$">
																																																<styles font-family="Verdana" font-weight="bold"/>
																																															</text>
																																														</children>
																																													</choiceoption>
																																												</children>
																																											</choice>
																																											<text fixtext=" "/>
																																											<text fixtext="requires a detailed report">
																																												<styles color="red" font-family="Arial Narrow" font-size="x-small"/>
																																											</text>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																				</children>
																																			</choice>
																																			<choice>
																																				<children>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Meal&apos; and  @expto = &apos;Development&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="x-small"/>
																																										<children>
																																											<text fixtext="Meals expensed to developers requires a detailed report">
																																												<styles color="red" font-family="Arial Narrow" font-size="x-small"/>
																																											</text>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																				</children>
																																			</choice>
																																			<choice>
																																				<children>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="expense &gt; 999"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="x-small"/>
																																										<children>
																																											<text fixtext="One expense can not exceed one thousand ">
																																												<styles color="red" font-family="Arial Narrow" font-size="x-small"/>
																																											</text>
																																											<choice>
																																												<children>
																																													<choiceoption>
																																														<testexpression>
																																															<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																														</testexpression>
																																														<children>
																																															<text fixtext="$">
																																																<styles color="red" font-family="Arial Narrow" font-size="x-small"/>
																																															</text>
																																														</children>
																																													</choiceoption>
																																													<choiceoption>
																																														<testexpression>
																																															<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																														</testexpression>
																																														<children>
																																															<text fixtext="£">
																																																<styles color="red" font-family="Arial Narrow" font-size="x-small" font-weight="bold"/>
																																															</text>
																																														</children>
																																													</choiceoption>
																																													<choiceoption>
																																														<testexpression>
																																															<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																														</testexpression>
																																														<children>
																																															<text fixtext="€">
																																																<styles color="red" font-family="Arial Narrow" font-size="x-small" font-weight="bold"/>
																																															</text>
																																														</children>
																																													</choiceoption>
																																													<choiceoption>
																																														<testexpression>
																																															<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																														</testexpression>
																																														<children>
																																															<text fixtext="¥">
																																																<styles color="red" font-family="Arial Narrow" font-size="x-small" font-weight="bold"/>
																																															</text>
																																														</children>
																																													</choiceoption>
																																													<choiceoption>
																																														<testexpression>
																																															<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																														</testexpression>
																																														<children>
																																															<text fixtext="AU">
																																																<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																															</text>
																																															<text fixtext="$">
																																																<styles font-family="Verdana" font-weight="bold"/>
																																															</text>
																																														</children>
																																													</choiceoption>
																																												</children>
																																											</choice>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																				</children>
																																			</choice>
																																			<choice>
																																				<children>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@expto = &apos;Accounting&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="x-small"/>
																																										<children>
																																											<text fixtext="All accounting expenses must have a detailed report">
																																												<styles color="red" font-family="Arial Narrow" font-size="x-small"/>
																																											</text>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																				</children>
																																			</choice>
																																		</children>
																																	</tablecol>
																																</children>
																															</tablerow>
																															<tablerow>
																																<children>
																																	<tablecol>
																																		<styles font-family="Arial Narrow" font-size="10pt"/>
																																		<properties bgcolor="#BBBBBB" colspan="5"/>
																																		<children>
																																			<text fixtext=" General Guidelines:"/>
																																			<choice>
																																				<children>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Meal&apos;"/>
																																						</testexpression>
																																						<children>
																																							<newline/>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="10pt"/>
																																										<children>
																																											<text fixtext="Meals should not be expensed to Development, IT, or Support"/>
																																										</children>
																																									</listrow>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="10pt"/>
																																										<children>
																																											<text fixtext="Meals expensed to Accounting reqire a Detailed report"/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type  = &apos;Lodging&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="10pt"/>
																																										<children>
																																											<text fixtext="Lodging should be expensed to Marketing and Sales only"/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Travel&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="10pt"/>
																																										<children>
																																											<text fixtext="Travel should be expensed to Marketing and Sales only"/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Parking&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="10pt"/>
																																										<children>
																																											<text fixtext="Parking should be expensed to the department of the vehicle&apos;s owner"/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Entertainment&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="10pt"/>
																																										<children>
																																											<text fixtext="Entertainment should not be expensed to Development "/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption>
																																						<testexpression>
																																							<xpath value="@type = &apos;Misc&apos;"/>
																																						</testexpression>
																																						<children>
																																							<list>
																																								<styles margin-bottom="0" margin-top="0"/>
																																								<children>
																																									<listrow>
																																										<styles font-family="Arial Narrow" font-size="10pt"/>
																																										<children>
																																											<text fixtext="All Miscellaneous expenses require a detailed report"/>
																																										</children>
																																									</listrow>
																																								</children>
																																							</list>
																																						</children>
																																					</choiceoption>
																																					<choiceoption/>
																																				</children>
																																			</choice>
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
																							</choiceoption>
																						</children>
																					</choice>
																					<table>
																						<properties border="0" border-collapse="collapse" cellpadding="0" cellspacing="0" table-layout="fixed" width="100%"/>
																						<children>
																							<tablebody>
																								<children>
																									<tablerow>
																										<children>
																											<tablecol>
																												<styles border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1pt"/>
																												<properties bgcolor="#D2FFFF"/>
																												<children>
																													<text fixtext="Expense Summary">
																														<styles font-family="Verdana" font-size="14pt"/>
																													</text>
																												</children>
																											</tablecol>
																										</children>
																									</tablerow>
																								</children>
																							</tablebody>
																						</children>
																					</table>
																					<table>
																						<properties border="0" table-layout="fixed" width="100%"/>
																						<children>
																							<tablebody>
																								<children>
																									<tablerow>
																										<children>
																											<tablecol>
																												<styles border-color="black" border-style="solid" border-width="1pt"/>
																												<properties width="100%"/>
																												<children>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@type = &apos;Parking&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Parking Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@type=&apos;Parking&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@type = &apos;Meal&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Meal Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@type=&apos;Meal&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@type = &apos;Travel&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Travel Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@type=&apos;Travel&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@type = &apos;Lodging&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Lodging Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@type=&apos;Lodging&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@type = &apos;Entertainment&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Entertainment Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@type=&apos;Entertainment&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@type = &apos;Misc&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Miscellaneous Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@type=&apos;Misc&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																												</children>
																											</tablecol>
																										</children>
																									</tablerow>
																								</children>
																							</tablebody>
																						</children>
																					</table>
																					<table>
																						<properties border="0" table-layout="fixed" width="100%"/>
																						<children>
																							<tablebody>
																								<children>
																									<tablerow>
																										<children>
																											<tablecol>
																												<styles border-color="black" border-style="solid" border-width="1pt" white-space="nowrap"/>
																												<children>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@expto = &apos;Marketing&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Marketing Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@expto=&apos;Marketing&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@expto = &apos;Development&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Development Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@expto=&apos;Development&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@expto = &apos;Accounting&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Accounting Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@expto=&apos;Accounting&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@expto = &apos;Sales&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Sales Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@expto=&apos;Sales&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@expto = &apos;Operations&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Operations Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@expto=&apos;Operations&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@expto = &apos;Support&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Support Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@expto=&apos;Support&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles white-space="nowrap"/>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value="expense-item/@expto = &apos;IT&apos;"/>
																																</testexpression>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties width="47%"/>
																																								<children>
																																									<text fixtext="Total Information Technology Expenses">
																																										<styles font-family="Verdana"/>
																																									</text>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<styles border-bottom-color="silver" border-bottom-style="solid" border-bottom-width="1pt" white-space="nowrap"/>
																																								<properties align="right" width="52%"/>
																																								<children>
																																									<autovalue>
																																										<styles font-family="Verdana"/>
																																										<editorproperties editable="0"/>
																																										<autocalc>
																																											<xpath value="sum(expense-item[@expto=&apos;IT&apos;]/expense)"/>
																																										</autocalc>
																																										<format string="###,##0.00" xslt="1" datatype="decimal"/>
																																									</autovalue>
																																									<choice>
																																										<children>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="£">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="€">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="¥">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																											<choiceoption>
																																												<testexpression>
																																													<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																												</testexpression>
																																												<children>
																																													<text fixtext="AU">
																																														<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																													</text>
																																													<text fixtext="$">
																																														<styles font-family="Verdana" font-weight="bold"/>
																																													</text>
																																												</children>
																																											</choiceoption>
																																										</children>
																																									</choice>
																																								</children>
																																							</tablecol>
																																							<tablecol>
																																								<properties width="1%"/>
																																							</tablecol>
																																						</children>
																																					</tablerow>
																																				</children>
																																			</tablebody>
																																		</children>
																																	</table>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																												</children>
																											</tablecol>
																										</children>
																									</tablerow>
																								</children>
																							</tablebody>
																						</children>
																					</table>
																					<table>
																						<properties border="0" table-layout="fixed" width="100%"/>
																						<children>
																							<tablebody>
																								<children>
																									<tablerow>
																										<children>
																											<tablecol>
																												<properties width="50%"/>
																												<children>
																													<text fixtext="TOTAL EXPENSES">
																														<styles font-family="Verdana" font-size="medium"/>
																													</text>
																												</children>
																											</tablecol>
																											<tablecol>
																												<properties align="right" width="50%"/>
																												<children>
																													<autovalue>
																														<styles font-family="Verdana" font-size="medium"/>
																														<editorproperties editable="0"/>
																														<autocalc>
																															<xpath value="sum( expense-item/expense  )"/>
																															<update>
																																<xpath value="@total-sum"/>
																															</update>
																														</autocalc>
																														<format string="###,##0.00" xslt="1" datatype="decimal"/>
																													</autovalue>
																													<choice>
																														<children>
																															<choiceoption>
																																<testexpression>
																																	<xpath value=" /expense-report/@currency  = &quot;USD&quot;"/>
																																</testexpression>
																																<children>
																																	<text fixtext="$">
																																		<styles font-family="Verdana" font-weight="bold"/>
																																	</text>
																																</children>
																															</choiceoption>
																															<choiceoption>
																																<testexpression>
																																	<xpath value=" /expense-report/@currency  = &quot;UKP&quot;"/>
																																</testexpression>
																																<children>
																																	<text fixtext="£">
																																		<styles font-family="Verdana" font-weight="bold"/>
																																	</text>
																																</children>
																															</choiceoption>
																															<choiceoption>
																																<testexpression>
																																	<xpath value=" /expense-report/@currency  = &quot;Euro&quot;"/>
																																</testexpression>
																																<children>
																																	<text fixtext="€">
																																		<styles font-family="Verdana" font-weight="bold"/>
																																	</text>
																																</children>
																															</choiceoption>
																															<choiceoption>
																																<testexpression>
																																	<xpath value=" /expense-report/@currency = &quot;JPY&quot;"/>
																																</testexpression>
																																<children>
																																	<text fixtext="¥">
																																		<styles font-family="Verdana" font-weight="bold"/>
																																	</text>
																																</children>
																															</choiceoption>
																															<choiceoption>
																																<testexpression>
																																	<xpath value=" /expense-report/@currency = &quot;AUD&quot;"/>
																																</testexpression>
																																<children>
																																	<text fixtext="AU">
																																		<styles font-family="Verdana" font-size="x-small" font-weight="bold"/>
																																	</text>
																																	<text fixtext="$">
																																		<styles font-family="Verdana" font-weight="bold"/>
																																	</text>
																																</children>
																															</choiceoption>
																														</children>
																													</choice>
																												</children>
																											</tablecol>
																										</children>
																									</tablerow>
																								</children>
																							</tablebody>
																						</children>
																					</table>
																					<choice>
																						<children>
																							<choiceoption>
																								<testexpression>
																									<xpath value="sum(/expense-report/expense-item/expense)&gt;100"/>
																								</testexpression>
																								<children>
																									<table>
																										<properties border="0" table-layout="fixed" width="100%"/>
																										<children>
																											<tablebody>
																												<children>
																													<tablerow>
																														<children>
																															<tablecol>
																																<properties align="left" colspan="2" width="85%"/>
																																<children>
																																	<text fixtext="This expense report has exceeded ">
																																		<styles font-size="10pt"/>
																																	</text>
																																	<text fixtext="100">
																																		<styles font-size="10pt" font-weight="bold"/>
																																	</text>
																																	<text fixtext=" ">
																																		<styles font-size="10pt"/>
																																	</text>
																																	<template>
																																		<styles font-size="x-small"/>
																																		<editorproperties adding="mandatory" autoaddname="0" editable="0" markupmode="hide"/>
																																		<match match="@currency"/>
																																		<children>
																																			<xpath allchildren="1">
																																				<styles font-size="10pt"/>
																																			</xpath>
																																		</children>
																																	</template>
																																	<text fixtext=" which under corporate policy requires approval of your direct superior.  All forms must be presented in triplicate and be submitted to the human resources department server in its current XML form.">
																																		<styles font-size="10pt"/>
																																	</text>
																																</children>
																															</tablecol>
																														</children>
																													</tablerow>
																													<tablerow>
																														<children>
																															<tablecol>
																																<styles border-color="#D3D3D3" border-style="solid" border-width="1pt"/>
																																<properties height="101" valign="bottom" width="15%"/>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol/>
																																						</children>
																																					</tablerow>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<children>
																																									<text fixtext="Date"/>
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
																															<tablecol>
																																<styles border-color="#D3D3D3" border-style="solid" border-width="1pt"/>
																																<properties height="101" valign="bottom" width="85%"/>
																																<children>
																																	<table>
																																		<properties border="0" width="100%"/>
																																		<children>
																																			<tablebody>
																																				<children>
																																					<tablerow>
																																						<children>
																																							<tablecol/>
																																						</children>
																																					</tablerow>
																																					<tablerow>
																																						<children>
																																							<tablecol>
																																								<children>
																																									<text fixtext="Signature"/>
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
																							</choiceoption>
																							<choiceoption/>
																						</children>
																					</choice>
																					<newline/>
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
		</children>
	</template>
	<template>
		<match match="italic"/>
		<children>
			<xpath allchildren="1">
				<styles font-style="italic"/>
			</xpath>
		</children>
	</template>
	<template>
		<match match="strong"/>
		<children>
			<xpath allchildren="1">
				<styles font-weight="bold"/>
			</xpath>
		</children>
	</template>
	<pagelayout>
		<properties pagemultiplepages="0" pagenumberingformat="1" pagenumberingstartat="1" paperheight="11in" papermarginbottom="0.79in" papermarginleft="0.6in" papermarginright="0.6in" papermargintop="0.79in" paperwidth="8.5in"/>
	</pagelayout>
</structure>
