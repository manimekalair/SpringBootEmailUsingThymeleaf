<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_418" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">418</xsl:variable>
		<xsl:variable name="rule_name">Check nesting of displayed material.</xsl:variable>
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
		
		<!-- create list of hits -->
		<xsl:variable name="hit_list">
			<xml>
				<!-- sion I think this should be p with just one element of this type and preceding sibling p -->
				<xsl:for-each select="//p[disp-quote|list|speech|verse-group|statement|boxed-text|fig|table-wrap]
					[count(node()[not(normalize-space()='')])=1]
					[preceding-sibling::*[1][self::p]]">
					<hit>
						<text>
							<xsl:value-of select="."/>
						</text>
						<name>
							<xsl:value-of select="*[1]/local-name()"/>
						</name>
						<location>
							<xsl:for-each select="*[1]">
								<xsl:for-each select="ancestor-or-self::*">
									<xsl:text>/</xsl:text>
									<xsl:value-of select="name()"/>
								</xsl:for-each>
							</xsl:for-each>
						</location>
						<last_char>
							<xsl:analyze-string select="preceding-sibling::p[1]/text()[last()]" regex="(.$)">
								<xsl:matching-substring>
									<xsl:value-of select="regex-group(1)"/>
								</xsl:matching-substring>
							</xsl:analyze-string>
						</last_char>
					</hit>
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
					<xsl:for-each select="$hit_list//hit">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found element &lt;</xsl:text>
								<xsl:value-of select="./name"/>
								<xsl:text>&gt; which may be incorrectly nested (preceding paragraph ends with "</xsl:text>
								<xsl:value-of select="./last_char"/>
								<xsl:text>"). Located at: </xsl:text>
								<xsl:value-of select="./location"/>
								<xsl:text> (text extract: "</xsl:text>
								<xsl:choose>
								<xsl:when test="string-length(./text) lt 100">
									<xsl:value-of select="./text"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring(./text,1,100)"/>
									<xsl:text> ... </xsl:text>
								</xsl:otherwise>
								</xsl:choose>
								<xsl:text>").</xsl:text>
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
