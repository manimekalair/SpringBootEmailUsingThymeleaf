<?xml version="1.0" encoding="UTF-8"?>
<structure version="2" schemafile="site.xsd" workingxmlfile="blocks.xml" templatexmlfile="blocks.xml">
	<xmltablesupport standard="HTML"/>
	<nspair prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
	<textstateicon match="header" iconfile="header.bmp"/>
	<textstateicon match="para" iconfile="para.bmp"/>
	<template>
		<match overwrittenxslmatch="/"/>
		<children>
			<table>
				<children>
					<tablebody>
						<children>
							<tablerow>
								<children>
									<tablecol>
										<styles border-bottom-color="black" border-bottom-style="solid" border-bottom-width="thin"/>
										<properties width="643"/>
										<children>
											<text fixtext="These are the &quot;blocks&quot; of the website.  They contain the chucks of content that are to populate the sections of the website.  Each xml file representing a webpage have the option of inserting these preformated parts, for the ability to change data on a site without editing each page individually."/>
										</children>
									</tablecol>
								</children>
							</tablerow>
						</children>
					</tablebody>
				</children>
			</table>
			<template>
				<match match="blocks"/>
				<children>
					<template>
						<match match="block_instance"/>
						<children>
							<table dynamic="1">
								<properties border="1"/>
								<children>
									<tableheader>
										<children>
											<tablerow>
												<children>
													<tablecol>
														<properties align="center" width="200"/>
														<children>
															<text fixtext="ID">
																<styles font-weight="bold"/>
															</text>
														</children>
													</tablecol>
													<tablecol>
														<properties align="center" width="354"/>
														<children>
															<text fixtext="Page Fragment">
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
												<children>
													<tablecol>
														<properties width="200"/>
														<children>
															<template>
																<match match="id"/>
																<children>
																	<xpath allchildren="1"/>
																</children>
															</template>
														</children>
													</tablecol>
													<tablecol>
														<properties width="354"/>
														<children>
															<template>
																<match match="pagefragment"/>
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
			<newline/>
			<newline/>
			<newline/>
		</children>
	</template>
	<template>
		<match match="br"/>
		<children>
			<newline/>
		</children>
	</template>
	<template>
		<styles font-size="large" font-style="italic" font-weight="bold"/>
		<match match="header"/>
		<children>
			<xpath allchildren="1">
				<styles font-size="large" font-style="italic" font-weight="bold"/>
			</xpath>
		</children>
	</template>
	<template>
		<styles font-style="italic"/>
		<match match="id"/>
		<children>
			<xpath allchildren="1">
				<styles font-style="italic"/>
			</xpath>
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
		<match match="list"/>
		<children>
			<template>
				<match match="listitem"/>
				<children>
					<list dynamic="1">
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
	<template>
		<match match="url"/>
		<children>
			<link>
				<hyperlink>
					<xpath value="."/>
				</hyperlink>
				<children>
					<xpath allchildren="1"/>
				</children>
			</link>
		</children>
	</template>
</structure>
