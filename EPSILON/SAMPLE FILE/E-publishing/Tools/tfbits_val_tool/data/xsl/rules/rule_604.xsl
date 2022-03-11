<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_604" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">604</xsl:variable>
		<xsl:variable name="rule_name">Check file types.</xsl:variable>
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
		<!-- build list of filenames, prefixes, and suffixes, exclusing extension -->
		<xsl:variable name="file_list">
			<xml>
				<!--
				-->
				<!-- select all files in artwork folder -->
				<xsl:for-each select="$filelist//folder[@path = 'artwork/']/filename">
					<file>
						<!--
						-->
						<!-- tokenize filename on full point -->
						<xsl:variable name="tokenized_name" select="tokenize(.,'\.')"/>
						<!--
						-->
						<!-- get filename -->
						<xsl:variable name="tokenized_name_tagged">
							<xml>
								<xsl:for-each select="$tokenized_name">
									<tag>
										<xsl:value-of select="."/>
									</tag>
								</xsl:for-each>
							</xml>
						</xsl:variable>
						<!--
						-->
						<!-- get filename and extension -->
						<filename>
							<xsl:for-each select="$tokenized_name_tagged//tag[not(position()=last())]">
								<xsl:value-of select="."/>
								<xsl:if test="position() lt last()">
									<xsl:text>.</xsl:text>
								</xsl:if>
							</xsl:for-each>
						</filename>
						<!--
						-->
						<ext>
							<xsl:for-each select="$tokenized_name_tagged//tag[last()]">
								<xsl:value-of select="."/>
							</xsl:for-each>
						</ext>
						<!--
						-->
					</file>
				</xsl:for-each>
				<!--
				-->
			</xml>
		</xsl:variable>
		<!--
		-->
		<!-- build hit list -->
		<xsl:variable name="hit_list">
			<xml>
				<xsl:for-each select="$file_list//file">
					<!--
					-->
					<xsl:choose>
						<xsl:when test="matches(lower-case(./ext),'^jpe?g$')"/>
						<xsl:when test="matches(lower-case(./ext),'^tiff?$')"/>
						<xsl:otherwise>
							<hit>
								<xsl:value-of select="concat(./filename,'.',./ext)"/>
							</hit>
						</xsl:otherwise>
					</xsl:choose>
					<!--
					-->
				</xsl:for-each>
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
							<xsl:text>Found invalid file extension:</xsl:text>
							<xsl:element name="ul">
								<xsl:for-each select="$hit_list//hit">
									<xsl:element name="li">
										<xsl:value-of select="."/>
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
