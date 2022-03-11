<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_307" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">307</xsl:variable>
		<xsl:variable name="rule_name">Test &lt;book-part&gt; nesting.</xsl:variable>
		<xsl:variable name="error_type">warning</xsl:variable>
		
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
		<!-- build list of parts or sections with no descendant book-parts -->
		<xsl:variable name="hit_list">
			<xml>
				<xsl:for-each select="//book-part[@book-part-type=('part','section')][not(.//book-part)]">
					<hit>
						<id>
							<xsl:value-of select="./@id"/>
						</id>
						<type>
							<xsl:value-of select="./@book-part-type"/>
						</type>
						<xsl:if test="./@book-part-number">
							<label>
								<xsl:value-of select="./@book-part-number"/>
							</label>
						</xsl:if>
						<title>
							<xsl:value-of select="./book-part-meta/title-group/title"/>
						</title>
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
								<xsl:text>Found a </xsl:text>
								<xsl:value-of select="./type"/>
								<xsl:text> with no nested book-parts: id="</xsl:text>
								<xsl:value-of select="./id"/>
								<xsl:text>" (</xsl:text>
								<xsl:if test="./label">
									<xsl:value-of select="substring(upper-case(./type),1,1)"/>
									<xsl:value-of select="substring(./type,2)"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select="./label"/>
									<xsl:text> – </xsl:text>
								</xsl:if>
								<xsl:value-of select="./title"/>
								<xsl:text>)</xsl:text>
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