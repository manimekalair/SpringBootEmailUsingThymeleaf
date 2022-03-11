<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">	
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_836">
		<!-- Journal references: Check that there is an &lt;issue&gt; element -->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">836</xsl:variable>
		<xsl:variable name="rule_name">Journal reference checks.</xsl:variable>
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
			<xsl:for-each select=".//ref/mixed-citation[@publication-type='journal'][not(./article-title)]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="warning">No &lt;article-title&gt; found: id="<xsl:value-of select="parent::ref/@id"/>" "<xsl:value-of select="parent::*"/>"</td>
				</tr>
			</xsl:for-each>
			<xsl:for-each select=".//ref/mixed-citation[@publication-type='journal'][not(./issue)]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="warning">No &lt;issue&gt; found: id="<xsl:value-of select="parent::ref/@id"/>" "<xsl:value-of select="parent::*"/>"</td>
				</tr>
			</xsl:for-each>
			<xsl:for-each select=".//ref/mixed-citation[@publication-type='journal'][not(./fpage)]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="warning">No &lt;fpage&gt; found: id="<xsl:value-of select="parent::ref/@id"/>" "<xsl:value-of select="parent::*"/>"</td>
				</tr>
			</xsl:for-each>
			<!--<xsl:for-each select=".//ref/mixed-citation[@publication-type='journal'][not(./volume)]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="warning">No &lt;volume&gt; found: id="<xsl:value-of select="parent::ref/@id"/>" "<xsl:value-of select="parent::*"/>"</td>
				</tr>
			</xsl:for-each>-->
		</xsl:variable>

		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
