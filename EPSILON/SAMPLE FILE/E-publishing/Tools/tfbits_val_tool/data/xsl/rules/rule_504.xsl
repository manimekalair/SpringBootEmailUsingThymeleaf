<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_504">
		<!--&lt;title&gt; must not contain chapter or part label/number -->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">504</xsl:variable>
		<xsl:variable name="rule_name">Check &lt;xref&gt; and &lt;target&gt; attributes.</xsl:variable>
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
			<xsl:for-each select=".//target[not(@target-type) or not(@id)]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">target "<xsl:value-of select="."/>" missing target-type or id attribute <xsl:for-each select="ancestor-or-self::*">
						<xsl:text>/</xsl:text>
						<xsl:value-of select="name()"/>
					</xsl:for-each></td>
				</tr>
			</xsl:for-each>
			<xsl:for-each select=".//xref[not(@ref-type)]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">xref "<xsl:value-of select="."/>" missing ref-type attribute <xsl:for-each select="ancestor-or-self::*">
						<xsl:text>/</xsl:text>
						<xsl:value-of select="name()"/>
					</xsl:for-each></td>
				</tr>
			</xsl:for-each>

			<xsl:for-each select=".//xref[not(@id) and not(@rid)]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">xref "<xsl:value-of select="."/>" missing id or rid attribute <xsl:for-each select="ancestor-or-self::*">
						<xsl:text>/</xsl:text>
						<xsl:value-of select="name()"/>
					</xsl:for-each></td>
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
