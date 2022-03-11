<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="things">

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" exclude-result-prefixes="xlink"
		encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_426">

		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">426</xsl:variable>
		<xsl:variable name="rule_name">Check for all-caps.</xsl:variable>
		<xsl:variable name="error_type">warning</xsl:variable>
		
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

		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:for-each select=".//text()[not(parent::term)]">
				<xsl:variable name="text" select="replace(.,'[^A-Za-z]+','')"/>
				<xsl:if test="string-length($text) &gt; 4">
					<xsl:choose>
						<xsl:when test="matches($text, '[a-z]+') "/>
						<xsl:otherwise>
							<tr>
								<xsl:copy-of select="$rule_details"/>
								<td class="warning">In element <xsl:for-each select="ancestor-or-self::*">
										<xsl:text>/</xsl:text>
										<xsl:value-of select="name()"/>
									</xsl:for-each>: found all-caps text – 
									<xsl:value-of select="."/>
								</td>
							</tr>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:for-each>		
		</xsl:variable>

		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
