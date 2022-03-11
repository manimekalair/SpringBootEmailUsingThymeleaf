<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="things">

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" exclude-result-prefixes="xlink"
		encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_414">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">414</xsl:variable>
		<xsl:variable name="rule_name">URL check.</xsl:variable>
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
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:for-each select=".//uri">
				<xsl:variable name="uri">
					<xsl:value-of select="."/>
				</xsl:variable>
				<xsl:variable name="uri_href">
					<xsl:value-of select="./@*:href"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when
							test="matches($uri, '^(http://|https://|ftp://|www\.|www1\.|www2\.|www3\.)') 
							or 
							matches($uri_href, '^(http://|https://|ftp|www\.|www1\.|www2\.|www3\.)')"/>
					<xsl:otherwise>
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="fail">
								<xsl:value-of select="."/> – content of
									&lt;uri&gt; element does not start with 'http://', 'ftp://', or
									'www' </td>
						</tr>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>

		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>
