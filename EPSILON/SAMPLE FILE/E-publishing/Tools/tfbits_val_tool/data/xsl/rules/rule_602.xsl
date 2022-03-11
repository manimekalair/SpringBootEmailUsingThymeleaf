<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_602" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">602</xsl:variable>
		<xsl:variable name="rule_name">Artwork files should be supplied in a folder named 'artwork'.</xsl:variable>
		<xsl:variable name="error_type">fail</xsl:variable>
		
		<!-- DISPLAY MESSAGE -->
		<xsl:call-template name="message">
			<xsl:with-param name="rule_number" select="$rule_number"/>
		</xsl:call-template>
		<!--
		
		-->
		<!-- SET GENERIC RULE DETAILS TEXT -->
		<xsl:variable name="rule_details">
			<xsl:element name="td">
				<xsl:element name="span">
					<xsl:attribute name="class">rule</xsl:attribute>
					<xsl:text>Rule </xsl:text>
					<xsl:value-of select="$rule_number"/>
				</xsl:element>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="$rule_name"/>
			</xsl:element>
		</xsl:variable>
		<!--
		
		-->
		<!-- SET VARIABLES AND DO RULE TESTING AND PROCESSING -->
		<!--
		
		-->
		<!-- import filelist.xml -->
		<xsl:variable name="filelist">
			<!--
			-->
			<!-- tokenize document path -->
			<xsl:variable name="tokenized_string" select="tokenize(base-uri(),'[/\\]')"/>
			<!--
			-->
			<!-- split out tokenized document path and tag -->
			<xsl:variable name="tokenized_tagged">
				<xml>
					<xsl:for-each select="$tokenized_string">
						<tag>
							<xsl:value-of select="."/>
						</tag>
					</xsl:for-each>
				</xml>
			</xsl:variable>
			<!--
			-->
			<!-- get filename -->
			<xsl:variable name="filename" select="$tokenized_tagged//tag[last()]"/>
			<!--
			-->
			<!-- build path -->
			<xsl:variable name="filelist_path" select="replace(base-uri(),$filename,'filelist.xml')"/>
			<!--
			-->
			<!-- load filelist.xml -->
			<xsl:copy-of select="document($filelist_path)"/>
			<!--
			-->
		</xsl:variable>
		<!--
		-->
		<!--  -->
		<xsl:variable name="hit_list">
			<xml>
				<!--
				-->
				<!-- check for an artwork folder -->
				<xsl:if test="count($filelist//filename) gt 1">
					<xsl:choose>
						<xsl:when test="($filelist//@path = 'artwork/') or ($filelist//empty_folders/folder[matches(.,'artwork')])"/>
						<xsl:otherwise>
							<hit type="missing"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<!--
				-->
				<!-- check for subfolders in artwork folder -->
				<xsl:for-each select="$filelist//@path[matches(.,'^artwork/.+')]">
					<hit type="subfolder">
						<xsl:value-of select="."/>
					</hit>
				</xsl:for-each>
				<!--
				-->
				<!-- check for any folder not called 'artwork' -->
				<xsl:for-each select="$filelist//(@path|folder[not(./filename)])[not(starts-with(.,'artwork') or . = './')]">
					<hit type="bad_folder">
						<xsl:value-of select="."/>
					</hit>
				</xsl:for-each>
				<!--
				-->
				<!-- check for an empty 'artwork' folder -->
				<xsl:for-each select="$filelist//empty_folders/folder[matches(.,'artwork')]">
					<hit type="empty_artwork">
						<xsl:value-of select="."/>
					</hit>
				</xsl:for-each>
				<!--
				-->
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="count($hit_list//hit) = 0">
					<xsl:element name="tr">
						<xsl:copy-of select="$rule_details"/>
						<xsl:element name="td">
							<xsl:attribute name="class">pass</xsl:attribute>
							<xsl:text>pass</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="tr">
						<xsl:copy-of select="$rule_details"/>
						<xsl:element name="td">
							<xsl:attribute name="class" select="$error_type"/>
							<xsl:text>Invalid folder structure:</xsl:text>
							<xsl:element name="ul">
								<xsl:for-each select="$hit_list//hit">
									<xsl:element name="li">
										<xsl:choose>
											<xsl:when test="@type = 'missing'">
												<xsl:text>No artwork folder found</xsl:text>
											</xsl:when>
											<xsl:when test="@type = 'subfolder'">
												<xsl:text>Subfolder in 'artwork' – </xsl:text>
												<xsl:value-of select="."/>
											</xsl:when>
											<xsl:when test="@type = 'bad_folder'">
												<xsl:text>Unexpected folder – </xsl:text>
												<xsl:value-of select="."/>
											</xsl:when>
											<xsl:when test="@type = 'empty_artwork'">
												<xsl:text>Empty artwork folder – </xsl:text>
											</xsl:when>
										</xsl:choose>
									</xsl:element>
								</xsl:for-each>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--
		
		-->
		<!-- DISPLAY RESULTS -->
		<xsl:copy-of select="$result"/>
		<!--
		
		-->
	</xsl:template>
</xsl:stylesheet>
