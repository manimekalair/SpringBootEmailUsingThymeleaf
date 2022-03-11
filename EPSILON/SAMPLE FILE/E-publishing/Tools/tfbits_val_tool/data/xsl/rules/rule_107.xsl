<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>

	<xsl:template name="rule_107">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">107</xsl:variable>
		<xsl:variable name="rule_name">Check value of sec-type attribute in &lt;sec&gt; elements nested in &lt;notes notes-type="imprint-page"&gt;.</xsl:variable>
		<xsl:variable name="error_type">fail</xsl:variable>

		<!-- SET GENERIC RULE DETAILS TEXT -->
		<xsl:variable name="rule_details">
			<xsl:call-template name="rule_details">
				<xsl:with-param name="rule_number" select="$rule_number"/>
				<xsl:with-param name="rule_name" select="$rule_name"/>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- DISPLAY MESSAGE -->
		<xsl:call-template name="message">
			<xsl:with-param name="rule_number" select="$rule_number"/>
		</xsl:call-template>

		<!-- SET VARIABLES AND DO RULE TESTING AND PROCESSING -->
		<!-- insert setting of variables, testing, and any processing of data here -->
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:for-each select="//notes[@notes-type = 'imprint-page']/sec
				[not(@sec-type)]
				[not(@sec-type=('imprint-bl-data','imprint-cip-data','imprint-statement','imprint-reproduction','imprint-trademark','imprint-moral-rights','imprint-other','imprint-publication-data'))]">
				<xsl:if test="./@sec-type">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">
							"<xsl:value-of select="./@sec-type"/>" does't match type attribute list</td>
					</tr>
				</xsl:if>
				<xsl:if test="not(./@sec-type)">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">
						"<xsl:value-of select="."/>" does't have type attribute</td>
					</tr>
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
