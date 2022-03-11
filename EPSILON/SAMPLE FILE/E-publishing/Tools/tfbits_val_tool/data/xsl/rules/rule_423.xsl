<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_423" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">423</xsl:variable>
		<xsl:variable name="rule_name">Check for styling in def-item &lt;term&gt; element.</xsl:variable>
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
				<!-- select all def-item terms -->
				<xsl:for-each select="//def-item/term">
					<xsl:variable name="term" select="."/>
					<!-- test if all bold -->
					<xsl:if test="./bold and count(child::node()) = 1">
						<hit type="bold">
							<term>
								<xsl:value-of select="$term"/>
							</term>
						</hit>
					</xsl:if>
					<!-- test if all bold (when there is a page start marker -->
					<xsl:if test="./bold and (count(child::node()) = 2) and (./target[@target-type = 'page' and matches(@id,'page_')])">
						<hit type="bold">
							<term>
								<xsl:value-of select="$term"/>
							</term>
						</hit>
					</xsl:if>
					<!-- test if ends with colon -->
					<xsl:analyze-string select="." regex=":$">
						<xsl:matching-substring>
							<hit type="colon">
								<term>
									<xsl:value-of select="$term"/>
								</term>
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
					<xsl:for-each select="$hit_list//hit[@type = 'bold']">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found bold styled term: "</xsl:text>
								<xsl:value-of select="./term"/>
								<xsl:text>".</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="$hit_list//hit[@type = 'colon']">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found term ending in colon: "</xsl:text>
								<xsl:value-of select="./term"/>
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
