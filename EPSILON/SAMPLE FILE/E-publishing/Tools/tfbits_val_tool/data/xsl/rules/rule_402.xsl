<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_402" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">402</xsl:variable>
		<xsl:variable name="rule_name">Check XML file name.</xsl:variable>
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
		<!-- get isbn from filename -->
		<xsl:variable name="filename_isbn" select="$tokenized_tagged//tag[last()]/substring-before(.,'.')"/>
		<!--
		
		-->
		<!-- get isbn to test against -->
		<xsl:variable name="isbn">
			<xsl:variable name="temp">
				<xsl:choose>
					<xsl:when test="//isbn[@publication-format='ebk']">
						<xsl:value-of select="//isbn[@publication-format='ebk']"/>
					</xsl:when>
					<xsl:when test="//isbn[@publication-format='hbk']">
						<xsl:value-of select="//isbn[@publication-format='hbk']"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="replace($temp,'[^0-9]','')"/>
		</xsl:variable>
		<!--
		
		-->
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="$filename_isbn = $isbn">
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
							<xsl:text>ISBN in filename does not match ISBN in XML: </xsl:text>
							<xsl:value-of select="$filename_isbn"/>
							<xsl:text> vs. </xsl:text>
							<xsl:value-of select="$isbn"/>
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
