<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_111" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">111</xsl:variable>
		<xsl:variable name="rule_name">Check for typesetting details.</xsl:variable>
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
		<!-- build hit list -->
		<xsl:variable name="hit_list">
			<xml>
				<!--
				-->
				<!-- set supplier variable -->
				<xsl:variable name="supplier" select="//notes[@notes-type = 'supplier']/p[1]/text()"/>
				<!--
				-->
				<xsl:for-each select="//sec[@sec-type[matches(., 'imprint')]]">
					<!--
					-->
					<xsl:choose>
						<!--
						-->
						<!-- test if imprint text contains 'typeset' -->
						<xsl:when test="contains(lower-case(.),'typeset')">
							<hit>
								<text>
									<xsl:value-of select="."/>
								</text>
								<type>
									<xsl:value-of select="@type"/>
								</type>
							</hit>
						</xsl:when>
						<!--
						-->
						<!-- if there is a supplier, test if imprint text contains supplier name -->
						<xsl:when test="$supplier and contains(.,$supplier)">
							<hit>
								<text>
									<xsl:value-of select="."/>
								</text>
								<type>
									<xsl:value-of select="@type"/>
								</type>
							</hit>
						</xsl:when>
					</xsl:choose>
					<!--
					-->
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
					<xsl:for-each select="$hit_list//hit">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found typesetting details in imprint data: </xsl:text>
								
								<xsl:value-of select="./text"/>
								
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
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
