<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_812" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">812</xsl:variable>
		<xsl:variable name="rule_name">Check children of &lt;string-name&gt;.</xsl:variable>
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
				<xsl:for-each select="//mixed-citation//string-name">
					<xsl:variable name="text">
						<text>
							<xsl:value-of select="."/>
						</text>
					</xsl:variable>
					<xsl:variable name="location">
						<location>
							<xsl:choose>
								<xsl:when test="./ancestor-or-self::*[@id][1]">
									<xsl:attribute name="type">element</xsl:attribute>
									<xsl:text>&lt;</xsl:text>
									<xsl:value-of select="name(./ancestor-or-self::*[@id][1])"/>
									<xsl:text> id="</xsl:text>
									<xsl:value-of select="./ancestor-or-self::*[@id][1]/@id"/>
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
					<!--
					-->
					<!-- test for more than 1 surname -->
					<xsl:if test="count(./surname) gt 1">
						<hit>
							<reason>too many &lt;surname&gt; elements (<xsl:value-of select="count(./surname)"/>)</reason>
							<xsl:copy-of select="$text"/>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!--
					-->
					<!-- test for more than 0 surnames -->
					<xsl:if test="count(./surname) = 0">
						<hit>
							<reason>no &lt;surname&gt; element</reason>
							<xsl:copy-of select="$text"/>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!--
					-->
					<!-- test for more than 1 given-names -->
					<xsl:if test="count(./given-names) gt 1">
						<hit>
							<reason>too many &lt;given-names&gt; elements (<xsl:value-of select="count(./given-names)"/>)</reason>
							<xsl:copy-of select="$text"/>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!--
					-->
					<!-- test for more than 1 suffix -->
					<xsl:if test="count(./suffix) gt 1">
						<hit>
							<reason>too many &lt;suffix&gt; elements (<xsl:value-of select="count(./suffix)"/>)</reason>
							<xsl:copy-of select="$text"/>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!--
					-->
					<!-- test for more than 1 prefix -->
					<xsl:if test="count(./prefix) gt 1">
						<hit>
							<reason>too many &lt;prefix&gt; elements (<xsl:value-of select="count(./prefix)"/>)</reason>
							<xsl:copy-of select="$text"/>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!--
					-->
					<!-- test for more than 1 degrees -->
					<xsl:if test="count(./degrees) gt 1">
						<hit>
							<reason>too many &lt;degrees&gt; elements (<xsl:value-of select="count(./degrees)"/>)</reason>
							<xsl:copy-of select="$text"/>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
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
								<xsl:text>Found </xsl:text>
								<xsl:value-of select="./reason"/>
								<xsl:text> in &lt;string-name&gt;. </xsl:text>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>At: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>In: </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
								<xsl:text> – "</xsl:text>
								<xsl:value-of select="./text"/>
								<xsl:text>".</xsl:text>
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
