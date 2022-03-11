<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="things">

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" exclude-result-prefixes="xlink"
		encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_413">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">413</xsl:variable>
		<xsl:variable name="rule_name">Check for lists of illustrations.</xsl:variable>
		<xsl:variable name="error_type">fail</xsl:variable>
		
		<!-- DISPLAY MESSAGE -->
		<xsl:call-template name="message">
			<xsl:with-param name="rule_number" select="$rule_number"/>
		</xsl:call-template>

		<!-- SET GENERIC RULE DETAILS TEXT -->
		<xsl:variable name="rule_details">
			<xsl:call-template name="rule_details">
				<xsl:with-param name="rule_number" select="$rule_number"/>
				<xsl:with-param name="rule_name" select="$rule_name"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- SET VARIABLES AND DO RULE TESTING AND PROCESSING -->
		<!-- insert setting of variables, testing, and any processing of data here -->
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:for-each select="//title/text()[matches(., '(^(figure|figures|table|tables|box|boxes|illustration|illustrations)$|(list|table) of (figure|table|box|illustration))', 'i')]">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">
							fail: "<xsl:value-of select="."/>" –  found in <xsl:for-each select="ancestor::*">
								<xsl:text>/</xsl:text>
								<xsl:value-of select="name()"/>
							</xsl:for-each>
							<xsl:text>/</xsl:text>
						</td>
					</tr>							
			</xsl:for-each>
		</xsl:variable>

		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
