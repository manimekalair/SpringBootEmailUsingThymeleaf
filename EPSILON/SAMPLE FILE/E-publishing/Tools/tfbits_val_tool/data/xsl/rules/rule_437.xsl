<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_437" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">437</xsl:variable>
		<xsl:variable name="rule_name">Check for replication of style from print book where errors can be determined.</xsl:variable>
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
				<xsl:for-each select="(//book-title|//title|//subtitle|//label|//source|//alt-title)">
					<!--
					-->
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
					<!-- test if element is all bold -->
					<xsl:if test="./bold and count(child::node()) = 1">
						<hit type="bold">
							<text>
								<xsl:value-of select="."/>
							</text>
							<name>
								<xsl:value-of select="name()"/>
							</name>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!-- test if element is all bold and includes a page marker xref -->
					<xsl:if test="./bold and (count(child::node()) = 2) and (./target[@target-type = 'page' and matches(@id,'page_')])">
						<hit type="bold">
							<text>
								<xsl:value-of select="."/>
							</text>
							<name>
								<xsl:value-of select="name()"/>
							</name>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!-- test if element is all sc -->
					<xsl:if test="./sc and count(child::node()) = 1">
						<hit type="sc">
							<text>
								<xsl:value-of select="."/>
							</text>
							<name>
								<xsl:value-of select="name()"/>
							</name>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!-- test if element is all sc and includes a page marker xref -->
					<xsl:if test="./sc and (count(child::node()) = 2) and (./target[@target-type = 'page' and matches(@id,'page_')])">
						<hit type="sc">
							<text>
								<xsl:value-of select="."/>
							</text>
							<name>
								<xsl:value-of select="name()"/>
							</name>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!-- test if element is all underline -->
					<xsl:if test="./underline and count(child::node()) = 1">
						<hit type="underline">
							<text>
								<xsl:value-of select="."/>
							</text>
							<name>
								<xsl:value-of select="name()"/>
							</name>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!-- test if element is all underline and includes a page marker xref -->
					<xsl:if test="./underline and (count(child::node()) = 2) and (./target[@target-type = 'page' and matches(@id,'page_')])">
						<hit type="underline">
							<text>
								<xsl:value-of select="."/>
							</text>
							<name>
								<xsl:value-of select="name()"/>
							</name>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
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
								<xsl:text>Found all &lt;</xsl:text>
								<xsl:value-of select="@type"/>
								<xsl:text>&gt; in "&lt;</xsl:text>
								<xsl:value-of select="./name"/>
								<xsl:text>&gt;</xsl:text>
								<xsl:value-of select="./text"/>
								<xsl:text>&lt;</xsl:text>
								<xsl:value-of select="./name"/>
								<xsl:text>&gt;" (</xsl:text>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>at: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>in: </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
								<xsl:text>).</xsl:text>
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