<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">	
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_827">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">827</xsl:variable>
		<xsl:variable name="rule_name">Check mandatory elements for journal references.</xsl:variable>
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
			<xsl:for-each select=".//ref/mixed-citation[@publication-type='journal'][not(./source)]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">No &lt;source&gt; found: id="<xsl:value-of select="parent::ref/@id"/>" "<xsl:value-of select="parent::*"/>"</td>
				</tr>
			</xsl:for-each>
			<xsl:for-each select=".//ref/mixed-citation[@publication-type='journal'][not(./volume or ./uri or ./ext-link[@ext-link-type = 'doi' and @xlink:href and string-length(@xlink:href) gt 5])]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">No &lt;volume&gt; / &lt;uri&gt; /r &lt;ext-link ext-link-type="doi"&gt; found: id="<xsl:value-of select="parent::ref/@id"/>" "<xsl:value-of select="parent::*"/>"</td>
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
