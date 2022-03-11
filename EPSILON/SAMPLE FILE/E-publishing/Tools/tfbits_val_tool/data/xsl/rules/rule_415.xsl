<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_415" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">415</xsl:variable>
		<xsl:variable name="rule_name">Check for untagged URLs.</xsl:variable>
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
		<!-- variable listing valid parents of uri -->
		<xsl:variable name="parents">
			<xml>
				<abbrev/>
				<address/>
				<addr-line/>
				<aff/>
				<alt-title/>
				<anonymous/>
				<array/>
				<article-title/>
				<attrib/>
				<award-id/>
				<bold/>
				<book-title/>
				<book-volume-id/>
				<book-volume-number/>
				<chapter-title/>
				<chem-struct/>
				<chem-struct-wrap/>
				<code/>
				<collab/>
				<comment/>
				<compound-kwd-part/>
				<conf-acronym/>
				<conf-loc/>
				<conf-name/>
				<conf-num/>
				<conf-sponsor/>
				<conf-theme/>
				<contrib/>
				<contrib-group/>
				<copyright-statement/>
				<corresp/>
				<data-title/>
				<def-head/>
				<degrees/>
				<disp-formula/>
				<disp-formula-group/>
				<edition/>
				<element-citation/>
				<email/>
				<etal/>
				<ext-link/>
				<fax/>
				<fig/>
				<fig-group/>
				<fixed-case/>
				<funding-source/>
				<funding-statement/>
				<given-names/>
				<gov/>
				<graphic/>
				<inline-formula/>
				<inline-supplementary-material/>
				<institution/>
				<issue/>
				<issue-part/>
				<issue-title/>
				<italic/>
				<kwd/>
				<label/>
				<license-p/>
				<media/>
				<meta-name/>
				<meta-value/>
				<mixed-citation/>
				<monospace/>
				<name-address-wrap/>
				<named-content/>
				<nav-pointer/>
				<on-behalf-of/>
				<overline/>
				<p/>
				<part-title/>
				<patent/>
				<phone/>
				<prefix/>
				<preformat/>
				<product/>
				<publisher-loc/>
				<publisher-name/>
				<rb/>
				<related-article/>
				<related-object/>
				<role/>
				<roman/>
				<sans-serif/>
				<sc/>
				<see/>
				<see-also/>
				<see-also-entry/>
				<see-entry/>
				<self-uri/>
				<series/>
				<serif/>
				<sig/>
				<sig-block/>
				<source/>
				<speaker/>
				<std-organization/>
				<strike/>
				<string-conf/>
				<string-date/>
				<string-name/>
				<styled-content/>
				<sub/>
				<subject/>
				<subtitle/>
				<suffix/>
				<sup/>
				<supplement/>
				<supplementary-material/>
				<surname/>
				<table-wrap/>
				<table-wrap-group/>
				<target/>
				<td/>
				<term/>
				<term-head/>
				<th/>
				<title/>
				<trans-source/>
				<trans-subtitle/>
				<trans-title/>
				<underline/>
				<unstructured-kwd-group/>
				<uri/>
				<verse-line/>
				<version/>
				<volume/>
				<volume-id/>
				<volume-series/>
				<volume-title/>
				<xref/>
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- built list of urls not tagged uri -->
		<xsl:variable name="hit_list">
			<xml>
				<!-- select text in all non-uri elements with no descendants and whose parent allows uri -->
				<!--<xsl:for-each select="//*[not(self::uri)]/text()[not(descendant::*)][parent::*/name() = $parents/xml/*/name()]">-->
				<xsl:for-each select="//*[not(self::uri)]/text()[parent::*/name() = $parents/xml/*/name()]">
					<!-- pass location of element to variable -->
					<xsl:variable name="location">
						<location>
							<xsl:choose>
								<xsl:when test="./ancestor::*[@id][1]">
									<xsl:attribute name="type">element</xsl:attribute>
									<xsl:text>&lt;</xsl:text>
									<xsl:value-of select="name(./ancestor::*[@id][1])"/>
									<xsl:text> id="</xsl:text>
									<xsl:value-of select="./ancestor::*[@id][1]/@id"/>
									<xsl:text>"&gt;</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="type">xpath</xsl:attribute>
									<xsl:for-each select="ancestor::*">
										<xsl:text>/</xsl:text>
										<xsl:value-of select="name()"/>
									</xsl:for-each>
									<xsl:text>/</xsl:text>
									<xsl:value-of select="name()"/>
								</xsl:otherwise>
							</xsl:choose>
						</location>
					</xsl:variable>
					<!-- test if the string contains a url and if so create a hit for the list-->
					<xsl:analyze-string select="." regex="(https?://|www[1-2]?.|ftp://)([^\s^\)]+)">
						<xsl:matching-substring>
							<hit>
								<url>
									<xsl:value-of select="regex-group(1)"/>
									<xsl:value-of select="regex-group(2)"/>
								</url>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:for-each>
				<!-- select text in all email or ext-link elements with no descendants that are urls -->
				<!--<xsl:for-each select="//*[self::email or self::ext-link]/text()[not(descendant::*)]">-->
				<xsl:for-each select="//*[self::email or self::ext-link]/text()">
					<!-- pass location of element to variable -->
					<xsl:variable name="location">
						<location>
							<xsl:choose>
								<xsl:when test="./ancestor::*[@id][1]">
									<xsl:attribute name="type">element</xsl:attribute>
									<xsl:text>&lt;</xsl:text>
									<xsl:value-of select="name(./ancestor::*[@id][1])"/>
									<xsl:text> id="</xsl:text>
									<xsl:value-of select="./ancestor::*[@id][1]/@id"/>
									<xsl:text>"&gt;</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="type">xpath</xsl:attribute>
									<xsl:for-each select="ancestor::*">
										<xsl:text>/</xsl:text>
										<xsl:value-of select="name()"/>
									</xsl:for-each>
									<xsl:text>/</xsl:text>
									<xsl:value-of select="name()"/>
								</xsl:otherwise>
							</xsl:choose>
						</location>
					</xsl:variable>
					<!-- test if the string contains a url and if so create a hit for the list-->
					<xsl:analyze-string select="." regex="(https?://|www[1-2]?.|ftp://)([^\s^\)]+)">
						<xsl:matching-substring>
							<hit>
								<url>
									<xsl:value-of select="regex-group(1)"/>
									<xsl:value-of select="regex-group(2)"/>
								</url>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
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
								<xsl:text>Found a URL not tagged &lt;uri&gt;: "</xsl:text>
								<xsl:value-of select="./url"/>
								<xsl:text>"</xsl:text>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text> in </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text> at </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
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
